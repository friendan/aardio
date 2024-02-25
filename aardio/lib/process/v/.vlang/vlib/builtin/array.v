// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module builtin

import strings

// array is a struct used for denoting array types in V
pub struct array {
pub:
	element_size int // size in bytes of one element in the array.
pub mut:
	data   voidptr
	offset int // in bytes (should be `size_t`)
	len    int // length of the array.
	cap    int // capacity of the array.
}

// array.data uses a void pointer, which allows implementing arrays without generics and without generating
// extra code for every type.
// Internal function, used by V (`nums := []int`)
fn __new_array(mylen int, cap int, elm_size int) array {
	cap_ := if cap < mylen { mylen } else { cap }
	arr := array{
		element_size: elm_size
		data: vcalloc(cap_ * elm_size)
		len: mylen
		cap: cap_
	}
	return arr
}

fn __new_array_with_default(mylen int, cap int, elm_size int, val voidptr) array {
	cap_ := if cap < mylen { mylen } else { cap }
	mut arr := array{
		element_size: elm_size
		data: vcalloc(cap_ * elm_size)
		len: mylen
		cap: cap_
	}
	if val != 0 {
		for i in 0 .. arr.len {
			unsafe { arr.set_unsafe(i, val) }
		}
	}
	return arr
}

fn __new_array_with_array_default(mylen int, cap int, elm_size int, val array) array {
	cap_ := if cap < mylen { mylen } else { cap }
	mut arr := array{
		element_size: elm_size
		data: vcalloc(cap_ * elm_size)
		len: mylen
		cap: cap_
	}
	for i in 0 .. arr.len {
		val_clone := val.clone()
		unsafe { arr.set_unsafe(i, &val_clone) }
	}
	return arr
}

// Private function, used by V (`nums := [1, 2, 3]`)
fn new_array_from_c_array(len int, cap int, elm_size int, c_array voidptr) array {
	cap_ := if cap < len { len } else { cap }
	arr := array{
		element_size: elm_size
		data: vcalloc(cap_ * elm_size)
		len: len
		cap: cap_
	}
	// TODO Write all memory functions (like memcpy) in V
	unsafe { C.memcpy(arr.data, c_array, len * elm_size) }
	return arr
}

// Private function, used by V (`nums := [1, 2, 3] !`)
fn new_array_from_c_array_no_alloc(len int, cap int, elm_size int, c_array voidptr) array {
	arr := array{
		element_size: elm_size
		data: c_array
		len: len
		cap: cap
	}
	return arr
}

// Private function. Doubles array capacity if needed.
fn (mut a array) ensure_cap(required int) {
	if required <= a.cap {
		return
	}
	mut cap := if a.cap > 0 { a.cap } else { 2 }
	for required > cap {
		cap *= 2
	}
	new_size := cap * a.element_size
	new_data := vcalloc(new_size)
	if a.data != voidptr(0) {
		unsafe { C.memcpy(new_data, a.data, a.len * a.element_size) }
		// TODO: the old data may be leaked when no GC is used (ref-counting?)
	}
	a.data = new_data
	a.offset = 0
	a.cap = cap
}

// repeat returns a new array with the given array elements repeated given times.
// `cgen` will replace this with an apropriate call to `repeat_to_depth()`

// This is a dummy placeholder that will be overridden by `cgen` with an appropriate
// call to `repeat_to_depth()`. However the `checker` needs it here.
pub fn (a array) repeat(count int) array {
	return unsafe { a.repeat_to_depth(count, 0) }
}

// version of `repeat()` that handles multi dimensional arrays
// `unsafe` to call directly because `depth` is not checked
[unsafe]
pub fn (a array) repeat_to_depth(count int, depth int) array {
	if count < 0 {
		panic('array.repeat: count is negative: $count')
	}
	mut size := count * a.len * a.element_size
	if size == 0 {
		size = a.element_size
	}
	arr := array{
		element_size: a.element_size
		data: vcalloc(size)
		len: count * a.len
		cap: count * a.len
	}
	if a.len > 0 {
		for i in 0 .. count {
			if depth > 0 {
				ary_clone := unsafe { a.clone_to_depth(depth) }
				unsafe { C.memcpy(arr.get_unsafe(i * a.len), &byte(ary_clone.data), a.len * a.element_size) }
			} else {
				unsafe { C.memcpy(arr.get_unsafe(i * a.len), &byte(a.data), a.len * a.element_size) }
			}
		}
	}
	return arr
}

// sort_with_compare sorts array in-place using given `compare` function as comparator.
pub fn (mut a array) sort_with_compare(compare voidptr) {
	$if freestanding {
		panic('sort does not work with -freestanding')
	} $else {
		C.qsort(mut a.data, a.len, a.element_size, compare)
	}
}

