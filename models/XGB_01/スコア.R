# train_rmse: xxxxxxxx,  test_rmse: xxxxxxxx  - xxx

# train_rmse: 1.469939,  test_rmse: 1.519262  - 全部のせ(Baseline)
# train_rmse: 1.135938,  test_rmse: 1.180403  - ↑likes + dislikes
# train_rmse: 1.021018,  test_rmse: 1.087768  - ↑likes + dislikes + categoryId
# train_rmse: 0.970706,  test_rmse: 1.06048   - ↑comment_count
# train_rmse: 0.8439732, test_rmse: 0.9440643 - ↑comments_disabled + ratings_disabled
# train_rmse: 0.7853704, test_rmse: 0.943976  - ↑title_length(やや微妙)
# train_rmse: 0.6901375, test_rmse: 0.8737658 - ↑published_year
# train_rmse: 0.6973229, test_rmse: 0.874766  - published_month
# train_rmse: 0.6557217, test_rmse: 0.8723014 - ↑published_month_x + published_month_y
# train_rmse: 0.7202411, test_rmse: 0.8931505 - published_day
# train_rmse: 0.6167776, test_rmse: 0.880453  - published_day_x + published_day_y
# train_rmse: 0.6501441, test_rmse: 0.8767759 - published_term_in_month
# train_rmse: 0.6303878, test_rmse: 0.881036  - published_dow
# train_rmse: 0.6363674, test_rmse: 0.8737321 - published_dow_x + published_dow_y
# train_rmse: 0.703266,  test_rmse: 0.8811539 - published_hour
# train_rmse: 0.62751,   test_rmse: 0.874543  - published_hour_x + published_hour_y
# train_rmse: 0.627193,  test_rmse: 0.8532097 - ↑channel_title_length
# train_rmse: 0.6196125, test_rmse: 0.8500449 - ↑flg_categoryId_low
# train_rmse: 0.6155714, test_rmse: 0.8453351 - ↑flg_categoryId_high
# train_rmse: 0.6153899, test_rmse: 0.8442788 - ↑flg_no_tags
# train_rmse: 0.5886151, test_rmse: 0.83574   - ↑tag_characters
# train_rmse: 0.5795549, test_rmse: 0.8383502 - tag_count
# train_rmse: 0.5903219, test_rmse: 0.8418404 - flg_no_description
# train_rmse: 0.5702914, test_rmse: 0.8361876 - description_length
# train_rmse: 0.5847015, test_rmse: 0.8383528 - flg_url
# train_rmse: 0.580388,  test_rmse: 0.8332744 - ↑url_count
# train_rmse: 0.5894854, test_rmse: 0.8299713 - ↑days_from_published
# train_rmse: 0.5917775, test_rmse: 0.8337657 - diff_likes_dislikes
# train_rmse: 0.589045,  test_rmse: 0.8313351 - ↑sum_likes_dislikes
# train_rmse: 0.5877905, test_rmse: 0.8319322 - ratio_likes
# train_rmse: 0.589861,  test_rmse: 0.8323994 - sum_likes_dislikes_comments
# train_rmse: 0.5883941, test_rmse: 0.8308755 - ↑ratio_comments_likedis
# train_rmse: 0.567716,  test_rmse: 0.8024439 - ↑flg_japanese
# train_rmse: 0.5662007, test_rmse: 0.8066194 - flg_emoji
# train_rmse: 0.5645361, test_rmse: 0.8029351 - flg_official
# train_rmse: 0.5653925, test_rmse: 0.8045492 - flg_movie_number
# train_rmse: 0.596183,  test_rmse: 0.8180911 - published_hour2
# train_rmse: 0.5558657, test_rmse: 0.8059097 - published_hour2_x + published_hour2_y
# train_rmse: 0.5765228, test_rmse: 0.7992546 - ↑title_length の除去

# train_rmse: 0.5712119, test_rmse: 0.8001168 - categoryId_mean_y
# train_rmse: 0.5710207, test_rmse: 0.7976098 - ↑categoryId_median_y
# train_rmse: 0.5657774, test_rmse: 0.795499  - ↑categoryId_min_y
# train_rmse: 0.5635459, test_rmse: 0.7992622 - categoryId_max_y
# train_rmse: 0.560943,  test_rmse: 0.7963545 - categoryId_sd_y

