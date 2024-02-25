module os

pub struct File {
	cfile voidptr // Using void* instead of FILE*
pub:
	fd int
pub mut:
	is_opened bool
}

struct FileInfo {
	name string
	size int
}

fn C.fseeko(&C.FILE, u64, int) int

fn C._fseeki64(&C.FILE, u64, int) int

fn C.getc(&C.FILE) int

// open_file can be used to open or create a file with custom flags and permissions and returns a `File` object.
pub fn open_file(path string, mode string, options ...int) ?File {
	mut flags := 0
	for m in mode {
		match m {
			`w` { flags |= o_create | o_trunc }
			`a` { flags |= o_create | o_append }
			`r` { flags |= o_rdonly }
			`b` { flags |= o_binary }
			`s` { flags |= o_sync }
			`n` { flags |= o_nonblock }
			`c` { flags |= o_noctty }
			`+` { flags |= o_rdwr }
			else {}
		}
	}
	if mode == 'r+' {
		flags = o_rdwr
	}
	if mode == 'w' {
		flags = o_wronly | o_create | o_trunc
	}
	if mode == 'a' {
		flags = o_wronly | o_create | o_append
	}
	mut permission := 0o666
	if options.len > 0 {
		permission = options[0]
	}
	$if windows {
		if permission < 0o600 {
			permission = 0x0100
		} else {
			permission = 0x0100 | 0x0080
		}
	}
	mut p := path
	$if windows {
		p = path.replace('/', '\\')
	}
	fd := C.open(&char(p.str), flags, permission)
	if fd == -1 {
		return error(posix_get_error_msg(C.errno))
	}
	cfile := C.fdopen(fd, &char(mode.str))
	if isnil(cfile) {
		return error('Failed to open or create file "$path"')
	}
	return File{
		cfile: cfile
		fd: fd
		is_opened: true
	}
}

// open tries to open a file for reading and returns back a read-only `File` object.
pub fn open(path string) ?File {
	/*
	$if linux {
		$if !android {
			fd := C.syscall(sys_open, path.str, 511)
			if fd == -1 {
				return error('failed to open file "$path"')
			}
			return File{
				fd: fd
				is_opened: true
			}
		}
	}
	*/
	cfile := vfopen(path, 'rb') ?
	fd := fileno(cfile)
	return File{
		cfile: cfile
		fd: fd
		is_opened: true
	}
}

// create creates or opens a file at a specified location and returns a write-only `File` object.
pub fn create(path string) ?File {
	/*
	// NB: android/termux/bionic is also a kind of linux,
	// but linux syscalls there sometimes fail,
	// while the libc version should work.
	$if linux {
		$if !android {
			//$if macos {
			//	fd = C.syscall(398, path.str, 0x601, 0x1b6)
			//}
			//$if linux {
			fd = C.syscall(sys_creat, path.str, 511)
			//}
			if fd == -1 {
				return error('failed to create file "$path"')
			}
			file = File{
				fd: fd
				is_opened: true
			}
			return file
		}
	}
	*/
	cfile := vfopen(path, 'wb') ?
	fd := fileno(cfile)
	return File{
		cfile: cfile
		fd: fd
		is_opened: true
	}
}

[deprecated: 'use os.stdin() instead']
[deprecated_after: '2021-05-17']
pub fn open_stdin() File {
	return stdin()
}

// stdin - return an os.File for stdin, so that you can use .get_line on it too.
pub fn stdin() File {
	return File{
		fd: 0
		cfile: C.stdin
		is_opened: true
	}
}

// stdout - return an os.File for stdout
pub fn stdout() File {
	return File{
		fd: 1
		cfile: C.stdout
		is_opened: true
	}
}

// stderr - return an os.File for stderr
pub fn stderr() File {
	return File{
		fd: 2
		cfile: C.stderr
		is_opened: true
	}
}

