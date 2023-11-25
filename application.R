# Load the tidyverse package which includes various packages like dplyr, ggplot2, etc.
library(tidyverse)

# Read the prediction data from CSV files
off_pred <- read_csv('off_pred_ssw.csv')
fb_pred <- read_csv('fb_pred_ssw.csv')
bb_pred <- read_csv('bb_pred_ssw.csv')

# Combine the individual prediction data into a single dataset
pred_2023 <- rbind(bb_pred, off_pred, fb_pred)

# Rename the columns of the combined dataset
colnames(pred_2023) <- c("na", "csw_pred")

# Drop the 'na' column from the combined dataset
pred_2023 <- pred_2023 %>% 
  select(-na)

# Combine the different data sources for 2023 into a single dataset
all_pitches_2023 <- plyr::rbind.fill(bb_data_2023, off_data_2023, fb_data_2023)

# Adjust the combined dataset to include the predictions
all_pitches_2023 <- cbind(all_pitches_2023, pred_2023)

# Clean up the player names by removing any double quotes
all_pitches_2023$player_name <- gsub('\"', '',all_pitches_2023$player_name)

# Create a new 'stuff' metric by scaling the 'csw_pred' values to have a median of 100
all_pitches_2023 <- all_pitches_2023 %>% 
  mutate(stuff = scale_to(csw_pred, 100))

# Calculate average 'stuff' metrics by player and team
overall_player_stuff <- all_pitches_2023 %>% 
  group_by(player_name, team_name) %>% 
  summarise(n = n(), stuff_plus = mean(stuff)) %>% 
  arrange(-stuff_plus)

overall_team_stuff <- all_pitches_2023 %>% 
  group_by(team_name) %>% 
  summarise(n = n(), stuff_plus = mean(stuff)) %>% 
  arrange(-stuff_plus)

# Calculate average 'stuff' metrics by player, team, and pitch type, filtering out instances with less than 40 pitches
pitch_player_stuff <- all_pitches_2023 %>% 
  group_by(player_name, tagged_pitch_type, team_name) %>% 
  summarise(n = n(), stuff_plus = mean(stuff)) %>% 
  arrange(-stuff_plus) %>% 
  filter(n > 40)

pitch_team_stuff <- all_pitches_2023 %>% 
  group_by(team_name, tagged_pitch_type) %>% 
  summarise(n = n(), stuff_plus = mean(stuff)) %>% 
  arrange(-stuff_plus)

# Calculate overall average 'stuff' metrics by pitch type
pitches <- all_pitches_2023 %>% 
  group_by(tagged_pitch_type) %>% 
  summarise(n = n(), stuff = mean(stuff))

# Save the computed metrics to CSV files
write_csv(overall_player_stuff, 'overall_player_stuff.csv')
write_csv(overall_team_stuff, 'overall_team_stuff.csv')
write_csv(pitch_player_stuff, 'pitch_player_stuff.csv')
write_csv(pitch_team_stuff, 'pitch_team_stuff.csv')





#### SSW testing
pitches_diff <- merge(pitches, pitches_ssw, by = "tagged_pitch_type")
colnames(pitches_diff) <- c("tagged_pitch_type", "n", "stuff", "n.y", "stuff_ssw")
pitches_diff <- pitches_diff %>% 
  mutate(diff = stuff - stuff_ssw) %>% 
  select(-n.y)

pitch_player_diff <- merge(pitch_player_stuff, pitch_player_stuff_ssw, by = c("player_name", "team_name", "tagged_pitch_type", "n"))
pitch_player_diff <- pitch_player_diff %>% 
  mutate(stuff_diff = stuff_plus.x - stuff_plus.y)
colnames(pitch_player_diff) <- c("player_name", "team_name", "tagged_pitch_type", "n", "stuff", "stuff_ssw", "stuff_diff")

overall_player_diff <- merge(overall_player_stuff, overall_player_stuff_ssw, by = "player_name")
overall_player_diff <- overall_player_diff %>% 
  select(-c(n.y, team_name.y)) %>% 
  mutate(stuff_diff = stuff_plus.x - stuff_plus.y)
colnames(overall_player_diff) <- c("player_name", "team_name", "n", "stuff", "stuff_ssw", "stuff_diff")

# Save the merged and adjusted data to CSV files
write_csv(pitch_player_diff, 'pitch_player_diff.csv')
write_csv(overall_player_diff, 'overall_player_diff.csv')





100 / median(bb_pred$`0`)
