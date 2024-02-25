module strconv

import math.bits
// import math

/*
f32/f64 to string utilities

Copyright (c) 2019-2021 Dario Deledda. All rights reserved.
Use of this source code is governed by an MIT license
that can be found in the LICENSE file.

This file contains the f32/f64 to string utilities functions

These functions are based on the work of:
Publication:PLDI 2018: Proceedings of the 39th ACM SIGPLAN
Conference on Programming Language Design and ImplementationJune 2018
Pages 270–282 https://doi.org/10.1145/3192366.3192369

inspired by the Go version here:
https://github.com/cespare/ryu/tree/ba56a33f39e3bbbfa409095d0f9ae168a595feea
*/

// General Utilities
[if debug_strconv ?]
fn assert1(t bool, msg string) {
	if !t {
		panic(msg)
	}
}

[inline]
fn bool_to_int(b bool) int {
	if b {
		return 1
	}
	return 0
}

[inline]
fn bool_to_u32(b bool) u32 {
	if b {
		return u32(1)
	}
	return u32(0)
}

[inline]
fn bool_to_u64(b bool) u64 {
	if b {
		return u64(1)
	}
	return u64(0)
}

fn get_string_special(neg bool, expZero bool, mantZero bool) string {
	if !mantZero {
		return 'nan'
	}
	if !expZero {
		if neg {
			return '-inf'
		} else {
			return '+inf'
		}
	}
	if neg {
		return '-0e+00'
	}
	return '0e+00'
}

/*
32 bit functions
*/
// decimal_len_32 return the number of decimal digits of the input
[deprecated]
pub fn decimal_len_32(u u32) int {
	// Function precondition: u is not a 10-digit number.
	// (9 digits are sufficient for round-tripping.)
	// This benchmarked faster than the log2 approach used for u64.
	assert1(u < 1000000000, 'too big')

	if u >= 100000000 {
		return 9
	} else if u >= 10000000 {
		return 8
	} else if u >= 1000000 {
		return 7
	} else if u >= 100000 {
		return 6
	} else if u >= 10000 {
		return 5
	} else if u >= 1000 {
		return 4
	} else if u >= 100 {
		return 3
	} else if u >= 10 {
		return 2
	}
	return 1
}

fn mul_shift_32(m u32, mul u64, ishift int) u32 {
	// QTODO
	// assert ishift > 32

	hi, lo := bits.mul_64(u64(m), mul)
	shifted_sum := (lo >> u64(ishift)) + (hi << u64(64 - ishift))
	assert1(shifted_sum <= 2147483647, 'shiftedSum <= math.max_u32')
	return u32(shifted_sum)
}

fn mul_pow5_invdiv_pow2(m u32, q u32, j int) u32 {
	return mul_shift_32(m, pow5_inv_split_32[q], j)
}

fn mul_pow5_div_pow2(m u32, i u32, j int) u32 {
	return mul_shift_32(m, pow5_split_32[i], j)
}

fn pow5_factor_32(i_v u32) u32 {
	mut v := i_v
	for n := u32(0); true; n++ {
		q := v / 5
		r := v % 5
		if r != 0 {
			return n
		}
		v = q
	}
	return v
}

// multiple_of_power_of_five_32 reports whether v is divisible by 5^p.
fn multiple_of_power_of_five_32(v u32, p u32) bool {
	return pow5_factor_32(v) >= p
}

// multiple_of_power_of_two_32 reports whether v is divisible by 2^p.
fn multiple_of_power_of_two_32(v u32, p u32) bool {
	return u32(bits.trailing_zeros_32(v)) >= p
}

// log10_pow2 returns floor(log_10(2^e)).
fn log10_pow2(e int) u32 {
	// The first value this approximation fails for is 2^1651
	// which is just greater than 10^297.
	assert1(e >= 0, 'e >= 0')
	assert1(e <= 1650, 'e <= 1650')
	return (u32(e) * 78913) >> 18
}

// log10_pow5 returns floor(log_10(5^e)).
fn log10_pow5(e int) u32 {
	// The first value this approximation fails for is 5^2621
	// which is just greater than 10^1832.
	assert1(e >= 0, 'e >= 0')
	assert1(e <= 2620, 'e <= 2620')
	return (u32(e) * 732923) >> 20
}

// pow5_bits returns ceil(log_2(5^e)), or else 1 if e==0.
fn pow5_bits(e int) int {
	// This approximation works up to the point that the multiplication
	// overflows at e = 3529. If the multiplication were done in 64 bits,
	// it would fail at 5^4004 which is just greater than 2^9297.
	assert1(e >= 0, 'e >= 0')
	assert1(e <= 3528, 'e <= 3528')
	return int(((u32(e) * 1217359) >> 19) + 1)
}

/*
64 bit functions
*/

