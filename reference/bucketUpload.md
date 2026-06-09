# Upload files to a bucket

Thin, loud wrapper around `rclone`. Copies `local` to `remotePath`
within the bucket. rclone only transfers what has changed, so re-running
is cheap and idempotent.

## Usage

``` r
bucketUpload(
  local,
  remotePath,
  container = NULL,
  remote = NULL,
  filterFile = NULL,
  transfers = 16L,
  extra = character(0),
  rclonePath = "rclone",
  dryRun = FALSE,
  echo = FALSE
)
```

## Arguments

- local:

  Path to a local file or directory to upload.

- remotePath:

  Destination within the bucket. Either a key/prefix like
  `"SCANFI_v2/1985"`, or a full public URL like
  `"https://endpoint/container/SCANFI_v2/file.csv"` — a URL is
  normalised to the key (`"SCANFI_v2/file.csv"`) so the file lands where
  you expect rather than nested under the bucket. Leading slashes are
  not required.

- container:

  The bucket (container) name. When `NULL` (the default), resolved from
  `options(buckethost.container=)`, then `BUCKETHOST_CONTAINER`, then a
  built-in default.

- remote:

  The name of your local `rclone` remote. When `NULL`, resolved from
  `options(buckethost.remote=)`, then `BUCKETHOST_REMOTE`, then a
  built-in default.

- filterFile:

  Optional path to an `rclone` filter file (`--filter-from`) to
  include/exclude by pattern. See the migration vignette for an example.

- transfers:

  Number of parallel transfers (`--transfers`). Default 16.

- extra:

  Character vector of additional raw `rclone` flags, e.g.
  `c("--retries", "10", "--stats", "60s")`.

- rclonePath:

  Path to the `rclone` executable. Default `"rclone"`.

- dryRun:

  If `TRUE`, pass `--dry-run` so rclone reports what it *would* do
  without transferring. Default `FALSE`.

- echo:

  If `TRUE`, print the rclone command before running it.

## Value

Invisibly, rclone's captured output (character).

## Details

When `local` is a single **file**, `rclone copyto` is used so the file
lands at exactly `remotePath` (treated as the destination object key).
When `local` is a **directory**, `rclone copy` is used so its contents
are synced under `remotePath` (treated as a prefix). This avoids the
classic `rclone copy` footgun where a single file sent to a file-like
destination is nested as `remotePath/filename`.

## See also

[`bucketVerify()`](https://predictiveecology.github.io/buckethost/reference/bucketVerify.md),
[`bucketDelete()`](https://predictiveecology.github.io/buckethost/reference/bucketDelete.md)

## Examples

``` r
if (FALSE) { # \dontrun{
bucketUpload("~/local/SCANFI/1985", "SCANFI_v2/1985",
              filterFile = "~/scanfi.filter",
              extra = c("--retries", "10", "--stats", "60s"))
} # }
```
