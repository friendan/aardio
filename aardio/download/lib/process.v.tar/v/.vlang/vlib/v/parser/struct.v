// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module parser

import v.ast
import v.token
import v.util

fn (mut p Parser) struct_decl() ast.StructDecl {
	p.top_level_statement_start()
	// save attributes, they will be changed later in fields
	attrs := p.attrs
	p.attrs = []
	start_pos := p.tok.position()
	is_pub := p.tok.kind == .key_pub
	if is_pub {
		p.next()
	}
	is_union := p.tok.kind == .key_union
	if p.tok.kind == .key_struct {
		p.next()
	} else {
		p.check(.key_union)
	}
	language := if p.tok.lit == 'C' && p.peek_tok.kind == .dot {
		ast.Language.c
	} else if p.tok.lit == 'JS' && p.peek_tok.kind == .dot {
		ast.Language.js
	} else {
		ast.Language.v
	}
	if language != .v {
		p.next() // C || JS
		p.next() // .
	}
	name_pos := p.tok.position()
	p.check_for_impure_v(language, name_pos)
	mut name := p.check_name()
	// defer {
	// if name.contains('App') {
	// println('end of struct decl $name')
	// }
	// }
	if name.len == 1 && name[0].is_capital() {
		p.error_with_pos('single letter capital names are reserved for generic template types.',
			name_pos)
		return ast.StructDecl{}
	}
	mut generic_types := []ast.Type{}
	if p.tok.kind == .lt {
		p.next()
		for {
			generic_types << p.parse_type()
			if p.tok.kind != .comma {
				break
			}
			p.next()
		}
		p.check(.gt)
	}
	no_body := p.tok.kind != .lcbr
	if language == .v && no_body {
		p.error('`$p.tok.lit` lacks body')
		return ast.StructDecl{}
	}
	if language == .v && !p.builtin_mod && name.len > 0 && !name[0].is_capital()
		&& !p.pref.translated {
		p.error_with_pos('struct name `$name` must begin with capital letter', name_pos)
		return ast.StructDecl{}
	}
	if name.len == 1 {
		p.error_with_pos('struct names must have more than one character', name_pos)
		return ast.StructDecl{}
	}
	mut orig_name := name
	if language == .c {
		name = 'C.$name'
		orig_name = name
	} else if language == .js {
		name = 'JS.$name'
		orig_name = name
	} else {
		name = p.prepend_mod(name)
	}
	mut ast_fields := []ast.StructField{}
	mut fields := []ast.StructField{}
	mut embed_types := []ast.Type{}
	mut embeds := []ast.Embed{}
	mut embed_field_names := []string{}
	mut mut_pos := -1
	mut pub_pos := -1
	mut pub_mut_pos := -1
	mut global_pos := -1
	mut module_pos := -1
	mut is_field_mut := false
	mut is_field_pub := false
	mut is_field_global := false
	mut last_line := p.prev_tok.position().line_nr + 1
	mut end_comments := []ast.Comment{}
	if !no_body {
		p.check(.lcbr)
		for p.tok.kind != .rcbr {
			mut comments := []ast.Comment{}
			for p.tok.kind == .comment {
				comments << p.comment()
				if p.tok.kind == .rcbr {
					break
				}
			}
			if p.tok.kind == .rcbr {
				end_comments = comments.clone()
				break
			}
			if p.tok.kind == .key_pub {
				p.next()
				if p.tok.kind == .key_mut {
					if pub_mut_pos != -1 {
						p.error('redefinition of `pub mut` section')
						return ast.StructDecl{}
					}
					p.next()
					pub_mut_pos = ast_fields.len
					is_field_pub = true
					is_field_mut = true
					is_field_global = false
				} else {
					if pub_pos != -1 {
						p.error('redefinition of `pub` section')
						return ast.StructDecl{}
					}
					pub_pos = ast_fields.len
					is_field_pub = true
					is_field_mut = false
					is_field_global = false
				}
				p.check(.colon)
			} else if p.tok.kind == .key_mut {
				if mut_pos != -1 {
					p.error('redefinition of `mut` section')
					return ast.StructDecl{}
				}
				p.next()
				p.check(.colon)
				mut_pos = ast_fields.len
				is_field_pub = false
				is_field_mut = true
				is_field_global = false
			} else if p.tok.kind == .key_global {
				if global_pos != -1 {
					p.error('redefinition of `global` section')
					return ast.StructDecl{}
				}
				p.next()
				p.check(.colon)
				global_pos = ast_fields.len
				is_field_pub = true
				is_field_mut = true
				is_field_global = true
			} else if p.tok.kind == .key_module {
				if module_pos != -1 {
					p.error('redefinition of `module` section')
					return {}
				}
				p.next()
				p.check(.colon)
				module_pos = ast_fields.len
				is_field_pub = false
				is_field_mut = false
				is_field_global = false
			}
			for p.tok.kind == .comment {
				comments << p.comment()
				if p.tok.kind == .rcbr {
					break
				}
			}
			field_start_pos := p.tok.position()
			is_embed := ((p.tok.lit.len > 1 && p.tok.lit[0].is_capital())
				|| p.peek_tok.kind == .dot) && language == .v && p.peek_tok.kind != .key_fn
			is_on_top := ast_fields.len == 0 && !(is_field_mut || is_field_global)
			mut field_name := ''
			mut typ := ast.Type(0)
			mut type_pos := token.Position{}
			mut field_pos := token.Position{}
			if is_embed {
				// struct embedding
				type_pos = p.tok.position()
				typ = p.parse_type()
				ecomments := p.eat_comments({})
				type_pos = type_pos.extend(p.prev_tok.position())
				if !is_on_top {
					p.error_with_pos('struct embedding must be declared at the beginning of the struct body',
						type_pos)
					return ast.StructDecl{}
				}
				sym := p.table.get_type_symbol(typ)
				if typ in embed_types {
					p.error_with_pos('cannot embed `$sym.name` more than once', type_pos)
					return ast.StructDecl{}
				}
				field_name = sym.embed_name()
				if field_name in embed_field_names {
					p.error_with_pos('duplicate field `$field_name`', type_pos)
					return ast.StructDecl{}
				}
				embed_field_names << field_name
				embed_types << typ
				embeds << ast.Embed{
					typ: typ
					pos: type_pos
					comments: ecomments
				}
			} else {
				// struct field
				field_name = p.check_name()
				for p.tok.kind == .comment {
					comments << p.comment()
					if p.tok.kind == .rcbr {
						break
					}
				}
				typ = p.parse_type()
				if typ.idx() == 0 {
					// error is set in parse_type
					return ast.StructDecl{}
				}
				type_pos = p.prev_tok.position()
				field_pos = field_start_pos.extend(type_pos)
			}
			// Comments after type (same line)
			comments << p.eat_comments({})
			if p.tok.kind == .lsbr {
				// attrs are stored in `p.attrs`
				p.attributes()
			}
			mut default_expr := ast.empty_expr()
			mut has_default_expr := false
			if !is_embed {
				if p.tok.kind == .assign {
					// Default value
					p.next()
					default_expr = p.expr(0)
					match mut default_expr {
						ast.EnumVal { default_expr.typ = typ }
						// TODO: implement all types??
						else {}
					}
					has_default_expr = true
					comments << p.eat_comments({})
				}
				ast_fields << ast.StructField{
					name: field_name
					typ: typ
					pos: field_pos
					type_pos: type_pos
					comments: comments
					default_expr: default_expr
					has_default_expr: has_default_expr
					attrs: p.attrs
					is_pub: is_embed || is_field_pub
					is_mut: is_embed || is_field_mut
					is_global: is_field_global
				}
			}
			// save embeds as table fields too, it will be used in generation phase
			fields << ast.StructField{
				name: field_name
				typ: typ
				pos: field_pos
				type_pos: type_pos
				comments: comments
				default_expr: default_expr
				has_default_expr: has_default_expr
				attrs: p.attrs
				is_pub: is_embed || is_field_pub
				is_mut: is_embed || is_field_mut
				is_global: is_field_global
			}
			p.attrs = []
		}
		p.top_level_statement_end()
		last_line = p.tok.line_nr
		p.check(.rcbr)
	}
	t := ast.TypeSymbol{
		kind: .struct_
		language: language
		name: name
		cname: util.no_dots(name)
		mod: p.mod
		info: ast.Struct{
			embeds: embed_types
			fields: fields
			is_typedef: attrs.contains('typedef')
			is_union: is_union
			is_heap: attrs.contains('heap')
			is_generic: generic_types.len > 0
			generic_types: generic_types
			attrs: attrs
		}
		is_public: is_pub
	}
	if p.table.has_deep_child_no_ref(&t, name) {
		p.error_with_pos('invalid recursive struct `$orig_name`', name_pos)
		return ast.StructDecl{}
	}
	mut ret := 0
	// println('reg type symbol $name mod=$p.mod')
	ret = p.table.register_type_symbol(t)
	// allow duplicate c struct declarations
	if ret == -1 && language != .c {
		p.error_with_pos('cannot register struct `$name`, another type with this name exists',
			name_pos)
		return ast.StructDecl{}
	}
	p.expr_mod = ''
	return ast.StructDecl{
		name: name
		is_pub: is_pub
		fields: ast_fields
		pos: start_pos.extend_with_last_line(name_pos, last_line)
		mut_pos: mut_pos
		pub_pos: pub_pos
		pub_mut_pos: pub_mut_pos
		global_pos: global_pos
		module_pos: module_pos
		language: language
		is_union: is_union
		attrs: attrs
		end_comments: end_comments
		generic_types: generic_types
		embeds: embeds
	}
}

