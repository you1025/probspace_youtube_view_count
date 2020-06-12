# TODO

# neighbors: xx, train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx

# neighbors:  5, train_rmse: 0.6944535, test_rmse: 0.7175875 - comment_count だけwww
# neighbors: 15, train_rmse: 0.46488567,test_rmse: 0.6083154 - 全部のせ
# neighbors: 15, train_rmse: 0.4959091, test_rmse: 0.5261112 - ↑comment_count + likes + dislikes のみ
# neighbors: 15, train_rmse: 0.5008169, test_rmse: 0.5336268 - diff_likes_dislikes
# neighbors: 15, train_rmse: 0.4888707, test_rmse: 0.5118537 - ↑likes + dislikes のみ
# neighbors: 15, train_rmse: 0.4854372, test_rmse: 0.5114415 - diff_likes_dislikes
# neighbors: 15, train_rmse: 0.452537,  test_rmse: 0.5021803 - ↑title_length
# neighbors: 15, train_rmse: 0.4448879, test_rmse: 0.5024966 - flg_no_tags
# neighbors: 15, train_rmse: 0.4116724, test_rmse: 0.490992  - ↑tag_characters
# neighbors: 15, train_rmse: 0.4055255, test_rmse: 0.4920241 - tag_count
# neighbors: 15, train_rmse: 0.3997674, test_rmse: 0.4827162 - ↑sum_likes_dislikes
# neighbors: 15, train_rmse: 0.3956516, test_rmse: 0.4835064 - ratio_likes
# neighbors: 15, train_rmse: 0.3947075, test_rmse: 0.4810672 - ↑ratio_comments_likedis
# neighbors: 15, train_rmse: 0.3916202, test_rmse: 0.4815542 - flg_no_description
# neighbors: 15, train_rmse: 0.3817426, test_rmse: 0.4703858 - ↑description_length

# neighbors: 15, train_rmse: 0.3745657, test_rmse: 0.4653735 - ↑flg_url
# neighbors: 15, train_rmse: 0.3719136, test_rmse: 0.4633481 - flg_url + url_count
# neighbors: 15, train_rmse: 0.3733212, test_rmse: 0.4623049 - ↑url_count

# neighbors: 15, train_rmse: 0.3560152, test_rmse: 0.4455771 - ↑flg_japanese
# neighbors: 15, train_rmse: 0.354684,  test_rmse: 0.4460952 - flg_emoji
# neighbors: 15, train_rmse: 0.3520474, test_rmse: 0.4411175 - ↑flg_official
# neighbors: 15, train_rmse: 0.3524674, test_rmse: 0.4430537 - flg_movie_number
# neighbors: 15, train_rmse: 0.3478184, test_rmse: 0.4390841 - ↑comments_disabled
# neighbors: 15, train_rmse: 0.3322582, test_rmse: 0.4205124 - ↑ratings_disabled
# neighbors: 15, train_rmse: 0.3143939, test_rmse: 0.3986442 - ↑published_year(☆)
# neighbors: 15, train_rmse: 0.3325836, test_rmse: 0.422894  - published_month_x + published_month_y (ショック...)(棄却)
# neighbors: 15, train_rmse: 0.3352064, test_rmse: 0.4254024 - published_dow_x + published_dow_y(棄却)

# neighbors: 15, train_rmse: 0.3119545, test_rmse: 0.3966004 - categoryId_X30(棄却)
# neighbors: 15, train_rmse: 0.314403,  test_rmse: 0.3995333 - categoryId_X19(棄却)

# neighbors: 19, train_rmse: 0.32853099, test_rmse: 0.3978533 - チューニング


# neighbors: xx, train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx

