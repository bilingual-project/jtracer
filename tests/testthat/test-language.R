test_that("there are languages available", {
  expect_true(length(jtrace_list_languages())>0)
})


test_that("languages can be retrieved as data frames", {
  expect_true(class(jtrace_get_language("default"))=="list")
  expect_true(class(jtrace_get_language("mayor2014"))=="list")
})

test_that("a new language can be created and found", {
  expect_error({
    my_phonemes <- c("-", "a", "s", "d", "f", "g", "c") 
    my_features <- data.frame(
      bur = c(9, 6, 4, 3, 1, 1, 2),
      voi = c(7, 4, 3, 3, 3, 3, 4),
      con = c(8, 2, 4, 2, 5, 5, 6),
      grd = c(4, 6, 1, 4, 6, 8, 6),
      dif = c(6, 3, 2, 6, 6, 6, 7),
      voc = c(3, 8, 1, 6, 6, 7, 4),
      pow = c(6, 4, 1, 6, 1, 1, 5)
      )
    jtrace_create_language(language_name = "my_lang", phonemes = my_phonemes, features = my_features)
  }, NA)
  expect_true("my_lang" %in% jtrace_list_languages())
})
