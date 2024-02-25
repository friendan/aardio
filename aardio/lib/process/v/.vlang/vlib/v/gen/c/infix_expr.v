// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module c

import v.ast
import v.token
import v.util

fn (mut g Gen) infix_expr(node ast.InfixExpr) {
	if node.auto_locked != '' {
		g.writeln('sync__RwMutex_lock(&$node.auto_locked->mtx);')
	}
	match node.op {
		.arrow {
			g.infix_expr_arrow_op(node)
		}
		.eq, .ne {
			g.infix_expr_eq_op(node)
		}
		.gt, .ge, .lt, .le {
			g.infix_expr_cmp_op(node)
		}
		.key_in, .not_in {
			g.infix_expr_in_op(node)
		}
		.key_is, .not_is {
			g.infix_expr_is_op(node)
		}
		.plus, .minus, .mul, .div, .mod {
			g.infix_expr_arithmetic_op(node)
		}
		.left_shift {
			g.infix_expr_left_shift_op(node)
		}
		else {
			// `x & y == 0` => `(x & y) == 0` in C
			need_par := node.op in [.amp, .pipe, .xor]
			if need_par {
				g.write('(')
			}
			g.gen_plain_infix_expr(node)
			if need_par {
				g.write(')')
			}
		}
	}
	if node.auto_locked != '' {
		g.writeln(';')
		g.write('sync__RwMutex_unlock(&$node.auto_locked->mtx)')
	}
}

// infix_expr_arrow_op generates C code for pushing into channels (chan <- val)
fn (mut g Gen) infix_expr_arrow_op(node ast.InfixExpr) {
	left := g.unwrap(node.left_type)
	styp := left.sym.cname
	elem_type := (left.sym.info as ast.Chan).elem_type
	gen_or := node.or_block.kind != .absent
	tmp_opt := if gen_or { g.new_tmp_var() } else { '' }
	if gen_or {
		elem_styp := g.typ(elem_type)
		g.register_chan_push_optional_call(elem_styp, styp)
		g.write('Option_void $tmp_opt = __Option_${styp}_pushval(')
	} else {
		g.write('__${styp}_pushval(')
	}
	g.expr(node.left)
	g.write(', ')
	g.expr(node.right)
	g.write(')')
	if gen_or {
		g.or_block(tmp_opt, node.or_block, ast.void_type)
	}
}