# train_rmse: 0.562885,  test_rmse: 0.8013895 - published_year_mean_y
# train_rmse: 0.564897,  test_rmse: 0.799852  - published_year_median_y
# train_rmse: 0.5629735, test_rmse: 0.7995438 - published_year_min_y
# train_rmse: 0.5655168, test_rmse: 0.8005784 - published_year_max_y
# train_rmse: 0.5662301, test_rmse: 0.7993363 - published_year_sd_y

# train_rmse: 0.5617031, test_rmse: 0.7999103 - published_month_mean_y
# train_rmse: 0.5635351, test_rmse: 0.8005307 - published_month_median_y
# train_rmse: 0.5613967, test_rmse: 0.7989454 - published_month_min_y
# train_rmse: 0.5633058, test_rmse: 0.8003022 - published_month_max_y
# train_rmse: 0.5640276, test_rmse: 0.7986076 - published_month_sd_y

# train_rmse: 0.5606285, test_rmse: 0.7980601 - published_dow_mean_y
# train_rmse: 0.5576587, test_rmse: 0.7980424 - published_dow_median_y
# train_rmse: 0.5565121, test_rmse: 0.8009125 - published_dow_min_y
# train_rmse: 0.556688,  test_rmse: 0.7992784 - published_dow_max_y
# train_rmse: 0.5593729, test_rmse: 0.7981528 - published_dow_sd_y

### 2 値フラグの Target Encoding はツリーモデルの場合は無意味 ###

# train_rmse: 0.5643172, test_rmse: 0.7985534 - categoryId_mean_likes
# train_rmse: 0.5621962, test_rmse: 0.8002464 - diff_categoryId_mean_likes
# train_rmse: 0.5650327, test_rmse: 0.8011498 - ratio_categoryId_mean_likes
# train_rmse: 0.5639719, test_rmse: 0.7964521 - categoryId_median_likes
# train_rmse: 0.5629164, test_rmse: 0.7987168 - diff_categoryId_median_likes
# train_rmse: 0.5630558, test_rmse: 0.7997241 - ratio_categoryId_median_likes
# train_rmse: 0.5679647, test_rmse: 0.7968109 - categoryId_min_likes
# train_rmse: 0.5674624, test_rmse: 0.7979863 - diff_categoryId_min_likes
# train_rmse: 1.227324,  test_rmse: 1.305571  - ratio_categoryId_min_likes
# train_rmse: 0.5648923, test_rmse: 0.7964245 - categoryId_max_likes
# train_rmse: 0.561632,  test_rmse: 0.7984612 - diff_categoryId_max_likes
# train_rmse: 0.5647221, test_rmse: 0.8010131 - ratio_categoryId_max_likes
# train_rmse: 0.5632169, test_rmse: 0.796308  - categoryId_sd_likes

# train_rmse: 0.5645889, test_rmse: 0.7978856 - categoryId_mean_dislikes
# train_rmse: 0.5624691, test_rmse: 0.7998607 - diff_categoryId_mean_dislikes
# train_rmse: 0.5614961, test_rmse: 0.7986755 - ratio_categoryId_mean_dislikes
# train_rmse: 0.5661515, test_rmse: 0.7968142 - categoryId_median_dislikes
# train_rmse: 0.5592654, test_rmse: 0.7990517 - diff_categoryId_median_dislikes
# train_rmse: 0.5616755, test_rmse: 0.8005251 - ratio_categoryId_median_dislikes
# train_rmse: 0.5679647, test_rmse: 0.7968109 - categoryId_min_dislikes
# train_rmse: 0.5679371, test_rmse: 0.7997012 - diff_categoryId_min_dislikes
# train_rmse: 1.552737,  test_rmse: 1.605309  - ratio_categoryId_min_dislikes
# train_rmse: 0.563282,  test_rmse: 0.7961501 - categoryId_max_dislikes
# train_rmse: 0.5604279, test_rmse: 0.7964001 - diff_categoryId_max_dislikes
# train_rmse: 0.5626419, test_rmse: 0.8001595 - ratio_categoryId_max_dislikes
# train_rmse: 0.5651755, test_rmse: 0.7960384 - categoryId_sd_dislikes

