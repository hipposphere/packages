#ifndef HIPPO_ZSTANDARD_H_
#define HIPPO_ZSTANDARD_H_

#include <stddef.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif

typedef struct HippoZstdResult HippoZstdResult;

uint32_t hippo_zstd_abi_version(void);

uint8_t *hippo_zstd_alloc(size_t length);
void hippo_zstd_input_free(uint8_t *data, size_t length);

HippoZstdResult *hippo_zstd_compress(
    const uint8_t *input,
    size_t input_length,
    int32_t level);

HippoZstdResult *hippo_zstd_decompress(
    const uint8_t *input,
    size_t input_length,
    size_t max_output_length);

int32_t hippo_zstd_result_error(const HippoZstdResult *result);
size_t hippo_zstd_result_length(const HippoZstdResult *result);
const uint8_t *hippo_zstd_result_data(const HippoZstdResult *result);
void hippo_zstd_result_free(HippoZstdResult *result);

#ifdef __cplusplus
}
#endif

#endif  // HIPPO_ZSTANDARD_H_
