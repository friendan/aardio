// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license that can be found in the LICENSE file.
module c

import v.ast
import v.util
import strings

pub enum StrIntpType {
	si_no_str = 0 // no parameter to print only fix string
	si_c
	si_u8
	si_i8
	si_u16
	si_i16
	si_u32
	si_i32
	si_u64
	si_i64
	si_e32
	si_e64
	si_f32
	si_f64
	si_g32
	si_g64
	si_s
	si_p
	si_vp
}

pub fn type_to_str(x StrIntpType) string {
	match x {
		.si_no_str { return 'no_str' }
		.si_c { return 'c' }
		.si_u8 { return 'u8' }
		.si_i8 { return 'i8' }
		.si_u16 { return 'u16' }
		.si_i16 { return 'i16' }
		.si_u32 { return 'u32' }
		.si_i32 { return 'i32' }
		.si_u64 { return 'u64' }
		.si_i64 { return 'i64' }
		.si_f32 { return 'f32' }
		.si_f64 { return 'f64' }
		.si_g32 { return 'f32' } // g32 format use f32 data
		.si_g64 { return 'f64' } // g64 format use f64 data
		.si_e32 { return 'f32' } // e32 format use f32 data
		.si_e64 { return 'f64' } // e64 format use f64 data
		.si_s { return 's' }
		.si_p { return 'p' }
		.si_vp { return 'vp' }
	}
}

pub fn data_str(x StrIntpType) string {
	match x {
		.si_no_str { return 'no_str' }
		.si_c { return 'd_c' }
		.si_u8 { return 'd_u8' }
		.si_i8 { return 'd_i8' }
		.si_u16 { return 'd_u16' }
		.si_i16 { return 'd_i16' }
		.si_u32 { return 'd_u32' }
		.si_i32 { return 'd_i32' }
		.si_u64 { return 'd_u64' }
		.si_i64 { return 'd_i64' }
		.si_f32 { return 'd_f32' }
		.si_f64 { return 'd_f64' }
		.si_g32 { return 'd_f32' } // g32 format use f32 data
		.si_g64 { return 'd_f64' } // g64 format use f64 data
		.si_e32 { return 'd_f32' } // e32 format use f32 data
		.si_e64 { return 'd_f64' } // e64 format use f64 data
		.si_s { return 'd_s' }
		.si_p { return 'd_p' }
		.si_vp { return 'd_vp' }
	}
}

const (
	// BUG: this const is not released from the memory! use a const for now
	// si_s_code = "0x" + int(StrIntpType.si_s).hex() // code for a simple string
	si_s_code = '0xfe10'
)

fn should_use_indent_func(kind ast.Kind) bool {
	return kind in [.struct_, .alias, .array, .array_fixed, .map, .sum_type, .interface_]
}

fn (mut g Gen) gen_str_default(sym ast.TypeSymbol, styp string, str_fn_name string) {
	mut convertor := ''
	mut typename_ := ''
	if sym.parent_idx in ast.integer_type_idxs {
		convertor = 'int'
		typename_ = 'int'
	} else if sym.parent_idx == ast.f32_type_idx {
		convertor = 'float'
		typename_ = 'f32'
	} else if sym.parent_idx == ast.f64_type_idx {
		convertor = 'double'
		typename_ = 'f64'
	} else if sym.parent_idx == ast.bool_type_idx {
		convertor = 'bool'
		typename_ = 'bool'
	} else {
		verror("could not generate string method for type '$styp'")
	}
	g.type_definitions.writeln('string ${str_fn_name}($styp it); // auto')
	g.auto_str_funcs.writeln('string ${str_fn_name}($styp it) {')
	if convertor == 'bool' {
		g.auto_str_funcs.writeln('\tstring tmp1 = string__plus(_SLIT("${styp}("), ($convertor)it ? _SLIT("true") : _SLIT("false"));')
	} else {
		g.auto_str_funcs.writeln('\tstring tmp1 = string__plus(_SLIT("${styp}("), tos3(${typename_}_str(($convertor)it).str));')
	}
	g.auto_str_funcs.writeln('\tstring tmp2 = string__plus(tmp1, _SLIT(")"));')
	g.auto_str_funcs.writeln('\tstring_free(&tmp1);')
	g.auto_str_funcs.writeln('\treturn tmp2;')
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) gen_str_for_type(typ ast.Type) string {
	styp := g.typ(typ).replace('*', '')
	mut sym := g.table.get_type_symbol(g.unwrap_generic(typ))
	mut str_fn_name := styp_to_str_fn_name(styp)
	if mut sym.info is ast.Alias {
		if sym.info.is_import {
			sym = g.table.get_type_symbol(sym.info.parent_type)
			str_fn_name = styp_to_str_fn_name(sym.name)
		}
	}
	sym_has_str_method, str_method_expects_ptr, str_nr_args := sym.str_method_info()
	already_generated_key := '$styp:$str_fn_name'
	if !sym_has_str_method && already_generated_key !in g.str_types && !typ.has_flag(.optional) {
		$if debugautostr ? {
			eprintln('> gen_str_for_type: |typ: ${typ:5}, ${sym.name:20}|has_str: ${sym_has_str_method:5}|expects_ptr: ${str_method_expects_ptr:5}|nr_args: ${str_nr_args:1}|fn_name: ${str_fn_name:20}')
		}
		g.str_types << already_generated_key
		match mut sym.info {
			ast.Alias {
				if sym.info.is_import {
					g.gen_str_default(sym, styp, str_fn_name)
				} else {
					g.gen_str_for_alias(sym.info, styp, str_fn_name)
				}
			}
			ast.Array {
				g.gen_str_for_array(sym.info, styp, str_fn_name)
			}
			ast.ArrayFixed {
				g.gen_str_for_array_fixed(sym.info, styp, str_fn_name)
			}
			ast.Enum {
				g.gen_str_for_enum(sym.info, styp, str_fn_name)
			}
			ast.FnType {
				g.gen_str_for_fn_type(sym.info, styp, str_fn_name)
			}
			ast.Struct {
				g.gen_str_for_struct(sym.info, styp, str_fn_name)
			}
			ast.Map {
				g.gen_str_for_map(sym.info, styp, str_fn_name)
			}
			ast.MultiReturn {
				g.gen_str_for_multi_return(sym.info, styp, str_fn_name)
			}
			ast.SumType {
				g.gen_str_for_union_sum_type(sym.info, styp, str_fn_name)
			}
			ast.Interface {
				g.gen_str_for_interface(sym.info, styp, str_fn_name)
			}
			ast.Chan {
				g.gen_str_for_chan(sym.info, styp, str_fn_name)
			}
			else {
				verror("could not generate string method $str_fn_name for type '$styp'")
			}
		}
	}
	if typ.has_flag(.optional) {
		option_already_generated_key := 'option_$already_generated_key'
		if option_already_generated_key !in g.str_types {
			g.gen_str_for_option(typ, styp, str_fn_name)
			g.str_types << option_already_generated_key
		}
		return str_fn_name
	}
	return str_fn_name
}

