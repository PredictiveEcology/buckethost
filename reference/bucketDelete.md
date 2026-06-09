# Delete an object or prefix from a bucket

Removes a single file (`rclone deletefile`) or an entire prefix
(`rclone delete`, when `recursive = TRUE`) from the bucket. Because this
is destructive it asks for confirmation by default; set
`confirm = FALSE` to delete non-interactively (e.g. in scripts).

## Usage

``` r
bucketDelete(
  remotePath,
  container = NULL,
  remote = NULL,
  recursive = FALSE,
  confirm = TRUE,
  rclonePath = "rclone",
  dryRun = FALSE
)
```

## Arguments

- remotePath:

  Key (single file) or prefix (with `recursive = TRUE`) to delete, e.g.
  `"SCANFI_v2/1985/old.tif"`. A full public URL is accepted and
  normalised to the key.

- container:

  The bucket (container) name. When `NULL` (the default), resolved from
  `options(buckethost.container=)`, then `BUCKETHOST_CONTAINER`, then a
  built-in default.

- remote:

  The name of your local `rclone` remote. When `NULL`, resolved from
  `options(buckethost.remote=)`, then `BUCKETHOST_REMOTE`, then a
  built-in default.

- recursive:

  If `TRUE`, delete everything under `remotePath` (a prefix). If `FALSE`
  (default), delete a single object.

- confirm:

  If `TRUE` (default) and the session is interactive, prompt before
  deleting.

- rclonePath:

  Path to the `rclone` executable. Default `"rclone"`.

- dryRun:

  If `TRUE`, pass `--dry-run`. Default `FALSE`.

## Value

Invisibly, rclone's captured output, or `NULL` if cancelled.

## See also

[`bucketUpload()`](https://predictiveecology.github.io/buckethost/reference/bucketUpload.md)
