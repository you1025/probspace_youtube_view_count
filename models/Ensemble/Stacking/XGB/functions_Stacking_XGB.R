source("models/Ensemble/Stacking/functions_Stacking.R", encoding = "utf-8")

train_and_predict <- function(split, recipe, model, formula, seed) {

  set.seed(seed)
  options("dplyr.summarise.inform" = F)

  # 前処理済データの作成
  trained_recipe <- recipes::prep(recipe, training = rsample::training(split))
  df.train <- recipes::juice(trained_recipe) %>%
    add_features_per_category(., .)
  df.test  <- recipes::bake(trained_recipe, new_data = rsample::testing(split)) %>%
    add_features_per_category(df.train)

  # モデルの学習
  fit <- parsnip::fit(model, formula, data = df.train)


  df.test %>%

    # 予測の追加
    dplyr::mutate(predicted = predict(fit, df.test,  type = "numeric")[[1]]) %>%

    dplyr::select(
      id,
      predicted
    ) %>%
    dplyr::arrange(id)
}