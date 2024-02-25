module builder

import v.pref
import v.util
import v.gen.native

pub fn (mut b Builder) build_native(v_files []string, out_file string) {
	if b.pref.os !in [.linux, .macos] {
		eprintln('Warning: v -native can only generate macOS and Linux binaries for now')
	}
	b.front_and_middle_stages(v_files) or { return }
	util.timing_start('Native GEN')
	b.stats_lines, b.stats_bytes = native.gen(b.parsed_files, b.table, out_file, b.pref)
	util.timing_measure('Native GEN')
}

pub fn (mut b Builder) compile_native() {
	// v.files << v.v_files_from_dir(os.join_path(v.pref.vlib_path,'builtin','bare'))
	files := [b.pref.path]
	b.set_module_lookup_paths()
	b.build_native(files, b.pref.out_name)
}