// insert inserts a value in the array at index `i`
pub fn (mut a array) insert(i int, val voidptr) {
	$if !no_bounds_checking ? {
		if i < 0 || i > a.len {
			panic('array.insert: index out of range (i == $i, a.len == $a.len)')
		}
	}
	a.ensure_cap(a.len + 1)
	unsafe {
		C.memmove(a.get_unsafe(i + 1), a.get_unsafe(i), (a.len - i) * a.element_size)
		a.set_unsafe(i, val)
	}
	a.len++
}

// insert_many inserts many values into the array from index `i`.
[unsafe]
pub fn (mut a array) insert_many(i int, val voidptr, size int) {
	$if !no_bounds_checking ? {
		if i < 0 || i > a.len {
			panic('array.insert_many: index out of range (i == $i, a.len == $a.len)')
		}
	}
	a.ensure_cap(a.len + size)
	elem_size := a.element_size
	unsafe {
		iptr := a.get_unsafe(i)
		C.memmove(a.get_unsafe(i + size), iptr, (a.len - i) * elem_size)
		C.memcpy(iptr, val, size * elem_size)
	}
	a.len += size
}

// prepend prepends one value to the array.
pub fn (mut a array) prepend(val voidptr) {
	a.insert(0, val)
}

// prepend_many prepends another array to this array.
[unsafe]
pub fn (mut a array) prepend_many(val voidptr, size int) {
	unsafe { a.insert_many(0, val, size) }
}

// delete deletes array element at index `i`.
pub fn (mut a array) delete(i int) {
	$if !no_bounds_checking ? {
		if i < 0 || i >= a.len {
			panic('array.delete: index out of range (i == $i, a.len == $a.len)')
		}
	}
	// NB: if a is [12,34], a.len = 2, a.delete(0)
	// should move (2-0-1) elements = 1 element (the 34) forward
	unsafe { C.memmove(a.get_unsafe(i), a.get_unsafe(i + 1), (a.len - i - 1) * a.element_size) }
	a.len--
}

// clear clears the array without deallocating the allocated data.
pub fn (mut a array) clear() {
	a.len = 0
}

// trim trims the array length to "index" without modifying the allocated data. If "index" is greater
// than len nothing will be changed.
pub fn (mut a array) trim(index int) {
	if index < a.len {
		a.len = index
	}
}

// we manually inline this for single operations for performance without -prod
[inline; unsafe]
fn (a array) get_unsafe(i int) voidptr {
	unsafe {
		return &byte(a.data) + i * a.element_size
	}
}

// Private function. Used to implement array[] operator.
fn (a array) get(i int) voidptr {
	$if !no_bounds_checking ? {
		if i < 0 || i >= a.len {
			panic('array.get: index out of range (i == $i, a.len == $a.len)')
		}
	}
	unsafe {
		return &byte(a.data) + i * a.element_size
	}
}

// Private function. Used to implement x = a[i] or { ... }
fn (a array) get_with_check(i int) voidptr {
	if i < 0 || i >= a.len {
		return 0
	}
	unsafe {
		return &byte(a.data) + i * a.element_size
	}
}

// first returns the first element of the array.
pub fn (a array) first() voidptr {
	$if !no_bounds_checking ? {
		if a.len == 0 {
			panic('array.first: array is empty')
		}
	}
	return a.data
}

// last returns the last element of the array.
pub fn (a array) last() voidptr {
	$if !no_bounds_checking ? {
		if a.len == 0 {
			panic('array.last: array is empty')
		}
	}
	unsafe {
		return &byte(a.data) + (a.len - 1) * a.element_size
	}
}

// pop returns the last element of the array, and removes it.
pub fn (mut a array) pop() voidptr {
	// in a sense, this is the opposite of `a << x`
	$if !no_bounds_checking ? {
		if a.len == 0 {
			panic('array.pop: array is empty')
		}
	}
	new_len := a.len - 1
	last_elem := unsafe { &byte(a.data) + new_len * a.element_size }
	a.len = new_len
	// NB: a.cap is not changed here *on purpose*, so that
	// further << ops on that array will be more efficient.
	return unsafe { memdup(last_elem, a.element_size) }
}

// delete_last efficiently deletes the last element of the array.
pub fn (mut a array) delete_last() {
	// copy pasting code for performance
	$if !no_bounds_checking ? {
		if a.len == 0 {
			panic('array.pop: array is empty')
		}
	}
	a.len--
}

// slice returns an array using the same buffer as original array
// but starting from the `start` element and ending with the element before
// the `end` element of the original array with the length and capacity
// set to the number of the elements in the slice.
fn (a array) slice(start int, _end int) array {
	mut end := _end
	$if !no_bounds_checking ? {
		if start > end {
			panic('array.slice: invalid slice index ($start > $end)')
		}
		if end > a.len {
			panic('array.slice: slice bounds out of range ($end >= $a.len)')
		}
		if start < 0 {
			panic('array.slice: slice bounds out of range ($start < 0)')
		}
	}
	offset := start * a.element_size
	data := unsafe { &byte(a.data) + offset }
	l := end - start
	res := array{
		element_size: a.element_size
		data: data
		offset: a.offset + offset
		len: l
		cap: l
	}
	return res
}

