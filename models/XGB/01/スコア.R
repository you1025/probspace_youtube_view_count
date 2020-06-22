# train_rmse: 0.4431623, test_rmse: 0.7937633 - Baseline

# train_rmse: 1.343507 , test_rmse: 1.430242  - なんで？？？
# train_rmse: 1.303768 , test_rmse: 1.436826  - lr: 0.1

# train_rmse: 0.5265626, test_rmse: 0.9192048 - 基本的な変数に絞った(悪さしてる変数があるっぽい)
# train_rmse: 0.7018075, test_rmse: 0.8718732 - trees: 73

# train_rmse: 0.6480923, test_rmse: 0.8647146 - ↑published_month_x + published_month_y
# train_rmse: 0.6049283, test_rmse: 0.8504801 - ↑channel_title_length
# train_rmse: 0.6019002, test_rmse: 0.8443593 - ↑flg_no_tags
# train_rmse: 0.564205 , test_rmse: 0.841037  - ↑tag_characters
# train_rmse: 0.5521659, test_rmse: 0.8372737 - ↑tag_count
# train_rmse: 0.5511486, test_rmse: 0.8394474 - flg_no_description
# train_rmse: 0.5296738, test_rmse: 0.8355727 - ↑description_length
# train_rmse: 0.5363415, test_rmse: 0.8384489 - days_from_published まじかー
# train_rmse: 0.5331776, test_rmse: 0.8395404 - sum_likes_dislikes
# train_rmse: 0.5224217, test_rmse: 0.8381904 - ratio_comments_likedis
# train_rmse: 0.5240885, test_rmse: 0.8417608 - ratio_likes
# train_rmse: 0.5130606, test_rmse: 0.8158294 - ↑flg_japanese
# train_rmse: 0.5074301, test_rmse: 0.8156475 - ↑url_count
# train_rmse: 0.5086465, test_rmse: 0.8071592 - ↑flg_url
# train_rmse: 0.5115412, test_rmse: 0.8088964 - flg_emoji
# train_rmse: 0.5045227, test_rmse: 0.8128649 - flg_official
# train_rmse: 0.5106295, test_rmse: 0.8124655 - flg_movie_number
# train_rmse: 0.5079564, test_rmse: 0.8161031 - flg_categoryId_low
# train_rmse: 0.5033521, test_rmse: 0.8041599 - ↑flg_categoryId_high
# train_rmse: 0.5129136, test_rmse: 0.8003573 - ↑comments_ratings_disabled_japanese
# train_rmse: 0.5096164, test_rmse: 0.8041055 - flg_comments_ratings_disabled_japanese_high
# train_rmse: 0.5131821, test_rmse: 0.8056225 - flg_comments_ratings_disabled_japanese_very_high
# train_rmse: 0.5137646, test_rmse: 0.8030766 - flg_comments_ratings_disabled_japanese_low
# train_rmse: 0.5168144, test_rmse: 0.8060727 - flg_comments_ratings_disabled_japanese_very_low
# train_rmse: 0.5116754, test_rmse: 1.363604  - pc1 やべーなwww
# train_rmse: 0.5150263, test_rmse: 0.8069982 - special_segment

# train_rmse: 0.5129136, test_rmse: 0.8003573 - Baseline

# train_rmse: 0.5552605, test_rmse: 0.8263526 - published_year(factor) なんでや・・・
# train_rmse: 0.513462 , test_rmse: 0.8027774 - tmp 作成 @get_dummies
# train_rmse: 0.5133732, test_rmse: 0.8036819 - tmp を戻す @get_dummies 何で・・・
# train_rmse: 0.5117183, test_rmse: 0.8055672 - step_dummy @get_dummies
# train_rmse: 0.5557036, test_rmse: 0.8247994 - published_year を factor に変更 いかんな
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year を変換しないように除外 @get_dummies

# train_rmse: 0.4778503, test_rmse: 0.8010271 - Label Encoding: categoryId 下がるけどやる(やっぱなし)

# train_rmse: 0.502096,  test_rmse: 0.8051081 - categoryId_mean_y
# train_rmse: 0.5051078, test_rmse: 0.8024378 - categoryId_median_y
# train_rmse: 0.5022165, test_rmse: 0.8027563 - categoryId_min_y
# train_rmse: 0.5034128, test_rmse: 0.8020897 - categoryId_max_y
# train_rmse: 0.5021709, test_rmse: 0.8041404 - categoryId_sd_y

# train_rmse: 0.5087932, test_rmse: 0.8044662 - published_year_mean_y
# train_rmse: 0.507405 , test_rmse: 0.8022688 - published_year_median_y
# train_rmse: 0.5071046, test_rmse: 0.8059045 - published_year_min_y
# train_rmse: 0.5072454, test_rmse: 0.8035674 - published_year_max_y
# train_rmse: 0.5099806, test_rmse: 0.8078919 - published_year_sd_y

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_mean_y
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_median_y
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_min_y
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_max_y
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_sd_y

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_mean_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_median_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_min_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_max_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_sd_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_mean_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_median_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_min_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_max_likes

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_mean_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_median_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_min_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_max_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_sd_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_mean_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_median_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_min_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_max_dislikes

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_mean_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_median_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_min_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_max_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - categoryId_sd_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_mean_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_median_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_min_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_categoryId_max_comment_count

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_mean_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_median_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_min_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_max_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_sd_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_mean_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_median_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_min_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_max_likes

# 0.8003573

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_mean_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_median_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_min_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_max_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_sd_dislikes
# train_rmse: 0.5095443, test_rmse: 0.8000405 - ↑diff_published_year_mean_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_median_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_min_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_max_dislikes

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_mean_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_median_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_min_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_max_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - published_year_sd_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_mean_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_median_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_min_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_published_year_max_comment_count

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_mean_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_median_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_min_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_max_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_sd_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_mean_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_median_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_min_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_max_likes

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_mean_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_median_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_min_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_max_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_sd_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_mean_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_median_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_min_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_max_dislikes

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_mean_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_median_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_min_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_max_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - flg_japanese_sd_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_mean_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_median_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_min_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - diff_flg_japanese_max_comment_count

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_mean_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_median_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_min_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_max_likes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_sd_likes

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_mean_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_median_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_min_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_max_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_sd_dislikes

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_mean_sum_likes_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_median_sum_likes_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_min_sum_likes_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_max_sum_likes_dislikes
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_sd_sum_likes_dislikes

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_mean_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_median_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_min_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_max_comment_count
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_sd_comment_count

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx

