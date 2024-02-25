module hash

//#flag -I @VEXEROOT/thirdparty/wyhash
//#include "wyhash.h"
fn C.wyhash(&byte, u64, u64, &u64) u64

fn C.wyhash64(u64, u64) u64

[inline]
pub fn wyhash_c(key &byte, len u64, seed u64) u64 {
	return C.wyhash(key, len, seed, &u64(C._wyp))
}

[inline]
pub fn wyhash64_c(a u64, b u64) u64 {
	return C.wyhash64(a, b)
}
