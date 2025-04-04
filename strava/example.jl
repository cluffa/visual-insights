using StravaConnect
using DataFrames

u = setup_user();

begin
    df = get_activity_list(u)

    reduce_subdicts!(df)
    fill_dicts!(df)

    df = DataFrame(df)
end

print(df[end-5:end, :]) # Show the last 5 activities in the list

# 6×59 DataFrame
#  Row │ elev_low  moving_time  kilojoules  timezone                      max_speed  end_latlng              workout_type  max_heartrate  total_elevation_gain  achievement_count  sport_type   utc_offset  upload_id    upload_id_str  private  weighted_average_watts  name                            trainer  manual  has_heartrate  has_kudoed  location_city  from_accepted_tag  athlete_resource_state  total_photo_count  distance  photo_count  flagged  commute  athlete_count  map_id        average_heartrate  kudos_count  device_watts  start_date_local      map_summary_polyline               max_watts  heartrate_opt_out  elapsed_time  location_country  start_date            athlete_id  visibility  location_state  display_hide_heartrate_option  gear_id    elev_high  external_id                        pr_count  map_resource_state  average_temp  resource_state  average_cadence  start_latlng            average_speed  average_watts  id           type         comment_count 
#      │ Union…    Int64        Union…      String                        Float64    Array…                  Union…        Union…         Float64               Int64              String       Int64       Union…       Union…         Bool     Union…                  String                          Bool     Bool    Bool           Bool        Nothing        Bool               Int64                   Int64              Float64   Int64        Bool     Bool     Int64          String        Union…             Int64        Union…        String                String                             Union…     Bool               Int64         Nothing           String                Int64       String      Nothing         Bool                           Union…     Union…     Union…                             Int64     Int64               Union…        Int64           Union…           Array…                  Float64        Union…         Int64        String       Int64         
# ─────┼──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#    1 │ 276.2            2996  1031.7      (GMT-05:00) America/New_York       4.74  Any[40.5923, -83.1856]  0             180                             8.0                  1  Run              -14400  15001434003  15001434003      false  381                     Afternoon Run                     false   false           true       false                             false                       1                  0    8890.8            0    false    false              1  a14053349753  154.6                        0  true          2025-04-01T17:52:54Z  qdwvFpcvzN@LE`DO|Fo@zLCpA_@zJCbC…  588                    false          3012                    2025-04-01T21:52:54Z    31282795  everyone                                             true  g19582091  283.4      garmin_ping_425025585236                  0                   2                             2  77.4             Any[40.5923, -83.1854]          2.968  345.9          14053349753  Run                      0
#    2 │ 0.0              2984              (GMT-04:00) America/Anguilla       0.0   Any[]                                 168                             0.0                  0  Workout          -14400  15011871598  15011871598       true                          Afternoon Workout                  true   false           true       false                             false                       1                  0       0.0            0    false    false              1  a14063212503  114.8                        0                2025-04-02T17:43:57Z                                                            false          2984                    2025-04-02T21:43:57Z    31282795  only_me                                              true             0.0        garmin_ping_425336171050                  0                   2                             2                   Any[]                           0.0                   14063212503  Workout                  0
#    3 │ 10.4             4031  426.9       (GMT-05:00) America/New_York      12.8   Any[-21.7273, 166.178]                125                           165.0                  3  VirtualRide      -14400  15012807250  15012807250      false  108                     Zwift - Douce France in France    false   false           true       false                             false                       1                  3   27683.2            0    false    false              2  a14064114324  113.4                        0  true          2025-04-02T19:54:37Z  hitcCwqhu^fLba@aHjHi@vKYRuAa@UlB…  133                    false          4031                    2025-04-02T23:54:37Z    31282795  everyone                                             true  b14691262  34.0       zwift-activity-18432242426493173…         0                   2                             2  70.1             Any[-21.736, 166.183]           6.868  105.9          14064114324  VirtualRide              0
#    4 │ 0.0               724              (GMT-04:00) America/Anguilla       0.0   Any[]                                 184                             0.0                  0  Workout          -14400  15021410266  15021410266       true                          Afternoon Workout                  true   false           true       false                             false                       1                  0       0.0            0    false    false              1  a14072268895  135.6                        0                2025-04-03T16:50:17Z                                                            false           724                    2025-04-03T20:50:17Z    31282795  only_me                                              true             0.0        garmin_ping_425627973578                  0                   2                             2                   Any[]                           0.0                   14072268895  Workout                  0
#    5 │ 0.0               572              (GMT-04:00) America/Anguilla       0.0   Any[]                                 180                             0.0                  0  Workout          -14400  15021521599  15021521599       true                          Afternoon Workout                  true   false           true       false                             false                       1                  0       0.0            0    false    false              1  a14072375195  157.0                        0                2025-04-03T17:10:03Z                                                            false           572                    2025-04-03T21:10:03Z    31282795  only_me                                              true             0.0        garmin_ping_425631757828                  0                   2                             2                   Any[]                           0.0                   14072375195  Workout                  0
#    6 │ 0.0              3305  1092.6      (GMT-04:00) America/Anguilla       3.64  Any[]                                 176                             0.0                  0  Run              -14400  15022153204  15022153204      false  355                     Afternoon Run                      true   false           true       false                             false                       1                  0    9173.3            0    false    false              1  a14072984925  157.6                        0  true          2025-04-03T17:58:23Z                                     426                    false          3305                    2025-04-03T21:58:23Z    31282795  everyone                                             true  g21926984  0.0        garmin_ping_425652886771                  0                   2                             2  74.2             Any[]                           2.776  330.6          14072984925  Run                      0

