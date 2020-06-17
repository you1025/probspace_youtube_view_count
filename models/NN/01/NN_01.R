# TODO
# - mse じゃなくて rmse に変更

# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx

# test_rmse: 0.9040815, train_rmse: 0.9605367- Baseline
# test_rmse: 0.8762598, train_rmse: 0.924464 - xxx
# test_rmse: 0.8603448, train_rmse: 0.9089911- xxx
# 何も変更してないのに大幅にスコアがぶれるorz

# test_rmse: 0.8756139, train_rmse: 0.9336335- tensorflow::tf$random$set_seed(seed = 1025)
# test_rmse: 0.8475199, train_rmse: 0.8919107- xxx
# test_rmse: 0.9115969, train_rmse: 0.9710066- xxx

# test_rmse: 0.8469782, train_rmse: 0.9033809- xxx
# test_rmse: 0.8471725, train_rmse: 0.9081653- xxx

# test_rmse: 0.8767293, train_rmse: 0.9152486- xxx
# test_rmse: 0.9006154, train_rmse: 0.9335485- xxx

# test_rmse: 0.881945,  train_rmse: 0.9415817- xxx
# test_rmse: 0.8843152, train_rmse: 0.9301028- xxx

# test_rmse: 0.8578905, train_rmse: 0.910953 - future::plan(future::sequential())
# test_rmse: 0.8578905, train_rmse: 0.910953 - xxx
# 並列処理をしなければ OK の模様

# test_rmse: 0.8707463, train_rmse: 0.9315824- xxx
# test_rmse: 0.8732515, train_rmse: 0.9442970- xxx

# test_rmse: 0.9007482, train_rmse: 0.9787296- xxx
# test_rmse: 0.9007482, train_rmse: 0.9787296- xxx
# test_rmse: 0.9007482, train_rmse: 0.9787296- xxx
# test_rmse: 0.9179448, train_rmse: 0.993981 - xxx
# 分かった事
# - 並列処理を実施する先で seed の固定が必要
# - set.seed と tensorflow::tf$random$set_seed の両方が必要

# test_rmse: 0.9255607, train_rmse: 0.9999555- xxx
# test_rmse: 0.9255607, train_rmse: 0.9999555- 66.919s
# test_rmse: 0.9255607, train_rmse: 0.9999555- 175.529s
# seed 検証終わり

# seed 固定
# - set.seed: 1025
# - tensorflow::tf$random$set_seed: 777

# test_rmse: 0.9046768, train_rmse: 0.9914849 - Baseline
# test_rmse: 0.9054299, train_rmse: 0.9894655 - ↑ダミー変数化で除外された変数を追加
# test_rmse: 0.9232227, train_rmse: 0.9980025 - published_year をダミー化
# test_rmse: 0.9090344, train_rmse: 0.9893682 - xxx
# test_rmse: 0.9364269, train_rmse: 1.018313  - special_segment
# test_rmse: 8.254084,  train_rmse: 8.219488  - categoryId_mean_y(スケーリングなし)
# test_rmse: 0.9423479, train_rmse: 1.027838  - categoryId_mean_y(min-max スケーリング)
# test_rmse: 0.9153063, train_rmse: 0.9948071 - categoryId_median_y
# test_rmse: 0.9040781, train_rmse: 0.986092  - ↑categoryId_min_y
# test_rmse: 0.9332698, train_rmse: 1.010057  - categoryId_max_y
# test_rmse: 1.01673,   train_rmse: 1.087344  - categoryId_sd_y
# test_rmse: 0.9170846, train_rmse: 0.9929384 - published_year_mean_y
# test_rmse: 0.9022068, train_rmse: 0.9894758 - published_year_median_y
# test_rmse: 0.9309463, train_rmse: 1.014038  - published_year_min_y
# test_rmse: 0.9258902, train_rmse: 1.004956  - published_year_max_y
# test_rmse: 0.9221483, train_rmse: 0.9969402 - flg_japanese_mean_y

# test_rmse: 0.885369,  train_rmse: 0.9927451 - units: 64
# test_rmse: 0.8777388, train_rmse: 1.013933  - units: 96
# test_rmse: 0.8688519, train_rmse: 1.024436  - units: 128
# test_rmse: 0.9177476, train_rmse: 1.066711  - units: 256


