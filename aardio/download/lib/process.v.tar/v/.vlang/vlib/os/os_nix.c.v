module os

import strings

#include <dirent.h>
#include <unistd.h>
#include <fcntl.h>
#include <sys/utsname.h>

pub const (
	path_separator = '/'
	path_delimiter = ':'
)

const (
	stdin_value  = 0
	stdout_value = 1
	stderr_value = 2
)

// (Must be realized in Syscall) (Must be specified)
// ref: http://www.ccfit.nsu.ru/~deviv/courses/unix/unix/ng7c229.html
pub const (
	s_ifmt  = 0xF000 // type of file
	s_ifdir = 0x4000 // directory
	s_iflnk = 0xa000 // link
	s_isuid = 0o4000 // SUID
	s_isgid = 0o2000 // SGID
	s_isvtx = 0o1000 // Sticky
	s_irusr = 0o0400 // Read by owner
	s_iwusr = 0o0200 // Write by owner
	s_ixusr = 0o0100 // Execute by owner
	s_irgrp = 0o0040 // Read by group
	s_iwgrp = 0o0020 // Write by group
	s_ixgrp = 0o0010 // Execute by group
	s_iroth = 0o0004 // Read by others
	s_iwoth = 0o0002 // Write by others
	s_ixoth = 0o0001 // Execute by others
)

struct C.utsname {
mut:
	sysname  &char
	nodename &char
	release  &char
	version  &char
	machine  &char
}

fn C.uname(name voidptr) int

fn C.symlink(&char, &char) int

fn C.link(&char, &char) int

fn C.gethostname(&char, int) int

// NB: not available on Android fn C.getlogin_r(&char, int) int
fn C.getlogin() &char

fn C.getppid() int

fn C.getgid() int

fn C.getegid() int

pub fn uname() Uname {
	mut u := Uname{}
	utsize := sizeof(C.utsname)
	unsafe {
		x := malloc_noscan(int(utsize))
		d := &C.utsname(x)
		if C.uname(d) == 0 {
			u.sysname = cstring_to_vstring(d.sysname)
			u.nodename = cstring_to_vstring(d.nodename)
			u.release = cstring_to_vstring(d.release)
			u.version = cstring_to_vstring(d.version)
			u.machine = cstring_to_vstring(d.machine)
		}
		free(d)
	}
	return u
}

pub fn hostname() string {
	mut hstnme := ''
	size := 256
	mut buf := unsafe { &char(malloc_noscan(size)) }
	if C.gethostname(buf, size) == 0 {
		hstnme = unsafe { cstring_to_vstring(buf) }
		unsafe { free(buf) }
		return hstnme
	}
	return ''
}

pub fn loginname() string {
	x := C.getlogin()
	if !isnil(x) {
		return unsafe { cstring_to_vstring(x) }
	}
	return ''
}

fn init_os_args(argc int, argv &&byte) []string {
	mut args_ := []string{}
	// mut args := []string(make(0, argc, sizeof(string)))
	// mut args := []string{len:argc}
	for i in 0 .. argc {
		// args [i] = argv[i].vstring()
		unsafe { args_ << (&byte(argv[i])).vstring_literal() }
	}
	return args_
}

pub fn ls(path string) ?[]string {
	mut res := []string{}
	dir := unsafe { C.opendir(&char(path.str)) }
	if isnil(dir) {
		return error('ls() couldnt open dir "$path"')
	}
	mut ent := &C.dirent(0)
	// mut ent := &C.dirent{!}
	for {
		ent = C.readdir(dir)
		if isnil(ent) {
			break
		}
		unsafe {
			bptr := &byte(&ent.d_name[0])
			if bptr[0] == 0 || (bptr[0] == `.` && bptr[1] == 0)
				|| (bptr[0] == `.` && bptr[1] == `.` && bptr[2] == 0) {
				continue
			}
			res << tos_clone(bptr)
		}
	}
	C.closedir(dir)
	return res
}

/*
pub fn is_dir(path string) bool {
	//$if linux {
		//C.syscall(4, path.str) // sys_newstat
	//}
	dir := C.opendir(path.str)
	res := !isnil(dir)
	if res {
		C.closedir(dir)
	}
	return res
}
*/
/*
pub fn (mut f File) fseek(pos, mode int) {
}
*/
// mkdir creates a new directory with the specified path.
pub fn mkdir(path string) ?bool {
	if path == '.' {
		return true
	}
	/*
	mut k := 0
	defer {
		k = 1
	}
	*/
	apath := real_path(path)
	// defer {
	// apath.free()
	//}
	/*
	$if linux {
		$if !android {
			ret := C.syscall(sys_mkdir, apath.str, 511)
			if ret == -1 {
				return error(posix_get_error_msg(C.errno))
			}
			return true
		}
	}
	*/
	r := unsafe { C.mkdir(&char(apath.str), 511) }
	if r == -1 {
		return error(posix_get_error_msg(C.errno))
	}
	return true
}