// decimal_len_64 return the number of decimal digits of the input
[deprecated]
pub fn decimal_len_64(u u64) int {
	// http://graphics.stanford.edu/~seander/bithacks.html#IntegerLog10
	log2 := 64 - bits.leading_zeros_64(u) - 1
	t := (log2 + 1) * 1233 >> 12
	return t - bool_to_int(u < powers_of_10[t]) + 1
}

fn shift_right_128(v Uint128, shift int) u64 {
	// The shift value is always modulo 64.
	// In the current implementation of the 64-bit version
	// of Ryu, the shift value is always < 64.
	// (It is in the range [2, 59].)
	// Check this here in case a future change requires larger shift
	// values. In this case this function needs to be adjusted.
	assert1(shift < 64, 'shift < 64')
	return (v.hi << u64(64 - shift)) | (v.lo >> u32(shift))
}

fn mul_shift_64(m u64, mul Uint128, shift int) u64 {
	hihi, hilo := bits.mul_64(m, mul.hi)
	lohi, _ := bits.mul_64(m, mul.lo)
	mut sum := Uint128{
		lo: lohi + hilo
		hi: hihi
	}
	if sum.lo < lohi {
		sum.hi++ // overflow
	}
	return shift_right_128(sum, shift - 64)
}

fn pow5_factor_64(v_i u64) u32 {
	mut v := v_i
	for n := u32(0); true; n++ {
		q := v / 5
		r := v % 5
		if r != 0 {
			return n
		}
		v = q
	}
	return u32(0)
}

fn multiple_of_power_of_five_64(v u64, p u32) bool {
	return pow5_factor_64(v) >= p
}

fn multiple_of_power_of_two_64(v u64, p u32) bool {
	return u32(bits.trailing_zeros_64(v)) >= p
}

/*
f64 to string with string format
*/

// TODO: Investigate precision issues
// f32_to_str_l return a string with the f32 converted in a string in decimal notation
[manualfree]
pub fn f32_to_str_l(f f32) string {
	s := f32_to_str(f, 6)
	res := fxx_to_str_l_parse(s)
	unsafe { s.free() }
	return res
}

[manualfree]
pub fn f32_to_str_l_no_dot(f f32) string {
	s := f32_to_str(f, 6)
	res := fxx_to_str_l_parse_no_dot(s)
	unsafe { s.free() }
	return res
}

[manualfree]
pub fn f64_to_str_l(f f64) string {
	s := f64_to_str(f, 18)
	res := fxx_to_str_l_parse(s)
	unsafe { s.free() }
	return res
}

[manualfree]
pub fn f64_to_str_l_no_dot(f f64) string {
	s := f64_to_str(f, 18)
	res := fxx_to_str_l_parse_no_dot(s)
	unsafe { s.free() }
	return res
}

// f64_to_str_l return a string with the f64 converted in a string in decimal notation
[manualfree]
pub fn fxx_to_str_l_parse(s string) string {
	// check for +inf -inf Nan
	if s.len > 2 && (s[0] == `n` || s[1] == `i`) {
		return s.clone()
	}

	m_sgn_flag := false
	mut sgn := 1
	mut b := [26]byte{}
	mut d_pos := 1
	mut i := 0
	mut i1 := 0
	mut exp := 0
	mut exp_sgn := 1

	// get sign and decimal parts
	for c in s {
		if c == `-` {
			sgn = -1
			i++
		} else if c == `+` {
			sgn = 1
			i++
		} else if c >= `0` && c <= `9` {
			b[i1] = c
			i1++
			i++
		} else if c == `.` {
			if sgn > 0 {
				d_pos = i
			} else {
				d_pos = i - 1
			}
			i++
		} else if c == `e` {
			i++
			break
		} else {
			return 'Float conversion error!!'
		}
	}
	b[i1] = 0

	// get exponent
	if s[i] == `-` {
		exp_sgn = -1
		i++
	} else if s[i] == `+` {
		exp_sgn = 1
		i++
	}

	mut c := i
	for c < s.len {
		exp = exp * 10 + int(s[c] - `0`)
		c++
	}

	// allocate exp+32 chars for the return string
	mut res := []byte{len: exp + 32, init: 0}
	mut r_i := 0 // result string buffer index

	// println("s:${sgn} b:${b[0]} es:${exp_sgn} exp:${exp}")

	if sgn == 1 {
		if m_sgn_flag {
			res[r_i] = `+`
			r_i++
		}
	} else {
		res[r_i] = `-`
		r_i++
	}

	i = 0
	if exp_sgn >= 0 {
		for b[i] != 0 {
			res[r_i] = b[i]
			r_i++
			i++
			if i >= d_pos && exp >= 0 {
				if exp == 0 {
					res[r_i] = `.`
					r_i++
				}
				exp--
			}
		}
		for exp >= 0 {
			res[r_i] = `0`
			r_i++
			exp--
		}
	} else {
		mut dot_p := true
		for exp > 0 {
			res[r_i] = `0`
			r_i++
			exp--
			if dot_p {
				res[r_i] = `.`
				r_i++
				dot_p = false
			}
		}
		for b[i] != 0 {
			res[r_i] = b[i]
			r_i++
			i++
		}
	}
	/*
	// remove the dot form the numbers like 2.
	if r_i > 1 && res[r_i-1] == `.` {
		r_i--
	}
	*/
	res[r_i] = 0
	return unsafe { tos(res.data, r_i) }
}