fn (mut g Gen) gen_str_for_option(typ ast.Type, styp string, str_fn_name string) {
	parent_type := typ.clear_flag(.optional)
	sym := g.table.get_type_symbol(parent_type)
	sym_has_str_method, _, _ := sym.str_method_info()
	mut parent_str_fn_name := styp_to_str_fn_name(sym.cname)
	if !sym_has_str_method {
		parent_str_fn_name = g.gen_str_for_type(parent_type)
	}
	g.type_definitions.writeln('string ${str_fn_name}($styp it); // auto')
	g.auto_str_funcs.writeln('string ${str_fn_name}($styp it) { return indent_${str_fn_name}(it, 0); }')
	g.type_definitions.writeln('string indent_${str_fn_name}($styp it, int indent_count); // auto')
	g.auto_str_funcs.writeln('string indent_${str_fn_name}($styp it, int indent_count) {')
	g.auto_str_funcs.writeln('\tstring res;')
	g.auto_str_funcs.writeln('\tif (it.state == 0) {')
	if sym.kind == .string {
		tmp_res := '${parent_str_fn_name}(*($sym.cname*)it.data)'
		g.auto_str_funcs.writeln('\t\tres = ${str_intp_sq(tmp_res)};')
	} else if should_use_indent_func(sym.kind) && !sym_has_str_method {
		g.auto_str_funcs.writeln('\t\tres = indent_${parent_str_fn_name}(*($sym.cname*)it.data, indent_count);')
	} else {
		g.auto_str_funcs.writeln('\t\tres = ${parent_str_fn_name}(*($sym.cname*)it.data);')
	}
	g.auto_str_funcs.writeln('\t} else {')

	tmp_str := str_intp_sub('error: %%', 'IError_str(it.err)')
	g.auto_str_funcs.writeln('\t\tres = $tmp_str;')
	g.auto_str_funcs.writeln('\t}')

	g.auto_str_funcs.writeln('\treturn ${str_intp_sub('Option(%%)', 'res')};')
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) gen_str_for_alias(info ast.Alias, styp string, str_fn_name string) {
	sym := g.table.get_type_symbol(info.parent_type)
	sym_has_str_method, _, _ := sym.str_method_info()
	mut parent_str_fn_name := styp_to_str_fn_name(sym.name.replace('.', '__'))
	if !sym_has_str_method {
		parent_str_fn_name = g.gen_str_for_type(info.parent_type)
	}
	mut clean_type_v_type_name := util.strip_main_name(styp.replace('__', '.'))
	g.type_definitions.writeln('static string ${str_fn_name}($styp it); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp it) { return indent_${str_fn_name}(it, 0); }')
	g.type_definitions.writeln('static string indent_${str_fn_name}($styp it, int indent_count); // auto')
	g.auto_str_funcs.writeln('static string indent_${str_fn_name}($styp it, int indent_count) {')
	g.auto_str_funcs.writeln('\tstring indents = string_repeat(_SLIT("    "), indent_count);')
	g.auto_str_funcs.writeln('\tstring tmp_ds = ${parent_str_fn_name}(it);')
	g.auto_str_funcs.writeln('\tstring res = str_intp(3, _MOV((StrIntpData[]){
		{_SLIT0, $c.si_s_code, {.d_s = indents }},
		{_SLIT("${clean_type_v_type_name}("), $c.si_s_code, {.d_s = tmp_ds }},
		{_SLIT(")"), 0, {.d_c = 0 }}
	}));')
	g.auto_str_funcs.writeln('\tstring_free(&indents);')
	g.auto_str_funcs.writeln('\tstring_free(&tmp_ds);')
	g.auto_str_funcs.writeln('\treturn res;')
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) gen_str_for_multi_return(info ast.MultiReturn, styp string, str_fn_name string) {
	for typ in info.types {
		sym := g.table.get_type_symbol(typ)
		if !sym.has_method('str') {
			g.gen_str_for_type(typ)
		}
	}
	g.type_definitions.writeln('static string ${str_fn_name}($styp a); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp a) {')
	g.auto_str_funcs.writeln('\tstrings__Builder sb = strings__new_builder($info.types.len * 10);')
	g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT("("));')
	for i, typ in info.types {
		sym := g.table.get_type_symbol(typ)
		field_styp := g.typ(typ)
		is_arg_ptr := typ.is_ptr()
		sym_has_str_method, str_method_expects_ptr, _ := sym.str_method_info()
		mut arg_str_fn_name := ''
		if sym_has_str_method {
			arg_str_fn_name = if is_arg_ptr {
				field_styp.replace('*', '') + '_str'
			} else {
				field_styp + '_str'
			}
		} else {
			arg_str_fn_name = styp_to_str_fn_name(field_styp)
		}
		if should_use_indent_func(sym.kind) && !sym_has_str_method {
			g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, ${arg_str_fn_name}(a.arg$i));')
		} else if sym.kind in [.f32, .f64] {
			if sym.kind == .f32 {
				tmp_val := str_intp_g32('a.arg$i')
				g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, $tmp_val);')
			} else {
				tmp_val := str_intp_g64('a.arg$i')
				g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, $tmp_val);')
			}
		} else if sym.kind == .string {
			tmp_str := str_intp_sq('a.arg$i')
			g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, $tmp_str);')
		} else if sym.kind == .function {
			g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, ${arg_str_fn_name}());')
		} else {
			deref, deref_label := deref_kind(str_method_expects_ptr, is_arg_ptr, typ)
			g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, _SLIT("$deref_label"));')
			g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, ${arg_str_fn_name}( $deref a.arg$i));')
		}
		if i != info.types.len - 1 {
			g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT(", "));')
		}
	}
	g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT(")"));')
	g.auto_str_funcs.writeln('\tstring res = strings__Builder_str(&sb);')
	g.auto_str_funcs.writeln('\tstrings__Builder_free(&sb);')
	g.auto_str_funcs.writeln('\treturn res;')
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) gen_str_for_enum(info ast.Enum, styp string, str_fn_name string) {
	s := util.no_dots(styp)
	g.type_definitions.writeln('static string ${str_fn_name}($styp it); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp it) { /* gen_str_for_enum */')
	// Enums tagged with `[flag]` are special in that they can be a combination of enum values
	if info.is_flag {
		clean_name := util.strip_main_name(styp.replace('__', '.'))
		g.auto_str_funcs.writeln('\tstring ret = _SLIT("$clean_name{");')
		g.auto_str_funcs.writeln('\tint first = 1;')
		for i, val in info.vals {
			g.auto_str_funcs.writeln('\tif (it & (1 << $i)) {if (!first) {ret = string__plus(ret, _SLIT(" | "));} ret = string__plus(ret, _SLIT(".$val")); first = 0;}')
		}
		g.auto_str_funcs.writeln('\tret = string__plus(ret, _SLIT("}"));')
		g.auto_str_funcs.writeln('\treturn ret;')
	} else {
		g.auto_str_funcs.writeln('\tswitch(it) {')
		// Only use the first multi value on the lookup
		mut seen := []string{len: info.vals.len}
		for val in info.vals {
			if info.is_multi_allowed && val in seen {
				continue
			} else if info.is_multi_allowed {
				seen << val
			}
			g.auto_str_funcs.writeln('\t\tcase ${s}_$val: return _SLIT("$val");')
		}
		g.auto_str_funcs.writeln('\t\tdefault: return _SLIT("unknown enum value");')
		g.auto_str_funcs.writeln('\t}')
	}
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) gen_str_for_interface(info ast.Interface, styp string, str_fn_name string) {
	mut gen_fn_names := map[string]string{}
	for typ in info.types {
		sym := g.table.get_type_symbol(typ)
		if !sym.has_method('str') {
			field_styp := g.typ(typ)
			field_fn_name := g.gen_str_for_type(typ)
			gen_fn_names[field_styp] = field_fn_name
		}
	}
	mut clean_interface_v_type_name := styp.replace('__', '.')
	if styp.ends_with('*') {
		clean_interface_v_type_name = '&' + clean_interface_v_type_name.replace('*', '')
	}
	clean_interface_v_type_name = util.strip_main_name(clean_interface_v_type_name)

	g.type_definitions.writeln('static string ${str_fn_name}($styp x); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp x) { return indent_${str_fn_name}(x, 0); }')
	g.type_definitions.writeln('static string indent_${str_fn_name}($styp x, int indent_count); // auto')
	g.auto_str_funcs.writeln('static string indent_${str_fn_name}($styp x, int indent_count) { /* gen_str_for_interface */')
	for typ in info.types {
		typ_str := g.typ(typ)
		subtype := g.table.get_type_symbol(typ)

		mut func_name := if typ_str in gen_fn_names {
			gen_fn_names[typ_str]
		} else {
			g.gen_str_for_type(typ)
		}

		sym_has_str_method, str_method_expects_ptr, _ := subtype.str_method_info()
		if should_use_indent_func(subtype.kind) && !sym_has_str_method {
			func_name = 'indent_$func_name'
		}

		//------------------------------------------
		// str_intp
		deref := if sym_has_str_method && str_method_expects_ptr { ' ' } else { '*' }
		if typ == ast.string_type {
			mut val := '${func_name}(${deref}($subtype.cname*)x._$subtype.cname'
			if should_use_indent_func(subtype.kind) && !sym_has_str_method {
				val += ', indent_count'
			}
			val += ')'
			res := 'str_intp(2, _MOV((StrIntpData[]){
				{_SLIT("${clean_interface_v_type_name}(\'"), $c.si_s_code, {.d_s = $val}},
				{_SLIT("\')"), 0, {.d_c = 0 }}
			}))'
			g.auto_str_funcs.write_string('\tif (x._typ == _${styp}_${subtype.cname}_index)')
			g.auto_str_funcs.write_string(' return $res;')
		} else {
			mut val := '${func_name}(${deref}($subtype.cname*)x._$subtype.cname'
			if should_use_indent_func(subtype.kind) && !sym_has_str_method {
				val += ', indent_count'
			}
			val += ')'
			res := 'str_intp(2, _MOV((StrIntpData[]){
				{_SLIT("${clean_interface_v_type_name}("), $c.si_s_code, {.d_s = $val}},
				{_SLIT(")"), 0, {.d_c = 0 }}
			}))'
			g.auto_str_funcs.write_string('\tif (x._typ == _${styp}_${subtype.cname}_index)')
			g.auto_str_funcs.write_string(' return $res;\n')
		}
	}
	g.auto_str_funcs.writeln('\treturn _SLIT("unknown interface value");')
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) gen_str_for_union_sum_type(info ast.SumType, styp string, str_fn_name string) {
	mut gen_fn_names := map[string]string{}
	for typ in info.variants {
		sym := g.table.get_type_symbol(typ)
		if !sym.has_method('str') {
			field_styp := g.typ(typ)
			field_fn_name := g.gen_str_for_type(typ)
			gen_fn_names[field_styp] = field_fn_name
		}
	}
	// _str() functions should have a single argument, the indenting ones take 2:
	g.type_definitions.writeln('static string ${str_fn_name}($styp x); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp x) { return indent_${str_fn_name}(x, 0); }')
	g.type_definitions.writeln('static string indent_${str_fn_name}($styp x, int indent_count); // auto')
	g.auto_str_funcs.writeln('static string indent_${str_fn_name}($styp x, int indent_count) {')
	mut clean_sum_type_v_type_name := styp.replace('__', '.')
	if styp.ends_with('*') {
		clean_sum_type_v_type_name = '&' + clean_sum_type_v_type_name.replace('*', '')
	}
	clean_sum_type_v_type_name = util.strip_main_name(clean_sum_type_v_type_name)
	g.auto_str_funcs.writeln('\tswitch(x._typ) {')
	for typ in info.variants {
		typ_str := g.typ(typ)
		mut func_name := if typ_str in gen_fn_names {
			gen_fn_names[typ_str]
		} else {
			g.gen_str_for_type(typ)
		}
		sym := g.table.get_type_symbol(typ)
		sym_has_str_method, str_method_expects_ptr, _ := sym.str_method_info()
		deref := if sym_has_str_method && str_method_expects_ptr { ' ' } else { '*' }
		if should_use_indent_func(sym.kind) && !sym_has_str_method {
			func_name = 'indent_$func_name'
		}

		//------------------------------------------
		// str_intp
		if typ == ast.string_type {
			mut val := '${func_name}(${deref}($typ_str*)x._$sym.cname'
			if should_use_indent_func(sym.kind) && !sym_has_str_method {
				val += ', indent_count'
			}
			val += ')'
			res := 'str_intp(2, _MOV((StrIntpData[]){
				{_SLIT("${clean_sum_type_v_type_name}(\'"), $c.si_s_code, {.d_s = $val}},
				{_SLIT("\')"), 0, {.d_c = 0 }}
			}))'
			g.auto_str_funcs.write_string('\t\tcase $typ: return $res;')
		} else {
			mut val := '${func_name}(${deref}($typ_str*)x._$sym.cname'
			if should_use_indent_func(sym.kind) && !sym_has_str_method {
				val += ', indent_count'
			}
			val += ')'
			res := 'str_intp(2, _MOV((StrIntpData[]){
				{_SLIT("${clean_sum_type_v_type_name}("), $c.si_s_code, {.d_s = $val}},
				{_SLIT(")"), 0, {.d_c = 0 }}
			}))'
			g.auto_str_funcs.write_string('\t\tcase $typ: return $res;')
		}
	}
	g.auto_str_funcs.writeln('\t\tdefault: return _SLIT("unknown sum type value");')
	g.auto_str_funcs.writeln('\t}')
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) fn_decl_str(info ast.FnType) string {
	mut fn_str := 'fn ('
	for i, arg in info.func.params {
		if arg.is_mut {
			fn_str += 'mut '
		}
		if i > 0 {
			fn_str += ', '
		}
		fn_str += util.strip_main_name(g.table.get_type_name(g.unwrap_generic(arg.typ)))
	}
	fn_str += ')'
	if info.func.return_type != ast.void_type {
		x := util.strip_main_name(g.table.get_type_name(g.unwrap_generic(info.func.return_type)))
		fn_str += ' $x'
	}
	return fn_str
}

