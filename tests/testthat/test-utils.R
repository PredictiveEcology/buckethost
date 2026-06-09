test_that("format_size picks readable units", {
  fs <- buckethost:::format_size
  expect_equal(fs(512), "0.5 KB")
  expect_equal(fs(1.5 * 1024^2), "1.5 MB")
  expect_equal(fs(2 * 1024^3), "2.00 GB")
})

test_that("dirs_for_key enumerates ancestors, not the file", {
  d <- buckethost:::dirs_for_key
  expect_equal(d("a/b/c.tif"), c("a", "a/b"))
  expect_equal(d("top.tif"), character(0))
  expect_equal(d("x/y.tif"), "x")
})

test_that("render_template substitutes every token", {
  rt <- buckethost:::render_template
  out <- rt("<h1>{{a}}</h1><p>{{b}} and {{a}}</p>", list(a = "X", b = "Y"))
  expect_equal(out, "<h1>X</h1><p>Y and X</p>")
})

test_that("html_escape neutralises markup", {
  he <- buckethost:::html_escape
  expect_equal(he("a & b < c > d"), "a &amp; b &lt; c &gt; d")
  expect_equal(he("it's \"x\""), "it&#39;s &quot;x&quot;")
})

test_that("config resolves option over default and arg over option", {
  old <- options(buckethost.container = "from_opt")
  on.exit(options(old), add = TRUE)
  expect_equal(bucket_container(), "from_opt")
  expect_equal(bucket_container("explicit"), "explicit")
})

test_that("base url and rclone remote compose correctly", {
  expect_equal(
    bucket_base_url(endpoint = "https://e.com", container = "c"),
    "https://e.com/c"
  )
  expect_equal(
    bucket_rclone_remote(remote = "r", container = "c"),
    "r:c"
  )
})
