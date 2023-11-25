import pandas as pd
from scipy.stats import randint
from sklearn.model_selection import RandomizedSearchCV
from catboost import CatBoostRegressor
from sklearn.model_selection import train_test_split
import numpy as np
from sklearn.metrics import mean_squared_error, mean_absolute_error

# Load the datasets for the years 2022 and 2023
df_2022 = pd.read_csv('/Users/samwirth/Desktop/643/stuff_plus/stufff_plus/2022_off_data.csv')
df_2023 = pd.read_csv('/Users/samwirth/Desktop/643/stuff_plus/stufff_plus/2023_off_data.csv')

# Remove rows with any missing values from both datasets
df_2022 = df_2022.dropna()
df_2023 = df_2023.dropna()

# Prepare feature matrices and target vectors for both years
# For 2022, drop 'csw' and 'pitcher_throws' columns and use 'csw' as target
df_2022_x = df_2022.drop(['csw', 'pitcher_throws'], axis=1)
df_2022_y = df_2022['csw']

# For 2023, drop specified columns and use 'csw' as target
df_2023_x = df_2023.drop(['csw', 'team_name', 'player_name', 'tagged_pitch_type'], axis=1)
df_2023_y = df_2023['csw']

print(df_2023_x.columns)

# # Identify the indices of categorical features in the 2022 dataset 
# categorical_features_indices = np.where(df_2022_x.dtypes != np.float)[0]

# model = CatBoostRegressor(learning_rate=.2, max_depth=3, iterations=103, loss_function='RMSE', eval_metric='RMSE', verbose=False)

# model.fit(df_2022_x, df_2022_y,eval_set=(df_2023_x, df_2023_y),plot=True)

# ypred = model.predict(df_2023_x)

# # Calculate error metrics for the predictions on the 2023 dataset
# mae = mean_absolute_error(df_2023_y, ypred)
# mse = mean_squared_error(df_2023_y, ypred)
# print("MAE: %.5f" % mae)
# print("RMSE: %.5f" % (mse**(1/2.0)))

# # Save the predictions to a CSV file
# pd.Series(ypred).to_csv('/Users/samwirth/Desktop/643/stuff_plus/stufff_plus/off_pred_ssw.csv', index=False)

# model_path = "/Users/samwirth/Desktop/643/stuff_plus/stufff_plus/off_catboost_model.cbm"
# model.save_model(model_path, format="cbm")


# # # Define the hyperparameter search space for CatBoostRegressor
# # param_dist = {
# #     "learning_rate": np.linspace(0, 0.2, 5),
# #     "max_depth": randint(3, 10),
# #     "iterations": randint(100, 1000),
# #     "loss_function": ['RMSE'],
# #     "cat_features": [categorical_features_indices]
# # }

# # # Split the 2022 dataset into training and validation subsets for cross-validation
# # X_train, X_val, y_train, y_val = train_test_split(df_2022_x, df_2022_y, test_size=0.2, random_state=42)

# # # Initialize a RandomizedSearchCV object to search over hyperparameters
# # rscv = RandomizedSearchCV(CatBoostRegressor(), param_dist, scoring='neg_mean_squared_error', cv=5, verbose=True, n_iter=10, n_jobs=-1)

# # # Fit the randomized search to the training data
# # rscv.fit(X_train, y_train)

# # # Display the best hyperparameters found by the search
# # print(rscv.best_params_)

# # # Use the model with the best hyperparameters to train on the full 2022 dataset and predict on the 2023 dataset
# # best_model = rscv.best_estimator_
# # best_model.fit(df_2022_x, df_2022_y, eval_set=(df_2023_x, df_2023_y), verbose=False, plot=True)
# # ypred = best_model.predict(df_2023_x)

# # # Calculate error metrics for the predictions on the 2023 dataset
# # mae = mean_absolute_error(df_2023_y, ypred)
# # mse = mean_squared_error(df_2023_y, ypred)
# # print("MAE: %.5f" % mae)
# # print("RMSE: %.5f" % (mse**(1/2.0)))

# # # Save the predictions to a CSV file
# # pd.Series(ypred).to_csv('/Users/samwirth/Desktop/643/stuff_plus/stufff_plus/off_pred_ssw.csv', index=False)

# # # {'cat_features': array([8]), 'iterations': 103, 'learning_rate': 0.2, 'loss_function': 'RMSE', 'max_depth': 3}