#' buckethost: Host and Catalogue Files on S3-Compatible Object Storage
#'
#' `buckethost` turns any S3-compatible bucket into a browsable, remotely
#' readable data repository. It has three jobs:
#'
#' \describe{
#'   \item{Discover}{[bucket_ls()] lists objects via the bucket's public S3
#'     listing API; [bucket_url()] and [bucket_raster()] build the HTTPS /
#'     `/vsicurl/` URLs you read from.}
#'   \item{Mutate}{[bucket_upload()] and [bucket_delete()] wrap `rclone` so
#'     transfers are robust and failures are loud.}
#'   \item{Maintain}{[generate_indexes()] writes a static `index.html` for
#'     every "folder" in the bucket so it can be browsed in a web browser;
#'     [bucket_verify()] checks a local tree against the remote.}
#' }
#'
#' @section Configuration:
#' Most functions default their connection details from options (falling back
#' to environment variables), so you set them once per session and omit them
#' everywhere after:
#'
#' \preformatted{
#' options(
#'   buckethost.endpoint  = "https://object-arbutus.cloud.computecanada.ca",
#'   buckethost.container = "predictiveecology",
#'   buckethost.remote    = "arbutus"   # the name of your rclone remote
#' )
#' }
#'
#' The equivalent environment variables are `BUCKETHOST_ENDPOINT`,
#' `BUCKETHOST_CONTAINER`, and `BUCKETHOST_REMOTE`. See [bucket_config].
#'
#' @keywords internal
#' @importFrom utils URLencode
#' @importFrom xml2 read_xml xml_find_all xml_find_first xml_ns xml_text
"_PACKAGE"
