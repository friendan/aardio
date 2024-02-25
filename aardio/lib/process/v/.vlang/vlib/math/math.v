// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module math

// aprox_sin returns an approximation of sin(a) made using lolremez
pub fn aprox_sin(a f64) f64 {
	a0 := 1.91059300966915117e-31
	a1 := 1.00086760103908896
	a2 := -1.21276126894734565e-2
	a3 := -1.38078780785773762e-1
	a4 := -2.67353392911981221e-2
	a5 := 2.08026600266304389e-2
	a6 := -3.03996055049204407e-3
	a7 := 1.38235642404333740e-4
	return a0 + a * (a1 + a * (a2 + a * (a3 + a * (a4 + a * (a5 + a * (a6 + a * a7))))))
}

// aprox_cos returns an approximation of sin(a) made using lolremez
pub fn aprox_cos(a f64) f64 {
	a0 := 9.9995999154986614e-1
	a1 := 1.2548995793001028e-3
	a2 := -5.0648546280678015e-1
	a3 := 1.2942246466519995e-2
	a4 := 2.8668384702547972e-2
	a5 := 7.3726485210586547e-3
	a6 := -3.8510875386947414e-3
	a7 := 4.7196604604366623e-4
	a8 := -1.8776444013090451e-5
	return a0 + a * (a1 + a * (a2 + a * (a3 + a * (a4 + a * (a5 + a * (a6 + a * (a7 + a * a8)))))))
}

// copysign returns a value with the magnitude of x and the sign of y
[inline]
pub fn copysign(x f64, y f64) f64 {
	return f64_from_bits((f64_bits(x) & ~sign_mask) | (f64_bits(y) & sign_mask))
}

// degrees convert from degrees to radians.
[inline]
pub fn degrees(radians f64) f64 {
	return radians * (180.0 / pi)
}

// digits returns an array of the digits of n in the given base.
pub fn digits(_n int, base int) []int {
	if base < 2 {
		panic('digits: Cannot find digits of n with base $base')
	}
	mut n := _n
	mut sign := 1
	if n < 0 {
		sign = -1
		n = -n
	}
	mut res := []int{}
	for n != 0 {
		res << (n % base) * sign
		n /= base
	}
	return res
}

[inline]
pub fn fabs(x f64) f64 {
	if x < 0.0 {
		return -x
	}
	return x
}

// gcd calculates greatest common (positive) divisor (or zero if a and b are both zero).
pub fn gcd(a_ i64, b_ i64) i64 {
	mut a := a_
	mut b := b_
	if a < 0 {
		a = -a
	}
	if b < 0 {
		b = -b
	}
	for b != 0 {
		a %= b
		if a == 0 {
			return b
		}
		b %= a
	}
	return a
}

// lcm calculates least common (non-negative) multiple.
pub fn lcm(a i64, b i64) i64 {
	if a == 0 {
		return a
	}
	res := a * (b / gcd(b, a))
	if res < 0 {
		return -res
	}
	return res
}

// max returns the maximum value of the two provided.
[inline]
pub fn max(a f64, b f64) f64 {
	if a > b {
		return a
	}
	return b
}

// min returns the minimum value of the two provided.
[inline]
pub fn min(a f64, b f64) f64 {
	if a < b {
		return a
	}
	return b
}

// sign returns the corresponding sign -1.0, 1.0 of the provided number.
// if n is not a number, its sign is nan too.
[inline]
pub fn sign(n f64) f64 {
	if is_nan(n) {
		return nan()
	}
	return copysign(1.0, n)
}

// signi returns the corresponding sign -1.0, 1.0 of the provided number.
[inline]
pub fn signi(n f64) int {
	return int(copysign(1.0, n))
}

// radians convert from radians to degrees.
[inline]
pub fn radians(degrees f64) f64 {
	return degrees * (pi / 180.0)
}

// signbit returns a value with the boolean representation of the sign for x
[inline]
pub fn signbit(x f64) bool {
	return f64_bits(x) & sign_mask != 0
}
