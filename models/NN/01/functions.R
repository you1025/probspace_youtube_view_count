source("models/NN/functions_NN.R", encoding = "utf-8")

# モデルに用いる説明変数
select_model_predictors <- function(data, include_y = T) {

  df.filtered <- data %>%

    dplyr::select(
      likes,
      dislikes,
      comment_count,
      comments_disabled,
      ratings_disabled,
      published_year,
      title_length,
      flg_no_tags,
      tag_characters,
      tag_count,
      diff_likes_dislikes,
      sum_likes_dislikes,
      ratio_likes,
      ratio_comments_likedis,
      flg_no_description,
      description_length,
      flg_url,
      url_count,
      flg_japanese,
      flg_emoji,
      flg_official,
      flg_movie_number,
      flg_categoryId_low,
      flg_categoryId_high,
      categoryId_X1,
      categoryId_X2,
      categoryId_X10,
      categoryId_X15,
      categoryId_X17,
      categoryId_X19,
      categoryId_X20,
      categoryId_X22,
      categoryId_X23,
      categoryId_X24,
      categoryId_X25,
      categoryId_X26,
      categoryId_X27,
      categoryId_X28,
      categoryId_X29,
      categoryId_X30,
      categoryId_Other,
      published_dow_1,
      published_dow_2,
      published_dow_3,
      published_dow_4,
      published_dow_5,
      published_dow_6,
      published_dow_7,
      published_month_X1,
      published_month_X2,
      published_month_X3,
      published_month_X4,
      published_month_X5,
      published_month_X6,
      published_month_X7,
      published_month_X8,
      published_month_X9,
      published_month_X10,
      published_month_X11,
      published_month_X12,
      categoryId_mean_y,
      categoryId_max_y,
      published_year_mean_y,
      published_year_sd_y
    )

  if(include_y) {
    df.filtered <- df.filtered %>%
      dplyr::mutate(y = data$y)
  }

  df.filtered
}
