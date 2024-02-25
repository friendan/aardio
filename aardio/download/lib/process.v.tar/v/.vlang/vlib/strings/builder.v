// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.
module strings

// strings.Builder is used to efficiently append many strings to a large
// dynamically growing buffer, then use the resulting large string. Using
// a string builder is much better for performance/memory usage than doing
// constantly string concatenation.
pub type Builder = []byte

// new_builder returns a new string builder, with an initial capacity of `initial_size`
pub fn new_builder(initial_size int) Builder {
	return Builder([]byte{cap: initial_size})
}

// write_ptr writes `len` bytes provided byteptr to the accumulated buffer
[unsafe]
pub fn (mut b Builder) write_ptr(ptr &byte, len int) {
	if len == 0 {
		return
	}
	unsafe { b.push_many(ptr, len) }
}

// write_b appends a single `data` byte to the accumulated buffer
pub fn (mut b Builder) write_b(data byte) {
	b << data
}

// write implements the Writer interface
pub fn (mut b Builder) write(data []byte) ?int {
	if data.len == 0 {
		return 0
	}
	b << data
	return data.len
}

[inline]
pub fn (b &Builder) byte_at(n int) byte {
	return unsafe { (&[]byte(b))[n] }
}

// write appends the string `s` to the buffer
[inline]
pub fn (mut b Builder) write_string(s string) {
	if s.len == 0 {
		return
	}
	unsafe { b.push_many(s.str, s.len) }
	// for c in s {
	// b.buf << c
	// }
	// b.buf << []byte(s)  // TODO
}

// go_back discards the last `n` bytes from the buffer
pub fn (mut b Builder) go_back(n int) {
	b.trim(b.len - n)
}

// cut_last cuts the last `n` bytes from the buffer and returns them
pub fn (mut b Builder) cut_last(n int) string {
	cut_pos := b.len - n
	x := unsafe { (&[]byte(b))[cut_pos..] }
	res := x.bytestr()
	b.trim(cut_pos)
	return res
}

// cut_to cuts the string after `pos` and returns it.
// if `pos` is superior to builder length, returns an empty string
// and cancel further operations
pub fn (mut b Builder) cut_to(pos int) string {
	if pos > b.len {
		return ''
	}
	return b.cut_last(b.len - pos)
}

// go_back_to resets the buffer to the given position `pos`
// NB: pos should be < than the existing buffer length.
pub fn (mut b Builder) go_back_to(pos int) {
	b.trim(pos)
}

// writeln appends the string `s`, and then a newline character.
[inline]
pub fn (mut b Builder) writeln(s string) {
	// for c in s {
	// b.buf << c
	// }
	if s.len > 0 {
		unsafe { b.push_many(s.str, s.len) }
	}
	// b.buf << []byte(s)  // TODO
	b << byte(`\n`)
}

// buf == 'hello world'
// last_n(5) returns 'world'
pub fn (b &Builder) last_n(n int) string {
	if n > b.len {
		return ''
	}
	x := unsafe { (&[]byte(b))[b.len - n..] }
	return x.bytestr()
}

// buf == 'hello world'
// after(6) returns 'world'
pub fn (b &Builder) after(n int) string {
	if n >= b.len {
		return ''
	}
	x := unsafe { (&[]byte(b))[n..] }
	return x.bytestr()
}

// str returns a copy of all of the accumulated buffer content.
// NB: after a call to b.str(), the builder b should not be
// used again, you need to call b.free() first, or just leave
// it to be freed by -autofree when it goes out of scope.
// The returned string *owns* its own separate copy of the
// accumulated data that was in the string builder, before the
// .str() call.
pub fn (mut b Builder) str() string {
	b << byte(0)
	bcopy := unsafe { &byte(memdup(b.data, b.len)) }
	s := unsafe { bcopy.vstring_with_len(b.len - 1) }
	b.trim(0)
	return s
}

// free - manually free the contents of the buffer
[unsafe]
pub fn (mut b Builder) free() {
	unsafe { free(b.data) }
}
