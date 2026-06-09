# Connection configuration

Helpers that resolve where your bucket lives. Each reads, in order, an R
option, then an environment variable, then a built-in default. Set the
options once (see
[buckethost-package](https://predictiveecology.github.io/buckethost/reference/buckethost-package.md))
and the rest of the package picks them up.

## Usage

``` r
bucket_endpoint(endpoint = NULL)

bucket_container(container = NULL)

bucket_remote(remote = NULL)

bucket_base_url(container = NULL, endpoint = NULL)

bucket_rclone_remote(container = NULL, remote = NULL)
```

## Arguments

- endpoint:

  The object store's HTTPS host (no bucket name). When `NULL`, resolved
  from `options(buckethost.endpoint=)`, then `BUCKETHOST_ENDPOINT`, then
  a built-in default.

- container:

  The bucket (container) name. When `NULL` (the default), resolved from
  `options(buckethost.container=)`, then `BUCKETHOST_CONTAINER`, then a
  built-in default.

- remote:

  The name of your local `rclone` remote. When `NULL`, resolved from
  `options(buckethost.remote=)`, then `BUCKETHOST_REMOTE`, then a
  built-in default.

## Value

A length-one character string.

`bucket_base_url()`: the public `endpoint/container` URL.

`bucket_rclone_remote()`: the `remote:container` string for rclone.

## Details

Two URL/identifier conventions are at play and are easy to confuse:

- `endpoint`:

  The object store's HTTPS host, e.g.
  `"https://object-arbutus.cloud.computecanada.ca"`. No bucket name.

- `container`:

  The bucket (a.k.a. container) name, e.g. `"predictiveecology"`.

- `remote`:

  The name of the `rclone` remote you configured with `rclone config`,
  e.g. `"arbutus"`. This is local to your machine and is unrelated to
  the public URL.

`bucket_base_url()` combines endpoint + container into the public base
URL for reads; `bucket_rclone_remote()` combines remote + container into
the `remote:container` string `rclone` expects.

## Examples

``` r
bucket_base_url(endpoint = "https://example.com", container = "mydata")
#> [1] "https://example.com/mydata"
bucket_rclone_remote(remote = "arbutus", container = "mydata")
#> [1] "arbutus:mydata"
```
