# TODO

# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx

# neighbors: 20, train_rmse: 0.7925282,  test_rmse: 0.9439161  - Baseline
# neighbors: 20, train_rmse: 0.07843984, test_rmse: 0.09468233 - 標準化

# ここから先 special_segment
# neighbors: 20, train_rmse: 0.7800315,  test_rmse: 0.9420086  - ↑likes
# neighbors: 20, train_rmse: 0.7845961,  test_rmse: 0.9433231  - special_segment_others を除去(☓)
# neighbors: 20, train_rmse: 0.7676744,  test_rmse: 0.9345753  - ↑dislikes
# neighbors: 20, train_rmse: 0.7768971,  test_rmse: 0.951196   - title_length
# neighbors: 20, train_rmse: 0.765567,   test_rmse: 0.9363585  - tag_characters
# neighbors: 20, train_rmse: 0.7699555,  test_rmse: 0.9378714  - description_length
# neighbors: 20, train_rmse: 0.7684032,  test_rmse: 0.93874    - url_count
# neighbors: 20, train_rmse: 0.7662592,  test_rmse: 0.9335777  - ↑days_from_published(うえ)
# neighbors: 20, train_rmse: 0.7608981,  test_rmse: 0.9304966  - ↑days_from_published(なか)
# neighbors: 20, train_rmse: 0.7588007,  test_rmse: 0.9296235  - ↑special_segment_***
# neighbors: 20, train_rmse: 0.7547115,  test_rmse: 0.9283427  - ↑diff_likes_dislikes(なか)
# neighbors: 20, train_rmse: 0.7553411,  test_rmse: 0.927023   - ↑diff_likes_dislikes(うえ)
# neighbors: 20, train_rmse: 0.7535467,  test_rmse: 0.9279289  - diff_likes_dislikes(両方)
# neighbors: 20, train_rmse: 0.7534461,  test_rmse: 0.9254286  - ↑sum_likes_dislikes(うえ)
# neighbors: 20, train_rmse: 0.751854,   test_rmse: 0.9258631  - sum_likes_dislikes(なか)
# neighbors: 20, train_rmse: 0.7508267,  test_rmse: 0.9251349  - ↑sum_likes_dislikes(両方)
# neighbors: 20, train_rmse: 0.7514139,  test_rmse: 0.9260993  - ratio_likes(うえ)
# neighbors: 20, train_rmse: 0.7499459,  test_rmse: 0.9256757  - ratio_likes(なか)
# neighbors: 20, train_rmse: 0.7500523,  test_rmse: 0.9258611  - ratio_likes(両方)
# neighbors: 20, train_rmse: 0.7503058,  test_rmse: 0.9246679  - ↑sum_likes_dislikes_comments(うえ)
# neighbors: 20, train_rmse: 0.7492378,  test_rmse: 0.9245141  - ↑sum_likes_dislikes_comments(なか)
# neighbors: 20, train_rmse: 0.7491377,  test_rmse: 0.9246034  - sum_likes_dislikes_comments(両方)
# neighbors: 20, train_rmse: 0.7492386,  test_rmse: 0.9248209  - ratio_comments_likedis(うえ)
# neighbors: 20, train_rmse: 0.7487648,  test_rmse: 0.9251707  - ratio_comments_likedis(なか)
# neighbors: 20, train_rmse: 0.7472272,  test_rmse: 0.9220354  - ↑flg_japanese(なか)
# neighbors: 20, train_rmse: 0.7478344,  test_rmse: 0.9230591  - flg_japanese(両方)
# neighbors: 20, train_rmse: 0.7414613,  test_rmse: 0.9265294  - flg_official(うえ)
# neighbors: 20, train_rmse: 0.7417528,  test_rmse: 0.9288716  - flg_official(なか)
# neighbors: 20, train_rmse: 0.7469386,  test_rmse: 0.9227604  - published_year(なか)
# neighbors: 20, train_rmse: 0.7472223,  test_rmse: 0.9231967  - published_year(両方)
# neighbors: 20, train_rmse: 0.7132028,  test_rmse: 0.8757759  - ↑categoryId_mean_y(そと)
# neighbors: 20, train_rmse: 0.7292943,  test_rmse: 0.8955891  - categoryId_mean_y(なか)
# neighbors: 20, train_rmse: 0.7119205,  test_rmse: 0.8755947  - categoryId_mean_y(両方)
# neighbors: 20, train_rmse: 0.7106438,  test_rmse: 0.8755445  - categoryId_median_y(そと)
# neighbors: 20, train_rmse: 0.7102326,  test_rmse: 0.8745593  - ↑categoryId_min_y(そと)
# neighbors: 20, train_rmse: 0.7076608,  test_rmse: 0.8752004  - categoryId_max_y(そと)
# neighbors: 20, train_rmse: 0.707588,   test_rmse: 0.874603   - ↑しきい値を -1.5 に & categoryId_mean_y
# neighbors: 20, train_rmse: 0.7084121,  test_rmse: 0.877717   - categoryId_min_y