fn (mut g Gen) gen_str_for_fn_type(info ast.FnType, styp string, str_fn_name string) {
	g.type_definitions.writeln('static string ${str_fn_name}(); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}() { return _SLIT("${g.fn_decl_str(info)}");}')
}

fn (mut g Gen) gen_str_for_chan(info ast.Chan, styp string, str_fn_name string) {
	elem_type_name := util.strip_main_name(g.table.get_type_name(g.unwrap_generic(info.elem_type)))
	g.type_definitions.writeln('static string ${str_fn_name}($styp x); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp x) { return sync__Channel_auto_str(x, _SLIT("$elem_type_name")); }')
}

[inline]
fn styp_to_str_fn_name(styp string) string {
	return styp.replace_each(['*', '', '.', '__', ' ', '__']) + '_str'
}

fn deref_kind(str_method_expects_ptr bool, is_elem_ptr bool, typ ast.Type) (string, string) {
	if str_method_expects_ptr != is_elem_ptr {
		if is_elem_ptr {
			return '*'.repeat(typ.nr_muls()), '&'.repeat(typ.nr_muls())
		} else {
			return '&', ''
		}
	}
	return '', ''
}

fn (mut g Gen) gen_str_for_array(info ast.Array, styp string, str_fn_name string) {
	mut typ := info.elem_type
	mut sym := g.table.get_type_symbol(info.elem_type)
	if mut sym.info is ast.Alias {
		typ = sym.info.parent_type
		sym = g.table.get_type_symbol(typ)
	}
	field_styp := g.typ(typ)
	is_elem_ptr := typ.is_ptr()
	sym_has_str_method, str_method_expects_ptr, _ := sym.str_method_info()
	mut elem_str_fn_name := ''
	if sym_has_str_method {
		elem_str_fn_name = if is_elem_ptr {
			field_styp.replace('*', '') + '_str'
		} else {
			field_styp + '_str'
		}
		if sym.kind == .byte {
			elem_str_fn_name = elem_str_fn_name + '_escaped'
		}
	} else {
		elem_str_fn_name = styp_to_str_fn_name(field_styp)
	}
	if !sym_has_str_method {
		g.gen_str_for_type(typ)
	}
	g.type_definitions.writeln('static string ${str_fn_name}($styp a); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp a) { return indent_${str_fn_name}(a, 0);}')
	g.type_definitions.writeln('static string indent_${str_fn_name}($styp a, int indent_count); // auto')
	g.auto_str_funcs.writeln('static string indent_${str_fn_name}($styp a, int indent_count) {')
	g.auto_str_funcs.writeln('\tstrings__Builder sb = strings__new_builder(a.len * 10);')
	g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT("["));')
	g.auto_str_funcs.writeln('\tfor (int i = 0; i < a.len; ++i) {')
	if sym.kind == .function {
		g.auto_str_funcs.writeln('\t\tstring x = ${elem_str_fn_name}();')
	} else {
		if sym.kind == .array_fixed {
			g.auto_str_funcs.writeln('\t\t$field_styp it;')
			g.auto_str_funcs.writeln('\t\tmemcpy(*($field_styp*)it, (byte*)array_get(a, i), sizeof($field_styp));')
		} else {
			g.auto_str_funcs.writeln('\t\t$field_styp it = *($field_styp*)array_get(a, i);')
		}
		if should_use_indent_func(sym.kind) && !sym_has_str_method {
			if is_elem_ptr {
				g.auto_str_funcs.writeln('\t\tstring x = indent_${elem_str_fn_name}(*it, indent_count);')
			} else {
				g.auto_str_funcs.writeln('\t\tstring x = indent_${elem_str_fn_name}(it, indent_count);')
			}
		} else if sym.kind in [.f32, .f64] {
			if sym.kind == .f32 {
				g.auto_str_funcs.writeln('\t\tstring x = ${str_intp_g32('it')};')
			} else {
				g.auto_str_funcs.writeln('\t\tstring x = ${str_intp_g64('it')};')
			}
		} else if sym.kind == .rune {
			// Rune are managed at this level as strings
			g.auto_str_funcs.writeln('\t\tstring x = str_intp(2, _MOV((StrIntpData[]){{_SLIT("\`"), $c.si_s_code, {.d_s = ${elem_str_fn_name}(it) }}, {_SLIT("\`"), 0, {.d_c = 0 }}}));\n')
		} else if sym.kind == .string {
			g.auto_str_funcs.writeln('\t\tstring x = str_intp(2, _MOV((StrIntpData[]){{_SLIT("\'"), $c.si_s_code, {.d_s = it }}, {_SLIT("\'"), 0, {.d_c = 0 }}}));\n')
		} else {
			// There is a custom .str() method, so use it.
			// NB: we need to take account of whether the user has defined
			// `fn (x T) str() {` or `fn (x &T) str() {`, and convert accordingly
			deref, deref_label := deref_kind(str_method_expects_ptr, is_elem_ptr, typ)
			g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, _SLIT("$deref_label"));')
			g.auto_str_funcs.writeln('\t\tstring x = ${elem_str_fn_name}( $deref it);')
		}
	}
	g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, x);')
	if g.is_autofree && typ != ast.bool_type {
		// no need to free "true"/"false" literals
		g.auto_str_funcs.writeln('\t\tstring_free(&x);')
	}
	g.auto_str_funcs.writeln('\t\tif (i < a.len-1) {')
	g.auto_str_funcs.writeln('\t\t\tstrings__Builder_write_string(&sb, _SLIT(", "));')
	g.auto_str_funcs.writeln('\t\t}')
	g.auto_str_funcs.writeln('\t}')
	g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT("]"));')
	g.auto_str_funcs.writeln('\tstring res = strings__Builder_str(&sb);')
	g.auto_str_funcs.writeln('\tstrings__Builder_free(&sb);')
	g.auto_str_funcs.writeln('\treturn res;')
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) gen_str_for_array_fixed(info ast.ArrayFixed, styp string, str_fn_name string) {
	mut typ := info.elem_type
	mut sym := g.table.get_type_symbol(info.elem_type)
	if mut sym.info is ast.Alias {
		typ = sym.info.parent_type
		sym = g.table.get_type_symbol(typ)
	}
	field_styp := g.typ(typ)
	is_elem_ptr := typ.is_ptr()
	sym_has_str_method, str_method_expects_ptr, _ := sym.str_method_info()
	mut elem_str_fn_name := ''
	if sym_has_str_method {
		elem_str_fn_name = if is_elem_ptr {
			field_styp.replace('*', '') + '_str'
		} else {
			field_styp + '_str'
		}
	} else {
		elem_str_fn_name = styp_to_str_fn_name(field_styp)
	}
	if !sym.has_method('str') {
		elem_str_fn_name = g.gen_str_for_type(typ)
	}
	g.type_definitions.writeln('static string ${str_fn_name}($styp a); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp a) { return indent_${str_fn_name}(a, 0);}')
	g.type_definitions.writeln('static string indent_${str_fn_name}($styp a, int indent_count); // auto')
	g.auto_str_funcs.writeln('static string indent_${str_fn_name}($styp a, int indent_count) {')
	g.auto_str_funcs.writeln('\tstrings__Builder sb = strings__new_builder($info.size * 10);')
	g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT("["));')
	if sym.kind == .function {
		g.auto_str_funcs.writeln('\t\tstring x = ${elem_str_fn_name}();')
	} else {
		deref, deref_label := deref_kind(str_method_expects_ptr, is_elem_ptr, typ)
		g.auto_str_funcs.writeln('\tfor (int i = 0; i < $info.size; ++i) {')
		if should_use_indent_func(sym.kind) && !sym_has_str_method {
			if is_elem_ptr {
				g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, _SLIT("$deref_label"));')
				g.auto_str_funcs.writeln('\t\tif ( 0 == a[i] ) {')
				g.auto_str_funcs.writeln('\t\t\tstrings__Builder_write_string(&sb, _SLIT("0"));')
				g.auto_str_funcs.writeln('\t\t}else{')
				g.auto_str_funcs.writeln('\t\t\tstrings__Builder_write_string(&sb, ${elem_str_fn_name}( $deref a[i]) );')
				g.auto_str_funcs.writeln('\t\t}')
			} else {
				g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${elem_str_fn_name}( $deref a[i]) );')
			}
		} else if sym.kind in [.f32, .f64] {
			if sym.kind == .f32 {
				g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${str_intp_g32('a[i]')} );')
			} else {
				g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${str_intp_g64('a[i]')} );')
			}
		} else if sym.kind == .string {
			g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${str_intp_sq('a[i]')});')
		} else if sym.kind == .rune {
			tmp_str := str_intp_rune('${elem_str_fn_name}(  $deref a[i])')
			g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, $tmp_str);')
		} else {
			g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${elem_str_fn_name}( $deref a[i]));')
		}
	}
	g.auto_str_funcs.writeln('\t\tif (i < ${info.size - 1}) {')
	g.auto_str_funcs.writeln('\t\t\tstrings__Builder_write_string(&sb, _SLIT(", "));')
	g.auto_str_funcs.writeln('\t\t}')
	g.auto_str_funcs.writeln('\t}')
	g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT("]"));')
	g.auto_str_funcs.writeln('\tstring res = strings__Builder_str(&sb);')
	g.auto_str_funcs.writeln('\tstrings__Builder_free(&sb);')
	g.auto_str_funcs.writeln('\treturn res;')
	g.auto_str_funcs.writeln('}')
}