# train_rmse: 0.5643002, test_rmse: 0.7981152 - categoryId_mean_comment_count
# train_rmse: 0.5597938, test_rmse: 0.7991374 - diff_categoryId_mean_comment_count
# train_rmse: 0.5618666, test_rmse: 0.7980017 - ratio_categoryId_mean_comment_count
# train_rmse: 0.5621114, test_rmse: 0.7968211 - categoryId_median_comment_count
# train_rmse: 0.558364 , test_rmse: 0.7994726 - diff_categoryId_median_comment_count
# train_rmse: 0.5742742, test_rmse: 0.7986231 - ratio_categoryId_median_comment_count
# train_rmse: 0.5679647, test_rmse: 0.7968109 - categoryId_min_comment_count
# train_rmse: 0.5656404, test_rmse: 0.7993254 - diff_categoryId_min_comment_count
# train_rmse: 0.939155,  test_rmse: 1.021255  - ratio_categoryId_min_comment_count
# train_rmse: 0.5627539, test_rmse: 0.7941654 - ↑categoryId_max_comment_count
# train_rmse: 0.556345,  test_rmse: 0.7909403 - ↑diff_categoryId_max_comment_count
# train_rmse: 0.5562839, test_rmse: 0.7916282 - ratio_categoryId_max_comment_count
# train_rmse: 0.5534994, test_rmse: 0.7920715 - categoryId_sd_comment_count

# train_rmse: 0.5552559,  test_rmse: 0.791549  - comments_disabled_mean_likes
# train_rmse: 0.5556529,  test_rmse: 0.7946825 - diff_comments_disabled_mean_likes
# train_rmse: 0.5552917,  test_rmse: 0.7955067 - ratio_comments_disabled_mean_likes
# train_rmse: 0.5552559,  test_rmse: 0.791549  - comments_disabled_median_likes
# train_rmse: 0.5536716,  test_rmse: 0.794617  - diff_comments_disabled_median_likes
# train_rmse: 0.5570028,  test_rmse: 0.7932673 - ratio_comments_disabled_median_likes
# train_rmse: 0.5586888,  test_rmse: 0.7928825 - comments_disabled_min_likes
# train_rmse: 0.5558661,  test_rmse: 0.7944975 - diff_comments_disabled_min_likes
# train_rmse: 1.215186,   test_rmse: 1.304392  - ratio_comments_disabled_min_likes
# train_rmse: 0.5552559,  test_rmse: 0.791549  - comments_disabled_max_likes
# train_rmse: 0.5560453,  test_rmse: 0.7951388 - diff_comments_disabled_max_likes
# train_rmse: 0.5560341,  test_rmse: 0.7947705 - ratio_comments_disabled_max_likes
# train_rmse: 0.5552559,  test_rmse: 0.791549  - comments_disabled_sd_likes

# train_rmse: 0.5552559,  test_rmse: 0.791549  - comments_disabled_mean_dislikes
# train_rmse: 0.5514523,  test_rmse: 0.7946284 - diff_comments_disabled_mean_dislikes
# train_rmse: 0.5555781,  test_rmse: 0.7924083 - ratio_comments_disabled_mean_dislikes
# train_rmse: 0.5552559,  test_rmse: 0.791549  - comments_disabled_median_dislikes
# train_rmse: 0.5538946,  test_rmse: 0.794605  - diff_comments_disabled_median_dislikes
# train_rmse: 0.7281278,  test_rmse: 0.8685727 - ratio_comments_disabled_median_dislikes
# train_rmse: 0.5586888,  test_rmse: 0.7928825 - comments_disabled_min_dislikes
# train_rmse: 0.5576573,  test_rmse: 0.7940131 - diff_comments_disabled_min_dislikes
# train_rmse: 1.52208,    test_rmse: 1.581029  - ratio_comments_disabled_min_dislikes
# train_rmse: 0.5552559,  test_rmse: 0.791549  - comments_disabled_max_dislikes
# train_rmse: 0.5527523,  test_rmse: 0.7960947 - diff_comments_disabled_max_dislikes
# train_rmse: 0.5566196,  test_rmse: 0.7911102 - ratio_comments_disabled_max_dislikes
# train_rmse: 0.5552559,  test_rmse: 0.791549  - comments_disabled_sd_dislikes

