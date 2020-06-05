# TODO
# - tags で bin counting

# tree_depth: xx, mtry: xx, min_n: xx, loss_reduction: xxxxxxxxx, sample_size: xxx, train_mse: xxxxxxxxx, test_mse: xxxxxxxxx - xxx

### learning_rate: 0.1 ###
# tree_depth: 11, mtry: 20, min_n: 20, loss_reduction: 0.5011872, sample_size: 0.8, train_mse: 0.5290893, test_mse: 0.7910878 - xxx
# tree_depth: 13, mtry: 20, min_n: 20, loss_reduction: 0.5011872, sample_size: 0.8, train_mse: 0.4881714, test_mse: 0.7916857 - xxx
# tree_depth: 10, mtry: 20, min_n: 20, loss_reduction: 0.5011872, sample_size: 0.8, train_mse: 0.5578207, test_mse: 0.7934653 - xxx
# tree_depth: 10, mtry: 20, min_n: 17, loss_reduction: 0.5011872, sample_size: 0.8, train_mse: 0.5381899, test_mse: 0.7921496 - xxx
# tree_depth: 10, mtry: 20, min_n: 10, loss_reduction: 0.5011872, sample_size: 0.8, train_mse: 0.4861050, test_mse: 0.7880758 - xxx
# tree_depth: 10, mtry: 20, min_n:  7, loss_reduction: 0.5011872, sample_size: 0.8, train_mse: 0.4572992, test_mse: 0.7882800 - xxx
# tree_depth: 10, mtry: 20, min_n:  7, loss_reduction: 0.6309573, sample_size: 0.8, train_mse: 0.4599571, test_mse: 0.7869657 - xxx
# tree_depth: 10, mtry: 20, min_n:  7, loss_reduction: 0.7340308, sample_size: 0.8, train_mse: 0.4685912, test_mse: 0.7848857 - xxx
# tree_depth: 10, mtry: 20, min_n:  7, loss_reduction: 0.7340308, sample_size: 0.79, train_mse: 0.4695275, test_mse: 0.7865898 - xxx
# tree_depth: 11, mtry: 22, min_n:  7, loss_reduction: 0.7340308, sample_size: 0.8, train_mse: 0.4269206, test_mse: 0.7855121 - xxx
# tree_depth: 11, mtry: 29, min_n:  7, loss_reduction: 0.7340308, sample_size: 0.8, train_mse: 0.4431623, test_mse: 0.7937633 - xxx

### learning_rate: 0.01 ###
# tree_depth: 11, mtry: 29, min_n:  7, loss_reduction: 0.7340308, sample_size: 0.8, train_mse: 0.4850193, test_mse: 0.784057 - xxx

library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/XGB_01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)
#recipes::prep(recipe) %>% recipes::juice() %>% summary()


# Model Definition --------------------------------------------------------

model <- parsnip::boost_tree(
  mode = "regression",
  learn_rate = 0.01,
  trees = 774,
  
  tree_depth = parsnip::varying(),
  mtry = parsnip::varying(),
  
  min_n = parsnip::varying(),
  sample_size = parsnip::varying(),
  
  loss_reduction = parsnip::varying()
) %>%
  parsnip::set_engine(
    engine = "xgboost",
    nthread = 1
  )


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- dials::grid_regular(
  dials::tree_depth(range = c(11, 11)),
  dials::mtry(range = c(29, 29)),
  dials::min_n(range = c(7, 7)),
  dials::loss_reduction(range = c(-0.1342857, -0.1342857)),
  levels = 8
) %>%
  tidyr::crossing(
    sample_size = 0.8
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

      # パラメータの適用
      model.applied <- parsnip::set_args(model, ...)

      # モデル構築用の説明変数を指定
      formula <- (
        y ~
          categoryId
        + likes
        + dislikes
        + comment_count
        + comments_disabled
        + ratings_disabled
        + published_year
        + published_month_x + published_month_y
        + channel_title_length
        + flg_categoryId_low
        + flg_categoryId_high
        + flg_no_tags
        + tag_characters
        + url_count
        + days_from_published
        + sum_likes_dislikes
        + ratio_comments_likedis
        + flg_japanese

        + categoryId_median_y
        + categoryId_min_y
        + categoryId_max_comment_count
        + diff_categoryId_max_comment_count
        + ratio_published_year_median_dislikes
      )

      # クロスバリデーションの分割ごとにモデル構築&評価
      purrr::map_dfr(df.cv$splits, train_and_eval, recipe = recipe, model = model.applied, formula = formula) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
    }, .options = furrr::future_options(seed = 1025L)) %>%

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
df.results