# units: 96
# test_rmse: 0.8503624, train_rmse: 0.9908709 - categoryId_mean_y
# test_rmse: 0.8521234, train_rmse: 0.9924228 - categoryId_median_y
# test_rmse: 0.8512005, train_rmse: 0.9954223 - categoryId_min_y
# test_rmse: 0.8426376, train_rmse: 0.9883721 - ↑categoryId_max_y
# test_rmse: 0.8425173, train_rmse: 0.985818  - ↑published_year_mean_y
# test_rmse: 0.844444,  train_rmse: 0.9918447 - published_year_median_y
# test_rmse: 0.8404763, train_rmse: 0.9862019 - published_year_min_y
# test_rmse: 0.8325478, train_rmse: 0.996745  - published_year_max_y
# test_rmse: 0.8735039, train_rmse: 1.014092  - flg_japanese_mean_y
# test_rmse: 0.8596968, train_rmse: 1.012556  - flg_japanese_median_y
# test_rmse: 0.8428489, train_rmse: 0.9899206 - flg_japanese_min_y
# test_rmse: 0.8831801, train_rmse: 1.021473  - flg_japanese_max_y

# test_rmse: 0.856247,  train_rmse: 0.9009017 - BatchNormalization の除去 まじかw
# test_rmse: 0.850137,  train_rmse: 0.8984117 - units: 64 ほぼ差がないので 96 で良いかな

# test_rmse: 0.8394961, train_rmse: 0.9227777 - layers: 2
# test_rmse: 0.8013854, train_rmse: 0.8992054 - layers: 3

# layers: 3
# test_rmse: 0.8093196, train_rmse: 0.9059115 - categoryId_median_y
# test_rmse: 0.8078647, train_rmse: 0.9138449 - categoryId_min_y
# test_rmse: 0.830782,  train_rmse: 0.9173987 - published_year_median_y
# test_rmse: 0.8144374, train_rmse: 0.907372  - published_year_min_y
# test_rmse: 0.8073161, train_rmse: 0.9021879 - published_year_max_y
# test_rmse: 0.8001123, train_rmse: 0.8996455 - ↑published_year_sd_y
# test_rmse: 0.8067844, train_rmse: 0.9040522 - categoryId_sd_y
# test_rmse: 0.8257367, train_rmse: 0.923455  - flg_japanese_mean_y
# test_rmse: 0.8100508, train_rmse: 0.9143137 - flg_japanese_median_y
# test_rmse: 0.805001,  train_rmse: 0.9050343 - flg_japanese_min_y
# test_rmse: 0.8617645, train_rmse: 0.9510653 - flg_japanese_max_y
# test_rmse: 0.8266088, train_rmse: 0.9264995 - flg_japanese_sd_y
# test_rmse: 0.819856,  train_rmse: 0.9043764 - special_segment

# test_rmse: 0.8335356, train_rmse: 0.9163432 - layers: 2
# test_rmse: 0.8050522, train_rmse: 0.9062606 - units: 256
# test_rmse: 0.8329899, train_rmse: 0.9165683 - units: 512
# test_rmse: 0.8704819, train_rmse: 0.9302231 - dropout: 0.25
# test_rmse: 0.8428522, train_rmse: 0.9146326 - dropout: 0.125
# test_rmse: 0.8270536, train_rmse: 0.9061992 - dropout: 0.06
# test_rmse: 0.8283228, train_rmse: 0.9110074 - dropout: 0.03
# test_rmse: 0.8270536, train_rmse: 0.9061992 - dropout: 0.06(☆)
# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx
# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx
# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx
# test_rmse: xxxxxxxxx, train_rmse: xxxxxxxxx - xxx


library(tidyverse)
library(tidymodels)
library(furrr)
library(keras)
library(tensorflow)

source("models/NN/01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- tidyr::crossing(
  layers = c(2),
  units = c(512),
  activation = c("relu"),
  l1 = c(1e-4),
  l2 = c(1e-4),
  dropout_rate = c(0.06),
  batch_size = c(64)
)
# df.grid.params <- tibble(
#   layers = c(2),
#   units = c(512),
#   activation = c("relu"),
#   l1 = c(1e-4),
#   l2 = c(1e-4),
#   dropout_rate = c(0.06),
#   batch_size = c(64)
# )
# df.grid.params <- tibble(
#   layers = c(7),
#   units = c(512),
#   activation = c("relu"),
#   l1 = c(1e-3),
#   l2 = c(1e-4),
#   dropout_rate = c(0.027),
#   batch_size = c(64)
# )
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 5))

system.time({

  df.results <-

    # ハイパーパラメータの組み合わせごとにループ
#    furrr::future_pmap_dfr(df.grid.params, function(...) {
    purrr::pmap_dfr(df.grid.params, function(...) {

      # ハイパラ一覧
      params <- list(...)

      # クロスバリデーションの分割ごとにモデル構築&評価
#      purrr::map_dfr(
      furrr::future_map_dfr(
        df.cv$splits,
        train_and_eval,
        recipe = recipe,
        params = params,
        batch_size = params$batch_size
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
