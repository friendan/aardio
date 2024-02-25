module native

import v.ast

enum Arm64Register {
	x0
	x1
	x2
	x3
	x4
	x5
	x6
	x7
	x8
	x9
	x10
	x11
	x12
	x13
	x14
	x15
	x16
}

pub struct Arm64 {
mut:
	g &Gen
	// arm64 specific stuff for code generation
}

pub fn (mut x Arm64) allocate_var(name string, size int, initial_val int) {
	eprintln('TODO: allocating var on arm64 ($name) = $size = $initial_val')
}

fn (mut g Gen) mov_arm(reg Arm64Register, val u64) {
	// m := u64(0xffff)
	// x := u64(val)
	// println('========')
	// println(x & ~m)
	// println(x & ~(m << 16))
	// g.write32(0x777777)
	r := int(reg)
	if r == 0 && val == 1 {
		g.write32(0xd2800020)
		g.println('mov x0, 1')
	} else if r >= 0 && r <= 16 {
		g.write32(0xd2800000 + int(r) + (int(val) << 5))
		g.println('mov x$r, $val')
	} else {
		verror('mov_arm unsupported values')
	}
	/*
	if 1 ^ (x & ~m) != 0 {
		// println('yep')
		g.write32(int(u64(0x52800000) | u64(r) | x << 5))
		g.write32(0x88888888)
		g.write32(int(u64(0x52800000) | u64(r) | x >> 11))
	} else if 1 ^ (x & ~(m << 16)) != 0 {
		// g.write32(int(u64(0x52800000) | u64(r) | x >> 11))
		// println('yep2')
		// g.write32(0x52a00000 | r | val >> 11)
	}
	*/
}

pub fn (mut g Gen) fn_decl_arm64(node ast.FnDecl) {
	g.gen_arm64_helloworld()
	// TODO
}

pub fn (mut g Gen) call_fn_arm64(node ast.CallExpr) {
	name := node.name
	// println('call fn $name')
	addr := g.fn_addr[name]
	if addr == 0 {
		verror('fn addr of `$name` = 0')
	}
	// Copy values to registers (calling convention)
	// g.mov_arm(.eax, 0)
	for i in 0 .. node.args.len {
		expr := node.args[i].expr
		match expr {
			ast.IntegerLiteral {
				// `foo(2)` => `mov edi,0x2`
				// g.mov_arm(native.fn_arg_registers[i], expr.val.int())
			}
			/*
			ast.Ident {
				// `foo(x)` => `mov edi,DWORD PTR [rbp-0x8]`
				var_offset := g.get_var_offset(expr.name)
				if g.pref.is_verbose {
					println('i=$i fn name= $name offset=$var_offset')
					println(int(native.fn_arg_registers[i]))
				}
				g.mov_var_to_reg(native.fn_arg_registers[i], var_offset)
			}
			*/
			else {
				verror('unhandled call_fn (name=$name) node: ' + expr.type_name())
			}
		}
	}
	if node.args.len > 6 {
		verror('more than 6 args not allowed for now')
	}
	g.call(int(addr))
	g.println('fn call `${name}()`')
	// println('call $name $addr')
}

fn (mut g Gen) gen_arm64_helloworld() {
	if g.pref.os == .linux {
		g.mov_arm(.x0, 1)
		g.adr(.x1, 0x10)
		g.mov_arm(.x2, 13)
		g.mov_arm(.x8, 64) // write (linux-arm64)
		g.svc()
	} else {
		g.mov_arm(.x0, 0)
		g.mov_arm(.x16, 1)
		g.svc()
	}
	zero := ast.IntegerLiteral{}
	g.gen_exit(zero)
	g.write_string('Hello World!\n')
	g.write8(0) // padding?
	g.write8(0)
	g.write8(0)
}

fn (mut g Gen) adr(r Arm64Register, delta int) {
	g.write32(0x10000000 | int(r) | (delta << 4))
	g.println('adr $r, $delta')
}

fn (mut g Gen) bl() {
	// g.write32(0xa9400000)
	g.write32(0x94000000)
	g.println('bl 0')
}

fn (mut g Gen) svc() {
	g.write32(0xd4001001)
	g.println('svc 0x80')
}

pub fn (mut c Arm64) gen_exit(mut g Gen, expr ast.Expr) {
	mut return_code := u64(0)
	match expr {
		ast.IntegerLiteral {
			return_code = expr.val.u64()
		}
		else {
			verror('native builtin exit expects a numeric argument')
		}
	}
	match c.g.pref.os {
		.macos {
			c.g.mov_arm(.x0, return_code)
			c.g.mov_arm(.x16, 1) // syscall exit
		}
		.linux {
			c.g.mov_arm(.x16, return_code)
			c.g.mov_arm(.x8, 93)
			c.g.mov_arm(.x0, 0)
		}
		else {
			verror('unsupported os $c.g.pref.os')
		}
	}
	g.svc()
}

pub fn (mut g Gen) gen_arm64_exit(expr ast.Expr) {
	match expr {
		ast.IntegerLiteral {
			g.mov_arm(.x16, expr.val.u64())
		}
		else {
			verror('native builtin exit expects a numeric argument')
		}
	}
	g.mov_arm(.x0, 0)
	g.svc()
}