# 諸々やり直し
# neighbors: 18, train_rmse: 1.158038,  test_rmse: 1.202616  - likes + dislikes
# neighbors: 18, train_rmse: 1.155577,  test_rmse: 1.216542  - comment_count やっぱりだめかw
# neighbors: 18, train_rmse: 1.154335,  test_rmse: 1.206597  - sum_likes_dislikes
# neighbors: 18, train_rmse: 1.14815,   test_rmse: 1.204927  - ratio_comments_likedis
# neighbors: 18, train_rmse: 1.079299,  test_rmse: 1.181629  - ↑title_length
# neighbors: 18, train_rmse: 0.9976864, test_rmse: 1.154334  - ↑tag_characters
# neighbors: 18, train_rmse: 0.9660948, test_rmse: 1.133123  - ↑description_length
# neighbors: 18, train_rmse: 0.9425305, test_rmse: 1.112135  - ↑url_count
# neighbors: 18, train_rmse: 0.8881471, test_rmse: 1.052821  - ↑flg_japanese
# neighbors: 18, train_rmse: 0.8767205, test_rmse: 1.064754  - flg_official
# neighbors: 18, train_rmse: 0.8836176, test_rmse: 1.068369  - flg_emoji
# neighbors: 18, train_rmse: 0.8871187, test_rmse: 1.066249  - flg_movie_number
# neighbors: 18, train_rmse: 0.8738967, test_rmse: 1.042742  - ↑comments_disabled
# neighbors: 18, train_rmse: 0.8244043, test_rmse: 0.9932612 - ↑ratings_disabled
# neighbors: 18, train_rmse: 0.8204674, test_rmse: 0.9926179 - comment_count
# neighbors: 18, train_rmse: 0.7790933, test_rmse: 0.9398923 - ↑published_year
# neighbors: 18, train_rmse: 0.8323288, test_rmse: 1.011576  - published_dow_x + published_dow_y あかん・・・
# neighbors: 18, train_rmse: 0.8219092, test_rmse: 1.000982  - published_month_x + published_month_y No...
# neighbors: 18, train_rmse: 0.7779771, test_rmse: 0.9430041 - flg_low_category
# neighbors: 18, train_rmse: 0.7770172, test_rmse: 0.9434845 - flg_high_category
# neighbors: 18, train_rmse: 0.7773692, test_rmse: 0.9406775 - days_from_published

# neighbors: 20, train_rmse: 0.79289016, test_rmse: 0.9397427 - チューニング(Best)


library(tidyverse)
library(tidymodels)
library(furrr)

source("models/KNN_01/functions.R", encoding = "utf-8")

# Data Load ---------------------------------------------------------------

df.train_data <- load_train_data("data/01.input/train_data.csv") %>% clean()

df.cv <- create_cv(df.train_data)


# Feature Engineering -----------------------------------------------------

recipe <- create_recipe(df.train_data)
#recipes::prep(recipe) %>% recipes::juice() %>% summary()


# Model Definition --------------------------------------------------------

model <- parsnip::nearest_neighbor(
  mode = "regression",
  neighbors = parsnip::varying()
) %>%
  parsnip::set_engine(engine = "kknn")


# Hyper Parameter ---------------------------------------------------------

df.grid.params <- dials::grid_regular(
  dials::neighbors(range = c(26L, 35L)),
  levels = 10
)
df.grid.params


# Parametr Fitting --------------------------------------------------------

# 並列処理
future::plan(future::multisession(workers = 8))

system.time({
  set.seed(1025)

  df.results <-

    # ハイパーパラメータをモデルに適用
    purrr::pmap(df.grid.params, function(neighbors) {
      parsnip::set_args(
        model,
        neighbors = neighbors
      )
    }) %>%

    # ハイパーパラメータの組み合わせごとにループ
    furrr::future_map_dfr(function(model.applied) {

      # クロスバリデーションの分割ごとにモデル構築&評価
      purrr::map_dfr(df.cv$splits, train_and_eval, recipe = recipe, model = model.applied) %>%

        # CV 分割全体の平均値を評価スコアとする
        dplyr::summarise_all(mean)
    }) %>%

    # 評価結果とパラメータを結合
    dplyr::bind_cols(df.grid.params) %>%

    # 評価スコアの順にソート(昇順)
    dplyr::arrange(
      test_rmse
    ) %>%
    
    dplyr::select(
      neighbors,
      
      train_rmse,
      test_rmse
    )
})
df.results
