#' Connection configuration
#'
#' Helpers that resolve where your bucket lives. Each reads, in order, an R
#' option, then an environment variable, then a built-in default. Set the
#' options once (see [buckethost-package]) and the rest of the package picks
#' them up.
#'
#' @details
#' Two URL/identifier conventions are at play and are easy to confuse:
#'
#' \describe{
#'   \item{`endpoint`}{The object store's HTTPS host, e.g.
#'     `"https://object-arbutus.cloud.computecanada.ca"`. No bucket name.}
#'   \item{`container`}{The bucket (a.k.a. container) name, e.g.
#'     `"predictiveecology"`.}
#'   \item{`remote`}{The name of the `rclone` remote you configured with
#'     `rclone config`, e.g. `"arbutus"`. This is local to your machine and is
#'     unrelated to the public URL.}
#' }
#'
#' [bucket_base_url()] combines endpoint + container into the public base URL
#' for reads; [bucket_rclone_remote()] combines remote + container into the
#' `remote:container` string `rclone` expects.
#'
#' @param container The bucket (container) name. When `NULL` (the default),
#'   resolved from `options(buckethost.container=)`, then
#'   `BUCKETHOST_CONTAINER`, then a built-in default.
#' @param endpoint The object store's HTTPS host (no bucket name). When `NULL`,
#'   resolved from `options(buckethost.endpoint=)`, then `BUCKETHOST_ENDPOINT`,
#'   then a built-in default.
#' @param remote The name of your local `rclone` remote. When `NULL`, resolved
#'   from `options(buckethost.remote=)`, then `BUCKETHOST_REMOTE`, then a
#'   built-in default.
#'
#' @return A length-one character string.
#' @name bucket_config
NULL

# Internal: option -> env var -> default resolver.
resolve_opt <- function(value, option, env, default) {
  if (!is.null(value)) {
    return(value)
  }
  opt <- getOption(option)
  if (!is.null(opt)) {
    return(opt)
  }
  envval <- Sys.getenv(env, unset = NA)
  if (!is.na(envval) && nzchar(envval)) {
    return(envval)
  }
  default
}

#' @rdname bucket_config
#' @export
bucket_endpoint <- function(endpoint = NULL) {
  resolve_opt(
    endpoint, "buckethost.endpoint", "BUCKETHOST_ENDPOINT",
    "https://object-arbutus.cloud.computecanada.ca"
  )
}

#' @rdname bucket_config
#' @export
bucket_container <- function(container = NULL) {
  resolve_opt(
    container, "buckethost.container", "BUCKETHOST_CONTAINER",
    "predictiveecology"
  )
}

#' @rdname bucket_config
#' @export
bucket_remote <- function(remote = NULL) {
  resolve_opt(remote, "buckethost.remote", "BUCKETHOST_REMOTE", "arbutus")
}

#' @rdname bucket_config
#' @return `bucket_base_url()`: the public `endpoint/container` URL.
#' @export
#' @examples
#' bucket_base_url(endpoint = "https://example.com", container = "mydata")
bucket_base_url <- function(container = NULL, endpoint = NULL) {
  paste0(bucket_endpoint(endpoint), "/", bucket_container(container))
}

#' @rdname bucket_config
#' @return `bucket_rclone_remote()`: the `remote:container` string for rclone.
#' @export
#' @examples
#' bucket_rclone_remote(remote = "arbutus", container = "mydata")
bucket_rclone_remote <- function(container = NULL, remote = NULL) {
  paste0(bucket_remote(remote), ":", bucket_container(container))
}