// used internally for [2..4]
fn (a array) slice2(start int, _end int, end_max bool) array {
	end := if end_max { a.len } else { _end }
	return a.slice(start, end)
}

// `clone_static_to_depth()` returns an independent copy of a given array.
// Unlike `clone_to_depth()` it has a value receiver and is used internally
// for slice-clone expressions like `a[2..4].clone()` and in -autofree generated code.
fn (a array) clone_static_to_depth(depth int) array {
	return unsafe { a.clone_to_depth(depth) }
}

// clone returns an independent copy of a given array.
// this will be overwritten by `cgen` with an apropriate call to `.clone_to_depth()`
// However the `checker` needs it here.
pub fn (a &array) clone() array {
	return unsafe { a.clone_to_depth(0) }
}

// recursively clone given array - `unsafe` when called directly because depth is not checked
[unsafe]
pub fn (a &array) clone_to_depth(depth int) array {
	mut size := a.cap * a.element_size
	if size == 0 {
		size++
	}
	mut arr := array{
		element_size: a.element_size
		data: vcalloc(size)
		len: a.len
		cap: a.cap
	}
	// Recursively clone-generated elements if array element is array type
	if depth > 0 {
		for i in 0 .. a.len {
			ar := array{}
			unsafe { C.memcpy(&ar, a.get_unsafe(i), int(sizeof(array))) }
			ar_clone := unsafe { ar.clone_to_depth(depth - 1) }
			unsafe { arr.set_unsafe(i, &ar_clone) }
		}
		return arr
	} else {
		if !isnil(a.data) {
			unsafe { C.memcpy(&byte(arr.data), a.data, a.cap * a.element_size) }
		}
		return arr
	}
}

// we manually inline this for single operations for performance without -prod
[inline; unsafe]
fn (mut a array) set_unsafe(i int, val voidptr) {
	unsafe { C.memcpy(&byte(a.data) + a.element_size * i, val, a.element_size) }
}

// Private function. Used to implement assigment to the array element.
fn (mut a array) set(i int, val voidptr) {
	$if !no_bounds_checking ? {
		if i < 0 || i >= a.len {
			panic('array.set: index out of range (i == $i, a.len == $a.len)')
		}
	}
	unsafe { C.memcpy(&byte(a.data) + a.element_size * i, val, a.element_size) }
}

fn (mut a array) push(val voidptr) {
	a.ensure_cap(a.len + 1)
	unsafe { C.memmove(&byte(a.data) + a.element_size * a.len, val, a.element_size) }
	a.len++
}

// push_many implements the functionality for pushing another array.
// `val` is array.data and user facing usage is `a << [1,2,3]`
[unsafe]
pub fn (mut a3 array) push_many(val voidptr, size int) {
	if a3.data == val && !isnil(a3.data) {
		// handle `arr << arr`
		copy := a3.clone()
		a3.ensure_cap(a3.len + size)
		unsafe {
			// C.memcpy(a.data, copy.data, copy.element_size * copy.len)
			C.memcpy(a3.get_unsafe(a3.len), copy.data, a3.element_size * size)
		}
	} else {
		a3.ensure_cap(a3.len + size)
		if !isnil(a3.data) && !isnil(val) {
			unsafe { C.memcpy(a3.get_unsafe(a3.len), val, a3.element_size * size) }
		}
	}
	a3.len += size
}

// reverse_in_place reverses existing array data, modifying original array.
pub fn (mut a array) reverse_in_place() {
	if a.len < 2 {
		return
	}
	unsafe {
		mut tmp_value := malloc(a.element_size)
		for i in 0 .. a.len / 2 {
			C.memcpy(tmp_value, &byte(a.data) + i * a.element_size, a.element_size)
			C.memcpy(&byte(a.data) + i * a.element_size, &byte(a.data) +
				(a.len - 1 - i) * a.element_size, a.element_size)
			C.memcpy(&byte(a.data) + (a.len - 1 - i) * a.element_size, tmp_value, a.element_size)
		}
		free(tmp_value)
	}
}

// reverse returns a new array with the elements of the original array in reverse order.
pub fn (a array) reverse() array {
	if a.len < 2 {
		return a
	}
	mut arr := array{
		element_size: a.element_size
		data: vcalloc(a.cap * a.element_size)
		len: a.len
		cap: a.cap
	}
	for i in 0 .. a.len {
		unsafe { arr.set_unsafe(i, a.get_unsafe(a.len - 1 - i)) }
	}
	return arr
}