// read implements the Reader interface.
pub fn (f &File) read(mut buf []byte) ?int {
	if buf.len == 0 {
		return 0
	}
	nbytes := fread(buf.data, 1, buf.len, f.cfile) ?
	return nbytes
}

// **************************** Write ops  ***************************
// write implements the Writer interface.
// It returns how many bytes were actually written.
pub fn (mut f File) write(buf []byte) ?int {
	if !f.is_opened {
		return error('file is not opened')
	}
	/*
	$if linux {
		$if !android {
			res := C.syscall(sys_write, f.fd, s.str, s.len)
			return res
		}
	}
	*/
	written := int(C.fwrite(buf.data, 1, buf.len, f.cfile))
	if written == 0 && buf.len != 0 {
		return error('0 bytes written')
	}
	return written
}

// writeln writes the string `s` into the file, and appends a \n character.
// It returns how many bytes were written, including the \n character.
pub fn (mut f File) writeln(s string) ?int {
	if !f.is_opened {
		return error('file is not opened')
	}
	/*
	$if linux {
		$if !android {
			snl := s + '\n'
			C.syscall(sys_write, f.fd, snl.str, snl.len)
			return
		}
	}
	*/
	// TODO perf
	written := int(C.fwrite(s.str, 1, s.len, f.cfile))
	if written == 0 && s.len != 0 {
		return error('0 bytes written')
	}
	x := C.fputs(c'\n', f.cfile)
	if x < 0 {
		return error('could not add newline')
	}
	return (written + 1)
}

// write_string writes the string `s` into the file
// It returns how many bytes were actually written.
pub fn (mut f File) write_string(s string) ?int {
	if !f.is_opened {
		return error('file is not opened')
	}
	// TODO perf
	written := int(C.fwrite(s.str, 1, s.len, f.cfile))
	if written == 0 && s.len != 0 {
		return error('0 bytes written')
	}
	return written
}

// write_to implements the RandomWriter interface.
// It returns how many bytes were actually written.
// It resets the seek position to the end of the file.
pub fn (mut f File) write_to(pos u64, buf []byte) ?int {
	if !f.is_opened {
		return error('file is not opened')
	}
	$if x64 {
		$if windows {
			C._fseeki64(f.cfile, pos, C.SEEK_SET)
			res := int(C.fwrite(buf.data, 1, buf.len, f.cfile))
			if res == 0 && buf.len != 0 {
				return error('0 bytes written')
			}
			C._fseeki64(f.cfile, 0, C.SEEK_END)
			return res
		} $else {
			C.fseeko(f.cfile, pos, C.SEEK_SET)
			res := int(C.fwrite(buf.data, 1, buf.len, f.cfile))
			if res == 0 && buf.len != 0 {
				return error('0 bytes written')
			}
			C.fseeko(f.cfile, 0, C.SEEK_END)
			return res
		}
	}
	$if x32 {
		C.fseek(f.cfile, pos, C.SEEK_SET)
		res := int(C.fwrite(buf.data, 1, buf.len, f.cfile))
		if res == 0 && buf.len != 0 {
			return error('0 bytes written')
		}
		C.fseek(f.cfile, 0, C.SEEK_END)
		return res
	}
	return error('Could not write to file')
}

// write_bytes writes `size` bytes to the file, starting from the address in `data`.
// NB: write_bytes is unsafe and should be used carefully, since if you pass invalid
// pointers to it, it will cause your programs to segfault.
[deprecated: 'use File.write_ptr()']
[unsafe]
pub fn (mut f File) write_bytes(data voidptr, size int) int {
	return unsafe { f.write_ptr(data, size) }
}

// write_bytes_at writes `size` bytes to the file, starting from the address in `data`,
// at byte offset `pos`, counting from the start of the file (pos 0).
// NB: write_bytes_at is unsafe and should be used carefully, since if you pass invalid
// pointers to it, it will cause your programs to segfault.
[deprecated: 'use File.write_ptr_at() instead']
[unsafe]
pub fn (mut f File) write_bytes_at(data voidptr, size int, pos u64) int {
	return unsafe { f.write_ptr_at(data, size, pos) }
}

