# TODO

# train_rmse: 0.8945769, test_rmse: 0.9176859 - Baseline
# train_rmse: 0.8941846, test_rmse: 0.9165181 - ↑tag_point

# train_rmse: 0.8814297, test_rmse: 0.9043645 - ↑avg_recent_y
# train_rmse: 0.8809111, test_rmse: 0.9038883 - ↑weighted_avg_recent_y(採用)
# train_rmse: 0.8815549, test_rmse: 0.9044294 - ↑avg_recent_y + weighted_avg_recent_y まぜるな危険という事なのかなw

# train_rmse: 0.8594921, test_rmse: 0.8838593 - ↑flg_low_y_1000
# train_rmse: 0.8519635, test_rmse: 0.8768221 - ↑flg_low_y_5000
# train_rmse: 0.8496022, test_rmse: 0.8736899 - ↑flg_low_y_10000
# train_rmse: 0.8611932, test_rmse: 0.8843553 - ↑flg_low_y_30000
# train_rmse: 0.845585 , test_rmse: 0.8711749 - ↑flg_low_y_10000 + flg_low_y_5000
# train_rmse: 0.8417701, test_rmse: 0.8669427 - ↑flg_low_y_10000 + flg_low_y_5000 + flg_low_y_1000
# train_rmse: 0.8377545, test_rmse: 0.8638358 - flg_low_y_10000 + flg_low_y_5000 + flg_low_y_1000 + flg_low_y_30000

# train_rmse: 0.8377438, test_rmse: 0.8637166 - ハイパラチューニング


library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/LR/02/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  add_extra_features_train()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Model Definition --------------------------------------------------------

model <- parsnip::linear_reg(
  mode = "regression",
  penalty = parsnip::varying(),
  mixture = parsnip::varying()
) %>%
  parsnip::set_engine(engine = "glmnet")


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- tidyr::crossing(
  penalty = c(0.0001),
  mixture = c(0.9571429)
)
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 5))

system.time({
  set.seed(1025)

  df.results <-

    # ハイパーパラメータの組み合わせごとにループ
#    furrr::future_pmap_dfr(df.grid.params, function(...) {
    purrr::pmap_dfr(df.grid.params, function(...) {

      # パラメータの適用
      model.applied <- parsnip::set_args(model, ...)

      # モデル構築用の説明変数を指定
      formula <- (
        y ~
        special_segment
        + special_segment:(
          categoryId
          + pc1
          + likes
          + dislikes
          + comment_count
          + title_length
          + tag_characters
          + tag_count
          + description_length
          + diff_likes_dislikes
          + sum_likes_dislikes
          + days_from_published
          + flg_japanese
          + published_dow
          + published_month
          + published_year
          + flg_no_tags
          + ratio_likes
          + ratio_comments_likedis
          + flg_no_description
          + description_length
          + flg_url
          + url_count
          + flg_emoji
          + flg_official
          + flg_movie_number
          + flg_categoryId_low
          + categoryId_mean_y
          + categoryId_min_y
          + published_year_mean_y
          + flg_japanese_mean_y
          + categoryId_max_comment_count
          + published_year_mean_pc1
          + comments_disabled_mean_pc1
          + diff_comments_disabled_mean_dislikes
          + published_year_median_likes
          + diff_published_year_mean_dislikes
          + tag_point
          + weighted_avg_recent_y
          + flg_low_y_1000
          + flg_low_y_5000
          + flg_low_y_10000
          + flg_low_y_30000
        )
      )

      # クロスバリデーションの分割ごとにモデル構築&評価
#      purrr::map_dfr(
      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval,
        recipe = recipe,
        model = model.applied,
        formula = formula
        ,.options = furrr::future_options(seed = 1025L)
      ) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
#    }, .options = furrr::future_options(seed = 1025L)) %>%
    }) %>%

    # 評価結果とパラメータを結合
    dplyr::bind_cols(df.grid.params) %>%

    # 評価スコアの順にソート(昇順)
    dplyr::arrange(
      test_rmse
    ) %>%

    dplyr::select(
      colnames(df.grid.params),

      train_rmse,
      test_rmse
    )
})
