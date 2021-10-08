test_that("there are lexicons available", {
  expect_true(length(jtrace_list_lexicons())>0)
})

test_that("frequencies can be extracted", {
  expect_true(class(jtrace_get_frequency("plane"))=="data.frame")
  expect_true(all(sapply(jtrace_get_frequency("plane"), class)==c("character", "character", "numeric")))
  expect_named(jtrace_get_frequency("plane"), c("word", "language", "frequency_abs"))
  expect_named(jtrace_get_frequency("plane", scale = "frequency_abs"), c("word", "language", "frequency_abs"))
  expect_named(jtrace_get_frequency("plane", scale = "frequency_rel"), c("word", "language", "frequency_rel"))
  expect_named(jtrace_get_frequency("plane", scale = "frequency_zipf"), c("word", "language", "frequency_zipf"))
  expect_named(jtrace_get_frequency("plane", language = c("Spanish", "English")), c("word", "language", "frequency_abs"))
  expect_true(nrow(jtrace_get_frequency("plane", language = c("Spanish", "English")))==2)
  expect_true(nrow(jtrace_get_frequency("plane", language = c("Spanish", "English", "Catalan")))==3)
})

test_that("lexicon can be retrieved as data frames", {
  expect_true(class(jtrace_get_lexicon("biglex901"))=="data.frame")
  expect_true(class(jtrace_get_lexicon("context_lex"))=="data.frame")
  expect_true(class(jtrace_get_lexicon("empty"))=="data.frame")
  expect_true(class(jtrace_get_lexicon("initial_lexicon"))=="data.frame")
  expect_true(class(jtrace_get_lexicon("sevenlex"))=="data.frame")
  expect_true(class(jtrace_get_lexicon("slex"))=="data.frame")
  expect_true(class(jtrace_get_lexicon("slex_pairs"))=="data.frame")
  expect_true(all(sapply(jtrace_get_lexicon("biglex901"), class)==c("character", "numeric")))
  
})

test_that("a new lexicon can be created and found", {
  expect_error({
    my_phons <- c("plEIn", "kEIk", "taIɡ@", "ham", "sit")
    my_freqs <- c(0.0483, 0.0804, 0.0288, 0.0282, 0.0767)
    jtrace_create_lexicon(phonology = my_phons, frequency = my_freqs, lexicon_name = "my_lex")
  }, NA)
})
