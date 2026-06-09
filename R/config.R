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
#' [bucketBaseUrl()] combines endpoint + container into the public base URL
#' for reads; [bucketRcloneRemote()] combines remote + container into the
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
#' @name bucketConfig
NULL

# Internal: option -> env var -> default resolver.
resolveOpt <- function(value, option, env, default) {
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

#' @rdname bucketConfig
#' @export
bucketEndpoint <- function(endpoint = NULL) {
  resolveOpt(
    endpoint, "buckethost.endpoint", "BUCKETHOST_ENDPOINT",
    "https://object-arbutus.cloud.computecanada.ca"
  )
}

#' @rdname bucketConfig
#' @export
bucketContainer <- function(container = NULL) {
  resolveOpt(
    container, "buckethost.container", "BUCKETHOST_CONTAINER",
    "predictiveecology"
  )
}

#' @rdname bucketConfig
#' @export
bucketRemote <- function(remote = NULL) {
  resolveOpt(remote, "buckethost.remote", "BUCKETHOST_REMOTE", "arbutus")
}

#' @rdname bucketConfig
#' @return `bucketBaseUrl()`: the public `endpoint/container` URL.
#' @export
#' @examples
#' bucketBaseUrl(endpoint = "https://example.com", container = "mydata")
bucketBaseUrl <- function(container = NULL, endpoint = NULL) {
  paste0(bucketEndpoint(endpoint), "/", bucketContainer(container))
}

#' @rdname bucketConfig
#' @return `bucketRcloneRemote()`: the `remote:container` string for rclone.
#' @export
#' @examples
#' bucketRcloneRemote(remote = "arbutus", container = "mydata")
bucketRcloneRemote <- function(container = NULL, remote = NULL) {
  paste0(bucketRemote(remote), ":", bucketContainer(container))
}