// infix_expr_eq_op generates code for `==` and `!=`
fn (mut g Gen) infix_expr_eq_op(node ast.InfixExpr) {
	left := g.unwrap(node.left_type)
	right := g.unwrap(node.right_type)
	has_operator_overloading := g.table.type_has_method(left.sym, '==')
	if (left.typ.is_ptr() && right.typ.is_int()) || (right.typ.is_ptr() && left.typ.is_int()) {
		g.gen_plain_infix_expr(node)
	} else if (left.typ.idx() == ast.string_type_idx || (!has_operator_overloading
		&& left.unaliased.idx() == ast.string_type_idx)) && node.right is ast.StringLiteral
		&& (node.right as ast.StringLiteral).val == '' {
		// `str == ''` -> `str.len == 0` optimization
		g.write('(')
		g.expr(node.left)
		g.write(')')
		arrow := if left.typ.is_ptr() { '->' } else { '.' }
		g.write('${arrow}len $node.op 0')
	} else if has_operator_overloading {
		if node.op == .ne {
			g.write('!')
		}
		g.write(g.typ(left.unaliased.set_nr_muls(0)))
		g.write('__eq(')
		g.write('*'.repeat(left.typ.nr_muls()))
		g.expr(node.left)
		g.write(', ')
		g.write('*'.repeat(right.typ.nr_muls()))
		g.expr(node.right)
		g.write(')')
	} else if left.typ.idx() == right.typ.idx()
		&& left.sym.kind in [.array, .array_fixed, .alias, .map, .struct_, .sum_type] {
		match left.sym.kind {
			.alias {
				ptr_typ := g.gen_alias_equality_fn(left.typ)
				if node.op == .ne {
					g.write('!')
				}
				g.write('${ptr_typ}_alias_eq(')
				if left.typ.is_ptr() {
					g.write('*')
				}
				g.expr(node.left)
				g.write(', ')
				if right.typ.is_ptr() {
					g.write('*')
				}
				g.expr(node.right)
				g.write(')')
			}
			.array {
				ptr_typ := g.gen_array_equality_fn(left.unaliased.clear_flag(.shared_f))
				if node.op == .ne {
					g.write('!')
				}
				g.write('${ptr_typ}_arr_eq(')
				if left.typ.is_ptr() && !left.typ.has_flag(.shared_f) {
					g.write('*')
				}
				g.expr(node.left)
				if left.typ.has_flag(.shared_f) {
					if left.typ.is_ptr() {
						g.write('->val')
					} else {
						g.write('.val')
					}
				}
				g.write(', ')
				if right.typ.is_ptr() && !right.typ.has_flag(.shared_f) {
					g.write('*')
				}
				g.expr(node.right)
				if right.typ.has_flag(.shared_f) {
					if right.typ.is_ptr() {
						g.write('->val')
					} else {
						g.write('.val')
					}
				}
				g.write(')')
			}
			.array_fixed {
				ptr_typ := g.gen_fixed_array_equality_fn(left.unaliased)
				if node.op == .ne {
					g.write('!')
				}
				g.write('${ptr_typ}_arr_eq(')
				if left.typ.is_ptr() {
					g.write('*')
				}
				if node.left is ast.ArrayInit {
					s := g.typ(left.unaliased)
					g.write('($s)')
				}
				g.expr(node.left)
				g.write(', ')
				if node.right is ast.ArrayInit {
					s := g.typ(right.unaliased)
					g.write('($s)')
				}
				g.expr(node.right)
				g.write(')')
			}
			.map {
				ptr_typ := g.gen_map_equality_fn(left.unaliased)
				if node.op == .ne {
					g.write('!')
				}
				g.write('${ptr_typ}_map_eq(')
				if left.typ.is_ptr() {
					g.write('*')
				}
				g.expr(node.left)
				g.write(', ')
				if right.typ.is_ptr() {
					g.write('*')
				}
				g.expr(node.right)
				g.write(')')
			}
			.struct_ {
				ptr_typ := g.gen_struct_equality_fn(left.unaliased)
				if node.op == .ne {
					g.write('!')
				}
				g.write('${ptr_typ}_struct_eq(')
				if left.typ.is_ptr() {
					g.write('*')
				}
				g.expr(node.left)
				g.write(', ')
				if right.typ.is_ptr() {
					g.write('*')
				}
				g.expr(node.right)
				g.write(')')
			}
			.sum_type {
				ptr_typ := g.gen_sumtype_equality_fn(left.unaliased)
				if node.op == .ne {
					g.write('!')
				}
				g.write('${ptr_typ}_sumtype_eq(')
				if left.typ.is_ptr() {
					g.write('*')
				}
				g.expr(node.left)
				g.write(', ')
				if right.typ.is_ptr() {
					g.write('*')
				}
				g.expr(node.right)
				g.write(')')
			}
			else {}
		}
	} else if left.unaliased.idx() in [ast.u32_type_idx, ast.u64_type_idx]
		&& right.unaliased.is_signed() {
		g.gen_safe_integer_infix_expr(
			op: node.op
			unsigned_type: left.unaliased
			unsigned_expr: node.left
			signed_type: right.unaliased
			signed_expr: node.right
		)
	} else if right.unaliased.idx() in [ast.u32_type_idx, ast.u64_type_idx]
		&& left.unaliased.is_signed() {
		g.gen_safe_integer_infix_expr(
			op: node.op
			reverse: true
			unsigned_type: right.unaliased
			unsigned_expr: node.right
			signed_type: left.unaliased
			signed_expr: node.left
		)
	} else {
		g.gen_plain_infix_expr(node)
	}
}

// infix_expr_cmp_op generates code for `<`, `<=`, `>`, `>=`
// It handles operator overloading when necessary
fn (mut g Gen) infix_expr_cmp_op(node ast.InfixExpr) {
	left := g.unwrap(node.left_type)
	right := g.unwrap(node.right_type)
	has_operator_overloading := g.table.type_has_method(left.sym, '<')
	if left.sym.kind == right.sym.kind && has_operator_overloading {
		if node.op in [.le, .ge] {
			g.write('!')
		}
		g.write(g.typ(left.typ.set_nr_muls(0)))
		g.write('__lt')
		if node.op in [.lt, .ge] {
			g.write('(')
			g.write('*'.repeat(left.typ.nr_muls()))
			g.expr(node.left)
			g.write(', ')
			g.write('*'.repeat(right.typ.nr_muls()))
			g.expr(node.right)
			g.write(')')
		} else {
			g.write('(')
			g.write('*'.repeat(right.typ.nr_muls()))
			g.expr(node.right)
			g.write(', ')
			g.write('*'.repeat(left.typ.nr_muls()))
			g.expr(node.left)
			g.write(')')
		}
	} else if left.unaliased.idx() in [ast.u32_type_idx, ast.u64_type_idx]
		&& right.unaliased.is_signed() {
		g.gen_safe_integer_infix_expr(
			op: node.op
			unsigned_type: left.unaliased
			unsigned_expr: node.left
			signed_type: right.unaliased
			signed_expr: node.right
		)
	} else if right.unaliased.idx() in [ast.u32_type_idx, ast.u64_type_idx]
		&& left.unaliased.is_signed() {
		g.gen_safe_integer_infix_expr(
			op: node.op
			reverse: true
			unsigned_type: right.unaliased
			unsigned_expr: node.right
			signed_type: left.unaliased
			signed_expr: node.left
		)
	} else {
		g.gen_plain_infix_expr(node)
	}
}

