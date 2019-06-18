library(nimi)

test_that("get_gender returns correct respone", {
  expect_equal(get_gender("Astrid"), "female")
  expect_equal(get_gender("astrid"), "female")
  expect_equal(get_gender("Tanel"), "male")
  expect_equal(get_gender("Tanel1"), NA)
})

test_that("functions return correct number of outputs", {
  expect_equal(sum(is.na(get_rank("Astrid"))), 1)
  expect_equal(sum(is.na(get_count("Astrid"))), 1)
  expect_equal(length(get_count_by_month("Astrid")), 12)
  expect_equal(length(get_normalized_count_by_county("Astrid")), 15)
  expect_equal(length(describe("Astrid")), 7)
})