// write_ptr writes `size` bytes to the file, starting from the address in `data`.
// NB: write_ptr is unsafe and should be used carefully, since if you pass invalid
// pointers to it, it will cause your programs to segfault.
[unsafe]
pub fn (mut f File) write_ptr(data voidptr, size int) int {
	return int(C.fwrite(data, 1, size, f.cfile))
}

// write_ptr_at writes `size` bytes to the file, starting from the address in `data`,
// at byte offset `pos`, counting from the start of the file (pos 0).
// NB: write_ptr_at is unsafe and should be used carefully, since if you pass invalid
// pointers to it, it will cause your programs to segfault.
[unsafe]
pub fn (mut f File) write_ptr_at(data voidptr, size int, pos u64) int {
	$if x64 {
		$if windows {
			C._fseeki64(f.cfile, pos, C.SEEK_SET)
			res := int(C.fwrite(data, 1, size, f.cfile))
			C._fseeki64(f.cfile, 0, C.SEEK_END)
			return res
		} $else {
			C.fseeko(f.cfile, pos, C.SEEK_SET)
			res := int(C.fwrite(data, 1, size, f.cfile))
			C.fseeko(f.cfile, 0, C.SEEK_END)
			return res
		}
	}
	$if x32 {
		C.fseek(f.cfile, pos, C.SEEK_SET)
		res := int(C.fwrite(data, 1, size, f.cfile))
		C.fseek(f.cfile, 0, C.SEEK_END)
		return res
	}
	return 0
}

// **************************** Read ops  ***************************

// fread wraps C.fread and handles error and end-of-file detection.
fn fread(ptr voidptr, item_size int, items int, stream &C.FILE) ?int {
	nbytes := int(C.fread(ptr, item_size, items, stream))
	// If no bytes were read, check for errors and end-of-file.
	if nbytes <= 0 {
		// If fread encountered end-of-file return the none error. Note that fread
		// may read data and encounter the end-of-file, but we shouldn't return none
		// in that case which is why we only check for end-of-file if no data was
		// read. The caller will get none on their next call because there will be
		// no data available and the end-of-file will be encountered again.
		if C.feof(stream) != 0 {
			return none
		}
		// If fread encountered an error, return it. Note that fread and ferror do
		// not tell us what the error was, so we can't return anything more specific
		// than there was an error. This is because fread and ferror do not set
		// errno.
		if C.ferror(stream) != 0 {
			return error('file read error')
		}
	}
	return nbytes
}

// read_bytes reads bytes from the beginning of the file.
// Utility method, same as .read_bytes_at(size, 0).
pub fn (f &File) read_bytes(size int) []byte {
	return f.read_bytes_at(size, 0)
}

// read_bytes_at reads `size` bytes at the given position in the file.
pub fn (f &File) read_bytes_at(size int, pos u64) []byte {
	mut arr := []byte{len: size}
	nreadbytes := f.read_bytes_into(pos, mut arr) or {
		// return err
		return []
	}
	return arr[0..nreadbytes]
}

// read_bytes_into_newline reads from the beginning of the file into the provided buffer.
// Each consecutive call on the same file continues reading where it previously ended.
// A read call is either stopped, if the buffer is full, a newline was read or EOF.
pub fn (f &File) read_bytes_into_newline(mut buf []byte) ?int {
	if buf.len == 0 {
		panic(@FN + ': `buf.len` == 0')
	}
	newline := 10
	mut c := 0
	mut buf_ptr := 0
	mut nbytes := 0

	stream := &C.FILE(f.cfile)
	for (buf_ptr < buf.len) {
		c = C.getc(stream)
		match c {
			C.EOF {
				if C.feof(stream) != 0 {
					return nbytes
				}
				if C.ferror(stream) != 0 {
					return error('file read error')
				}
			}
			newline {
				buf[buf_ptr] = byte(c)
				nbytes++
				return nbytes
			}
			else {
				buf[buf_ptr] = byte(c)
				buf_ptr++
				nbytes++
			}
		}
	}
	return nbytes
}

