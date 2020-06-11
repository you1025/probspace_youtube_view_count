# TODO
# - interaction で書き換える
# - Target Encoding を書き換える(OK)
#   - across を導入する(OK)
#   - special_category の集約値を追加する(OK)

# train_rmse: 0.8850716, test_rmse: 0.905594  - xxx
# train_rmse: 0.7854593, test_rmse: 0.7955688 - special_category の集約値を追加 ほんとかな・・・w
# train_rmse: 0.7867538, test_rmse: 0.7966115 - 集約値を special_category の交互作用対象外に(考え方としては正しいと思うのでこのままで)

# たぶんリークしてる・・・orz
# train_rmse: 0.9026673, test_rmse: 0.9262622 - 集約系を全部はずした
# train_rmse: 0.8992932, test_rmse: 0.9224845 - y 集約系の除外を解除
# train_rmse: 0.8991157, test_rmse: 0.9225918 - diff_categoryId_mean_pc1 + categoryId_max_comment_count
# train_rmse: 0.8982342, test_rmse: 0.9219909 - published_year_mean_pc1 + diff_published_year_mean_pc1 + ratio_published_year_mean_pc1

# キタ！！！
# train_rmse: 0.7870132, test_rmse: 0.7982192 - published_year_median_likes + ratio_published_year_median_likes + diff_published_year_mean_dislikes + ratio_published_year_median_dislikes

# 一旦除外して続き
# train_rmse: 0.8982493, test_rmse: 0.9214342 - comments_disabled_mean_pc1 + diff_comments_disabled_mean_pc1 + ratio_comments_disabled_mean_pc1 + diff_comments_disabled_mean_dislikes
# train_rmse: 0.8982493, test_rmse: 0.9214342 - flg_japanese_sd_comment_count

# リーク(？)調査 ひとつずつ検証
# ratings_disabled が special_segment に含まれてるので likes / dislikes 系の ratio は必ず NA が発生
# => 線形モデルでは likes/dislikes の ratio は除外する事で対応(ツリーモデルは可)
# train_rmse: 0.89485,   test_rmse: 0.919152  - published_year_median_likes
# train_rmse: 0.7880956, test_rmse: 0.7989003 - ratio_published_year_median_likes 犯人！
# train_rmse: 0.895621,  test_rmse: 0.9196475 - diff_published_year_mean_dislikes
# train_rmse: 0.7914084, test_rmse: 0.8024325 - ratio_published_year_median_dislikes こいつも共犯？？？

# train_rmse: 0.8945604, test_rmse: 0.9191601 - NA 系を除外
# train_rmse: 0.8945646, test_rmse: 0.9191317 - ↑- diff_categoryId_mean_pc1
# train_rmse: 0.8945832, test_rmse: 0.9194948 - pc1 の集約系を全て除外
# train_rmse: 0.8943279, test_rmse: 0.9192518 - published_year_median_y
# train_rmse: 0.8944994, test_rmse: 0.9189914 - ↑flg_japanese_mean_y
# train_rmse: 0.8945378, test_rmse: 0.9195232 - flg_japanese_median_y
# train_rmse: 0.8945425, test_rmse: 0.9190704 - flg_japanese_min_y
# train_rmse: 0.8945132, test_rmse: 0.9189972 - flg_japanese_max_y
# train_rmse: 0.8945185, test_rmse: 0.9194221 - flg_japanese_sd_y
# train_rmse: 0.8965938, test_rmse: 0.9192957 - flg_no_xxx を除外 あれ・・・

# train_rmse: 0.8943885, test_rmse: 0.9191866 - チューニング
# train_rmse: 0.8950711, test_rmse: 0.9188556 - 集約系に交互作用を適用(pc1は除外)(意味あるのかな・・・)
# train_rmse: 0.8945769, test_rmse: 0.9176859 - ratio pc1 のみ除外
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx


library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/LR_05/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

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

# df.grid.params <- dials::grid_regular(
#   dials::penalty(c(-6.0, -5.0)),
#   dials::mixture(c(0.95, 1.0)),
#   levels = 4
# )
df.grid.params <- tidyr::crossing(
  penalty = c(0.00001),
  mixture = c(0.9666667)
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
df.results