fn (mut g Gen) gen_str_for_map(info ast.Map, styp string, str_fn_name string) {
	mut key_typ := info.key_type
	mut key_sym := g.table.get_type_symbol(key_typ)
	if mut key_sym.info is ast.Alias {
		key_typ = key_sym.info.parent_type
		key_sym = g.table.get_type_symbol(key_typ)
	}
	key_styp := g.typ(key_typ)
	key_str_fn_name := key_styp.replace('*', '') + '_str'
	if !key_sym.has_method('str') {
		g.gen_str_for_type(key_typ)
	}

	mut val_typ := info.value_type
	mut val_sym := g.table.get_type_symbol(val_typ)
	if mut val_sym.info is ast.Alias {
		val_typ = val_sym.info.parent_type
		val_sym = g.table.get_type_symbol(val_typ)
	}
	val_styp := g.typ(val_typ)
	elem_str_fn_name := val_styp.replace('*', '') + '_str'
	if !val_sym.has_method('str') {
		g.gen_str_for_type(val_typ)
	}

	g.type_definitions.writeln('static string ${str_fn_name}($styp m); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp m) { return indent_${str_fn_name}(m, 0);}')
	g.type_definitions.writeln('static string indent_${str_fn_name}($styp m, int indent_count); // auto')
	g.auto_str_funcs.writeln('static string indent_${str_fn_name}($styp m, int indent_count) { /* gen_str_for_map */')
	g.auto_str_funcs.writeln('\tstrings__Builder sb = strings__new_builder(m.key_values.len*10);')
	g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT("{"));')
	g.auto_str_funcs.writeln('\tfor (int i = 0; i < m.key_values.len; ++i) {')
	g.auto_str_funcs.writeln('\t\tif (!DenseArray_has_index(&m.key_values, i)) { continue; }')

	if key_sym.kind == .string {
		g.auto_str_funcs.writeln('\t\tstring key = *(string*)DenseArray_key(&m.key_values, i);')
	} else {
		g.auto_str_funcs.writeln('\t\t$key_styp key = *($key_styp*)DenseArray_key(&m.key_values, i);')
	}
	if key_sym.kind == .string {
		g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${str_intp_sq('key')});')
	} else if key_sym.kind == .rune {
		tmp_str := str_intp_rune('${key_str_fn_name}(key)')
		g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, $tmp_str);')
	} else {
		g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${key_str_fn_name}(key));')
	}
	g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, _SLIT(": "));')
	if val_sym.kind == .function {
		g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${elem_str_fn_name}());')
	} else if val_sym.kind == .string {
		tmp_str := str_intp_sq('*($val_styp*)DenseArray_value(&m.key_values, i)')
		g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, $tmp_str);')
	} else if should_use_indent_func(val_sym.kind) && !val_sym.has_method('str') {
		g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, indent_${elem_str_fn_name}(*($val_styp*)DenseArray_value(&m.key_values, i), indent_count));')
	} else if val_sym.kind in [.f32, .f64] {
		tmp_val := '*($val_styp*)DenseArray_value(&m.key_values, i)'
		if val_sym.kind == .f32 {
			g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${str_intp_g32(tmp_val)});')
		} else {
			g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${str_intp_g64(tmp_val)});')
		}
	} else if val_sym.kind == .rune {
		tmp_str := str_intp_rune('${elem_str_fn_name}(*($val_styp*)DenseArray_value(&m.key_values, i))')
		g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, $tmp_str);')
	} else {
		g.auto_str_funcs.writeln('\t\tstrings__Builder_write_string(&sb, ${elem_str_fn_name}(*($val_styp*)DenseArray_value(&m.key_values, i)));')
	}
	g.auto_str_funcs.writeln('\t\tif (i != m.key_values.len-1) {')
	g.auto_str_funcs.writeln('\t\t\tstrings__Builder_write_string(&sb, _SLIT(", "));')
	g.auto_str_funcs.writeln('\t\t}')
	g.auto_str_funcs.writeln('\t}')
	g.auto_str_funcs.writeln('\tstrings__Builder_write_string(&sb, _SLIT("}"));')
	g.auto_str_funcs.writeln('\tstring res = strings__Builder_str(&sb);')
	g.auto_str_funcs.writeln('\tstrings__Builder_free(&sb);')
	g.auto_str_funcs.writeln('\treturn res;')
	g.auto_str_funcs.writeln('}')
}