# neighbors: 20, train_rmse: 0.707588,   test_rmse: 0.874603   - Baseline
# neighbors: 20, train_rmse: 0.7066285,  test_rmse: 0.8742425  - scaling 前
# neighbors: 20, train_rmse: 0.7066285,  test_rmse: 0.874297   - scaling 後(正しい変更なので OK とする)
# neighbors: 20, train_rmse: 0.703222,   test_rmse: 0.8725536  - ↑categoryId_median_y
# neighbors: 20, train_rmse: 0.6993568,  test_rmse: 0.8675327  - ↑categoryId_min_y
# neighbors: 20, train_rmse: 0.6974037,  test_rmse: 0.8646722  - ↑categoryId_max_y
# neighbors: 20, train_rmse: 0.698045,　 test_rmse: 0.8665632 　- categoryId_sd_y そりゃそうだよねw
# sd は外す
# neighbors: 20, train_rmse: 0.6973765,  test_rmse: 0.8643821  - ↑published_year_mean_y
# neighbors: 20, train_rmse: 0.6978903,  test_rmse: 0.8649641  - published_year_median_y
# neighbors: 20, train_rmse: 0.6983664,  test_rmse: 0.8665906  - published_year_min_y
# neighbors: 20, train_rmse: 0.7008683,  test_rmse: 0.8695719  - published_year_max_y

# neighbors: 20, train_rmse: 0.697288,   test_rmse: 0.8643047  - ↑flg_japanese_mean_y
# neighbors: 20, train_rmse: 0.6971782,  test_rmse: 0.8642748  - ↑flg_japanese_median_y
# neighbors: 20, train_rmse: 0.6971052,  test_rmse: 0.8642929  - flg_japanese_min_y
# neighbors: 20, train_rmse: 0.6972179,  test_rmse: 0.8644043  - flg_japanese_max_y

# neighbors: 20, train_rmse: 0.6971934,  test_rmse: 0.8650045  - categoryId_mean_likes
# neighbors: 20, train_rmse: 0.6971789,  test_rmse: 0.8649427  - categoryId_median_likes
# neighbors: 20, train_rmse: 0.6988975,  test_rmse: 0.8661532  - categoryId_min_likes
# neighbors: 20, train_rmse: 0.6972598,  test_rmse: 0.8646507  - categoryId_max_likes
# 間接的な変数は効果が無いのかも

# neighbors: 20, train_rmse: 0.6971782,  test_rmse: 0.8642748  - Baseline
# neighbors: 20, train_rmse: 0.705799,   test_rmse: 0.8754358  - 閾値: -1.5
# neighbors: 20, train_rmse: 0.6970127,  test_rmse: 0.8667979  - 閾値: -1.25
# neighbors: 20, train_rmse: 0.6971782,  test_rmse: 0.8642748  - 閾値: -1.05
# neighbors: 20, train_rmse: 0.6967047,  test_rmse: 0.8628054  - 閾値: -1.0
# neighbors: 20, train_rmse: 0.6967047,  test_rmse: 0.8628054  - 閾値: -0.95
# neighbors: 20, train_rmse: 0.6965471,  test_rmse: 0.8616238  - 閾値: -0.90(☆)
# neighbors: 20, train_rmse: 0.6956871,  test_rmse: 0.8620297  - 閾値: -0.80
# neighbors: 20, train_rmse: 0.696027,   test_rmse: 0.8624277  - 閾値: -0.85

# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx
# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx
# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx
# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx
# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx
# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx
# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx
# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx
# neighbors: 20, train_rmse: xxxxxxxxxx, test_rmse: xxxxxxxxxx - xxx

library(tidyverse)
library(tidymodels)
library(furrr)

options("dplyr.summarise.inform" = F)

source("models/KNN/01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

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
  dials::neighbors(range = c(20L, 20L)),
  levels = 1
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