// execute starts the specified command, waits for it to complete, and returns its output.
[manualfree]
pub fn execute(cmd string) Result {
	// if cmd.contains(';') || cmd.contains('&&') || cmd.contains('||') || cmd.contains('\n') {
	// return Result{ exit_code: -1, output: ';, &&, || and \\n are not allowed in shell commands' }
	// }
	pcmd := '$cmd 2>&1'
	f := vpopen(pcmd)
	if isnil(f) {
		return Result{
			exit_code: -1
			output: 'exec("$cmd") failed'
		}
	}
	buf := unsafe { malloc_noscan(4096) }
	mut res := strings.new_builder(1024)
	defer {
		unsafe { res.free() }
	}
	unsafe {
		bufbp := buf
		for C.fgets(&char(bufbp), 4096, f) != 0 {
			buflen := vstrlen(bufbp)
			res.write_ptr(bufbp, buflen)
		}
	}
	soutput := res.str()
	exit_code := vpclose(f)
	unsafe { free(buf) }
	return Result{
		exit_code: exit_code
		output: soutput
	}
}

pub struct Command {
mut:
	f voidptr
pub mut:
	eof bool
pub:
	path            string
	redirect_stdout bool
}

[manualfree]
pub fn (mut c Command) start() ? {
	pcmd := c.path + ' 2>&1'
	defer {
		unsafe { pcmd.free() }
	}
	c.f = vpopen(pcmd)
	if isnil(c.f) {
		return error('exec("$c.path") failed')
	}
}

[manualfree]
pub fn (mut c Command) read_line() string {
	buf := [4096]byte{}
	mut res := strings.new_builder(1024)
	defer {
		unsafe { res.free() }
	}
	unsafe {
		bufbp := &buf[0]
		for C.fgets(&char(bufbp), 4096, c.f) != 0 {
			len := vstrlen(bufbp)
			for i in 0 .. len {
				if bufbp[i] == `\n` {
					res.write_ptr(bufbp, i)
					final := res.str()
					return final
				}
			}
			res.write_ptr(bufbp, len)
		}
	}
	c.eof = true
	final := res.str()
	return final
}

pub fn (c &Command) close() ? {
	exit_code := vpclose(c.f)
	if exit_code == 127 {
		return error_with_code('error', 127)
	}
}

pub fn symlink(origin string, target string) ?bool {
	res := C.symlink(&char(origin.str), &char(target.str))
	if res == 0 {
		return true
	}
	return error(posix_get_error_msg(C.errno))
}

pub fn link(origin string, target string) ?bool {
	res := C.link(&char(origin.str), &char(target.str))
	if res == 0 {
		return true
	}
	return error(posix_get_error_msg(C.errno))
}

// get_error_msg return error code representation in string.
pub fn get_error_msg(code int) string {
	return posix_get_error_msg(code)
}

pub fn (mut f File) close() {
	if !f.is_opened {
		return
	}
	f.is_opened = false
	/*
	$if linux {
		$if !android {
			C.syscall(sys_close, f.fd)
			return
		}
	}
	*/
	C.fflush(f.cfile)
	C.fclose(f.cfile)
}

pub fn debugger_present() bool {
	return false
}

fn C.mkstemp(stemplate &byte) int

// `is_writable_folder` - `folder` exists and is writable to the process
pub fn is_writable_folder(folder string) ?bool {
	if !exists(folder) {
		return error('`$folder` does not exist')
	}
	if !is_dir(folder) {
		return error('`folder` is not a folder')
	}
	tmp_perm_check := join_path(folder, 'XXXXXX')
	unsafe {
		x := C.mkstemp(&char(tmp_perm_check.str))
		if -1 == x {
			return error('folder `$folder` is not writable')
		}
		C.close(x)
	}
	rm(tmp_perm_check) ?
	return true
}

[inline]
pub fn getpid() int {
	return C.getpid()
}

[inline]
pub fn getppid() int {
	return C.getppid()
}

[inline]
pub fn getuid() int {
	return C.getuid()
}

[inline]
pub fn geteuid() int {
	return C.geteuid()
}

[inline]
pub fn getgid() int {
	return C.getgid()
}

[inline]
pub fn getegid() int {
	return C.getegid()
}

// Turns the given bit on or off, depending on the `enable` parameter
pub fn posix_set_permission_bit(path_s string, mode u32, enable bool) {
	mut s := C.stat{}
	mut new_mode := u32(0)
	path := &char(path_s.str)
	unsafe {
		C.stat(path, &s)
		new_mode = s.st_mode
	}
	match enable {
		true { new_mode |= mode }
		false { new_mode &= (0o7777 - mode) }
	}
	C.chmod(path, int(new_mode))
}
