test_that("formatSize picks readable units", {
  fs <- buckethost:::formatSize
  expect_equal(fs(512), "0.5 KB")
  expect_equal(fs(1.5 * 1024^2), "1.5 MB")
  expect_equal(fs(2 * 1024^3), "2.00 GB")
})

test_that("dirsForKey enumerates ancestors, not the file", {
  d <- buckethost:::dirsForKey
  expect_equal(d("a/b/c.tif"), c("a", "a/b"))
  expect_equal(d("top.tif"), character(0))
  expect_equal(d("x/y.tif"), "x")
})

test_that("renderTemplate substitutes every token", {
  rt <- buckethost:::renderTemplate
  out <- rt("<h1>{{a}}</h1><p>{{b}} and {{a}}</p>", list(a = "X", b = "Y"))
  expect_equal(out, "<h1>X</h1><p>Y and X</p>")
})

test_that("htmlEscape neutralises markup", {
  he <- buckethost:::htmlEscape
  expect_equal(he("a & b < c > d"), "a &amp; b &lt; c &gt; d")
  expect_equal(he("it's \"x\""), "it&#39;s &quot;x&quot;")
})

test_that("config resolves option over default and arg over option", {
  old <- options(buckethost.container = "from_opt")
  on.exit(options(old), add = TRUE)
  expect_equal(bucketContainer(), "from_opt")
  expect_equal(bucketContainer("explicit"), "explicit")
})

test_that("base url and rclone remote compose correctly", {
  expect_equal(
    bucketBaseUrl(endpoint = "https://e.com", container = "c"),
    "https://e.com/c"
  )
  expect_equal(
    bucketRcloneRemote(remote = "r", container = "c"),
    "r:c"
  )
})

test_that("asBucketKey normalises plain keys and full URLs", {
   abk <- buckethost:::asBucketKey
  # plain key, leading slashes trimmed
  expect_equal(abk("SCANFI_v2/x.csv", container = "predictiveecology"),
               "SCANFI_v2/x.csv")
  expect_equal(abk("/SCANFI_v2/x.csv", container = "predictiveecology"),
               "SCANFI_v2/x.csv")
  # full public URL (default Arbutus endpoint) -> stripped to key
  url <- paste0("https://object-arbutus.cloud.computecanada.ca/",
                "predictiveecology/SCANFI_v2/x.csv")
  expect_equal(abk(url, container = "predictiveecology"), "SCANFI_v2/x.csv")
  # URL with a non-default endpoint still strips via the /<container>/ marker
  expect_equal(
    abk("https://minio.example.org/mybucket/a/b.tif", container = "mybucket"),
    "a/b.tif"
  )
  # a URL whose container can't be located errors clearly
  expect_error(
    abk("https://host/other/a/b.tif", container = "mybucket"),
    "Could not derive an object key"
  )
})