act = [get_activity(x, u; verbose = true) for x in df.id[end-5:end]];

reduce_subdicts!(act)
fill_dicts!(act)

print(DataFrame(act[1])[end-5:end, :]) # Show the last 5 activities in the list after filling dicts

# 6×40 DataFrame
#  Row │ altitude_data  altitude_original_size  altitude_resolution  altitude_series_type  cadence_data  cadence_original_size  cadence_resolution  cadence_series_type  distance_data  distance_original_size  distance_resolution  distance_series_type  grade_smooth_data  grade_smooth_original_size  grade_smooth_resolution  grade_smooth_series_type  heartrate_data  heartrate_original_size  heartrate_resolution  heartrate_series_type  latlng_data             latlng_original_size  latlng_resolution  latlng_series_type  moving_data  moving_original_size  moving_resolution  moving_series_type  time_data  time_original_size  time_resolution  time_series_type  velocity_smooth_data  velocity_smooth_original_size  velocity_smooth_resolution  velocity_smooth_series_type  watts_data  watts_original_size  watts_resolution  watts_series_type 
#      │ Any            Int64                   String               String                Any           Int64                  String              String               Any            Int64                   String               String                Any                Int64                       String                   String                    Any             Int64                    String                String                 Any                     Int64                 String             String              Any          Int64                 String             String              Any        Int64               String           String            Any                   Int64                          String                      String                       Any         Int64                String            String            
# ─────┼───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────
#    1 │ 278                              3013  high                 distance              72                             3013  high                distance             8884.8                           3013  high                 distance              3.6                                      3013  high                     distance                  143                                3013  high                  distance               Any[40.5923, -83.1857]                  3013  high               distance            true                         3013  high               distance            3007                     3013  high             distance          1.94                                           3013  high                        distance                     304                        3013  high              distance
#    2 │ 278.2                            3013  high                 distance              56                             3013  high                distance             8886.5                           3013  high                 distance              3.9                                      3013  high                     distance                  142                                3013  high                  distance               Any[40.5923, -83.1857]                  3013  high               distance            true                         3013  high               distance            3008                     3013  high             distance          1.78                                           3013  high                        distance                     235                        3013  high              distance
#    3 │ 278.4                            3013  high                 distance              54                             3013  high                distance             8888.2                           3013  high                 distance              4.5                                      3013  high                     distance                  142                                3013  high                  distance               Any[40.5923, -83.1857]                  3013  high               distance            true                         3013  high               distance            3009                     3013  high             distance          1.62                                           3013  high                        distance                     223                        3013  high              distance
#    4 │ 278.4                            3013  high                 distance              54                             3013  high                distance             8889.9                           3013  high                 distance              5.2                                      3013  high                     distance                  141                                3013  high                  distance               Any[40.5923, -83.1857]                  3013  high               distance            true                         3013  high               distance            3010                     3013  high             distance          1.54                                           3013  high                        distance                     203                        3013  high              distance
#    5 │ 278.4                            3013  high                 distance              54                             3013  high                distance             8891.3                           3013  high                 distance              3.3                                      3013  high                     distance                  141                                3013  high                  distance               Any[40.5923, -83.1856]                  3013  high               distance            true                         3013  high               distance            3011                     3013  high             distance          1.54                                           3013  high                        distance                     189                        3013  high              distance
#    6 │ 278.4                            3013  high                 distance              54                             3013  high                distance             8892.5                           3013  high                 distance              0                                        3013  high                     distance                  141                                3013  high                  distance               Any[40.5923, -83.1856]                  3013  high               distance            true                         3013  high               distance            3012                     3013  high             distance          1.54                                           3013  high                        distance                     185                        3013  high              distance