# Functions here are tested via the exported functions but we also run extra
# tests here.

test_that(".remart_batches() splits IDs into batches of at most `size`", {
  expect_identical(.remart_batches(1:5, 2L), list(1:2, 3:4, 5L))
  expect_identical(.remart_batches(character(), 50L), list())
  expect_identical(.remart_batches(1:3, 50L), list(1:3))
})
