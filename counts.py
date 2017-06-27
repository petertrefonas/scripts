import sys
import pandas as pd
import os






# Read the file
p=os.path.dirname(os.path.dirname(os.path.realpath('f.py')))+"/excel_reports/"
data = pd.read_csv(p+sys.argv[1], low_memory=False)

# clean data
data.rename(columns = {'Member - Role':'Role'}, inplace = True)
data.rename(columns = {'Product Waived (Y/N)':'Waived'}, inplace = True)
data = data[data.Waived != 'yes']
data.rename(columns = {'Product Name':'ProductName'}, inplace = True)
data.rename(columns = {'Product Type':'ProductType'}, inplace = True)


#counts
print("\nCounts per type")
print("-----------")


for pType, group_data in data.groupby(["ProductType"]):
	print "{0}: {1} \n ".format(pType, len(group_data))


print("\nCounts per Product")
print("-----------")


for name, group_data in data.groupby(["ProductName"]):
	print "{0}: {1} \n ".format(name, len(group_data))


print("\nCounts per product per role")
print("-----------")

for (name, role), group_data in data.groupby(["ProductName", "Role"]):
	print "{0}: {1}:{2}\n ".format(name, role, len(group_data))
