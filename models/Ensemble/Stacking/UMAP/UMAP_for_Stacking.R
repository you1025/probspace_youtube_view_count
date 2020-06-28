library(tidyverse)
library(umap)

source("models/KNN/02/functions.R", encoding = "utf-8")
source("models/Ensemble/Stacking/UMAP/functions_Stacking_UMAP.R", encoding = "utf-8")

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()
df.test_data  <- load_test_data("data/01.input/test_data.csv")   %>% clean()

recipe <- create_recipe(df.train_data)

trained_recipe <- recipes::prep(recipe, training = df.train_data)
df.train <- recipes::juice(trained_recipe) %>%
  add_special_segment() %>%
  add_features_per_category(., .)
df.test  <- recipes::bake(trained_recipe, new_data = df.test_data) %>%
  add_special_segment() %>%
  add_features_per_category(df.train)

df.data <- dplyr::bind_rows(
  df.train %>% dplyr::mutate(class = "train"),
  df.test  %>% dplyr::mutate(class = "test")
) %>%
  dplyr::select(
    class,
    categoryId,
    likes,
    dislikes,
    comment_count,
    comments_disabled,
    ratings_disabled,
    title_length,
    published_year,
    published_month_x,
    published_month_y,
    published_day_x,
    published_day_y,
    published_dow_x,
    published_dow_y,
    published_hour2_x,
    published_hour2_y,
    channel_title_length,
    flg_categoryId_low,
    flg_categoryId_high,
    flg_no_tags,
    tag_characters,
    tag_count,
    flg_no_description,
    description_length,
    flg_url,
    url_count,
    days_from_published,
    diff_likes_dislikes,
    sum_likes_dislikes,
    ratio_likes,
    sum_likes_dislikes_comments,
    ratio_comments_likedis,
    flg_japanese,
    flg_emoji,
    flg_official,
    flg_movie_number,
    flg_comments_ratings_disabled_japanese_high,
    flg_comments_ratings_disabled_japanese_very_high,
    flg_comments_ratings_disabled_japanese_low,
    flg_comments_ratings_disabled_japanese_very_low,
    pc1,
    categoryId_mean_y,
    categoryId_median_y,
    categoryId_min_y,
    categoryId_max_y,
    published_year_mean_y,
    published_year_median_y,
    published_year_min_y,
    published_year_max_y,
    flg_japanese_mean_y,
    flg_japanese_median_y,
    flg_japanese_min_y,
    flg_japanese_max_y
  ) %>% {
    data <- (.)
    recipes::recipe(~ ., data) %>%
      recipes::step_dummy(categoryId, one_hot = T) %>%
      recipes::prep() %>%
      recipes::juice()
  }
umap.result <- df.data %>%
  dplyr::select(-class) %>%
  umap::umap(random_state = 1025)

umap.result$layout %>%
  tibble::as_tibble() %>%
  ggplot(aes(V1, V2)) +
    geom_point(size = 1, alpha = 1/7)

knn.5 <- umap.result$layout %>%
  tibble::as_tibble() %>%
  kmeans(centers = 5, nstart = 10)
knn.10 <- umap.result$layout %>%
  tibble::as_tibble() %>%
  kmeans(centers = 10, nstart = 10)
knn.50 <- umap.result$layout %>%
  tibble::as_tibble() %>%
  kmeans(centers = 50, nstart = 10)
knn.100 <- umap.result$layout %>%
  tibble::as_tibble() %>%
  kmeans(centers = 100, nstart = 10)
knn.500 <- umap.result$layout %>%
  tibble::as_tibble() %>%
  kmeans(centers = 500, nstart = 10)

df.results <- umap.result$layout %>%
  tibble::as_tibble() %>%
  dplyr::mutate(
    class = df.data$class,
    cluster.5   = factor(knn.5$cluster),
    cluster.10  = factor(knn.10$cluster),
    cluster.50  = factor(knn.50$cluster),
    cluster.100 = factor(knn.100$cluster),
    cluster.500 = factor(knn.500$cluster)
  )

df.results %>%
  ggplot(aes(V1, V2)) +
    geom_point(aes(colour = cluster.500), size = 0.5, alpha = 1/7, show.legend = F)

# データ生成
df.results.train <- df.results %>%
  dplyr::filter(class == "train")
df.results.test  <- df.results %>%
  dplyr::filter(class == "test")

# ファイル書き出し
save_UMAP(df.results.train, df.results.test)
