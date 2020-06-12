source("functions.R", encoding = "utf-8")

# レシピの作成
create_recipe <- function(data) {

  recipe <- create_feature_engineerging_recipe(data)

  recipe %>%

    # 不要項目の削除
    recipes::step_rm(
      id,
      video_id,
      title,
      publishedAt,
      channelId,
      channelTitle,
      collection_date,
      tags,
      thumbnail_link,
      description
    ) %>%

    # 対数変換
    recipes::step_log(
      likes,
      dislikes,
      sum_likes_dislikes,
      tag_characters,
      tag_count,
      comment_count,
      description_length,
      url_count,

      offset = 1
    ) %>%
    recipes::step_mutate(
      diff_likes_dislikes = sign(diff_likes_dislikes) * log(abs(diff_likes_dislikes) + 1)
    ) %>%

    # 視聴回数の対数変換
    recipes::step_log(y, offset = 1, skip = T)
}


add_features_per_category <- function(target_data, train_data) {

  target_data %>%

    # categoryId
    add_feature_per_category(train_data, categoryId, y, mean) %>%
    add_feature_per_category(train_data, categoryId, y, median) %>%
    add_feature_per_category(train_data, categoryId, y, min) %>%
    add_feature_per_category(train_data, categoryId, y, max) %>%
    add_feature_per_category(train_data, categoryId, y, sd) %>%

    # published_year
    add_feature_per_category(train_data, published_year, y, mean) %>%
    add_feature_per_category(train_data, published_year, y, median) %>%
    add_feature_per_category(train_data, published_year, y, min) %>%
    add_feature_per_category(train_data, published_year, y, max) %>%
    add_feature_per_category(train_data, published_year, y, sd) %>%

    # published_month
    add_feature_per_category(train_data, published_month, y, mean) %>%
    add_feature_per_category(train_data, published_month, y, median) %>%
    add_feature_per_category(train_data, published_month, y, min) %>%
    add_feature_per_category(train_data, published_month, y, max) %>%
    add_feature_per_category(train_data, published_month, y, sd) %>%

    # published_dow
    add_feature_per_category(train_data, published_dow, y, mean) %>%
    add_feature_per_category(train_data, published_dow, y, median) %>%
    add_feature_per_category(train_data, published_dow, y, min) %>%
    add_feature_per_category(train_data, published_dow, y, max) %>%
    add_feature_per_category(train_data, published_dow, y, sd) %>%

    # comments_disabled
    add_feature_per_category(train_data, comments_disabled, y, mean) %>%
    add_feature_per_category(train_data, comments_disabled, y, median) %>%
    add_feature_per_category(train_data, comments_disabled, y, min) %>%
    add_feature_per_category(train_data, comments_disabled, y, max) %>%
    add_feature_per_category(train_data, comments_disabled, y, sd) %>%

    # ratings_disabled
    add_feature_per_category(train_data, ratings_disabled, y, mean) %>%
    add_feature_per_category(train_data, ratings_disabled, y, median) %>%
    add_feature_per_category(train_data, ratings_disabled, y, min) %>%
    add_feature_per_category(train_data, ratings_disabled, y, max) %>%
    add_feature_per_category(train_data, ratings_disabled, y, sd) %>%

    # flg_categoryId_low
    add_feature_per_category(train_data, flg_categoryId_low, y, mean) %>%
    add_feature_per_category(train_data, flg_categoryId_low, y, median) %>%
    add_feature_per_category(train_data, flg_categoryId_low, y, min) %>%
    add_feature_per_category(train_data, flg_categoryId_low, y, max) %>%
    add_feature_per_category(train_data, flg_categoryId_low, y, sd) %>%

    # flg_category_high
    add_feature_per_category(train_data, flg_categoryId_high, y, mean) %>%
    add_feature_per_category(train_data, flg_categoryId_high, y, median) %>%
    add_feature_per_category(train_data, flg_categoryId_high, y, min) %>%
    add_feature_per_category(train_data, flg_categoryId_high, y, max) %>%
    add_feature_per_category(train_data, flg_categoryId_high, y, sd) %>%

    # flg_no_tags
    add_feature_per_category(train_data, flg_no_tags, y, mean) %>%
    add_feature_per_category(train_data, flg_no_tags, y, median) %>%
    add_feature_per_category(train_data, flg_no_tags, y, min) %>%
    add_feature_per_category(train_data, flg_no_tags, y, max) %>%
    add_feature_per_category(train_data, flg_no_tags, y, sd) %>%

    # flg_no_description
    add_feature_per_category(train_data, flg_no_description, y, mean) %>%
    add_feature_per_category(train_data, flg_no_description, y, median) %>%
    add_feature_per_category(train_data, flg_no_description, y, min) %>%
    add_feature_per_category(train_data, flg_no_description, y, max) %>%
    add_feature_per_category(train_data, flg_no_description, y, sd) %>%

    # flg_url
    add_feature_per_category(train_data, flg_url, y, mean) %>%
    add_feature_per_category(train_data, flg_url, y, median) %>%
    add_feature_per_category(train_data, flg_url, y, min) %>%
    add_feature_per_category(train_data, flg_url, y, max) %>%
    add_feature_per_category(train_data, flg_url, y, sd) %>%

    # flg_japanese
    add_feature_per_category(train_data, flg_japanese, y, mean) %>%
    add_feature_per_category(train_data, flg_japanese, y, median) %>%
    add_feature_per_category(train_data, flg_japanese, y, min) %>%
    add_feature_per_category(train_data, flg_japanese, y, max) %>%
    add_feature_per_category(train_data, flg_japanese, y, sd) %>%

    # flg_emoji
    add_feature_per_category(train_data, flg_emoji, y, mean) %>%
    add_feature_per_category(train_data, flg_emoji, y, median) %>%
    add_feature_per_category(train_data, flg_emoji, y, min) %>%
    add_feature_per_category(train_data, flg_emoji, y, max) %>%
    add_feature_per_category(train_data, flg_emoji, y, sd) %>%

    # flg_official
    add_feature_per_category(train_data, flg_official, y, mean) %>%
    add_feature_per_category(train_data, flg_official, y, median) %>%
    add_feature_per_category(train_data, flg_official, y, min) %>%
    add_feature_per_category(train_data, flg_official, y, max) %>%
    add_feature_per_category(train_data, flg_official, y, sd) %>%

    # flg_movie_number
    add_feature_per_category(train_data, flg_movie_number, y, mean) %>%
    add_feature_per_category(train_data, flg_movie_number, y, median) %>%
    add_feature_per_category(train_data, flg_movie_number, y, min) %>%
    add_feature_per_category(train_data, flg_movie_number, y, max) %>%
    add_feature_per_category(train_data, flg_movie_number, y, sd) %>%


    # categoryId - likes
    add_feature_per_category(train_data, categoryId, likes, mean) %>%
    dplyr::mutate(
      diff_categoryId_mean_likes  = likes - categoryId_mean_likes,
      ratio_categoryId_mean_likes = likes / categoryId_mean_likes
    ) %>%
    add_feature_per_category(train_data, categoryId, likes, median) %>%
    dplyr::mutate(
      diff_categoryId_median_likes  = likes - categoryId_median_likes,
      ratio_categoryId_median_likes = likes / categoryId_median_likes
    ) %>%
    add_feature_per_category(train_data, categoryId, likes, min) %>%
    dplyr::mutate(
      diff_categoryId_min_likes  = likes - categoryId_min_likes,
      ratio_categoryId_min_likes = likes / categoryId_min_likes
    ) %>%
    add_feature_per_category(train_data, categoryId, likes, max) %>%
    dplyr::mutate(
      diff_categoryId_max_likes  = likes - categoryId_max_likes,
      ratio_categoryId_max_likes = likes / categoryId_max_likes
    ) %>%
    add_feature_per_category(train_data, categoryId, likes, sd) %>%

    # categoryId - dislikes
    add_feature_per_category(train_data, categoryId, dislikes, mean) %>%
    dplyr::mutate(
      diff_categoryId_mean_dislikes  = dislikes - categoryId_mean_dislikes,
      ratio_categoryId_mean_dislikes = dislikes / categoryId_mean_dislikes
    ) %>%
    add_feature_per_category(train_data, categoryId, dislikes, median) %>%
    dplyr::mutate(
      diff_categoryId_median_dislikes  = dislikes - categoryId_median_dislikes,
      ratio_categoryId_median_dislikes = dislikes / categoryId_median_dislikes
    ) %>%
    add_feature_per_category(train_data, categoryId, dislikes, min) %>%
    dplyr::mutate(
      diff_categoryId_min_dislikes  = dislikes - categoryId_min_dislikes,
      ratio_categoryId_min_dislikes = dislikes / categoryId_min_dislikes
    ) %>%
    add_feature_per_category(train_data, categoryId, dislikes, max) %>%
    dplyr::mutate(
      diff_categoryId_max_dislikes  = dislikes - categoryId_max_dislikes,
      ratio_categoryId_max_dislikes = dislikes / categoryId_max_dislikes
    ) %>%
    add_feature_per_category(train_data, categoryId, dislikes, sd) %>%

    # categoryId - comment_count
    add_feature_per_category(train_data, categoryId, comment_count, mean) %>%
    dplyr::mutate(
      diff_categoryId_mean_comment_count  = comment_count - categoryId_mean_comment_count,
      ratio_categoryId_mean_comment_count = comment_count / categoryId_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, categoryId, comment_count, median) %>%
    dplyr::mutate(
      diff_categoryId_median_comment_count  = comment_count - categoryId_median_comment_count,
      ratio_categoryId_median_comment_count = comment_count / categoryId_median_comment_count
    ) %>%
    add_feature_per_category(train_data, categoryId, comment_count, min) %>%
    dplyr::mutate(
      diff_categoryId_min_comment_count  = comment_count - categoryId_min_comment_count,
      ratio_categoryId_min_comment_count = comment_count / categoryId_min_comment_count
    ) %>%
    add_feature_per_category(train_data, categoryId, comment_count, max) %>%
    dplyr::mutate(
      diff_categoryId_max_comment_count  = comment_count - categoryId_max_comment_count,
      ratio_categoryId_max_comment_count = comment_count / categoryId_max_comment_count
    ) %>%
    add_feature_per_category(train_data, categoryId, comment_count, sd) %>%

    # comments_disabled - likes
    add_feature_per_category(train_data, comments_disabled, likes, mean) %>%
    dplyr::mutate(
      diff_comments_disabled_mean_likes  = likes - comments_disabled_mean_likes,
      ratio_comments_disabled_mean_likes = likes / comments_disabled_mean_likes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, likes, median) %>%
    dplyr::mutate(
      diff_comments_disabled_median_likes  = likes - comments_disabled_median_likes,
      ratio_comments_disabled_median_likes = likes / comments_disabled_median_likes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, likes, min) %>%
    dplyr::mutate(
      diff_comments_disabled_min_likes  = likes - comments_disabled_min_likes,
      ratio_comments_disabled_min_likes = likes / comments_disabled_min_likes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, likes, max) %>%
    dplyr::mutate(
      diff_comments_disabled_max_likes  = likes - comments_disabled_max_likes,
      ratio_comments_disabled_max_likes = likes / comments_disabled_max_likes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, likes, sd) %>%

    # comments_disabled - dislikes
    add_feature_per_category(train_data, comments_disabled, dislikes, mean) %>%
    dplyr::mutate(
      diff_comments_disabled_mean_dislikes  = dislikes - comments_disabled_mean_dislikes,
      ratio_comments_disabled_mean_dislikes = dislikes / comments_disabled_mean_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, dislikes, median) %>%
    dplyr::mutate(
      diff_comments_disabled_median_dislikes  = dislikes - comments_disabled_median_dislikes,
      ratio_comments_disabled_median_dislikes = dislikes / comments_disabled_median_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, dislikes, min) %>%
    dplyr::mutate(
      diff_comments_disabled_min_dislikes  = dislikes - comments_disabled_min_dislikes,
      ratio_comments_disabled_min_dislikes = dislikes / comments_disabled_min_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, dislikes, max) %>%
    dplyr::mutate(
      diff_comments_disabled_max_dislikes  = dislikes - comments_disabled_max_dislikes,
      ratio_comments_disabled_max_dislikes = dislikes / comments_disabled_max_dislikes
    ) %>%
    add_feature_per_category(train_data, comments_disabled, dislikes, sd) %>%

    # ratings_disabled - comment_counts
    add_feature_per_category(train_data, ratings_disabled, comment_count, mean) %>%
    dplyr::mutate(
      diff_ratings_disabled_mean_comment_count  = comment_count - ratings_disabled_mean_comment_count,
      ratio_ratings_disabled_mean_comment_count = comment_count / ratings_disabled_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, ratings_disabled, comment_count, median) %>%
    dplyr::mutate(
      diff_ratings_disabled_median_comment_count  = comment_count - ratings_disabled_median_comment_count,
      ratio_ratings_disabled_median_comment_count = comment_count / ratings_disabled_median_comment_count
    ) %>%
    add_feature_per_category(train_data, ratings_disabled, comment_count, min) %>%
    dplyr::mutate(
      diff_ratings_disabled_min_comment_count  = comment_count - ratings_disabled_min_comment_count,
      ratio_ratings_disabled_min_comment_count = comment_count / ratings_disabled_min_comment_count
    ) %>%
    add_feature_per_category(train_data, ratings_disabled, comment_count, max) %>%
    dplyr::mutate(
      diff_ratings_disabled_max_comment_count  = comment_count - ratings_disabled_max_comment_count,
      ratio_ratings_disabled_max_comment_count = comment_count / ratings_disabled_max_comment_count
    ) %>%
    add_feature_per_category(train_data, ratings_disabled, comment_count, sd) %>%

    # published_year - likes
    add_feature_per_category(train_data, published_year, likes, mean) %>%
    dplyr::mutate(
      diff_published_year_mean_likes  = likes - published_year_mean_likes,
      ratio_published_year_mean_likes = likes / published_year_mean_likes
    ) %>%
    add_feature_per_category(train_data, published_year, likes, median) %>%
    dplyr::mutate(
      diff_published_year_median_likes  = likes - published_year_median_likes,
      ratio_published_year_median_likes = likes / published_year_median_likes
    ) %>%
    add_feature_per_category(train_data, published_year, likes, min) %>%
    dplyr::mutate(
      diff_published_year_min_likes  = likes - published_year_min_likes,
      ratio_published_year_min_likes = likes / published_year_min_likes
    ) %>%
    add_feature_per_category(train_data, published_year, likes, max) %>%
    dplyr::mutate(
      diff_published_year_max_likes  = likes - published_year_max_likes,
      ratio_published_year_max_likes = likes / published_year_max_likes
    ) %>%
    add_feature_per_category(train_data, published_year, likes, sd) %>%

    # published_year - dislikes
    add_feature_per_category(train_data, published_year, dislikes, mean) %>%
    dplyr::mutate(
      diff_published_year_mean_dislikes  = dislikes - published_year_mean_dislikes,
      ratio_published_year_mean_dislikes = dislikes / published_year_mean_dislikes
    ) %>%
    add_feature_per_category(train_data, published_year, dislikes, median) %>%
    dplyr::mutate(
      diff_published_year_median_dislikes  = dislikes - published_year_median_dislikes,
      ratio_published_year_median_dislikes = dislikes / published_year_median_dislikes
    ) %>%
    add_feature_per_category(train_data, published_year, dislikes, min) %>%
    dplyr::mutate(
      diff_published_year_min_dislikes  = dislikes - published_year_min_dislikes,
      ratio_published_year_min_dislikes = dislikes / published_year_min_dislikes
    ) %>%
    add_feature_per_category(train_data, published_year, dislikes, max) %>%
    dplyr::mutate(
      diff_published_year_max_dislikes  = dislikes - published_year_max_dislikes,
      ratio_published_year_max_dislikes = dislikes / published_year_max_dislikes
    ) %>%
    add_feature_per_category(train_data, published_year, dislikes, sd) %>%

    # published_year - comment_counts
    add_feature_per_category(train_data, published_year, comment_count, mean) %>%
    dplyr::mutate(
      diff_published_year_mean_comment_count  = comment_count - published_year_mean_comment_count,
      ratio_published_year_mean_comment_count = comment_count / published_year_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, published_year, comment_count, median) %>%
    dplyr::mutate(
      diff_published_year_median_comment_count  = comment_count - published_year_median_comment_count,
      ratio_published_year_median_comment_count = comment_count / published_year_median_comment_count
    ) %>%
    add_feature_per_category(train_data, published_year, comment_count, min) %>%
    dplyr::mutate(
      diff_published_year_min_comment_count  = comment_count - published_year_min_comment_count,
      ratio_published_year_min_comment_count = comment_count / published_year_min_comment_count
    ) %>%
    add_feature_per_category(train_data, published_year, comment_count, max) %>%
    dplyr::mutate(
      diff_published_year_max_comment_count  = comment_count - published_year_max_comment_count,
      ratio_published_year_max_comment_count = comment_count / published_year_max_comment_count
    ) %>%
    add_feature_per_category(train_data, published_year, comment_count, sd) %>%
  
    # flg_japanese - likes
    add_feature_per_category(train_data, flg_japanese, likes, mean) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_likes  = likes - flg_japanese_mean_likes,
      ratio_flg_japanese_mean_likes = likes / flg_japanese_mean_likes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, likes, median) %>%
    dplyr::mutate(
      diff_flg_japanese_median_likes  = likes - flg_japanese_median_likes,
      ratio_flg_japanese_median_likes = likes / flg_japanese_median_likes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, likes, min) %>%
    dplyr::mutate(
      diff_flg_japanese_min_likes  = likes - flg_japanese_min_likes,
      ratio_flg_japanese_min_likes = likes / flg_japanese_min_likes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, likes, max) %>%
    dplyr::mutate(
      diff_flg_japanese_max_likes  = likes - flg_japanese_max_likes,
      ratio_flg_japanese_max_likes = likes / flg_japanese_max_likes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, likes, sd) %>%

    # flg_japanese - dislikes
    add_feature_per_category(train_data, flg_japanese, dislikes, mean) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_dislikes  = dislikes - flg_japanese_mean_dislikes,
      ratio_flg_japanese_mean_dislikes = dislikes / flg_japanese_mean_dislikes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, dislikes, median) %>%
    dplyr::mutate(
      diff_flg_japanese_median_dislikes  = dislikes - flg_japanese_median_dislikes,
      ratio_flg_japanese_median_dislikes = dislikes / flg_japanese_median_dislikes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, dislikes, min) %>%
    dplyr::mutate(
      diff_flg_japanese_min_dislikes  = dislikes - flg_japanese_min_dislikes,
      ratio_flg_japanese_min_dislikes = dislikes / flg_japanese_min_dislikes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, dislikes, max) %>%
    dplyr::mutate(
      diff_flg_japanese_max_dislikes  = dislikes - flg_japanese_max_dislikes,
      ratio_flg_japanese_max_dislikes = dislikes / flg_japanese_max_dislikes
    ) %>%
    add_feature_per_category(train_data, flg_japanese, dislikes, sd) %>%

    # flg_japanese - comment_count
    add_feature_per_category(train_data, flg_japanese, comment_count, mean) %>%
    dplyr::mutate(
      diff_flg_japanese_mean_comment_count  = comment_count - flg_japanese_mean_comment_count,
      ratio_flg_japanese_mean_comment_count = comment_count / flg_japanese_mean_comment_count
    ) %>%
    add_feature_per_category(train_data, flg_japanese, comment_count, median) %>%
    dplyr::mutate(
      diff_flg_japanese_median_comment_count  = comment_count - flg_japanese_median_comment_count,
      ratio_flg_japanese_median_comment_count = comment_count / flg_japanese_median_comment_count
    ) %>%
    add_feature_per_category(train_data, flg_japanese, comment_count, min) %>%
    dplyr::mutate(
      diff_flg_japanese_min_comment_count  = comment_count - flg_japanese_min_comment_count,
      ratio_flg_japanese_min_comment_count = comment_count / flg_japanese_min_comment_count
    ) %>%
    add_feature_per_category(train_data, flg_japanese, comment_count, max) %>%
    dplyr::mutate(
      diff_flg_japanese_max_comment_count  = comment_count - flg_japanese_max_comment_count,
      ratio_flg_japanese_max_comment_count = comment_count / flg_japanese_max_comment_count
    ) %>%
    add_feature_per_category(train_data, flg_japanese, comment_count, sd)
}

