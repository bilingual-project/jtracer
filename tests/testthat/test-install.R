test_that("jtrace can be installed", {
  expect_error(jtrace_is_installed(), NA)
  expect_error(jtrace_install(overwrite = TRUE, quiet = TRUE), NA)
})

