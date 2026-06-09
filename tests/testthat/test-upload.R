test_that("cleanArg trims whitespace and rejects control characters", {
  ca <- buckethost:::cleanArg
  expect_equal(ca("  SCANFI_v2/x.csv\n", "remotePath"), "SCANFI_v2/x.csv")
  expect_error(ca("SCAN\nFI_v2.csv", "remotePath"), "control character")
  expect_error(ca("a\tb", "local"), "control character")
  expect_error(ca(c("a", "b"), "x"), "single string")
})

# A stub rclone that records the subcommand (its first arg) to a log file, so
# tests can assert which verb bucketUpload chose without a real bucket.
makeVerbStub <- function(log) {
  stub <- tempfile(fileext = ".sh")
  writeLines(c("#!/bin/sh", sprintf("printf '%%s\\n' \"$1\" >> '%s'", log)), stub)
  Sys.chmod(stub, "0755")
  stub
}

test_that("bucketUpload uses copyto for a file and copy for a directory", {
  skip_on_os("windows")
  log <- tempfile()
  stub <- makeVerbStub(log)

  f <- tempfile(fileext = ".csv")
  writeLines("a,b", f)
  bucketUpload(f, "SCANFI_v2/x.csv", rclonePath = stub)
  expect_equal(readLines(log), "copyto")

  unlink(log)
  d <- tempfile()
  dir.create(d)
  writeLines("a", file.path(d, "y.csv"))
  bucketUpload(d, "SCANFI_v2", rclonePath = stub)
  expect_equal(readLines(log), "copy")
})

test_that("bucketUpload normalises a full URL and errors on a missing local", {
  skip_on_os("windows")
  log <- tempfile()
  stub <- makeVerbStub(log)
  f <- tempfile(fileext = ".csv")
  writeLines("a,b", f)
  url <- paste0("https://object-arbutus.cloud.computecanada.ca/",
                "predictiveecology/SCANFI_v2/SCANFI_v2_files_on_arbutus.csv")
  # full URL as remotePath is accepted (file exists -> copyto)
  expect_no_error(bucketUpload(f, url, rclonePath = stub))
  expect_equal(readLines(log), "copyto")

  # a non-existent local path fails clearly, before rclone is invoked
  expect_error(
    bucketUpload(tempfile(), "x/y.csv", rclonePath = "true"),
    "Local path does not exist"
  )
})