fn (mut p Parser) struct_init(short_syntax bool) ast.StructInit {
	first_pos := p.tok.position()
	typ := if short_syntax { ast.void_type } else { p.parse_type() }
	p.expr_mod = ''
	// sym := p.table.get_type_symbol(typ)
	// p.warn('struct init typ=$sym.name')
	if !short_syntax {
		p.check(.lcbr)
	}
	pre_comments := p.eat_comments({})
	mut fields := []ast.StructInitField{}
	mut i := 0
	no_keys := p.peek_tok.kind != .colon && p.tok.kind != .rcbr && p.tok.kind != .ellipsis // `Vec{a,b,c}
	// p.warn(is_short_syntax.str())
	saved_is_amp := p.is_amp
	p.is_amp = false
	mut update_expr := ast.empty_expr()
	mut update_expr_comments := []ast.Comment{}
	mut has_update_expr := false
	for p.tok.kind !in [.rcbr, .rpar, .eof] {
		mut field_name := ''
		mut expr := ast.empty_expr()
		mut field_pos := token.Position{}
		mut first_field_pos := token.Position{}
		mut comments := []ast.Comment{}
		mut nline_comments := []ast.Comment{}
		is_update_expr := fields.len == 0 && p.tok.kind == .ellipsis
		if no_keys {
			// name will be set later in checker
			expr = p.expr(0)
			field_pos = expr.position()
			first_field_pos = field_pos
			comments = p.eat_comments(same_line: true)
		} else if is_update_expr {
			// struct updating syntax; f2 := Foo{ ...f, name: 'f2' }
			p.check(.ellipsis)
			update_expr = p.expr(0)
			update_expr_comments << p.eat_comments(same_line: true)
			has_update_expr = true
		} else {
			first_field_pos = p.tok.position()
			field_name = p.check_name()
			p.check(.colon)
			expr = p.expr(0)
			comments = p.eat_comments(same_line: true)
			last_field_pos := expr.position()
			field_len := if last_field_pos.len > 0 {
				last_field_pos.pos - first_field_pos.pos + last_field_pos.len
			} else {
				first_field_pos.len + 1
			}
			field_pos = token.Position{
				line_nr: first_field_pos.line_nr
				pos: first_field_pos.pos
				len: field_len
				col: first_field_pos.col
			}
		}
		i++
		if p.tok.kind == .comma {
			p.next()
		}
		comments << p.eat_comments(same_line: true)
		nline_comments << p.eat_comments({})
		if !is_update_expr {
			fields << ast.StructInitField{
				name: field_name
				expr: expr
				pos: field_pos
				name_pos: first_field_pos
				comments: comments
				next_comments: nline_comments
				parent_type: typ
			}
		}
	}
	if !short_syntax {
		p.check(.rcbr)
	}
	p.is_amp = saved_is_amp
	return ast.StructInit{
		unresolved: typ.has_flag(.generic)
		typ: typ
		fields: fields
		update_expr: update_expr
		update_expr_comments: update_expr_comments
		has_update_expr: has_update_expr
		name_pos: first_pos
		pos: first_pos.extend(if short_syntax { p.tok.position() } else { p.prev_tok.position() })
		is_short: no_keys
		pre_comments: pre_comments
	}
}