// infix_expr_in_op generates code for `in` and `!in`
fn (mut g Gen) infix_expr_in_op(node ast.InfixExpr) {
	left := g.unwrap(node.left_type)
	right := g.unwrap(node.right_type)
	if node.op == .not_in {
		g.write('!')
	}
	if right.unaliased_sym.kind == .array {
		if mut node.right is ast.ArrayInit {
			if node.right.exprs.len > 0 {
				// `a in [1,2,3]` optimization => `a == 1 || a == 2 || a == 3`
				// avoids an allocation
				g.write('(')
				g.infix_expr_in_optimization(node.left, node.right)
				g.write(')')
				return
			}
		}
		fn_name := g.gen_array_contains_method(node.right_type)
		g.write('(${fn_name}(')
		if right.typ.is_ptr() {
			g.write('*')
		}
		g.expr(node.right)
		g.write(', ')
		g.expr(node.left)
		g.write('))')
		return
	} else if right.unaliased_sym.kind == .map {
		g.write('_IN_MAP(')
		if !left.typ.is_ptr() {
			styp := g.typ(node.left_type)
			g.write('ADDR($styp, ')
			g.expr(node.left)
			g.write(')')
		} else {
			g.expr(node.left)
		}
		g.write(', ')
		if !right.typ.is_ptr() {
			g.write('ADDR(map, ')
			g.expr(node.right)
			g.write(')')
		} else {
			g.expr(node.right)
		}
		g.write(')')
	} else if right.unaliased_sym.kind == .string {
		g.write('string_contains(')
		g.expr(node.right)
		g.write(', ')
		g.expr(node.left)
		g.write(')')
	}
}

// infix_expr_in_optimization optimizes `<var> in <array>` expressions,
// and transform them in a serie of equality comparison
// i.e. `a in [1,2,3]` => `a == 1 || a == 2 || a == 3`
fn (mut g Gen) infix_expr_in_optimization(left ast.Expr, right ast.ArrayInit) {
	is_str := right.elem_type.idx() == ast.string_type_idx
	elem_sym := g.table.get_type_symbol(right.elem_type)
	is_array := elem_sym.kind == .array
	for i, array_expr in right.exprs {
		if is_str {
			g.write('string__eq(')
		} else if is_array {
			ptr_typ := g.gen_array_equality_fn(right.elem_type)
			g.write('${ptr_typ}_arr_eq(')
		}
		g.expr(left)
		if is_str || is_array {
			g.write(', ')
		} else {
			g.write(' == ')
		}
		g.expr(array_expr)
		if is_str || is_array {
			g.write(')')
		}
		if i < right.exprs.len - 1 {
			g.write(' || ')
		}
	}
}

// infix_expr_is_op generates code for `is` and `!is`
fn (mut g Gen) infix_expr_is_op(node ast.InfixExpr) {
	cmp_op := if node.op == .key_is { '==' } else { '!=' }
	g.write('(')
	g.expr(node.left)
	g.write(')')
	if node.left_type.is_ptr() {
		g.write('->')
	} else {
		g.write('.')
	}
	sym := g.table.get_type_symbol(node.left_type)
	if sym.kind == .interface_ {
		g.write('_typ $cmp_op ')
		// `_Animal_Dog_index`
		sub_type := match mut node.right {
			ast.TypeNode { node.right.typ }
			ast.None { g.table.type_idxs['None__'] }
			else { ast.Type(0) }
		}
		sub_sym := g.table.get_type_symbol(sub_type)
		g.write('_${c_name(sym.name)}_${c_name(sub_sym.name)}_index')
		return
	} else if sym.kind == .sum_type {
		g.write('_typ $cmp_op ')
	}
	g.expr(node.right)
}