# train_rmse: 0.5582259,  test_rmse: 0.79134   - ratings_disabled_mean_comment_count
# train_rmse: 0.556887,   test_rmse: 0.7945343 - diff_ratings_disabled_mean_comment_count
# train_rmse: 0.5606998,  test_rmse: 0.7937107 - ratio_ratings_disabled_mean_comment_count
# train_rmse: 0.5582259,  test_rmse: 0.79134   - ratings_disabled_median_comment_count
# train_rmse: 0.5559956,  test_rmse: 0.7961145 - diff_ratings_disabled_median_comment_count
# train_rmse: 0.9853676,  test_rmse: 1.101886  - ratio_ratings_disabled_median_comment_count
# train_rmse: 0.5586888,  test_rmse: 0.7928825 - ratings_disabled_min_comment_count
# train_rmse: 0.5579905,  test_rmse: 0.7915491 - diff_ratings_disabled_min_comment_count
# train_rmse: 0.9232241,  test_rmse: 1.007731  - ratio_ratings_disabled_min_comment_count
# train_rmse: 0.5582259,  test_rmse: 0.79134   - ratings_disabled_max_comment_count
# train_rmse: 0.5568361,  test_rmse: 0.7942348 - diff_ratings_disabled_max_comment_count
# train_rmse: 0.5599757,  test_rmse: 0.7933369 - ratio_ratings_disabled_max_comment_count
# train_rmse: 0.5582259,  test_rmse: 0.79134   - ratings_disabled_sd_comment_count

# train_rmse: 0.5537979,  test_rmse: 0.7945858 - published_year_mean_likes
# train_rmse: 0.5563781,  test_rmse: 0.7938844 - diff_published_year_mean_likes
# train_rmse: 0.5555737,  test_rmse: 0.7952475 - ratio_published_year_mean_likes
# train_rmse: 0.5568071,  test_rmse: 0.7933514 - published_year_median_likes
# train_rmse: 0.5560135,  test_rmse: 0.7953243 - diff_published_year_median_likes
# train_rmse: 0.5557801,  test_rmse: 0.7960708 - ratio_published_year_median_likes
# train_rmse: 0.5586888,  test_rmse: 0.7928825 - published_year_min_likes
# train_rmse: 0.5558661,  test_rmse: 0.7944975 - diff_published_year_min_likes
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_published_year_min_likes
# train_rmse: 0.5531672,  test_rmse: 0.7953046 - published_year_max_likes
# train_rmse: 0.5547312,  test_rmse: 0.7948232 - diff_published_year_max_likes
# train_rmse: 0.5563441,  test_rmse: 0.7970298 - ratio_published_year_max_likes
# train_rmse: 0.5553294,  test_rmse: 0.794488  - published_year_sd_likes

# train_rmse: 0.556056,   test_rmse: 0.7929967 - published_year_mean_dislikes
# train_rmse: 0.5528899,  test_rmse: 0.7930095 - diff_published_year_mean_dislikes
# train_rmse: 0.5564689,  test_rmse: 0.792487  - ratio_published_year_mean_dislikes
# train_rmse: 0.5559312,  test_rmse: 0.795351  - published_year_median_dislikes

# train_rmse: 0.5545558,  test_rmse: 0.7908839 - ↑diff_published_year_median_dislikes(取り消し)
# train_rmse: xxxxxxxxx,  test_rmse: 0.7908663 - ↑ratio_published_year_median_dislikes

# train_rmse: 0.5588964,  test_rmse: 0.793214  - published_year_min_dislikes
# train_rmse: 0.5595103,  test_rmse: 0.7942197 - diff_published_year_min_dislikes
# train_rmse: 1.519435,   test_rmse: 1.577999  - ratio_published_year_min_dislikes
# train_rmse: 0.5540476,  test_rmse: 0.7937089 - published_year_max_dislikes
# train_rmse: 0.5536122,  test_rmse: 0.7941969 - diff_published_year_max_dislikes
# train_rmse: 0.5566761,  test_rmse: 0.7927173 - ratio_published_year_max_dislikes
# train_rmse: 0.5584692,  test_rmse: 0.7935949 - published_year_sd_dislikes