// read_bytes_into fills `buf` with bytes at the given position in the file.
// `buf` *must* have length greater than zero.
// Returns the number of read bytes, or an error.
pub fn (f &File) read_bytes_into(pos u64, mut buf []byte) ?int {
	if buf.len == 0 {
		panic(@FN + ': `buf.len` == 0')
	}
	$if x64 {
		$if windows {
			// Note: fseek errors if pos == os.file_size, which we accept
			C._fseeki64(f.cfile, pos, C.SEEK_SET)
			nbytes := fread(buf.data, 1, buf.len, f.cfile) ?
			$if debug {
				C._fseeki64(f.cfile, 0, C.SEEK_SET)
			}
			return nbytes
		} $else {
			C.fseeko(f.cfile, pos, C.SEEK_SET)
			nbytes := fread(buf.data, 1, buf.len, f.cfile) ?
			$if debug {
				C.fseeko(f.cfile, 0, C.SEEK_SET)
			}
			return nbytes
		}
	}
	$if x32 {
		C.fseek(f.cfile, pos, C.SEEK_SET)
		nbytes := fread(buf.data, 1, buf.len, f.cfile) ?
		$if debug {
			C.fseek(f.cfile, 0, C.SEEK_SET)
		}
		return nbytes
	}
	return error('Could not read file')
}

// read_at reads `buf.len` bytes starting at file byte offset `pos`, in `buf`.
[deprecated: 'use File.read_from() instead']
pub fn (f &File) read_at(pos u64, mut buf []byte) ?int {
	return f.read_from(pos, mut buf)
}

// read_from implements the RandomReader interface.
pub fn (f &File) read_from(pos u64, mut buf []byte) ?int {
	if buf.len == 0 {
		return 0
	}
	$if x64 {
		$if windows {
			C._fseeki64(f.cfile, pos, C.SEEK_SET)
		} $else {
			C.fseeko(f.cfile, pos, C.SEEK_SET)
		}

		nbytes := fread(buf.data, 1, buf.len, f.cfile) ?
		return nbytes
	}
	$if x32 {
		C.fseek(f.cfile, pos, C.SEEK_SET)
		nbytes := fread(buf.data, 1, buf.len, f.cfile) ?
		return nbytes
	}
	return error('Could not read file')
}

// **************************** Utility  ops ***********************
// flush writes any buffered unwritten data left in the file stream.
pub fn (mut f File) flush() {
	if !f.is_opened {
		return
	}
	C.fflush(f.cfile)
}

// write_str writes the bytes of a string into a file,
// *including* the terminating 0 byte.
[deprecated: 'use File.write_string() instead']
pub fn (mut f File) write_str(s string) ? {
	f.write_string(s) or { return err }
}

pub struct ErrFileNotOpened {
	msg  string = 'os: file not opened'
	code int
}

pub struct ErrSizeOfTypeIs0 {
	msg  string = 'os: size of type is 0'
	code int
}

fn error_file_not_opened() IError {
	return IError(&ErrFileNotOpened{})
}

fn error_size_of_type_0() IError {
	return IError(&ErrSizeOfTypeIs0{})
}

// read_struct reads a single struct of type `T`
pub fn (mut f File) read_struct<T>(mut t T) ? {
	if !f.is_opened {
		return error_file_not_opened()
	}
	tsize := int(sizeof(*t))
	if tsize == 0 {
		return error_size_of_type_0()
	}
	nbytes := fread(t, 1, tsize, f.cfile) ?
	if nbytes != tsize {
		return error_with_code('incomplete struct read', nbytes)
	}
}

