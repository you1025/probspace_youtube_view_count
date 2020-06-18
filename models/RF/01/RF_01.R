# TODO

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx

# train_rmse: 0.472205, test_rmse: 0.8239852  - Baseline

# train_rmse: 0.5446227, test_rmse: 0.8771576 - 主要項目のみ(mtry=5)
# train_rmse: 0.5201126, test_rmse: 0.8680987 - ↑tag_count
# train_rmse: 0.5134144, test_rmse: 0.8649992 - ↑tag_characters
# train_rmse: 0.5040598, test_rmse: 0.8593231 - ↑description_length
# train_rmse: 0.5024688, test_rmse: 0.8535455 - ↑days_from_published
# train_rmse: 0.505915,  test_rmse: 0.8574724 - diff_likes_dislikes
# train_rmse: 0.502767,  test_rmse: 0.8572245 - sum_likes_dislikes
# train_rmse: 0.4801055, test_rmse: 0.8282298 - ↑flg_japanese
# train_rmse: 0.4819049, test_rmse: 0.8274716 - ↑flg_official
# train_rmse: 0.4796032, test_rmse: 0.8201797 - ↑flg_categoryId_high
# train_rmse: 0.484889,  test_rmse: 0.8206467 - flg_categoryId_low
# train_rmse: 0.4796032, test_rmse: 0.8201797 - published_year をカテゴリ値にする(変わらないのかい。。。当たり前かw)
# train_rmse: 0.4777822, test_rmse: 0.8200839 - ↑published_month
# train_rmse: 0.479256,  test_rmse: 0.8204278 - published_dow
# train_rmse: 0.4777116, test_rmse: 0.8147866 - ↑channel_title_length
# train_rmse: 0.4743431, test_rmse: 0.8147491 - ↑flg_url
# train_rmse: 0.4758733, test_rmse: 0.8143622 - ↑url_count
# train_rmse: 0.4803065, test_rmse: 0.81681   - flg_emoji
# train_rmse: 0.480867,  test_rmse: 0.8166156 - flg_movie_number
# train_rmse: 0.4767685, test_rmse: 0.8131031 - ↑comments_ratings_disabled_japanese
# train_rmse: 0.4822139, test_rmse: 0.8150782 - flg_comments_ratings_disabled_japanese_high
# train_rmse: 0.481162,  test_rmse: 0.8148804 - flg_comments_ratings_disabled_japanese_very_high
# train_rmse: 0.4806148, test_rmse: 0.8148303 - flg_comments_ratings_disabled_japanese_low
# train_rmse: 0.4806895, test_rmse: 0.8151969 - flg_comments_ratings_disabled_japanese_very_low
# train_rmse: 0.4744879, test_rmse: 1.236331  - pc1 ？？？なんでや
# train_rmse: 0.478646,  test_rmse: 0.8167158 - special_segment

# train_rmse: 0.478753,  test_rmse: 0.8162147 - categoryId_mean_y
# train_rmse: 0.479156,  test_rmse: 0.8164388 - categoryId_median_y
# train_rmse: 0.4772441, test_rmse: 0.8144077 - categoryId_min_y
# train_rmse: 0.4767183, test_rmse: 0.8121575 - ↑categoryId_max_y
# train_rmse: 0.4797591, test_rmse: 0.8158303 - categoryId_sd_y
# train_rmse: 0.477559,  test_rmse: 0.8127897 - published_year_mean_y
# train_rmse: 0.4780758, test_rmse: 0.8124688 - published_year_median_y
# train_rmse: 0.4797706, test_rmse: 0.815051  - published_year_min_y
# train_rmse: 0.4803661, test_rmse: 0.8155934 - published_year_max_y
# train_rmse: 0.4789669, test_rmse: 0.8144379 - published_year_sd_y
# train_rmse: 0.4791565, test_rmse: 0.8146224 - flg_japanese_mean_y
# train_rmse: 0.4791932, test_rmse: 0.8143673 - flg_japanese_median_y
# train_rmse: 0.4780725, test_rmse: 0.8142081 - flg_japanese_min_y
# train_rmse: 0.4782307, test_rmse: 0.8133788 - flg_japanese_max_y
# train_rmse: 0.4796121, test_rmse: 0.8144509 - flg_japanese_sd_y

# train_rmse: 0.4506065, test_rmse: 0.8085844 - mtry = 10

# train_rmse: 0.4581109, test_rmse: 0.8048675 - Baseline
# train_rmse: 0.3885913, test_rmse: 0.8010822 - max.depth = 16
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx


library(tidyverse)
library(tidymodels)
library(furrr)

source("models/RF/01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Model Definition --------------------------------------------------------

model <- parsnip::rand_forest(
  mode = "regression",
  mtry  = parsnip::varying(),
  trees = parsnip::varying(),
  min_n = parsnip::varying()
) %>%
  parsnip::set_engine(
    engine = "ranger",
    num.threads = 1,
    seed = 1025
  )


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- dials::grid_regular(
  dials::mtry(range = c(10, 10)),
  dials::trees(range = c(1000, 1000)),
  dials::min_n(range = c(3, 3)),
  levels = 1
) %>%
  tidyr::crossing(
    max.depth = seq(16, 16)
  )
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 8))

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
          categoryId
        + likes
        + dislikes
        + comment_count
        + comments_disabled
        + ratings_disabled
        + title_length
        + published_year
        + tag_count
        + tag_characters
        + description_length
        + days_from_published
        + flg_japanese
        + flg_official
        + flg_categoryId_high
        + published_month
        + channel_title_length
        + flg_url
        + url_count
        + comments_ratings_disabled_japanese
        + categoryId_max_y
        + categoryId_mean_likes
        + categoryId_median_likes
        + categoryId_min_likes
        + categoryId_max_likes
        + categoryId_mean_dislikes
        + categoryId_max_dislikes
        + categoryId_sd_dislikes
        + flg_japanese_mean_comment_count
        + comments_ratings_disabled_japanese_sd_y
        + comments_ratings_disabled_japanese_sd_likes
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
