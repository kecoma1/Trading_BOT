import pandas as pd

dataframe = pd.read_csv("data.csv")

# Checking the data
print(dataframe.head(5))

# Getting the shape of the data
print("\nData shape (rows, columns):", dataframe.shape)

column_types = []

# Iterating through types
for type in dataframe.dtypes:
    column_types.append(type)

print("\nDataframe types:", column_types, "\n")

# Iterating through columns
for i, col in enumerate(dataframe.iteritems()):
    column_name = col[0]
    print("Column "+str(i+1)+": "+column_name, end=" ")
    
    # Getting the unique values of each column
    column_unique_values = list(dataframe[column_name].unique()).copy()
    print("- Unique values:", column_unique_values, end=" ")
    
    column_unique_values.sort()
    print("- sorted ->", column_unique_values)

# Iterating through rows
for i, row in enumerate(dataframe.iterrows()):
    print("\nRow "+str(i)+": "+str(row))
    
    # Iterating through columns in the row
    for j, col in enumerate(row[1].items()):
        print(str(j)+": "+str(col), end=" | ")

# Adding rows
dataframe = dataframe.append({'C1': 'y', 'C3': 'x', 'C4': 0.5}, ignore_index=True)
print(dataframe.tail(5))

# Editing rows
dataframe.at[9, 'C2'] = 12
dataframe.at[9, 'C5'] = 'z'
dataframe.at[9, 'Class'] = 'D'
print("\n", dataframe.tail(5))

# Deleting rows
dataframe = dataframe.drop([0, 1])
print("\n", dataframe.head(5))

# Add column
dataframe.insert(1, "New col", [1,2,3,4,5,6,7,8])
print("\n", dataframe.head(5))

# New empty column
import numpy as np
dataframe["empty col"] = np.nan

# Delete a column
dataframe = dataframe.drop(columns="New col")
print("\n", dataframe.head(5))

