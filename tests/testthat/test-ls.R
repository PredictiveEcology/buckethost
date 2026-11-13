# A stub rclone that prints a fixed `lsf -R --format pst` listing (tab-separated
# path, size, time) and records its last argument (the listed path) to `log`.
makeLsfStub <- function(log, lines) {
  stub <- tempfile(fileext = ".sh")
  writeLines(c(
    "#!/bin/sh",
    sprintf("for a; do last=\"$a\"; done; printf '%%s\\n' \"$last\" > '%s'", log),
    "echo 'NOTICE: some rclone chatter on stderr' >&2",
    sprintf("printf '%s'", paste0(paste(lines, collapse = "\\n"), "\\n"))
  ), stub)
  Sys.chmod(stub, "0755")
  stub
}

denied <- function(...) {
  stop(structure(
    class = c("buckethostListingDenied", "error", "condition"),
    list(message = "denied", call = NULL)
  ))
}

test_that("bucketLs falls back to rclone when anonymous listing is refused", {
  skip_on_os("windows")
  log <- tempfile()
  stub <- makeLsfStub(log, c(
    "a.tif\t10\t2026-04-16 10:12:03",
    "b.tif\t20\t2026-04-16 10:12:04",
    "index.html\t5\t2026-04-16 10:12:05"
  ))
  local_mocked_bindings(fetchAllKeys = denied)

  expect_message(
    res <- bucketLs("SCANFI_v2/1985/", container = "123abc:mybucket",
                    remote = "r", rclonePath = stub),
    "listing with rclone remote 'r:mybucket'"
  )
  # rclone is pointed at the bare bucket (project-id prefix dropped).
  expect_equal(readLines(log), "r:mybucket/SCANFI_v2/1985/")
  expect_equal(res$key, c("SCANFI_v2/1985/a.tif", "SCANFI_v2/1985/b.tif"))
  expect_equal(res$size, c(10, 20))
  expect_equal(res$modified[1], "2026-04-16 10:12:03")
})

test_that("rclone fallback keeps S3 prefix semantics for a partial name", {
  skip_on_os("windows")
  log <- tempfile()
  stub <- makeLsfStub(log, c(
    "1985/a.tif\t1\t2026-01-01 00:00:00",
    "1990/b.tif\t2\t2026-01-01 00:00:00"
  ))
  local_mocked_bindings(fetchAllKeys = denied)

  res <- suppressMessages(
    bucketLs("SCANFI_v2/198", container = "c", remote = "r", rclonePath = stub)
  )
  # Lists the directory part, then filters on the full prefix.
  expect_equal(readLines(log), "r:c/SCANFI_v2/")
  expect_equal(res$key, "SCANFI_v2/1985/a.tif")
})

test_that("other listing errors are not swallowed", {
  local_mocked_bindings(fetchAllKeys = function(...) stop("network down"))
  expect_error(bucketLs(container = "c", remote = "r"), "network down")
})

test_that("bucketRcloneRemote drops a project-id prefix", {
  expect_equal(bucketRcloneRemote(remote = "r", container = "123abc:mybucket"),
               "r:mybucket")
  expect_equal(bucketBaseUrl(endpoint = "https://e", container = "123abc:mybucket"),
               "https://e/123abc:mybucket")
})

test_that("a listing error names the HTTP status and hints at a project id on 404", {
  skip_on_cran()
  skip_if_offline("object-arbutus.alliancecan.ca")
  expect_error(
    bucketLs(endpoint = "https://object-arbutus.alliancecan.ca",
             container = "no-such-bucket-buckethost-test"),
    "HTTP 404.*<project-id>:<bucket>"
  )
})