# train_rmse: 0.5544455,  test_rmse: 0.7941842 - published_year_mean_comment_count
# train_rmse: 0.5550654,  test_rmse: 0.7941605 - diff_published_year_mean_comment_count
# train_rmse: 0.5563313,  test_rmse: 0.7925931 - ratio_published_year_mean_comment_count
# train_rmse: 0.5551974,  test_rmse: 0.7929511 - published_year_median_comment_count
# train_rmse: 0.5585585,  test_rmse: 0.7940066 - diff_published_year_median_comment_count
# train_rmse: 0.5590852,  test_rmse: 0.7940888 - ratio_published_year_median_comment_count
# train_rmse: 0.5588964,  test_rmse: 0.793214  - published_year_min_comment_count
# train_rmse: 0.5593912,  test_rmse: 0.7926022 - diff_published_year_min_comment_count
# train_rmse: 0.9330096,  test_rmse: 1.016965  - ratio_published_year_min_comment_count
# train_rmse: 0.5547884,  test_rmse: 0.79421   - published_year_max_comment_count
# train_rmse: 0.5544449,  test_rmse: 0.7973205 - diff_published_year_max_comment_count
# train_rmse: 0.5573897,  test_rmse: 0.7928656 - ratio_published_year_max_comment_count
# train_rmse: 0.5585443,  test_rmse: 0.791908  - published_year_sd_comment_count

# train_rmse: 0.5610181,  test_rmse: 0.7949213 - flg_japanese_mean_likes
# train_rmse: 0.5607586,  test_rmse: 0.7950185 - diff_flg_japanese_mean_likes
# train_rmse: 0.5596583,  test_rmse: 0.7949585 - ratio_flg_japanese_mean_likes
# train_rmse: 0.5610181,  test_rmse: 0.7949213 - flg_japanese_median_likes
# train_rmse: 0.5599445,  test_rmse: 0.797853  - diff_flg_japanese_median_likes
# train_rmse: 0.556083,   test_rmse: 0.795502  - ratio_flg_japanese_median_likes
# train_rmse: 0.5588964,  test_rmse: 0.793214  - flg_japanese_min_likes
# train_rmse: 0.5568304,  test_rmse: 0.7924879 - diff_flg_japanese_min_likes
# train_rmse: 1.225258,   test_rmse: 1.3077    - ratio_flg_japanese_min_likes
# train_rmse: 0.5610181,  test_rmse: 0.7949213 - flg_japanese_max_likes
# train_rmse: 0.5605427,  test_rmse: 0.7981588 - diff_flg_japanese_max_likes
# train_rmse: 0.5609812,  test_rmse: 0.7977358 - ratio_flg_japanese_max_likes
# train_rmse: 0.5610181,  test_rmse: 0.7949213 - flg_japanese_sd_likes

# train_rmse: 0.5610181,  test_rmse: 0.7949213 - flg_japanese_mean_dislikes
# train_rmse: 0.5616213,  test_rmse: 0.7940892 - diff_flg_japanese_mean_dislikes
# train_rmse: 0.5588494,  test_rmse: 0.7946238 - ratio_flg_japanese_mean_dislikes
# train_rmse: 0.5610181,  test_rmse: 0.7949213 - flg_japanese_median_dislikes
# train_rmse: 0.5585548,  test_rmse: 0.7931214 - diff_flg_japanese_median_dislikes
# train_rmse: 0.5581997,  test_rmse: 0.7914719 - ratio_flg_japanese_median_dislikes
# train_rmse: 0.5588964,  test_rmse: 0.793214  - flg_japanese_min_dislikes
# train_rmse: 0.5595103,  test_rmse: 0.7942197 - diff_flg_japanese_min_dislikes
# train_rmse: 1.519435,   test_rmse: 1.577999  - ratio_flg_japanese_min_dislikes
# train_rmse: 0.5610181,  test_rmse: 0.7949213 - flg_japanese_max_dislikes
# train_rmse: 0.5623091,  test_rmse: 0.7950722 - diff_flg_japanese_max_dislikes
# train_rmse: 0.5604788,  test_rmse: 0.79476   - ratio_flg_japanese_max_dislikes
# train_rmse: 0.5610181,  test_rmse: 0.7949213 - flg_japanese_sd_dislikes

