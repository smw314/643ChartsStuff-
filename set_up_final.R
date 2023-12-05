library(tidyverse)
library(readr)
library(janitor)
library(data.table)

# load data
pitches <- fread('/Users/samwirth/Downloads/p5_2022-2.csv')

# clean column names
pitches <- pitches %>% 
  clean_names()

# create swstr and csw variables
pitches <- pitches %>% 
  mutate(csw = case_when(pitch_call == "StrikeSwinging" ~ 1,
                         pitch_call == "StrikeCalled" & strikes == 2 ~ .873,
                         pitch_call == "StrikeCalled" & strikes == 1 ~ .724,
                         pitch_call == "StrikeCalled" & strikes == 0 ~ .503,
                         TRUE ~ 0),
         movement_axis = ifelse(pfxx < 0, 180 + (180 / pi*atan(pfxz/pfxx) + 90), 
                                         180 / pi * atan(pfxz/pfxx) + 90),
         axis_deviation = (360 + movement_axis - spin_axis) %% 360)
         
         # Now correct for values over 180 to get the minimal difference
pitches$axis_deviation[pitches$axis_deviation > 180] <- 360 - pitches$axis_deviation[pitches$axis_deviation > 180]
                              


ssw_test <- pitches %>% group_by(player_name, tagged_pitch_type) %>% 
  summarise(n = n(), spin_axis = mean(spin_axis), 
            movement_axis = mean(movement_axis), 
            axis_deviation = mean(axis_deviation))
View(ssw_test)

pitches$platoon <- ifelse(pitches$batter_side == pitches$pitcher_throws, 1, 0)

# select stuff features
stuff_plus_data <- pitches %>% 
  select(player_id, pitch_date, pitcher_throws, balls, strikes, tagged_pitch_type, rel_speed, spin_rate, 
         spin_axis, rel_height, rel_side, extension, induced_vert_break, 
         horz_break, vert_appr_angle, horz_appr_angle, platoon, csw, axis_deviation)

# omit NA
stuff_plus_data <- na.omit(stuff_plus_data)

## 2022 pitches
pitches2022 <- stuff_plus_data %>% 
  filter(year(pitch_date) == 2022) %>% 
  select(-pitch_date)


fastballs <- c("Fastball", "Sinker", "Cutter", "FourSeamFastBall", 
               "TwoSeamFastBall", "OneSeamFastBall")
breaking_balls <- c("Slider", "Curveball")
offspeed <- c("Changeup", "Splitter")

fb_data_2022 <- pitches2022 %>% 
  filter(tagged_pitch_type %in% fastballs)

bb_data_2022 <- pitches2022 %>% 
  filter(tagged_pitch_type %in% breaking_balls)

off_data_2022 <- pitches2022 %>% 
  filter(tagged_pitch_type %in% offspeed)

pitchers_fb_2022 <- pitches2022 %>%
  filter(tagged_pitch_type %in% fastballs) %>%
  group_by(player_id) %>%
  summarise(fb_velo = mean(rel_speed, na.rm = TRUE),
            fb_ivb = mean(induced_vert_break, na.rm = TRUE),
            fb_hb = mean(horz_break, na.rm = TRUE))

pitchers_non_fb_2022 <- pitches2022 %>% 
  filter(!(tagged_pitch_type %in% fastballs)) %>%
  group_by(player_id) %>%
  mutate(total_pitches = n()) %>% 
  ungroup() %>% 
  group_by(player_id, tagged_pitch_type) %>% 
  summarise(n = n(),
            non_fb_velo = mean(rel_speed, na.rm = TRUE),
            pct = n/total_pitches) %>% 
  distinct() %>% 
  group_by(player_id) %>% 
  summarise(non_fb_velo_all = weighted.mean(non_fb_velo, pct))

off_data_2022 <- merge(off_data_2022, pitchers_fb_2022, by = "player_id")

off_data_2022 <- off_data_2022 %>% 
  mutate(velo_dif = rel_speed - fb_velo,
         ivb_dif = induced_vert_break - fb_ivb,
         hb_dif = horz_break - fb_hb)

off_data_2022 <- off_data_2022 %>%
  select(-player_id, -fb_velo, -fb_ivb, -fb_hb)

bb_data_2022 <- merge(bb_data_2022, pitchers_fb_2022, by = "player_id")

bb_data_2022 <- bb_data_2022 %>% 
  mutate(velo_dif = rel_speed - fb_velo) %>% 
  select(-player_id, -fb_velo, -fb_ivb, -fb_hb)

fb_data_2022 <- merge(fb_data_2022, pitchers_non_fb_2022, by = "player_id")

fb_data_2022 <- fb_data_2022 %>% 
  mutate(velo_dif = rel_speed - non_fb_velo_all) %>% 
  select(-player_id, -non_fb_velo_all)

fb_data_2022 <- fb_data_2022 %>% 
  select(-vert_appr_angle, -horz_appr_angle, -tagged_pitch_type)
bb_data_2022 <- bb_data_2022 %>% 
  select(-vert_appr_angle, -horz_appr_angle, -tagged_pitch_type)
off_data_2022 <- off_data_2022 %>% 
  select(-vert_appr_angle, -horz_appr_angle, -tagged_pitch_type)

fb_data_2022 <- fb_data_2022 %>%
  select(-balls, -strikes)
bb_data_2022 <- bb_data_2022 %>%
  select(-balls, -strikes)
off_data_2022 <- off_data_2022 %>%
  select(-balls, -strikes)

write_csv(fb_data_2022, '2022_fb_data.csv')
write_csv(bb_data_2022, '2022_bb_data.csv')
write_csv(off_data_2022, '2022_off_data.csv')

