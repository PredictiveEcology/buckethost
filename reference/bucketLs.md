# List objects in a bucket

Reads the bucket's public S3 listing API and returns one row per object.
Pagination (1000 keys per response) is handled for you. If the bucket
refuses anonymous listing (HTTP 403), as the PredictiveEcology bucket on
the new Arbutus does, it lists with `rclone` instead, using the
credentials of your rclone `remote`.

## Usage

``` r
bucketLs(
  prefix = "",
  container = NULL,
  endpoint = NULL,
  includeIndexes = FALSE,
  remote = NULL,
  rclonePath = "rclone"
)
```

## Arguments

- prefix:

  Optional key prefix to restrict the listing, e.g. `"SCANFI_v2/1985"`.
  Default `""` lists everything.

- container:

  The bucket (container) name. When `NULL` (the default), resolved from
  `options(buckethost.container=)`, then `BUCKETHOST_CONTAINER`, then a
  built-in default.

- endpoint:

  The object store's HTTPS host (no bucket name). When `NULL`, resolved
  from `options(buckethost.endpoint=)`, then `BUCKETHOST_ENDPOINT`, then
  a built-in default.

- includeIndexes:

  If `FALSE` (default), generated `index.html` files are dropped from
  the result so you see only data objects.

- remote:

  The name of your local `rclone` remote. When `NULL`, resolved from
  `options(buckethost.remote=)`, then `BUCKETHOST_REMOTE`, then a
  built-in default.

- rclonePath:

  Path to the `rclone` executable, used only when anonymous listing is
  refused. Default `"rclone"`.

## Value

A `data.frame` with columns `key`, `size` (bytes), and `modified` (a
time string: ISO-8601 from the public listing, `"YYYY-MM-DD HH:MM:SS"`
from rclone), sorted by key.

## See also

[`bucketUrl()`](https://predictiveecology.github.io/buckethost/reference/bucketUrl.md),
[`generateIndexes()`](https://predictiveecology.github.io/buckethost/reference/generateIndexes.md)

## Examples

``` r
if (FALSE) { # \dontrun{
bucketLs(prefix = "SCANFI_v2/1985",
          endpoint = "https://object-arbutus.cloud.computecanada.ca",
          container = "predictiveecology")
} # }
```
