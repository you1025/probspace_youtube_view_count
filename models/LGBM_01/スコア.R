
# train_rmse: xxxxxxxx, test_rmse: xxxxxxxx - xxx

# train_rmse: 1.024154, test_rmse: 1.076321 - categoryId + likes + dislikes + comment_count(ベースライン)

# train_rmse: 1.039356, test_rmse: 1.081406 - categoryId(自前 LabelEncoding)

# train_rmse: 1.024154, test_rmse: 1.076321 - comments_disabled(カテゴリ指定)
# train_rmse: 0.921678, test_rmse: 1.003369 - ↑comments_disabled(自前 LabelEncoding)

# train_rmse: 0.921678, test_rmse: 1.003369 - ratings_disabled(カテゴリ指定)
# train_rmse: 0.8779254,test_rmse: 0.9466283- ↑ratings_disabled(自前 LabelEncoding)

# めんどいからカテゴリ値は自前 Encoding で良いと思う

# train_rmse: 0.8549646, test_rmse: 0.938067 - ↑title_length
# train_rmse: 0.7769351, test_rmse: 0.8799019- ↑published_year
# train_rmse: 0.7235635, test_rmse: 0.8702272- ↑published_month
# train_rmse: 0.7252054, test_rmse: 0.8731753 - published_month_x + published_month_y
# train_rmse: 0.6992839, test_rmse: 0.8750406 - published_day
# train_rmse: 0.7186323, test_rmse: 0.8752473 - published_day_x + published_day_y
# train_rmse: 0.7098051, test_rmse: 0.8743768 - published_term_in_month

# train_rmse: 0.7132829, test_rmse: 0.8671304 - ↑published_dow
# train_rmse: 0.7034046, test_rmse: 0.8668063 - published_dow_x + published_dow_y

# train_rmse: 0.7004901, test_rmse: 0.8639794 - ↑published_hour
# train_rmse: 0.6792362, test_rmse: 0.8658031 - published_hour_x + published_hour_y

# train_rmse: 0.6357584, test_rmse: 0.8537153 - ↑channel_title_length
# train_rmse: 0.6419064, test_rmse: 0.8476512 - ↑flg_categoryId_low
# train_rmse: 0.6840687, test_rmse: 0.8508976 - flg_categoryId_high
# train_rmse: 0.6544945, test_rmse: 0.8519549 - flg_no_tags
# train_rmse: 0.6109983, test_rmse: 0.8458459 - ↑tag_characters
# train_rmse: 0.580868,  test_rmse: 0.8393788 - ↑tag_count
# train_rmse: 0.5854865, test_rmse: 0.8422699 - flg_no_description
# train_rmse: 0.5939091, test_rmse: 0.8388593 - ↑description_length
# train_rmse: 0.5967388, test_rmse: 0.8393317 - flg_url
# train_rmse: 0.5630573, test_rmse: 0.8377533 - ↑url_count
# train_rmse: 0.5569464, test_rmse: 0.8354229 - ↑days_from_published
# train_rmse: 0.5755771, test_rmse: 0.8307188 - ↑diff_likes_dislikes
# train_rmse: 0.5674941, test_rmse: 0.8316972 - sum_likes_dislikes
# train_rmse: 0.5454238, test_rmse: 0.8310772 - ratio_likes
# train_rmse: 0.5354847, test_rmse: 0.8317923 - sum_likes_dislikes_comments
# train_rmse: 0.5597025, test_rmse: 0.8283579 - ↑ratio_comments_likedis
# train_rmse: 0.5323023, test_rmse: 0.8101541 - ↑flg_japanese
# train_rmse: 0.5761294, test_rmse: 0.8161116 - flg_emoji
# train_rmse: 0.5679533, test_rmse: 0.8122008 - flg_official
# train_rmse: 0.5789512, test_rmse: 0.81652   - flg_movie_number
# train_rmse: 0.5459787, test_rmse: 0.8195892 - published_hour2
# train_rmse: 0.5586361, test_rmse: 0.8104735 - published_hour2_x + published_hour2_y
# train_rmse: 0.550295,  test_rmse: 0.8166714 - comments_ratings_disabled_japanese
# train_rmse: 0.4909489, test_rmse: 0.817313  - flg_comments_ratings_disabled_japanese_high
# train_rmse: 0.5347964, test_rmse: 0.8164009 - flg_comments_ratings_disabled_japanese_very_high
# train_rmse: 0.5027024, test_rmse: 0.814753  - flg_comments_ratings_disabled_japanese_low
# train_rmse: 0.5329838, test_rmse: 0.8175195 - flg_comments_ratings_disabled_japanese_very_low

# train_rmse: 0.5451223, test_rmse: 0.8095946 - ↑"mean" 全部のせ
# train_rmse: 0.5305789, test_rmse: 0.8080263 - ↑"median" 全部のせ
# train_rmse: 0.5461993, test_rmse: 0.8074823 - ↑"min" 全部のせ
# train_rmse: 0.5429794, test_rmse: 0.8121191 - "max" 全部のせ
# train_rmse: 0.5276186, test_rmse: 0.8096625 - "sd" 全部のせ

# train_rmse: 0.5523874, test_rmse: 0.8110684 - -flg_categoryId_high_*
# train_rmse: 0.5560334, test_rmse: 0.8069065 - ↑-flg_no_tags_*
# train_rmse: 0.55471,   test_rmse: 0.8061451 - ↑-flg_no_description_*
# train_rmse: 0.5105766, test_rmse: 0.8112012 - -flg_url_*
# train_rmse: 0.5934399, test_rmse: 0.8087113 - -flg_emoji_*
# train_rmse: 0.5892704, test_rmse: 0.8096245 - -flg_official_*
# train_rmse: 0.5479506, test_rmse: 0.8109986 - -flg_movie_number_*
# train_rmse: 0.5256873, test_rmse: 0.808933  - -comments_ratings_disabled_japanese_*

# train_rmse: 0.5367527, test_rmse: 0.8127005 - min と max 入れ替え

# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
# train_rmse: xxxxxxxxx, test_rmse: xxxxxxxxx - xxx