// read_struct_at reads a single struct of type `T` at position specified in file
pub fn (mut f File) read_struct_at<T>(mut t T, pos u64) ? {
	if !f.is_opened {
		return error_file_not_opened()
	}
	tsize := int(sizeof(*t))
	if tsize == 0 {
		return error_size_of_type_0()
	}
	mut nbytes := 0
	$if x64 {
		$if windows {
			C._fseeki64(f.cfile, pos, C.SEEK_SET)
			nbytes = fread(t, 1, tsize, f.cfile) ?
			C._fseeki64(f.cfile, 0, C.SEEK_END)
		} $else {
			C.fseeko(f.cfile, pos, C.SEEK_SET)
			nbytes = fread(t, 1, tsize, f.cfile) ?
			C.fseeko(f.cfile, 0, C.SEEK_END)
		}
	}
	$if x32 {
		C.fseek(f.cfile, pos, C.SEEK_SET)
		nbytes = fread(t, 1, tsize, f.cfile) ?
		C.fseek(f.cfile, 0, C.SEEK_END)
	}
	if nbytes != tsize {
		return error_with_code('incomplete struct read', nbytes)
	}
}

// read_raw reads and returns a single instance of type `T`
pub fn (mut f File) read_raw<T>() ?T {
	if !f.is_opened {
		return error_file_not_opened()
	}
	tsize := int(sizeof(T))
	if tsize == 0 {
		return error_size_of_type_0()
	}
	mut t := T{}
	nbytes := fread(&t, 1, tsize, f.cfile) ?
	if nbytes != tsize {
		return error_with_code('incomplete struct read', nbytes)
	}
	return t
}

// read_raw_at reads and returns a single instance of type `T` starting at file byte offset `pos`
pub fn (mut f File) read_raw_at<T>(pos u64) ?T {
	if !f.is_opened {
		return error_file_not_opened()
	}
	tsize := int(sizeof(T))
	if tsize == 0 {
		return error_size_of_type_0()
	}
	mut nbytes := 0
	mut t := T{}
	$if x64 {
		$if windows {
			if C._fseeki64(f.cfile, pos, C.SEEK_SET) != 0 {
				return error(posix_get_error_msg(C.errno))
			}
			nbytes = fread(&t, 1, tsize, f.cfile) ?
			if C._fseeki64(f.cfile, 0, C.SEEK_END) != 0 {
				return error(posix_get_error_msg(C.errno))
			}
		} $else {
			if C.fseeko(f.cfile, pos, C.SEEK_SET) != 0 {
				return error(posix_get_error_msg(C.errno))
			}
			nbytes = fread(&t, 1, tsize, f.cfile) ?
			if C.fseeko(f.cfile, 0, C.SEEK_END) != 0 {
				return error(posix_get_error_msg(C.errno))
			}
		}
	}
	$if x32 {
		if C.fseek(f.cfile, pos, C.SEEK_SET) != 0 {
			return error(posix_get_error_msg(C.errno))
		}
		nbytes = fread(&t, 1, tsize, f.cfile) ?
		if C.fseek(f.cfile, 0, C.SEEK_END) != 0 {
			return error(posix_get_error_msg(C.errno))
		}
	}

	if nbytes != tsize {
		return error_with_code('incomplete struct read', nbytes)
	}
	return t
}

// write_struct writes a single struct of type `T`
pub fn (mut f File) write_struct<T>(t &T) ? {
	if !f.is_opened {
		return error_file_not_opened()
	}
	tsize := int(sizeof(T))
	if tsize == 0 {
		return error_size_of_type_0()
	}
	C.errno = 0
	nbytes := int(C.fwrite(t, 1, tsize, f.cfile))
	if C.errno != 0 {
		return error(posix_get_error_msg(C.errno))
	}
	if nbytes != tsize {
		return error_with_code('incomplete struct write', nbytes)
	}
}