## 恐らく二値フラグはダメ！！！
# 下記は中止
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - flg_japanese_mean_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - diff_flg_japanese_mean_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_flg_japanese_mean_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - flg_japanese_median_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - diff_flg_japanese_median_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_flg_japanese_median_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - flg_japanese_min_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - diff_flg_japanese_min_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_flg_japanese_min_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - flg_japanese_max_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - diff_flg_japanese_max_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_flg_japanese_max_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - flg_japanese_sd_comment_count

# フラグ追加

# train_rmse: 0.5568559,  test_rmse: 0.7926703 - flg_comments_ratings_disabled_japanese_high
# train_rmse: 0.5619435,  test_rmse: 0.7939494 - flg_comments_ratings_disabled_japanese_very_high
# train_rmse: 0.5564673,  test_rmse: 0.7947951 - flg_comments_ratings_disabled_japanese_low
# train_rmse: 0.5629332,  test_rmse: 0.7952264 - flg_comments_ratings_disabled_japanese_very_low
# train_rmse: 0.5646561,  test_rmse: 0.7944641 - 全部のせ orz

# train_rmse: 0.5644632,  test_rmse: 0.7951431 - comments_ratings_disabled_japanese_mean_y
# train_rmse: 0.5614578,  test_rmse: 0.7981501 - comments_ratings_disabled_japanese_median_y
# train_rmse: 0.560823,   test_rmse: 0.7959514 - comments_ratings_disabled_japanese_min_y
# train_rmse: 0.5645899,  test_rmse: 0.7975564 - comments_ratings_disabled_japanese_max_y
# train_rmse: 0.5609424,  test_rmse: 0.7949513 - comments_ratings_disabled_japanese_sd_y

# train_rmse: 0.5608282,  test_rmse: 0.7975336 - comments_ratings_disabled_japanese_mean_comment_count
# train_rmse: 0.5602027,  test_rmse: 0.7992541 - diff_comments_ratings_disabled_japanese_mean_comment_count
# train_rmse: 0.7493135,  test_rmse: 0.8780318 - ratio_comments_ratings_disabled_japanese_mean_comment_count
# train_rmse: 0.5620221,  test_rmse: 0.7972409 - comments_ratings_disabled_japanese_median_comment_count
# train_rmse: 0.5611347,  test_rmse: 0.7974323 - diff_comments_ratings_disabled_japanese_median_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_comments_ratings_disabled_japanese_median_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_min_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - diff_comments_ratings_disabled_japanese_min_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_comments_ratings_disabled_japanese_min_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_max_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - diff_comments_ratings_disabled_japanese_max_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_comments_ratings_disabled_japanese_max_comment_count
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - comments_ratings_disabled_japanese_sd_comment_count

# train_rmse: 0.5606178,  test_rmse: 0.7961355 - comments_ratings_disabled_japanese_mean_sum_likes_dislikes
# train_rmse: 0.5640332,  test_rmse: 0.7937209 - diff_comments_ratings_disabled_japanese_mean_sum_likes_dislikes
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_comments_ratings_disabled_japanese_mean_sum_likes_dislikes
# train_rmse: 0.5591187,  test_rmse: 0.7954062 - comments_ratings_disabled_japanese_median_sum_likes_dislikes
# train_rmse: 0.5646064,  test_rmse: 0.7940544 - diff_comments_ratings_disabled_japanese_median_sum_likes_dislikes
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_comments_ratings_disabled_japanese_median_sum_likes_dislikes
# train_rmse: 0.5597619,  test_rmse: 0.7930838 - comments_ratings_disabled_japanese_min_sum_likes_dislikes
# train_rmse: 0.5612704,  test_rmse: 0.7922723 - diff_comments_ratings_disabled_japanese_min_sum_likes_dislikes
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_comments_ratings_disabled_japanese_min_sum_likes_dislikes
# train_rmse: 0.5619829,  test_rmse: 0.7954045 - comments_ratings_disabled_japanese_max_sum_likes_dislikes
# train_rmse: 0.5623275,  test_rmse: 0.7980188 - diff_comments_ratings_disabled_japanese_max_sum_likes_dislikes
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - ratio_comments_ratings_disabled_japanese_max_sum_likes_dislikes
# train_rmse: 0.5603499,  test_rmse: 0.7943525 - comments_ratings_disabled_japanese_sd_sum_likes_dislikes



# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx,  test_rmse: xxxxxxxxx - xxx