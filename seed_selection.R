library(tidyverse)
library(purrr)

future::plan(future::multisession(workers = 8))

#   100: 3.165s
#  1000: 11.615s
# 10000: 117.032s
# Best: 2851
system.time(
  df.seed_results <- furrr::future_map_dfr(1:10000, function(seed, data) {

    score <- create_cv(data, v = 5, seed = seed)$splits %>%

      purrr::imap_dfr(function(split, i) {
        rsample::training(split) %>%
          dplyr::group_by(categoryId) %>%
          dplyr::summarise(avg_y = mean(log(y+1))) %>%
          dplyr::mutate(id = i)
      }) %>%

      dplyr::group_by(categoryId) %>%
      dplyr::mutate(diff = mean(avg_y) - avg_y) %>%
      dplyr::ungroup() %>%
      dplyr::summarise(score = sqrt(mean(diff^2))) %>%

      dplyr::pull(score)

    tibble(seed = seed, score = score)

  }, data = df.train_data) %>%

    dplyr::arrange(score)
)


# 可視化で比較
purrr::map_dfr(c(2851, 6257, 8711), function(seed) {

  create_cv(df.train_data, v = 5, seed = seed)$splits %>%

    purrr::imap_dfr(function(split, i) {
      rsample::training(split) %>%
        dplyr::group_by(categoryId) %>%
        dplyr::summarise(avg_y = mean(log(y+1))) %>%
        dplyr::mutate(id = i)
    }) %>%
    
    dplyr::group_by(categoryId) %>%
    dplyr::mutate(diff = mean(avg_y) - avg_y) %>%
    dplyr::ungroup() %>%

    dplyr::mutate(seed = seed) %>%

    dplyr::select(
      seed,
      categoryId,
      id,
      diff
    )
}) %>%

  ggplot(aes(categoryId, diff)) +
    geom_line(aes(group = id, colour = factor(id))) +
    facet_grid(seed ~ .)
