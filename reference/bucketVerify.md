# Verify a local tree against the bucket

Wraps `rclone check` to compare a local directory with a remote prefix
after an upload. `method = "size"` (the default, `--size-only`) is fast
and usually sufficient; `method = "hash"` compares checksums for a
stronger, slower guarantee.

## Usage

``` r
bucketVerify(
  localDir,
  remotePath,
  container = NULL,
  remote = NULL,
  method = c("size", "hash"),
  filterFile = NULL,
  rclonePath = "rclone"
)
```

## Arguments

- localDir:

  Local directory to compare.

- remotePath:

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

- filterFile:

  Optional `rclone` filter file, matching the one used for the upload,
  so the comparison considers the same set of files.

- rclonePath:

  Path to the `rclone` executable. Default `"rclone"`.

## Value

Invisibly, a list with `ok` (logical; `TRUE` when rclone reports no
differences) and `output` (rclone's captured stderr/stdout, which lists
any mismatches).

## See also

[`bucketUpload()`](https://predictiveecology.github.io/buckethost/reference/bucketUpload.md)

## Examples

``` r
if (FALSE) { # \dontrun{
res <- bucketVerify("~/local/SCANFI/1985", "SCANFI_v2/1985",
                     filterFile = "~/scanfi.filter")
res$ok
} # }
```
