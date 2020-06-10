# TODO
# - 新方式で書き換える(OK)
# - PCA の適用(OK)

# train_rmse: xxxxxxxx, test_rmse: xxxxxxxx - xxx

# train_rmse: 1.008577, test_rmse: 1.01157  - Baseline
# train_rmse: 1.008529, test_rmse: 1.011616 - PCA(1つ)
# train_rmse: 1.008531, test_rmse: 1.011599 - PCA(2つ)
# train_rmse: 1.010093, test_rmse: 1.013166 - diff_likes_dislikes / sum_likes_dislikes の除去

# train_rmse: 1.078312, test_rmse: 1.880393 - PCA(1つ) のみ
# train_rmse: 1.012257, test_rmse: 1.795412 - PCA(2つ) のみ
# train_rmse: 1.010102, test_rmse: 1.925502 - likes
# train_rmse: 1.010125, test_rmse: 1.538354 - dislikes
# train_rmse: 1.010125, test_rmse: 1.538354 - comment_count
# train_rmse: 1.010129, test_rmse: 1.657097 - pca1 + dislikes + comment_count
# train_rmse: 1.023998, test_rmse: 1.029117 - dislikes + comment_count

# pca 時に対数変換なし
# train_rmse: 1.023993, test_rmse: 1.029096 - pc1 + dislikes + comment_count
# train_rmse: 1.0237,   test_rmse: 1.029436 - pc1 + pc2 + dislikes + comment_count
# train_rmse: 1.010044, test_rmse: 1.012933 - pc1 + likes + dislikes + comment_count
# train_rmse: 1.010106, test_rmse: 1.013026 - likes + dislikes + comment_count
# train_rmse: 1.978139, test_rmse: 2.058668 - pc1
# train_rmse: 1.970244, test_rmse: 2.06584  - pc1 + pc2
# train_rmse: 1.09985,  test_rmse: 1.108165 - pc1 + likes
# train_rmse: 1.027383, test_rmse: 1.029395 - pc1 + dislikes
# train_rmse: 1.411095, test_rmse: 1.645145 - pc1 + comment_count
# train_rmse: 1.023993, test_rmse: 1.029096 - pc1 + dislikes + comment_count
# train_rmse: 1.010044, test_rmse: 1.012933 - pc1 + likes + dislikes + comment_count
# train_rmse: 1.010106, test_rmse: 1.013026 - likes + dislikes + comment_count
# train_rmse: 1.009739, test_rmse: 1.013617 - pc1 + pc2 + likes + dislikes + comment_count
# train_rmse: 1.0093,   test_rmse: 1.012309 - pc1 + likes + dislikes + comment_count + diff_likes_dislikes
# train_rmse: 1.008395, test_rmse: 1.011412 - pc1 + likes + dislikes + comment_count + diff_likes_dislikes + sum_likes_dislikes

# PCA を likes & dislikes で実施
# train_rmse: 1.008308, test_rmse: 1.01129  - pc1 + likes + dislikes + comment_count + diff_likes_dislikes + sum_likes_dislikes
# train_rmse: 1.971202, test_rmse: 2.047324 - pc1
# train_rmse: 1.09912,  test_rmse: 1.107054 - pc1 + likes
# train_rmse: 1.02734,  test_rmse: 1.029337 - pc1 + dislikes
# train_rmse: 1.407443, test_rmse: 1.637053 - pc1 + comment_count
# train_rmse: 1.009968, test_rmse: 1.012725 - pc1 + likes + dislikes
# train_rmse: 1.009959, test_rmse: 1.012812 - pc1 + likes + dislikes + comment_count
# train_rmse: 1.009189, test_rmse: 1.012092 - pc1 + likes + dislikes + diff_likes_dislikes
# train_rmse: 1.008326, test_rmse: 1.011246 - pc1 + likes + dislikes + diff_likes_dislikes + sum_likes_dislikes

# train_rmse: 1.010527, test_rmse: 1.013738 - 除去: flg_emoji / flg_official / flg_movie_number
# train_rmse: 1.008608, test_rmse: 1.011729 - 除去: flg_emoji / flg_movie_number
# train_rmse: 1.008359, test_rmse: 1.01152  - 除去: flg_emoji

# train_rmse: 1.008315, test_rmse: 1.011224 - flg_categoryId_low
# train_rmse: 1.008394, test_rmse: 1.0113   - flg_categoryId_high
# train_rmse: 1.008387, test_rmse: 1.011271 - days_from_published

# train_rmse: 1.008388, test_rmse: 1.011247 - categoryId_median_y
# train_rmse: 1.008399, test_rmse: 1.011247 - categoryId_mean_y

# train_rmse: 1.008318, test_rmse: 1.011202 - categoryId_min_y
# train_rmse: 1.008404, test_rmse: 1.011255 - categoryId_max_y

# train_rmse: 1.008324, test_rmse: 1.01122  - categoryId_max_comment_count
# train_rmse: 1.008318, test_rmse: 1.011202 - categoryId_mean_comment_count
# train_rmse: 1.0083,   test_rmse: 1.011295 - diff_categoryId_max_comment_count
# train_rmse: 1.008315, test_rmse: 1.011291 - diff_categoryId_mean_comment_count
# train_rmse: 0.9964813,test_rmse: 0.9989963- ratio_published_year_median_dislikes