fn (g &Gen) type_to_fmt1(typ ast.Type) StrIntpType {
	if typ == ast.byte_type_idx {
		return .si_u8
	}
	if typ == ast.char_type_idx {
		return .si_c
	}
	if typ == ast.voidptr_type_idx || typ in ast.byteptr_types {
		return .si_p
	}
	if typ in ast.charptr_types {
		return .si_s
		// return '%C\\000' // a C string
	}
	sym := g.table.get_type_symbol(typ)
	if typ.is_ptr() && (typ.is_int_valptr() || typ.is_float_valptr()) {
		return .si_s
	} else if sym.kind in [.struct_, .array, .array_fixed, .map, .bool, .enum_, .interface_,
		.sum_type, .function, .alias, .chan] {
		return .si_s
	} else if sym.kind == .string {
		return .si_s
		// return "'%.*s\\000'"
	} else if sym.kind in [.f32, .f64] {
		if sym.kind == .f32 {
			return .si_g32
		}
		return .si_g64
	} else if sym.kind == .int {
		return .si_i32
	} else if sym.kind == .u32 {
		return .si_u32
	} else if sym.kind == .u64 {
		return .si_u64
	} else if sym.kind == .i64 {
		return .si_i64
	}
	return .si_i32
}

fn (mut g Gen) gen_str_for_struct(info ast.Struct, styp string, str_fn_name string) {
	// _str() functions should have a single argument, the indenting ones take 2:
	g.type_definitions.writeln('static string ${str_fn_name}($styp it); // auto')
	g.auto_str_funcs.writeln('static string ${str_fn_name}($styp it) { return indent_${str_fn_name}(it, 0);}')
	g.type_definitions.writeln('static string indent_${str_fn_name}($styp it, int indent_count); // auto')
	mut fn_builder := strings.new_builder(512)
	defer {
		g.auto_fn_definitions << fn_builder.str()
	}
	fn_builder.writeln('static string indent_${str_fn_name}($styp it, int indent_count) {')
	mut clean_struct_v_type_name := styp.replace('__', '.')
	if clean_struct_v_type_name.contains('_T_') {
		// TODO: this is a bit hacky. styp shouldn't be even parsed with _T_
		// use something different than g.typ for styp
		clean_struct_v_type_name =
			clean_struct_v_type_name.replace('Array_', '[]').replace('_T_', '<').replace('_', ', ') +
			'>'
	}
	clean_struct_v_type_name = util.strip_main_name(clean_struct_v_type_name)
	// generate ident / indent length = 4 spaces
	if info.fields.len == 0 {
		fn_builder.writeln('\treturn _SLIT("$clean_struct_v_type_name{}");')
		fn_builder.writeln('}')
		fn_builder.writeln('')
		return
	}

	fn_builder.writeln('\tstring indents = string_repeat(_SLIT("    "), indent_count);')
	fn_builder.writeln('\tstring res = str_intp( ${info.fields.len * 4 + 3}, _MOV((StrIntpData[]){')
	fn_builder.writeln('\t\t{_SLIT("$clean_struct_v_type_name{\\n"), 0, {.d_c=0}},')

	for i, field in info.fields {
		mut ptr_amp := if field.typ.is_ptr() { '&' } else { '' }
		base_fmt := g.type_to_fmt1(g.unwrap_generic(field.typ))

		// manage prefix and quote symbol for the filed
		mut quote_str := ''
		mut prefix := ''
		sym := g.table.get_type_symbol(g.unwrap_generic(field.typ))
		if sym.kind == .string {
			quote_str = "'"
		} else if field.typ in ast.charptr_types {
			quote_str = '\\"'
			prefix = 'C'
		}

		// first fields doesn't need \n
		if i == 0 {
			fn_builder.write_string('\t\t{_SLIT0, $c.si_s_code, {.d_s=indents}}, {_SLIT("    $field.name: $ptr_amp$prefix"), 0, {.d_c=0}}, ')
		} else {
			fn_builder.write_string('\t\t{_SLIT("\\n"), $c.si_s_code, {.d_s=indents}}, {_SLIT("    $field.name: $ptr_amp$prefix"), 0, {.d_c=0}}, ')
		}

		// custom methods management
		has_custom_str := sym.has_method('str')
		mut field_styp := g.typ(field.typ).replace('*', '')
		field_styp_fn_name := if has_custom_str {
			'${field_styp}_str'
		} else {
			g.gen_str_for_type(field.typ)
		}

		// manage the fact hat with float we use always the g representation
		if sym.kind !in [.f32, .f64] {
			fn_builder.write_string('{_SLIT("$quote_str"), ${int(base_fmt)}, {.${data_str(base_fmt)}=')
		} else {
			g_fmt := '0x' + (u32(base_fmt) | u32(0x7F) << 9).hex()
			fn_builder.write_string('{_SLIT("$quote_str"), $g_fmt, {.${data_str(base_fmt)}=')
		}

		mut func := struct_auto_str_func1(sym, field.typ, field_styp_fn_name, field.name)

		// manage reference types can be "nil"
		if field.typ.is_ptr() && !(field.typ in ast.charptr_types
			|| field.typ in ast.byteptr_types || field.typ == ast.voidptr_type_idx) {
			fn_builder.write_string('isnil(it.${c_name(field.name)})')
			fn_builder.write_string(' ? _SLIT("nil") : ')
			// struct, floats and ints have a special case through the _str function
			if sym.kind != .struct_ && !field.typ.is_int_valptr() && !field.typ.is_float_valptr() {
				fn_builder.write_string('*')
			}
		}
		// handle circular ref type of struct to the struct itself
		if styp == field_styp {
			fn_builder.write_string('_SLIT("<circular>")')
		} else {
			// manage C charptr
			if field.typ in ast.charptr_types {
				fn_builder.write_string('tos2((byteptr)$func)')
			} else {
				fn_builder.write_string(func)
			}
		}

		fn_builder.writeln('}}, {_SLIT("$quote_str"), 0, {.d_c=0}},')
	}
	fn_builder.writeln('\t\t{_SLIT("\\n"), $c.si_s_code, {.d_s=indents}}, {_SLIT("}"), 0, {.d_c=0}},')
	fn_builder.writeln('\t}));')
	fn_builder.writeln('\tstring_free(&indents);')
	fn_builder.writeln('\treturn res;')
	fn_builder.writeln('}')
}

