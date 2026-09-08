import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns

df=pd.read_csv('market_data.csv')
print(df.head())
print(df.describe())
print(df.info())
print(df.columns.tolist())

#Data Cleanin
df= df.drop_duplicates()
df.columns= df.columns.str.strip().str.lower().str.replace(' ', '_').str.replace('(', '').str.replace(')', '')
print(df.columns.tolist())

df['price'] = df['price'].astype(str).str.replace(',','').astype(float)
df['area'] = df['area'].astype(str).str.replace(',','').astype(int)
print(df['area'])

df['rate_per_sqft'] = df['rate_per_sqft'].astype(str).str.replace(',','').astype(float)
print(df['rate_per_sqft'])

df['status'] = df['status'].astype(str).str.strip().str.lower()
df['rera_approval'] = df['rera_approval'].astype(str).str.strip().map({'Approved by RERA': True, 'Not approved by RERA': False})   

#print df
# print(df.info())

#Question 1: Which is the costliest flat in the dataset?
costliest_flat = df[df['price'] == df['price'].max()]
print("Costliest Flat Details:")
print(costliest_flat)  
print("Costliest Flat Price:", costliest_flat['price'].values[0])

#Question 2: Which locality has the highest average price?
df.groupby('locality')['price'].mean().idxmax()
highest_avg_price_locality = df.groupby('locality')['price'].mean().idxmax()
print("Locality with Highest Average Price:", highest_avg_price_locality)
print("Highest Average Price:", df.groupby('locality')['price'].mean().max())
print(df.groupby('locality')['price'].head(10),df.groupby('locality')['socity'].head(10))

print (df.info())

#Question 3:  Do ready-to-move properties cost more than under-construction properties?
ready_to_move_avg_price = df[df['status'] == 'ready to move']['price'].mean()
under_construction_avg_price = df[df['status'] == 'under construction']['price'].mean()
print("Average Price of Ready-to-Move Properties:", ready_to_move_avg_price)
print("Average Price of Under-Construction Properties:", under_construction_avg_price)
print("Ready-to-Move properties cost more than Under-Construction properties:", ready_to_move_avg_price > under_construction_avg_price)
print(df.groupby('status')['price'].mean())
print(df.groupby('status')['price'].head(10))
print(df.groupby('status')['price'].describe())
print(df.groupby('status')['price'].describe().head(10))

#Question 4: Do RERA-approved properties command a price premium?
rera_approved_avg_price = df[df['rera_approval'] == True]['price'].mean()
rera_not_approved_avg_price = df[df['rera_approval'] == False]['price'].mean()
print("Average Price of RERA-approved Properties:", rera_approved_avg_price)
print("Average Price of RERA-not-approved Properties:", rera_not_approved_avg_price)
print("RERA-approved properties command a price premium:", rera_approved_avg_price > rera_not_approved_avg_price)

#Question 5 : How does area (sqft) impact property price?
area_price_correlation = df['area'].corr(df['price'])
print("Correlation between Area and Price:", area_price_correlation)
print(df[['area', 'price']].head(10))

#Question 6: Which BHK configuration is the most expensive on average?
bhk_avg_price = df.groupby('bhk_count')['price'].mean()
most_expensive_bhk = bhk_avg_price.idxmax()
print("Most Expensive BHK Configuration:", most_expensive_bhk)
print("Average Price of Most Expensive BHK Configuration:", bhk_avg_price.max())

#Question 7: Which property type (Apartment, Floor, Plot) is the costliest?
property_type_avg_price = df.groupby('property_type')['price'].mean()
costliest_property_type = property_type_avg_price.idxmax()
print("Costliest Property Type:", costliest_property_type)
print("Average Price of Costliest Property Type:", property_type_avg_price.max())

#Question 8: Do certain builders or companies consistently price higher?
builder_avg_price = df.groupby('builder_name')['price'].mean()
most_expensive_builder = builder_avg_price.idxmax()
print("Most Expensive Builder:", most_expensive_builder)
print("Average Price of Most Expensive Builder:", builder_avg_price.max())

# Question 10: Are larger homes always more expensive per square foot?
df['price_per_sqft'] = df['price'] / df['area']
larger_homes_expensive = df.groupby('area')['price_per_sqft'].mean()
print("Larger homes are more expensive per square foot:", larger_homes_expensive.iloc[-1] > larger_homes_expensive.iloc[0])


sns.scatterplot(x="area", y="price", data=df)
plt.show()