fn (mut p Parser) interface_decl() ast.InterfaceDecl {
	p.top_level_statement_start()
	mut pos := p.tok.position()
	is_pub := p.tok.kind == .key_pub
	if is_pub {
		p.next()
	}
	p.next() // `interface`
	language := if p.tok.lit == 'C' && p.peek_tok.kind == .dot {
		ast.Language.c
	} else if p.tok.lit == 'JS' && p.peek_tok.kind == .dot {
		ast.Language.js
	} else {
		ast.Language.v
	}
	if language != .v {
		p.next() // C || JS
		p.next() // .
	}
	name_pos := p.tok.position()
	p.check_for_impure_v(language, name_pos)
	interface_name := p.prepend_mod(p.check_name()).clone()
	// println('interface decl $interface_name')
	p.check(.lcbr)
	pre_comments := p.eat_comments({})
	// Declare the type
	reg_idx := p.table.register_type_symbol(
		is_public: is_pub
		kind: .interface_
		name: interface_name
		cname: util.no_dots(interface_name)
		mod: p.mod
		info: ast.Interface{
			types: []
		}
	)
	if reg_idx == -1 {
		p.error_with_pos('cannot register interface `$interface_name`, another type with this name exists',
			name_pos)
		return ast.InterfaceDecl{}
	}
	typ := ast.new_type(reg_idx)
	mut ts := p.table.get_type_symbol(typ)
	mut info := ts.info as ast.Interface
	// if methods were declared before, it's an error, ignore them
	ts.methods = []ast.Fn{cap: 20}
	// Parse fields or methods
	mut fields := []ast.StructField{cap: 20}
	mut methods := []ast.FnDecl{cap: 20}
	mut is_mut := false
	mut mut_pos := -1
	mut ifaces := []ast.InterfaceEmbedding{}
	for p.tok.kind != .rcbr && p.tok.kind != .eof {
		if p.tok.kind == .name && p.tok.lit.len > 0 && p.tok.lit[0].is_capital() {
			iface_pos := p.tok.position()
			iface_name := p.tok.lit
			iface_type := p.parse_type()
			comments := p.eat_comments({})
			ifaces << ast.InterfaceEmbedding{
				name: iface_name
				typ: iface_type
				pos: iface_pos
				comments: comments
			}
			if p.tok.kind == .rcbr {
				break
			}
			continue
		}
		if p.tok.kind == .key_mut {
			if is_mut {
				p.error_with_pos('redefinition of `mut` section', p.tok.position())
				return {}
			}
			p.next()
			p.check(.colon)
			is_mut = true
			mut_pos = fields.len
		}
		if p.peek_tok.kind == .lpar {
			method_start_pos := p.tok.position()
			line_nr := p.tok.line_nr
			name := p.check_name()

			if name == 'type_name' {
				p.error_with_pos('cannot override built-in method `type_name`', method_start_pos)
				return ast.InterfaceDecl{}
			}
			if ts.has_method(name) {
				p.error_with_pos('duplicate method `$name`', method_start_pos)
				return ast.InterfaceDecl{}
			}
			if language == .v && util.contains_capital(name) {
				p.error('interface methods cannot contain uppercase letters, use snake_case instead')
				return ast.InterfaceDecl{}
			}
			// field_names << name
			args2, _, is_variadic := p.fn_args() // TODO merge ast.Param and ast.Arg to avoid this
			mut args := [ast.Param{
				name: 'x'
				is_mut: is_mut
				typ: typ
				is_hidden: true
			}]
			args << args2
			mut method := ast.FnDecl{
				name: name
				mod: p.mod
				params: args
				file: p.file_name
				return_type: ast.void_type
				is_variadic: is_variadic
				is_pub: true
				pos: method_start_pos.extend(p.prev_tok.position())
				scope: p.scope
			}
			if p.tok.kind.is_start_of_type() && p.tok.line_nr == line_nr {
				method.return_type_pos = p.tok.position()
				method.return_type = p.parse_type()
				method.return_type_pos = method.return_type_pos.extend(p.tok.position())
				method.pos = method.pos.extend(method.return_type_pos)
			}
			mcomments := p.eat_comments(same_line: true)
			mnext_comments := p.eat_comments({})
			method.comments = mcomments
			method.next_comments = mnext_comments
			methods << method
			// println('register method $name')
			tmethod := ast.Fn{
				name: name
				params: args
				pos: method.pos
				return_type: method.return_type
				is_variadic: is_variadic
				is_pub: true
			}
			ts.register_method(tmethod)
			info.methods << tmethod
		} else {
			// interface fields
			field_pos := p.tok.position()
			field_name := p.check_name()
			mut type_pos := p.tok.position()
			field_typ := p.parse_type()
			type_pos = type_pos.extend(p.prev_tok.position())
			mut comments := []ast.Comment{}
			for p.tok.kind == .comment {
				comments << p.comment()
				if p.tok.kind == .rcbr {
					break
				}
			}
			fields << ast.StructField{
				name: field_name
				pos: field_pos
				type_pos: type_pos
				typ: field_typ
				comments: comments
				is_pub: true
			}
			info.fields << ast.StructField{
				name: field_name
				typ: field_typ
				is_pub: true
				is_mut: is_mut
			}
		}
	}
	info.ifaces = ifaces.map(it.typ)
	ts.info = info
	p.top_level_statement_end()
	p.check(.rcbr)
	pos = pos.extend_with_last_line(p.prev_tok.position(), p.prev_tok.line_nr)
	res := ast.InterfaceDecl{
		name: interface_name
		language: language
		typ: typ
		fields: fields
		methods: methods
		ifaces: ifaces
		is_pub: is_pub
		pos: pos
		pre_comments: pre_comments
		mut_pos: mut_pos
		name_pos: name_pos
	}
	p.table.register_interface(res)
	return res
}
