// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module c

import v.ast

fn (mut g Gen) gen_assert_stmt(original_assert_statement ast.AssertStmt) {
	if !original_assert_statement.is_used {
		return
	}
	mut node := original_assert_statement
	g.writeln('// assert')
	if mut node.expr is ast.InfixExpr {
		if mut node.expr.left is ast.CallExpr {
			node.expr.left = g.new_ctemp_var_then_gen(node.expr.left, node.expr.left_type)
		}
		if mut node.expr.right is ast.CallExpr {
			node.expr.right = g.new_ctemp_var_then_gen(node.expr.right, node.expr.right_type)
		}
	}
	g.inside_ternary++
	if g.is_test {
		g.write('if (')
		g.expr(node.expr)
		g.write(')')
		g.decrement_inside_ternary()
		g.writeln(' {')
		g.writeln('\tg_test_oks++;')
		metaname_ok := g.gen_assert_metainfo(node)
		g.writeln('\tmain__cb_assertion_ok(&$metaname_ok);')
		g.writeln('} else {')
		g.writeln('\tg_test_fails++;')
		metaname_fail := g.gen_assert_metainfo(node)
		g.writeln('\tmain__cb_assertion_failed(&$metaname_fail);')
		g.gen_assert_postfailure_mode(node)
		g.writeln('\tlongjmp(g_jump_buffer, 1);')
		g.writeln('\t// TODO')
		g.writeln('\t// Maybe print all vars in a test function if it fails?')
		g.writeln('}')
	} else {
		g.write('if (!(')
		g.expr(node.expr)
		g.write('))')
		g.decrement_inside_ternary()
		g.writeln(' {')
		metaname_panic := g.gen_assert_metainfo(node)
		g.writeln('\t__print_assert_failure(&$metaname_panic);')
		g.gen_assert_postfailure_mode(node)
		g.writeln('\tv_panic(_SLIT("Assertion failed..."));')
		g.writeln('}')
	}
}

fn (mut g Gen) gen_assert_postfailure_mode(node ast.AssertStmt) {
	g.write_v_source_line_info(node.pos)
	match g.pref.assert_failure_mode {
		.default {}
		.aborts {
			g.writeln('\tabort();')
		}
		.backtraces {
			g.writeln('\tprint_backtrace();')
		}
	}
}

fn (mut g Gen) gen_assert_metainfo(node ast.AssertStmt) string {
	mod_path := cestring(g.file.path)
	fn_name := g.fn_decl.name
	line_nr := node.pos.line_nr
	src := cestring(node.expr.str())
	metaname := 'v_assert_meta_info_$g.new_tmp_var()'
	g.writeln('\tVAssertMetaInfo $metaname = {0};')
	g.writeln('\t${metaname}.fpath = ${ctoslit(mod_path)};')
	g.writeln('\t${metaname}.line_nr = $line_nr;')
	g.writeln('\t${metaname}.fn_name = ${ctoslit(fn_name)};')
	metasrc := cnewlines(ctoslit(src))
	g.writeln('\t${metaname}.src = $metasrc;')
	match mut node.expr {
		ast.InfixExpr {
			expr_op_str := ctoslit(node.expr.op.str())
			expr_left_str := cnewlines(ctoslit(node.expr.left.str()))
			expr_right_str := cnewlines(ctoslit(node.expr.right.str()))
			g.writeln('\t${metaname}.op = $expr_op_str;')
			g.writeln('\t${metaname}.llabel = $expr_left_str;')
			g.writeln('\t${metaname}.rlabel = $expr_right_str;')
			g.write('\t${metaname}.lvalue = ')
			g.gen_assert_single_expr(node.expr.left, node.expr.left_type)
			g.writeln(';')
			g.write('\t${metaname}.rvalue = ')
			g.gen_assert_single_expr(node.expr.right, node.expr.right_type)
			g.writeln(';')
		}
		ast.CallExpr {
			g.writeln('\t${metaname}.op = _SLIT("call");')
		}
		else {}
	}
	return metaname
}

fn (mut g Gen) gen_assert_single_expr(expr ast.Expr, typ ast.Type) {
	unknown_value := '*unknown value*'
	match expr {
		ast.CastExpr, ast.IndexExpr, ast.MatchExpr {
			g.write(ctoslit(unknown_value))
		}
		ast.PrefixExpr {
			if expr.right is ast.CastExpr {
				// TODO: remove this check;
				// vlib/builtin/map_test.v (a map of &int, set to &int(0)) fails
				// without special casing ast.CastExpr here
				g.write(ctoslit(unknown_value))
			} else {
				g.gen_expr_to_string(expr, typ)
			}
		}
		ast.TypeNode {
			sym := g.table.get_type_symbol(typ)
			g.write(ctoslit('$sym.name'))
		}
		else {
			g.gen_expr_to_string(expr, typ)
		}
	}
	g.write(' /* typeof: ' + expr.type_name() + ' type: ' + typ.str() + ' */ ')
}
