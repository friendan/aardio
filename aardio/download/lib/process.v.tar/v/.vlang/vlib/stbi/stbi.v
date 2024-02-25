// Copyright (c) 2019-2021 Alexander Medvednikov. All rights reserved.
// Use of this source code is governed by an MIT license
// that can be found in the LICENSE file.

module stbi

#flag -I @VEXEROOT/thirdparty/stb_image
#include "stb_image.h"
#flag @VEXEROOT/thirdparty/stb_image/stbi.o

pub struct Image {
pub mut:
	width       int
	height      int
	nr_channels int
	ok          bool
	data        voidptr
	ext         string
}

fn C.stbi_load(filename &char, x &int, y &int, channels_in_file &int, desired_channels int) &byte

fn C.stbi_load_from_file(f voidptr, x &int, y &int, channels_in_file &int, desired_channels int) &byte

fn C.stbi_load_from_memory(buffer &byte, len int, x &int, y &int, channels_in_file &int, desired_channels int) &byte

fn C.stbi_image_free(retval_from_stbi_load &byte)

fn C.stbi_set_flip_vertically_on_load(should_flip int)

fn init() {
	set_flip_vertically_on_load(false)
}

pub fn load(path string) ?Image {
	ext := path.all_after_last('.')
	mut res := Image{
		ok: true
		ext: ext
		data: 0
	}
	// flag := if ext == 'png' { C.STBI_rgb_alpha } else { 0 }
	desired_channels := if ext == 'png' { 4 } else { 0 }
	res.data = C.stbi_load(&char(path.str), &res.width, &res.height, &res.nr_channels,
		desired_channels)
	if desired_channels == 4 && res.nr_channels == 3 {
		// Fix an alpha png bug
		res.nr_channels = 4
	}
	if isnil(res.data) {
		return error('stbi image failed to load from "$path"')
	}
	return res
}

pub fn load_from_memory(buf &byte, bufsize int) ?Image {
	mut res := Image{
		ok: true
		data: 0
	}
	flag := C.STBI_rgb_alpha
	res.data = C.stbi_load_from_memory(buf, bufsize, &res.width, &res.height, &res.nr_channels,
		flag)
	if isnil(res.data) {
		return error('stbi image failed to load from memory')
	}
	return res
}

pub fn (img &Image) free() {
	C.stbi_image_free(img.data)
}

/*
pub fn (img Image) tex_image_2d() {
	mut rgb_flag := C.GL_RGB
	if img.ext == 'png' {
		rgb_flag = C.GL_RGBA
	}
	C.glTexImage2D(C.GL_TEXTURE_2D, 0, rgb_flag, img.width, img.height, 0,
		rgb_flag, C.GL_UNSIGNED_BYTE,	img.data)
}
*/

pub fn set_flip_vertically_on_load(val bool) {
	C.stbi_set_flip_vertically_on_load(val)
}
