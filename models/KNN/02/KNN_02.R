# TODO

# train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx

# train_rmse: 0.6965471, test_rmse: 0.8616238 - Baseline
# train_rmse: 0.6994751, test_rmse: 0.863709  - tag_point

# train_rmse: 0.6957005, test_rmse: 0.8596976 - ↑avg_recent_y(☆)
# train_rmse: 0.6956782, test_rmse: 0.8598099 - ↑weighted_avg_recent_y
# train_rmse: 0.6980431, test_rmse: 0.8614268 - avg_recent_y + weighted_avg_recent_y

# train_rmse: 0.6949562, test_rmse: 0.8596146 - ↑flg_low_y_1000
# train_rmse: 0.691176 , test_rmse: 0.8580476 - ↑flg_low_y_5000
# train_rmse: 0.6888586, test_rmse: 0.8539538 - ↑flg_low_y_10000
# train_rmse: 0.6887269, test_rmse: 0.8522104 - ↑flg_low_y_30000
# train_rmse: 0.6848322, test_rmse: 0.8503069 - ↑flg_low_y_30000 + flg_low_y_10000
# train_rmse: 0.6841305, test_rmse: 0.8515139 - flg_low_y_30000 + flg_low_y_10000 + flg_low_y_5000
# train_rmse: 0.6845128, test_rmse: 0.8500619 - ↑flg_low_y_30000 + flg_low_y_10000 + flg_low_y_1000

# train_rmse: 0.7096855, test_rmse: 0.8491482 - ハイパラチューニング


library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/KNN/02/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean() %>%
  add_extra_features_train()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Model Definition --------------------------------------------------------

model <- parsnip::nearest_neighbor(
  mode = "regression",
  neighbors = parsnip::varying()
) %>%
  parsnip::set_engine(engine = "kknn")


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- dials::grid_regular(
  dials::neighbors(range = c(25L, 25L)),
  levels = 1
)
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 8))

system.time({
  set.seed(1025)

  df.results <-

    # ハイパーパラメータの組み合わせごとにループ
    furrr::future_pmap_dfr(df.grid.params, function(...) {
#    purrr::pmap_dfr(df.grid.params, function(...) {

      # パラメータの適用
      model.applied <- parsnip::set_args(model, ...)

      # モデル構築用の説明変数を指定
      formula <- (
        y ~
          likes
        + dislikes
        + title_length
        + tag_characters
        + description_length
        + url_count
        + comments_disabled
        + ratings_disabled
        + published_year
        + sum_likes_dislikes
        + diff_likes_dislikes
        + (special_segment_others + special_segment_ratings_disabled + special_segment_ratings_abled_low_comments)
        + (special_segment_others + special_segment_ratings_disabled + special_segment_ratings_abled_low_comments):(
          likes
          + dislikes
          + sum_likes_dislikes
          + sum_likes_dislikes_comments
          + flg_japanese
          + days_from_published
        )
        + categoryId_mean_y
        + categoryId_median_y
        + categoryId_min_y
        + categoryId_max_y
        + published_year_mean_y
        + flg_japanese_mean_y
        + flg_japanese_median_y
        + avg_recent_y
        + flg_low_y_1000
        + flg_low_y_10000
        + flg_low_y_30000
      )

      # クロスバリデーションの分割ごとにモデル構築&評価
      purrr::map_dfr(
#      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval,
        recipe = recipe,
        model = model.applied,
        formula = formula
#        ,.options = furrr::future_options(seed = 1025L)
      ) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
    }, .options = furrr::future_options(seed = 1025L)) %>%
#    }) %>%

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
