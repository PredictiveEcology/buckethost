# List objects in a bucket

Reads the bucket's public S3 listing API and returns one row per object.
Pagination (1000 keys per response) is handled for you. The bucket must
be configured for public/anonymous read.

## Usage

``` r
bucketLs(
  prefix = "",
  container = NULL,
  endpoint = NULL,
  includeIndexes = FALSE
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

## Value

A `data.frame` with columns `key`, `size` (bytes), and `modified`
(ISO-8601 string), sorted by key.

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
