use std::panic::{catch_unwind, AssertUnwindSafe};
use std::ptr;
use std::slice;

const ABI_VERSION: u32 = 1;
const ERROR_NONE: i32 = 0;
const ERROR_INVALID_DATA: i32 = 1;
const ERROR_OUTPUT_LIMIT_EXCEEDED: i32 = 2;
const ERROR_INTERNAL: i32 = 3;
const ERROR_INVALID_ARGUMENT: i32 = 4;

pub struct HippoZstdResult {
    data: Vec<u8>,
    error: i32,
}

impl HippoZstdResult {
    fn success(data: Vec<u8>) -> *mut Self {
        Box::into_raw(Box::new(Self {
            data,
            error: ERROR_NONE,
        }))
    }

    fn failure(error: i32) -> *mut Self {
        Box::into_raw(Box::new(Self {
            data: Vec::new(),
            error,
        }))
    }
}

#[no_mangle]
pub extern "C" fn hippo_zstd_abi_version() -> u32 {
    ABI_VERSION
}

#[no_mangle]
pub extern "C" fn hippo_zstd_alloc(length: usize) -> *mut u8 {
    if length == 0 {
        return ptr::null_mut();
    }

    let bytes = vec![0_u8; length].into_boxed_slice();
    Box::into_raw(bytes) as *mut u8
}

#[no_mangle]
pub unsafe extern "C" fn hippo_zstd_input_free(data: *mut u8, length: usize) {
    if data.is_null() || length == 0 {
        return;
    }

    drop(Box::from_raw(ptr::slice_from_raw_parts_mut(data, length)));
}

fn input_slice<'a>(input: *const u8, input_length: usize) -> Result<&'a [u8], i32> {
    if input_length == 0 {
        return Ok(&[]);
    }
    if input.is_null() {
        return Err(ERROR_INVALID_ARGUMENT);
    }

    // SAFETY: Callers allocate `input_length` bytes through `hippo_zstd_alloc`
    // and keep that allocation alive for the duration of this call.
    Ok(unsafe { slice::from_raw_parts(input, input_length) })
}

fn guarded(operation: impl FnOnce() -> Result<Vec<u8>, i32>) -> *mut HippoZstdResult {
    match catch_unwind(AssertUnwindSafe(operation)) {
        Ok(Ok(data)) => HippoZstdResult::success(data),
        Ok(Err(error)) => HippoZstdResult::failure(error),
        Err(_) => HippoZstdResult::failure(ERROR_INTERNAL),
    }
}

#[no_mangle]
pub extern "C" fn hippo_zstd_compress(
    input: *const u8,
    input_length: usize,
    level: i32,
) -> *mut HippoZstdResult {
    guarded(|| {
        let input = input_slice(input, input_length)?;
        zrip::compress(input, level).map_err(|_| ERROR_INVALID_ARGUMENT)
    })
}

#[no_mangle]
pub extern "C" fn hippo_zstd_decompress(
    input: *const u8,
    input_length: usize,
    max_output_length: usize,
) -> *mut HippoZstdResult {
    guarded(|| {
        let input = input_slice(input, input_length)?;
        zrip::decompress_with_limit(input, max_output_length).map_err(|error| match error {
            zrip::DecompressError::OutputTooSmall => ERROR_OUTPUT_LIMIT_EXCEEDED,
            _ => ERROR_INVALID_DATA,
        })
    })
}

#[no_mangle]
pub unsafe extern "C" fn hippo_zstd_result_error(result: *const HippoZstdResult) -> i32 {
    result
        .as_ref()
        .map_or(ERROR_INVALID_ARGUMENT, |value| value.error)
}

#[no_mangle]
pub unsafe extern "C" fn hippo_zstd_result_length(result: *const HippoZstdResult) -> usize {
    result.as_ref().map_or(0, |value| value.data.len())
}

#[no_mangle]
pub unsafe extern "C" fn hippo_zstd_result_data(result: *const HippoZstdResult) -> *const u8 {
    result
        .as_ref()
        .map_or(ptr::null(), |value| value.data.as_ptr())
}

#[no_mangle]
pub unsafe extern "C" fn hippo_zstd_result_free(result: *mut HippoZstdResult) {
    if !result.is_null() {
        drop(Box::from_raw(result));
    }
}