pitches_2023 <- fread('/Users/samwirth/Downloads/p5_2023-2.csv')
non_p5_pitches <- fread('/Users/samwirth/Downloads/non_p5_2023-2.csv')

pitches_2023 <- rbind(non_p5_pitches, pitches_2023)

# clean column names
pitches_2023 <- pitches_2023 %>% 
  clean_names()

# turn data to numeric
# pitches_2023[, 16:ncol(pitches_2023)] <- lapply(16:ncol(pitches_2023), function(x) as.numeric(pitches_2023[[x]]))

# create swstr and csw variables
pitches_2023 <- pitches_2023 %>% 
  mutate(csw = case_when(pitch_call == "StrikeSwinging" ~ 1,
                         pitch_call == "StrikeCalled" & strikes == 2 ~ .873,
                         pitch_call == "StrikeCalled" & strikes == 1 ~ .724,
                         pitch_call == "StrikeCalled" & strikes == 0 ~ .503,
                         TRUE ~ 0),
         movement_axis = ifelse(pfxx < 0, 180 + (180 / pi*atan(pfxz/pfxx) + 90), 
                                180 / pi * atan(pfxz/pfxx) + 90),
         axis_deviation = (360 + movement_axis - spin_axis) %% 360)

# Now correct for values over 180 to get the minimal difference
pitches_2023$axis_deviation[pitches_2023$axis_deviation > 180] <- 360 - pitches_2023$axis_deviation[pitches_2023$axis_deviation > 180]

pitches_2023$platoon <- ifelse(pitches_2023$batter_side == pitches_2023$pitcher_throws, 1, 0)

pitches2023 <- pitches_2023 %>% 
  select(player_id, pitch_date, balls, strikes, tagged_pitch_type, rel_speed, spin_rate, 
         spin_axis, rel_height, rel_side, extension, induced_vert_break, 
         horz_break, vert_appr_angle, horz_appr_angle, platoon, csw, team_name, player_name,
         axis_deviation) %>% 
  #filter(year(pitch_date) == 2023) %>% 
  select(-pitch_date)

pitches2023 <- na.omit(pitches2023)


fastballs <- c("Fastball", "Sinker", "Cutter", "FourSeamFastBall", 
               "TwoSeamFastBall", "OneSeamFastBall")
breaking_balls <- c("Slider", "Curveball")
offspeed <- c("Changeup", "Splitter")

fb_data_2023 <- pitches2023 %>% 
  filter(tagged_pitch_type %in% fastballs)

bb_data_2023 <- pitches2023 %>% 
  filter(tagged_pitch_type %in% breaking_balls)

off_data_2023 <- pitches2023 %>% 
  filter(tagged_pitch_type %in% offspeed)

pitchers_fb_2023 <- pitches2023 %>%
  filter(tagged_pitch_type %in% fastballs) %>%
  group_by(player_id) %>%
  summarise(fb_velo = mean(rel_speed, na.rm = TRUE),
            fb_ivb = mean(induced_vert_break, na.rm = TRUE),
            fb_hb = mean(horz_break, na.rm = TRUE))

pitchers_non_fb_2023 <- pitches2023 %>% 
  filter(!(tagged_pitch_type %in% fastballs)) %>%
  group_by(player_id) %>%
  mutate(total_pitches = n()) %>% 
  ungroup() %>% 
  group_by(player_id, tagged_pitch_type) %>% 
  summarise(n = n(),
            non_fb_velo = mean(rel_speed, na.rm = TRUE),
            pct = n/total_pitches) %>% 
  distinct() %>% 
  group_by(player_id) %>% 
  summarise(non_fb_velo_all = weighted.mean(non_fb_velo, pct))

off_data_2023 <- merge(off_data_2023, pitchers_fb_2023, by = "player_id")

off_data_2023 <- off_data_2023 %>%
  mutate(velo_dif = rel_speed - fb_velo,
         ivb_dif = induced_vert_break - fb_ivb,
         hb_dif = horz_break - fb_hb)

off_data_2023 <- off_data_2023 %>%
  select(-player_id, -fb_velo, -fb_ivb, -fb_hb)

bb_data_2023 <- merge(bb_data_2023, pitchers_fb_2023, by = "player_id")

bb_data_2023 <- bb_data_2023 %>% 
  mutate(velo_dif = rel_speed - fb_velo) %>% 
  select(-player_id, -fb_velo, -fb_ivb, -fb_hb)

fb_data_2023 <- merge(fb_data_2023, pitchers_non_fb_2023, by = "player_id")

fb_data_2023 <- fb_data_2023 %>% 
  mutate(velo_dif = rel_speed - non_fb_velo_all) %>% 
  select(-player_id, -non_fb_velo_all)


fb_data_2023 <- fb_data_2023 %>% 
  select(-vert_appr_angle, -horz_appr_angle)
bb_data_2023 <- bb_data_2023 %>% 
  select(-vert_appr_angle, -horz_appr_angle)
off_data_2023 <- off_data_2023 %>% 
  select(-vert_appr_angle, -horz_appr_angle)

fb_data_2023 <- fb_data_2023 %>%
  select(-balls, -strikes)
bb_data_2023 <- bb_data_2023 %>%
  select(-balls, -strikes)
off_data_2023 <- off_data_2023 %>%
  select(-balls, -strikes)

write_csv(fb_data_2023, '2023_fb_data.csv')
write_csv(bb_data_2023, '2023_bb_data.csv')
write_csv(off_data_2023, '2023_off_data.csv')
