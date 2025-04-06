import pandas as pd
import numpy as np

# read in data from csv, extract relevant columns, create new frame from extracted columns
df = pd.read_csv("Dataset/Food_Waste_Characterization_perc.csv")
ID_cols = df[['num','G.num','Food.Wastes.Clean','Group']]
macro_cols = df[['Carbohydrate.Perc','Protein.Perc','Fat.Perc']]
trimmed = pd.concat([ID_cols, macro_cols], axis=1)

# set up to build df with combined food waste items
batch_combinations = pd.DataFrame(columns=trimmed.columns)
continuous_combinations = pd.DataFrame(columns=trimmed.columns)
# percent_combinations = pd.DataFrame(columns=df.columns)
batch_combinations = batch_combinations.rename(columns={'Carbohydrate.Perc':'carb.mass', 'Protein.Perc':'protein.mass', 'Fat.Perc':'fat.mass'})
continuous_combinations = continuous_combinations.rename(columns={'Carbohydrate.Perc':'carb.mass', 'Protein.Perc':'protein.mass', 'Fat.Perc':'fat.mass'})
cur_num = 1

# for each unique combination of food items, create a new entry with their combined/averaged properties
for i in range(len(trimmed)):
    row_a = trimmed.iloc[i]
    for j in range(i+1, len(trimmed)):
        row_b = trimmed.iloc[j]
        new_G_num = row_a['G.num'] + '+' + row_b['G.num']
        new_food_wastes = row_a['Food.Wastes.Clean'] + '_AND_' + row_b['Food.Wastes.Clean']
        new_group = row_a['Group'] + '+' + row_b['Group']

        carb_a = row_a['Carbohydrate.Perc']
        carb_b = row_b['Carbohydrate.Perc']
        prot_a = row_a['Protein.Perc']
        prot_b = row_b['Protein.Perc']
        fat_a = row_a['Fat.Perc']
        fat_b = row_b['Fat.Perc']

        new_batch_carb = round(carb_a*5 + carb_b*5, 5)
        new_batch_protein = round(prot_a*5 + prot_b*5, 5)
        new_batch_fat = round(fat_a*5 + fat_b*5, 5)
        new_batch_row = [cur_num, new_G_num, new_food_wastes, new_group, new_batch_carb, new_batch_protein, new_batch_fat]
        batch_combinations.loc[len(batch_combinations)] = new_batch_row

        new_continuous_carb = round(carb_a*37 + carb_b*37, 5)
        new_continuous_protein = round(prot_a*37 + prot_b*37, 5)
        new_continuous_fat = round(fat_a*37 + fat_b*37, 5)
        new_continuous_row = [cur_num, new_G_num, new_food_wastes, new_group, new_continuous_carb, new_continuous_protein, new_continuous_fat]
        continuous_combinations.loc[len(continuous_combinations)] = new_continuous_row

        # new_percent_carb = round((carb_a + carb_b)/2, 5)
        # new_percent_protein = round((prot_a + prot_b)/2, 5)
        # new_percent_fat = round((fat_a + fat_b)/2, 5)
        # new_percent_row = [cur_num, new_G_num, new_food_wastes, new_food_wastes, new_group, 0, 0, 0, 0, 0, new_percent_fat, new_percent_protein, new_percent_carb, 0, 0, 0, 0]
        # percent_combinations.loc[len(percent_combinations)] = new_percent_row

        cur_num+=1

# percent_combinations.to_csv("Dataset/Food_waste_characterization_combinations.csv", index=False)
# set up tables formatted for ADM1 input
# get column headers from test_feed_inputs
# std_inputs = pd.read_csv("ADM1_MATLAB_Code/Experimental/structures/feed_inputs/std.csv")
# std_columns = std_inputs.columns
std_columns = ["time", "q_in", "S_ch4", "S_IC", "S_IN", "S_h2o", "X_ch", "X_pr", "X_li", "X_bac", "S_gas_ch4", "S_gas_co2"]

cont_length = 100
cont_times = np.arange(cont_length)
cont_quants = np.repeat(5, cont_length)
cont_water = np.repeat(960.51175, cont_length)

batch_length = 10
batch_times = np.array([0,10,20,30,40,50,60,70,80,90])
batch_quants = np.repeat(100, batch_length)
batch_water = np.repeat(960.51175, batch_length)

# assemble a continuous and batch version of inputs for each combination
for index, row in batch_combinations.iterrows():
    # Batch
    batch_df = pd.DataFrame(0, index=np.arange(batch_length), columns=std_columns)
    batch_df['time'] = batch_times
    batch_df['q_in'] = batch_quants
    batch_df['S_h2o'] = batch_water
    batch_df['X_ch'] = np.repeat(row['carb.mass'], batch_length)
    batch_df['X_pr'] = np.repeat(row['protein.mass'], batch_length)
    batch_df['X_li'] = np.repeat(row['fat.mass'], batch_length)
    batch_df.to_csv(f'Dataset/Combinations/Event/{row['Food.Wastes.Clean']}_event.csv', index=False)

for index, row in continuous_combinations.iterrows():
    # Continuous
    cont_df = pd.DataFrame(0, index=np.arange(cont_length), columns=std_columns)
    cont_df['time'] = cont_times
    cont_df['q_in'] = cont_quants
    cont_df['S_h2o'] = cont_water
    cont_df['X_ch'] = np.repeat(row['carb.mass'], cont_length)
    cont_df['X_pr'] = np.repeat(row['protein.mass'], cont_length)
    cont_df['X_li'] = np.repeat(row['fat.mass'], cont_length)
    cont_df.to_csv(f'Dataset/Combinations/Continuous/{row['Food.Wastes.Clean']}_continuous.csv', index=False)