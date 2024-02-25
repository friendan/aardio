use std::ffi::CStr;
use std::ffi::CString;
use std::os::raw::c_char;
extern crate toml;
extern crate serde_json; 
use toml::Value;

#[no_mangle]
pub extern fn freeCString(ptr: *mut c_char){
	unsafe {
		let _ = CString::from_raw(ptr);
	}
}

#[no_mangle]
pub extern fn json2tomlP(ptr_utf8: *const c_char,pretty:i32,err:  &mut i32)-> *mut c_char{
	let mut result: String = String::from("");

	let cstr_utf8 = unsafe { 
		assert!(!ptr_utf8.is_null());
		CStr::from_ptr(ptr_utf8) 
	};

	*err = 0; 
	let s_utf8 = match cstr_utf8.to_str() {
		Ok(s) => s,
		Err(e) => {
			result = String::from(e.to_string()); 
			*err = 1;
			""
		},
	};

	if *err != 0  { 
		let c_string = CString::new(result).expect("CString::new failed"); 
		return c_string.into_raw();
	}

	*err = 0;  
	let value: serde_json::Value = match serde_json::from_str(&s_utf8) {
		Ok(s) =>  s,
		Err(e) => {
			result = String::from(e.to_string()); 
			*err = 2;
			serde_json::Value::Null
		},
	};
	
	if *err != 0  { 
		let c_string = CString::new(result).expect("CString::new failed"); 
		return c_string.into_raw();
	}

	if pretty != 0 {  
		result = match toml::to_string_pretty(&value){
			Ok(s) => s,
			Err(e) =>{
				*err = 3;
				String::from(e.to_string())
			}
		}
	}
	else{
		result = match toml::to_string(&value){
			Ok(s) => s,
			Err(e) =>{ 
				*err = 3;
				String::from(e.to_string())
			}
		}
	}

	let c_string = CString::new(result).expect("CString::new failed"); 
	return c_string.into_raw(); //std::ptr::null_mut::<c_char>();
}

#[no_mangle]
pub extern fn toml2jsonP(ptr_utf8: *const c_char,pretty:i32,err:  &mut i32)-> *mut c_char{
	let mut result: String = String::from("");

	let cstr_utf8 = unsafe { 
		assert!(!ptr_utf8.is_null());
		CStr::from_ptr(ptr_utf8) 
	};


	*err = 0; 
	let s_utf8 = match cstr_utf8.to_str() {
		Ok(s) => s,
		Err(e) => {
			result = String::from(e.to_string()); 
			*err = 1;
			""
		},
	};

	if *err != 0  { 
		let c_string = CString::new(result).expect("CString::new failed"); 
		return c_string.into_raw();
	}
 
	let value = match s_utf8.parse::<Value>()  {
		Ok(s) =>  s,
		Err(e) => {
			result = String::from(e.to_string()); 
			*err = 2; 
			Value::Boolean(false)
		},
	};
	 
	if *err != 0  { 
		let c_string = CString::new(result).expect("CString::new failed"); 
		return c_string.into_raw();
	}

	if pretty != 0 {  
		result = match serde_json::to_string_pretty(&value){
			Ok(s) => s,
			Err(e) =>{
				*err = 3;
				String::from(e.to_string())
			}
		}
	}
	else{
		result = match serde_json::to_string(&value){
			Ok(s) => s,
			Err(e) =>{
				*err = 3;
				String::from(e.to_string())
			}
		}
	}

	let c_string = CString::new(result).expect("CString::new failed"); 
	return c_string.into_raw();
}