// write_struct_at writes a single struct of type `T` at position specified in file
pub fn (mut f File) write_struct_at<T>(t &T, pos u64) ? {
	if !f.is_opened {
		return error_file_not_opened()
	}
	tsize := int(sizeof(T))
	if tsize == 0 {
		return error_size_of_type_0()
	}
	C.errno = 0
	mut nbytes := 0
	$if x64 {
		$if windows {
			C._fseeki64(f.cfile, pos, C.SEEK_SET)
			nbytes = int(C.fwrite(t, 1, tsize, f.cfile))
			C._fseeki64(f.cfile, 0, C.SEEK_END)
		} $else {
			C.fseeko(f.cfile, pos, C.SEEK_SET)
			nbytes = int(C.fwrite(t, 1, tsize, f.cfile))
			C.fseeko(f.cfile, 0, C.SEEK_END)
		}
	}
	$if x32 {
		C.fseek(f.cfile, pos, C.SEEK_SET)
		nbytes = int(C.fwrite(t, 1, tsize, f.cfile))
		C.fseek(f.cfile, 0, C.SEEK_END)
	}
	if C.errno != 0 {
		return error(posix_get_error_msg(C.errno))
	}
	if nbytes != tsize {
		return error_with_code('incomplete struct write', nbytes)
	}
}

// TODO `write_raw[_at]` implementations are copy-pasted from `write_struct[_at]`

// write_raw writes a single instance of type `T`
pub fn (mut f File) write_raw<T>(t &T) ? {
	if !f.is_opened {
		return error_file_not_opened()
	}
	tsize := int(sizeof(T))
	if tsize == 0 {
		return error_size_of_type_0()
	}
	C.errno = 0
	nbytes := int(C.fwrite(t, 1, tsize, f.cfile))
	if C.errno != 0 {
		return error(posix_get_error_msg(C.errno))
	}
	if nbytes != tsize {
		return error_with_code('incomplete struct write', nbytes)
	}
}

// write_raw_at writes a single instance of type `T` starting at file byte offset `pos`
pub fn (mut f File) write_raw_at<T>(t &T, pos u64) ? {
	if !f.is_opened {
		return error_file_not_opened()
	}
	tsize := int(sizeof(T))
	if tsize == 0 {
		return error_size_of_type_0()
	}
	mut nbytes := 0

	$if x64 {
		$if windows {
			if C._fseeki64(f.cfile, pos, C.SEEK_SET) != 0 {
				return error(posix_get_error_msg(C.errno))
			}
			nbytes = int(C.fwrite(t, 1, tsize, f.cfile))
			if C.errno != 0 {
				return error(posix_get_error_msg(C.errno))
			}
			if C._fseeki64(f.cfile, 0, C.SEEK_END) != 0 {
				return error(posix_get_error_msg(C.errno))
			}
		} $else {
			if C.fseeko(f.cfile, pos, C.SEEK_SET) != 0 {
				return error(posix_get_error_msg(C.errno))
			}
			nbytes = int(C.fwrite(t, 1, tsize, f.cfile))
			if C.errno != 0 {
				return error(posix_get_error_msg(C.errno))
			}
			if C.fseeko(f.cfile, 0, C.SEEK_END) != 0 {
				return error(posix_get_error_msg(C.errno))
			}
		}
	}
	$if x32 {
		if C.fseek(f.cfile, pos, C.SEEK_SET) != 0 {
			return error(posix_get_error_msg(C.errno))
		}
		nbytes = int(C.fwrite(t, 1, tsize, f.cfile))
		if C.errno != 0 {
			return error(posix_get_error_msg(C.errno))
		}
		if C.fseek(f.cfile, 0, C.SEEK_END) != 0 {
			return error(posix_get_error_msg(C.errno))
		}
	}

	if nbytes != tsize {
		return error_with_code('incomplete struct write', nbytes)
	}
}
