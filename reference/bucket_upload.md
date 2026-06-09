# Upload files to a bucket

Thin, loud wrapper around `rclone copy`. Copies `local` (a file or
directory) to `remote_path` within the bucket. rclone only transfers
what has changed, so re-running is cheap and idempotent.

## Usage

``` r
bucket_upload(
  local,
  remote_path,
  container = NULL,
  remote = NULL,
  filter_file = NULL,
  transfers = 16L,
  extra = character(0),
  rclone_path = "rclone",
  dry_run = FALSE,
  echo = FALSE
)
```

## Arguments

- local:

  Path to a local file or directory to upload.

- remote_path:

  Destination key/prefix within the bucket, e.g. `"SCANFI_v2/1985"`.
  Leading slashes are not required.

- container:

  The bucket (container) name. When `NULL` (the default), resolved from
  `options(buckethost.container=)`, then `BUCKETHOST_CONTAINER`, then a
  built-in default.

- remote:

  The name of your local `rclone` remote. When `NULL`, resolved from
  `options(buckethost.remote=)`, then `BUCKETHOST_REMOTE`, then a
  built-in default.

- filter_file:

  Optional path to an `rclone` filter file (`--filter-from`) to
  include/exclude by pattern. See the migration vignette for an example.

- transfers:

  Number of parallel transfers (`--transfers`). Default 16.

- extra:

  Character vector of additional raw `rclone` flags, e.g.
  `c("--retries", "10", "--stats", "60s")`.

- rclone_path:

  Path to the `rclone` executable. Default `"rclone"`.

- dry_run:

  If `TRUE`, pass `--dry-run` so rclone reports what it *would* do
  without transferring. Default `FALSE`.

- echo:

  If `TRUE`, print the rclone command before running it.

## Value

Invisibly, rclone's captured output (character).

## See also

[`bucket_verify()`](https://predictiveecology.github.io/buckethost/reference/bucket_verify.md),
[`bucket_delete()`](https://predictiveecology.github.io/buckethost/reference/bucket_delete.md)

## Examples

``` r
if (FALSE) { # \dontrun{
bucket_upload("~/local/SCANFI/1985", "SCANFI_v2/1985",
              filter_file = "~/scanfi.filter",
              extra = c("--retries", "10", "--stats", "60s"))
} # }
```