// infix_expr_arithmetic_op generates code for `+`, `-`, `*`, `/`, and `%`
// It handles operator overloading when necessary
fn (mut g Gen) infix_expr_arithmetic_op(node ast.InfixExpr) {
	left := g.unwrap(node.left_type)
	right := g.unwrap(node.right_type)
	has_operator_overloading := g.table.type_has_method(left.sym, node.op.str())
	if left.sym.kind == right.sym.kind && has_operator_overloading {
		g.write(g.typ(left.typ.set_nr_muls(0)))
		g.write('_')
		g.write(util.replace_op(node.op.str()))
		g.write('(')
		g.write('*'.repeat(left.typ.nr_muls()))
		g.expr(node.left)
		g.write(', ')
		g.write('*'.repeat(right.typ.nr_muls()))
		g.expr(node.right)
		g.write(')')
	} else {
		g.gen_plain_infix_expr(node)
	}
}

// infix_expr_left_shift_op generates code for the `<<` operator
// This can either be a value pushed into an array or a bit shift
fn (mut g Gen) infix_expr_left_shift_op(node ast.InfixExpr) {
	left := g.unwrap(node.left_type)
	right := g.unwrap(node.right_type)
	if left.unaliased_sym.kind == .array {
		// arr << val
		tmp_var := g.new_tmp_var()
		array_info := left.unaliased_sym.info as ast.Array
		noscan := g.check_noscan(array_info.elem_type)
		//&& array_info.elem_type != g.unwrap_generic(node.right_type)
		if right.unaliased_sym.kind == .array && array_info.elem_type != right.typ {
			// push an array => PUSH_MANY, but not if pushing an array to 2d array (`[][]int << []int`)
			g.write('_PUSH_MANY${noscan}(')
			mut expected_push_many_atype := left.typ
			if !expected_push_many_atype.is_ptr() {
				// fn f(mut a []int) { a << [1,2,3] } -> type of `a` is `array_int*` -> no need for &
				g.write('&')
			} else {
				expected_push_many_atype = expected_push_many_atype.deref()
			}
			g.expr(node.left)
			g.write(', (')
			g.expr_with_cast(node.right, node.right_type, left.unaliased)
			styp := g.typ(expected_push_many_atype)
			g.write('), $tmp_var, $styp)')
		} else {
			// push a single element
			elem_type_str := g.typ(array_info.elem_type)
			elem_sym := g.table.get_type_symbol(array_info.elem_type)
			g.write('array_push${noscan}((array*)')
			if !left.typ.is_ptr() {
				g.write('&')
			}
			g.expr(node.left)
			if elem_sym.kind == .function {
				g.write(', _MOV((voidptr[]){ ')
			} else {
				g.write(', _MOV(($elem_type_str[]){ ')
			}
			// if g.autofree
			needs_clone := array_info.elem_type.idx() == ast.string_type_idx && !g.is_builtin_mod
			if needs_clone {
				g.write('string_clone(')
			}
			g.expr_with_cast(node.right, node.right_type, array_info.elem_type)
			if needs_clone {
				g.write(')')
			}
			g.write(' }))')
		}
	} else {
		g.gen_plain_infix_expr(node)
	}
}

// gen_plain_infix_expr generates basic code for infix expressions,
// without any overloading of any kind
// i.e. v`a + 1` => c`a + 1`
// It handles auto dereferencing of variables, as well as automatic casting
// (see Gen.expr_with_cast for more details)
fn (mut g Gen) gen_plain_infix_expr(node ast.InfixExpr) {
	if node.left_type.is_ptr() && node.left.is_auto_deref_var() {
		g.write('*')
	}
	g.expr(node.left)
	g.write(' $node.op.str() ')
	g.expr_with_cast(node.right, node.right_type, node.left_type)
}

struct GenSafeIntegerCfg {
	op            token.Kind
	reverse       bool
	unsigned_type ast.Type
	unsigned_expr ast.Expr
	signed_type   ast.Type
	signed_expr   ast.Expr
}

// gen_safe_integer_infix_expr generates code for comparison of
// unsigned and signed integers
fn (mut g Gen) gen_safe_integer_infix_expr(cfg GenSafeIntegerCfg) {
	bitsize := if cfg.unsigned_type.idx() == ast.u32_type_idx
		&& cfg.signed_type.idx() != ast.i64_type_idx {
		32
	} else {
		64
	}
	op_idx := int(cfg.op) - int(token.Kind.eq)
	op_str := if cfg.reverse { cmp_rev[op_idx] } else { cmp_str[op_idx] }
	g.write('_us${bitsize}_${op_str}(')
	g.expr(cfg.unsigned_expr)
	g.write(',')
	g.expr(cfg.signed_expr)
	g.write(')')
}
