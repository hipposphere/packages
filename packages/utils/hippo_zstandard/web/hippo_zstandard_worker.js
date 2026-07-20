let wasm;

self.onmessage = async (event) => {
  const request = event.data;

  if (request.operation === 'initialize') {
    try {
      const response = await fetch(request.wasmUrl);
      if (!response.ok) {
        throw new Error(`Failed to fetch hippo_zstandard.wasm: ${response.status}`);
      }

      try {
        const result = await WebAssembly.instantiateStreaming(response.clone(), {});
        wasm = result.instance.exports;
      } catch (_) {
        const result = await WebAssembly.instantiate(await response.arrayBuffer(), {});
        wasm = result.instance.exports;
      }

      if (wasm.hippo_zstd_abi_version() !== 1) {
        throw new Error('Unsupported hippo_zstandard WebAssembly ABI.');
      }
      self.postMessage({type: 'ready'});
    } catch (error) {
      setTimeout(() => {
        throw error;
      });
    }
    return;
  }

  if (!wasm) {
    self.postMessage({id: request.id, error: 3});
    return;
  }

  const bytes = new Uint8Array(request.bytes);
  const inputPointer = wasm.hippo_zstd_alloc(bytes.byteLength);
  if (bytes.byteLength > 0 && inputPointer === 0) {
    self.postMessage({id: request.id, error: 3});
    return;
  }

  let resultPointer = 0;
  try {
    if (bytes.byteLength > 0) {
      new Uint8Array(wasm.memory.buffer, inputPointer, bytes.byteLength).set(bytes);
    }
    resultPointer = request.operation === 'compress'
      ? wasm.hippo_zstd_compress(inputPointer, bytes.byteLength, request.value)
      : wasm.hippo_zstd_decompress(inputPointer, bytes.byteLength, request.value);

    if (resultPointer === 0) {
      self.postMessage({id: request.id, error: 3, details: 'Native result pointer was null.'});
      return;
    }

    const error = wasm.hippo_zstd_result_error(resultPointer);
    if (error !== 0) {
      self.postMessage({id: request.id, error});
      return;
    }

    const outputLength = wasm.hippo_zstd_result_length(resultPointer);
    const outputPointer = wasm.hippo_zstd_result_data(resultPointer);
    const output = new Uint8Array(outputLength);
    if (outputLength > 0) {
      output.set(new Uint8Array(wasm.memory.buffer, outputPointer, outputLength));
    }
    self.postMessage({id: request.id, bytes: output}, [output.buffer]);
  } catch (error) {
    console.error('hippo_zstandard worker operation failed', error);
    self.postMessage({
      id: request.id,
      error: 3,
      details: String(error && error.stack ? error.stack : error),
    });
  } finally {
    if (resultPointer !== 0) {
      wasm.hippo_zstd_result_free(resultPointer);
    }
    wasm.hippo_zstd_input_free(inputPointer, bytes.byteLength);
  }
};