// pub fn (a []int) free() {
// free frees all memory occupied by the array.
[unsafe]
pub fn (a &array) free() {
	$if prealloc {
		return
	}
	// if a.is_slice {
	// return
	// }
	unsafe { free(&byte(a.data) - a.offset) }
}

[unsafe]
pub fn (mut a []string) free() {
	$if prealloc {
		return
	}
	for s in a {
		unsafe { s.free() }
	}
	unsafe { free(a.data) }
}

// str returns a string representation of the array of strings
// => '["a", "b", "c"]'.
[manualfree]
pub fn (a []string) str() string {
	mut sb := strings.new_builder(a.len * 3)
	sb.write_string('[')
	for i in 0 .. a.len {
		val := a[i]
		sb.write_string("'")
		sb.write_string(val)
		sb.write_string("'")
		if i < a.len - 1 {
			sb.write_string(', ')
		}
	}
	sb.write_string(']')
	res := sb.str()
	unsafe { sb.free() }
	return res
}

// hex returns a string with the hexadecimal representation
// of the byte elements of the array.
pub fn (b []byte) hex() string {
	mut hex := unsafe { malloc(b.len * 2 + 1) }
	mut dst_i := 0
	for i in b {
		n0 := i >> 4
		unsafe {
			hex[dst_i] = if n0 < 10 { n0 + `0` } else { n0 + byte(87) }
			dst_i++
		}
		n1 := i & 0xF
		unsafe {
			hex[dst_i] = if n1 < 10 { n1 + `0` } else { n1 + byte(87) }
			dst_i++
		}
	}
	unsafe {
		hex[dst_i] = 0
		return tos(hex, dst_i)
	}
}

// copy copies the `src` byte array elements to the `dst` byte array.
// The number of the elements copied is the minimum of the length of both arrays.
// Returns the number of elements copied.
// TODO: implement for all types
pub fn copy(dst []byte, src []byte) int {
	min := if dst.len < src.len { dst.len } else { src.len }
	if min > 0 {
		unsafe { C.memcpy(&byte(dst.data), src.data, min) }
	}
	return min
}

// Private function. Comparator for int type.
fn compare_ints(a &int, b &int) int {
	if *a < *b {
		return -1
	}
	if *a > *b {
		return 1
	}
	return 0
}

fn compare_ints_reverse(a &int, b &int) int {
	if *a > *b {
		return -1
	}
	if *a < *b {
		return 1
	}
	return 0
}

// sort sorts an array of int in place in ascending order.
pub fn (mut a []int) sort() {
	a.sort_with_compare(compare_ints)
}

// index returns the first index at which a given element can be found in the array
// or -1 if the value is not found.
pub fn (a []string) index(v string) int {
	for i in 0 .. a.len {
		if a[i] == v {
			return i
		}
	}
	return -1
}

// reduce executes a given reducer function on each element of the array,
// resulting in a single output value.
pub fn (a []int) reduce(iter fn (int, int) int, accum_start int) int {
	mut accum_ := accum_start
	for i in a {
		accum_ = iter(accum_, i)
	}
	return accum_
}

// grow_cap grows the array's capacity by `amount` elements.
pub fn (mut a array) grow_cap(amount int) {
	a.ensure_cap(a.cap + amount)
}

// grow_len ensures that an array has a.len + amount of length
[unsafe]
pub fn (mut a array) grow_len(amount int) {
	a.ensure_cap(a.len + amount)
	a.len += amount
}

// eq checks if the arrays have the same elements or not.
// TODO: make it work with all types.
pub fn (a1 []string) eq(a2 []string) bool {
	// return array_eq(a, a2)
	if a1.len != a2.len {
		return false
	}
	size_of_string := int(sizeof(string))
	for i in 0 .. a1.len {
		offset := i * size_of_string
		s1 := unsafe { &string(&byte(a1.data) + offset) }
		s2 := unsafe { &string(&byte(a2.data) + offset) }
		if *s1 != *s2 {
			return false
		}
	}
	return true
}

// pointers returns a new array, where each element
// is the address of the corresponding element in the array.
[unsafe]
pub fn (a array) pointers() []voidptr {
	mut res := []voidptr{}
	for i in 0 .. a.len {
		unsafe { res << a.get_unsafe(i) }
	}
	return res
}

// voidptr.vbytes() - makes a V []byte structure from a C style memory buffer. NB: the data is reused, NOT copied!
[unsafe]
pub fn (data voidptr) vbytes(len int) []byte {
	res := array{
		element_size: 1
		data: data
		len: len
		cap: len
	}
	return res
}

// byteptr.vbytes() - makes a V []byte structure from a C style memory buffer. NB: the data is reused, NOT copied!
[unsafe]
pub fn (data &byte) vbytes(len int) []byte {
	return unsafe { voidptr(data).vbytes(len) }
}