# train_rmse: 0.9878123,test_rmse: 0.9909929- published_year_mean_y
# train_rmse: 0.9878123,test_rmse: 0.9909935- flg_japanese_mean_y
# train_rmse: 0.9878123,test_rmse: 0.9909935- flg_japanese_median_y
# train_rmse: 0.9878281, test_rmse: 0.9910526 - diff_categoryId_mean_comment_count
# train_rmse: 0.987906, test_rmse: 0.9909467 - ↑categoryId_max_comment_count
# train_rmse: 0.9879161,test_rmse: 0.9908761 - ↑diff_comments_disabled_mean_dislikes
# train_rmse: 0.9873947,test_rmse: 0.9902188- ↑published_year_median_likes
# train_rmse: 0.9777087,test_rmse: 0.9797361- ↑ratio_published_year_median_likes
# train_rmse: 0.9777087,test_rmse: 0.9797361- published_year_min_likes
# train_rmse: 0.9777028,test_rmse: 0.9797402- published_year_sd_likes
# train_rmse: 0.9734845,test_rmse: 0.9757343- ↑diff_published_year_mean_dislikes
# train_rmse: 0.9740586,test_rmse: 0.9762581- diff_flg_japanese_max_dislikes
# train_rmse: 0.9738831,test_rmse: 0.9761292- diff_flg_japanese_max_comment_count
# train_rmse: 0.9734847,test_rmse: 0.975734 - flg_japanese_sd_comment_count

# train_rmse: 0.9734848,test_rmse: 0.9757334- comments_disabled_mean_pc1
# train_rmse: 0.973484, test_rmse: 0.9757323- ↑diff_comments_disabled_mean_pc1
# train_rmse: 0.9732271,test_rmse: 0.9755383- ↑ratio_comments_disabled_mean_pc1
# train_rmse: 0.9732271,test_rmse: 0.9755383- categoryId_mean_pc1
# train_rmse: 0.9732277,test_rmse: 0.9755364- ↑diff_categoryId_mean_pc1
# train_rmse: 0.9731788,test_rmse: 0.9757162- ratio_categoryId_mean_pc1
# train_rmse: 0.9732683,test_rmse: 0.9754304- ↑published_year_mean_pc1
# train_rmse: 0.9732712,test_rmse: 0.9754293- ↑diff_published_year_mean_pc1
# train_rmse: 0.9732532,test_rmse: 0.9753529- ↑ratio_published_year_mean_pc1

# train_rmse: 0.9732532, test_rmse: 0.9753529 - Baseline
# train_rmse: 0.9746653, test_rmse: 0.9769661 - special_segment
# train_rmse: 0.9724603, test_rmse: 0.974532  - ↑special_segment:likes
# train_rmse: 0.9725581, test_rmse: 0.9746267 - ↑spsecial_segment:dislikes
# train_rmse: 0.9741061, test_rmse: 0.9782567 - special_segment:pc1
# train_rmse: 0.9615414, test_rmse: 0.963721  - ↑↑special_segment:comment_count
# train_rmse: 0.9722591, test_rmse: 0.9742889 - ↑special_segment:diff_likes_dislikes
# train_rmse: 0.9724615, test_rmse: 0.9745534 - ↑special_segment:sum_likes_dislikes

# train_rmse: 0.960961,  test_rmse: 0.9639496 - special_segment:comment_count + special_segment:sum_likes_dislikes
# train_rmse: 0.9611222, test_rmse: 0.9638941 - special_segment:comment_count + special_segment:diff_likes_dislikes
# train_rmse: 0.961305,  test_rmse: 0.9642746 - special_segment:comment_count + special_segment:likes
# train_rmse: 0.9611266, test_rmse: 0.9637807 - special_segment:comment_count + special_segment:dislikes

# 4
# train_rmse: 0.9612251, test_rmse: 0.9635096 - xxx
# train_rmse: 0.961291,  test_rmse: 0.9640106 - special_segment:diff_likes_dislikes
# train_rmse: 0.9608099, test_rmse: 0.9636189 - special_segment:sum_likes_dislikes
# train_rmse: 0.9615341, test_rmse: 0.9643687 - special_segment
# train_rmse: 0.9604061, test_rmse: 0.9633171 - special_segment:(likes + dislikes + comment_count)
# train_rmse: 0.9427593, test_rmse: 0.9472097 - special_segment:(likes + dislikes + comment_count + title_length + tag_characters + tag_count + description_length)
# train_rmse: 0.9356829, test_rmse: 0.9408433 - xxx
# train_rmse: 0.8966484, test_rmse: 0.915128  - xxx
# train_rmse: 0.8861519, test_rmse: 0.9079322 - xxx
# train_rmse: 0.8852182, test_rmse: 0.9074982 - チューニング
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx

library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/LR_04/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)
#recipes::prep(recipe) %>% recipes::juice() %>% summary()


# Model Definition --------------------------------------------------------

model <- parsnip::linear_reg(
  mode = "regression",
  penalty = parsnip::varying(),
  mixture = parsnip::varying()
) %>%
  parsnip::set_engine(engine = "glmnet")


# Hyper Parameter ---------------------------------------------------------

# df.grid.params <- dials::grid_regular(
#   dials::penalty(c(-5.0, -4.0)),
#   dials::mixture(c(0.95, 0.95)),
#   levels = 8
# )
df.grid.params <- tidyr::crossing(
  penalty = c(0.0001),
  mixture = c(0.975)
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
          + ratio_published_year_median_dislikes
          + published_year_mean_y
          + categoryId_max_comment_count
          + diff_comments_disabled_mean_dislikes
          + published_year_median_likes
          + ratio_published_year_median_likes
          + diff_published_year_mean_dislikes
          + flg_japanese_sd_comment_count
          + comments_disabled_mean_pc1
          + diff_comments_disabled_mean_pc1
          + ratio_comments_disabled_mean_pc1
          + diff_categoryId_mean_pc1
          + published_year_mean_pc1
          + diff_published_year_mean_pc1
          + ratio_published_year_mean_pc1
        )
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
df.results
