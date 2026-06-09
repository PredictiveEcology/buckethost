# Verify a local tree against the bucket

Wraps `rclone check` to compare a local directory with a remote prefix
after an upload. `method = "size"` (the default, `--size-only`) is fast
and usually sufficient; `method = "hash"` compares checksums for a
stronger, slower guarantee.

## Usage

``` r
bucket_verify(
  local_dir,
  remote_path,
  container = NULL,
  remote = NULL,
  method = c("size", "hash"),
  filter_file = NULL,
  rclone_path = "rclone"
)
```

## Arguments

- local_dir:

  Local directory to compare.

- remote_path:

  Remote prefix within the bucket to compare against.

- container:

  The bucket (container) name. When `NULL` (the default), resolved from
  `options(buckethost.container=)`, then `BUCKETHOST_CONTAINER`, then a
  built-in default.

- remote:

  The name of your local `rclone` remote. When `NULL`, resolved from
  `options(buckethost.remote=)`, then `BUCKETHOST_REMOTE`, then a
  built-in default.

- method:

  `"size"` for a size-only check (fast) or `"hash"` for a checksum
  comparison (thorough).

- filter_file:

  Optional `rclone` filter file, matching the one used for the upload,
  so the comparison considers the same set of files.

- rclone_path:

  Path to the `rclone` executable. Default `"rclone"`.

## Value

Invisibly, a list with `ok` (logical; `TRUE` when rclone reports no
differences) and `output` (rclone's captured stderr/stdout, which lists
any mismatches).

## See also

[`bucket_upload()`](https://predictiveecology.github.io/buckethost/reference/bucket_upload.md)

## Examples

``` r
if (FALSE) { # \dontrun{
res <- bucket_verify("~/local/SCANFI/1985", "SCANFI_v2/1985",
                     filter_file = "~/scanfi.filter")
res$ok
} # }
```