fn struct_auto_str_func1(sym &ast.TypeSymbol, field_type ast.Type, fn_name string, field_name string) string {
	has_custom_str, expects_ptr, _ := sym.str_method_info()
	if sym.kind == .enum_ {
		return '${fn_name}(it.${c_name(field_name)})'
	} else if should_use_indent_func(sym.kind) {
		mut obj := 'it.${c_name(field_name)}'
		if field_type.is_ptr() && !expects_ptr {
			obj = '*$obj'
		}
		if has_custom_str {
			return '${fn_name}($obj)'
		}
		return 'indent_${fn_name}($obj, indent_count + 1)'
	} else if sym.kind in [.array, .array_fixed, .map, .sum_type] {
		if has_custom_str {
			return '${fn_name}(it.${c_name(field_name)})'
		}
		return 'indent_${fn_name}(it.${c_name(field_name)}, indent_count + 1)'
	} else if sym.kind == .function {
		return '${fn_name}()'
	} else {
		if sym.kind == .chan {
			return '${fn_name}(it.${c_name(field_name)})'
		}
		mut method_str := 'it.${c_name(field_name)}'
		if sym.kind == .bool {
			method_str += ' ? _SLIT("true") : _SLIT("false")'
		} else if (field_type.is_int_valptr() || field_type.is_float_valptr())
			&& field_type.is_ptr() && !expects_ptr {
			// ptr int can be "nil", so this needs to be casted to a string
			if sym.kind == .f32 {
				return 'str_intp(1, _MOV((StrIntpData[]){
					{_SLIT0, $si_g32_code, {.d_f32 = *$method_str }}
				}))'
			} else if sym.kind == .f64 {
				return 'str_intp(1, _MOV((StrIntpData[]){
					{_SLIT0, $si_g64_code, {.d_f64 = *$method_str }}
				}))'
			} else if sym.kind == .u64 {
				fmt_type := StrIntpType.si_u64
				return 'str_intp(1, _MOV((StrIntpData[]){{_SLIT0, ${u32(fmt_type) | 0xfe00}, {.d_u64 = *$method_str }}}))'
			}
			fmt_type := StrIntpType.si_i32
			return 'str_intp(1, _MOV((StrIntpData[]){{_SLIT0, ${u32(fmt_type) | 0xfe00}, {.d_i32 = *$method_str }}}))'
		}
		return method_str
	}
}