// f64_to_str_l return a string with the f64 converted in a string in decimal notation
[manualfree]
pub fn fxx_to_str_l_parse_no_dot(s string) string {
	// check for +inf -inf Nan
	if s.len > 2 && (s[0] == `n` || s[1] == `i`) {
		return s.clone()
	}

	m_sgn_flag := false
	mut sgn := 1
	mut b := [26]byte{}
	mut d_pos := 1
	mut i := 0
	mut i1 := 0
	mut exp := 0
	mut exp_sgn := 1

	// get sign and decimal parts
	for c in s {
		if c == `-` {
			sgn = -1
			i++
		} else if c == `+` {
			sgn = 1
			i++
		} else if c >= `0` && c <= `9` {
			b[i1] = c
			i1++
			i++
		} else if c == `.` {
			if sgn > 0 {
				d_pos = i
			} else {
				d_pos = i - 1
			}
			i++
		} else if c == `e` {
			i++
			break
		} else {
			return 'Float conversion error!!'
		}
	}
	b[i1] = 0

	// get exponent
	if s[i] == `-` {
		exp_sgn = -1
		i++
	} else if s[i] == `+` {
		exp_sgn = 1
		i++
	}

	mut c := i
	for c < s.len {
		exp = exp * 10 + int(s[c] - `0`)
		c++
	}

	// allocate exp+32 chars for the return string
	mut res := []byte{len: exp + 32, init: 0}
	mut r_i := 0 // result string buffer index

	// println("s:${sgn} b:${b[0]} es:${exp_sgn} exp:${exp}")

	if sgn == 1 {
		if m_sgn_flag {
			res[r_i] = `+`
			r_i++
		}
	} else {
		res[r_i] = `-`
		r_i++
	}

	i = 0
	if exp_sgn >= 0 {
		for b[i] != 0 {
			res[r_i] = b[i]
			r_i++
			i++
			if i >= d_pos && exp >= 0 {
				if exp == 0 {
					res[r_i] = `.`
					r_i++
				}
				exp--
			}
		}
		for exp >= 0 {
			res[r_i] = `0`
			r_i++
			exp--
		}
	} else {
		mut dot_p := true
		for exp > 0 {
			res[r_i] = `0`
			r_i++
			exp--
			if dot_p {
				res[r_i] = `.`
				r_i++
				dot_p = false
			}
		}
		for b[i] != 0 {
			res[r_i] = b[i]
			r_i++
			i++
		}
	}

	// remove the dot form the numbers like 2.
	if r_i > 1 && res[r_i - 1] == `.` {
		r_i--
	}

	res[r_i] = 0
	return unsafe { tos(res.data, r_i) }
}

// dec_digits return the number of decimal digit of an u64
pub fn dec_digits(n u64) int {
	if n <= 9_999_999_999 { // 1-10
		if n <= 99_999 { // 5
			if n <= 99 { // 2
				if n <= 9 { // 1
					return 1
				} else {
					return 2
				}
			} else {
				if n <= 999 { // 3
					return 3
				} else {
					if n <= 9999 { // 4
						return 4
					} else {
						return 5
					}
				}
			}
		} else {
			if n <= 9_999_999 { // 7
				if n <= 999_999 { // 6
					return 6
				} else {
					return 7
				}
			} else {
				if n <= 99_999_999 { // 8
					return 8
				} else {
					if n <= 999_999_999 { // 9
						return 9
					}
					return 10
				}
			}
		}
	} else {
		if n <= 999_999_999_999_999 { // 5
			if n <= 999_999_999_999 { // 2
				if n <= 99_999_999_999 { // 1
					return 11
				} else {
					return 12
				}
			} else {
				if n <= 9_999_999_999_999 { // 3
					return 13
				} else {
					if n <= 99_999_999_999_999 { // 4
						return 14
					} else {
						return 15
					}
				}
			}
		} else {
			if n <= 99_999_999_999_999_999 { // 7
				if n <= 9_999_999_999_999_999 { // 6
					return 16
				} else {
					return 17
				}
			} else {
				if n <= 999_999_999_999_999_999 { // 8
					return 18
				} else {
					if n <= 9_999_999_999_999_999_999 { // 9
						return 19
					}
					return 20
				}
			}
		}
	}
}
