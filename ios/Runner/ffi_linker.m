#include <stddef.h>

extern int file_ingest_md_convert(
    const char *file_type,
    const char *input_path,
    const char *output_dir,
    char **out_path,
    char **out_err
);

extern void file_ingest_md_free(char *ptr);

__attribute__((used))
static void *file_ingest_md_convert_ptr = (void *)&file_ingest_md_convert;

__attribute__((used))
static void *file_ingest_md_free_ptr = (void *)&file_ingest_md_free;
