from openpyxl import load_workbook
import sys
import pandas as pd
import os
import datetime
from calendar import monthrange
now = datetime.datetime.now()

#Get path to excel reports folder for input (used so that countscompare.py doesn't need full path when calling individually)

p = os.path.dirname(os.path.realpath('f.py'))
reports=p+"/"+os.pardir+"/reports/"
filepath = os.path.join(reports, "JIRA_counts_discrepancy_report.txt")
if not os.path.exists(reports):
	os.makedirs(reports)
discrepancyReportFile = open(filepath, "w")
p=p+"/"+os.pardir+"/excel_reports/"
psName = sys.argv[1]
vName = sys.argv[2]


if(len(psName)<5 or psName[-4:]!=".csv"):
	psFullPath = p+psName+".csv"
else:
	psFullPath = p+psName

if(len(vName)<6 or vName[-5:]!=".xlsx"):
	vFullPath = p+vName+".xlsx"
else:
	vFullPath = p+vName

uniqueSSNList={}



#Load data from Validator Report

wb1 = load_workbook(vFullPath)
ws=wb1['Verification Table']

#Convert to pandas dataframe for easier accessibility

data = pd.DataFrame(ws.values)



#Try statement is a workaround for a rare bug when portals are using unusual characters in names. The counts script is run instead of the full countscompare script.
#First, collect tags for each product ID
#The purpose of this is to find which products will have multiple lines on validator report, such as BL/BA or VEL/VEA
#If a product has extra lines, the additional lines can be assumed to exist and skipped for purposes of comparing counts
#Tag verification checks that they actually do exist (though this never seems to come up)

i=1
productList={}
while i<len(data[1]):
	currentPlanID = data[22][i]
	currentTag = data[24][i]
	if currentPlanID in productList:
		if currentTag not in productList[currentPlanID]:
			productList[currentPlanID]["tagList"].append(currentTag)
	else:
		productList[currentPlanID]={"tagList":[],"skipList":[]}
		productList[currentPlanID]["tagList"].append(currentTag)
	i+=1
for currentPlanID in productList:

#skipList is the list of tags to skip for a given product, based on linked tags

	if "VEL" in productList[currentPlanID]["tagList"] and "VEA" in productList[currentPlanID]["tagList"]:
		productList[currentPlanID]["skipList"].append("VEA")
		if "VSA" in productList[currentPlanID]["tagList"]:
			productList[currentPlanID]["skipList"].append("VSA")
		if "VCA" in productList[currentPlanID]["tagList"]:
			productList[currentPlanID]["skipList"].append("VCA")
	elif "BL" in productList[currentPlanID]["tagList"] and "BA" in productList[currentPlanID]["tagList"]:
		productList[currentPlanID]["skipList"].append("BA")

#data[1] is Subscriber_Id column. First entry is data[1][1]
#data[3] is Relationship column (18=employee, 19=child, 1=spouse, 53= domestic partner)
#data[6],data[7] is First_Name, Last_Name column
#data[22] is Plan_ID column
#data[24] is insurance_Line_Code column




#This map is used for both production support and validator to consolidate types.

employeeTypeMap = {"18":"E","employee":"E","1":"S","01":"S","spouse":"S","53":"P","domestic partner":"P","19":"C","child":"C"}


#This function creates pieces of the datastructure that need to exist in order to add a person and a count to either production support or validator.
i=1
warnings=""
def addPersonIfNotExist(currentSSN,currentPlanID,currentPerson,currentPersonType,phiName):
	if currentPlanID not in productList:
		productList[currentPlanID]={"tagList":[],"skipList":[]}
		global warnings
		warnings+="ProductID "+currentPlanID+" is in the production support report but not the XML\n"
	if(currentSSN in uniqueSSNList):
		if(currentPlanID in uniqueSSNList[currentSSN]):
			if(currentPerson not in uniqueSSNList[currentSSN][currentPlanID]["people"]):
				#Children count is used in tag comparison to see if VCL, VCA tags == childrenCount+1
				if currentPersonType == 'C':
					uniqueSSNList[currentSSN][currentPlanID]["childrenCount"]+=1
				#hasSpouse is used in tag comparison to see if VSL, VSA tags == 2 when there is a spouse
				elif currentPersonType == 'S' or currentPersonType == 'P':
					uniqueSSNList[currentSSN][currentPlanID]["hasSpouse"]=1
				#Baseline datastructure for a person
				uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]={'ps':0,'v':0,'psRows':[],'vRows':[],'psProducts':[],"vTags":[],'active':'U','type':currentPersonType,'hasAcc':False,'phiName':phiName}
		else:
			#Baseline datastructure for a plan
			uniqueSSNList[currentSSN][currentPlanID]={"people":{},"tagCounts":{},"hasSpouse":0,"childrenCount":0}
			for tag in productList[currentPlanID]["tagList"]:
				uniqueSSNList[currentSSN][currentPlanID]["tagCounts"][tag]=0
			if currentPersonType == 'C':
				uniqueSSNList[currentSSN][currentPlanID]["childrenCount"]+=1
			elif currentPersonType == 'S' or currentPersonType == 'P':
				uniqueSSNList[currentSSN][currentPlanID]["hasSpouse"]=1
			uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]={'ps':0,'v':0,'psRows':[],'vRows':[],'psProducts':[],"vTags":[],'active':'U','type':currentPersonType,'hasAcc':False,'phiName':phiName}
	else:
		#Baseline datastructure for a SSN
		uniqueSSNList[currentSSN]={}
		uniqueSSNList[currentSSN][currentPlanID]={"people":{},"tagCounts":{},"hasSpouse":0,"childrenCount":0}
		for tag in productList[currentPlanID]["tagList"]:
			uniqueSSNList[currentSSN][currentPlanID]["tagCounts"][tag]=0
		if currentPersonType == 'C':
			uniqueSSNList[currentSSN][currentPlanID]["childrenCount"]+=1
		elif currentPersonType == 'S' or currentPersonType == 'P':
			uniqueSSNList[currentSSN][currentPlanID]["hasSpouse"]=1
		uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]={'ps':0,'v':0,'psRows':[],'vRows':[],'psProducts':[],"vTags":[],'active':'U','type':currentPersonType,'hasAcc':False,'phiName':phiName}


#Now go through and count validator data
while i<len(data[1]):
	currentTag = data[24][i]
	currentSSN = data[1][i]

	#void data seems to look something like "000000nan" for whatever reason
	if(str(currentSSN)[-4:]!="None"):
		currentSSN=int(currentSSN)
	else:
		i+=1
		continue
	currentPlanID = data[22][i]
	#Store people by first name concatenated with last name concatenated with year of birth
	currentDOB=str(data[8][i])
	if(currentDOB[-4:]!="None"):
		currentYOB=currentDOB[2:4]
	else:
		currentYOB="**"
	currentPerson = (data[6][i]+"_"+data[7][i]).replace(',','')+"_"+currentYOB
	phiName = (data[6][i][:1]+". "+data[7][i]).replace(',','')
	currentPersonType = employeeTypeMap[str(data[3][i])]
	addPersonIfNotExist(currentSSN,currentPlanID,currentPerson,currentPersonType,phiName)
	currentSkipList = productList[currentPlanID]["skipList"]
	if currentTag in currentSkipList:
		if(currentTag=="VEA" and currentPersonType=='E'):
			uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['hasAcc']=True
		elif(currentTag=="VCA" and currentPersonType!='E'):
			uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['hasAcc']=True
		elif(currentTag=="VSA" and currentPersonType!='E'):
			uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['hasAcc']=True
		elif(currentTag=="BA"):
			uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['hasAcc']=True
	#Skip conditions (extra lines in production support which will not be in validator)
	#Note that this else if tag is not in skip list
	#If plan is just VEA/VSA/VCA, it will still be counted because not in skip ist and not fulfilling following criteria)
	elif not (currentPersonType == 'E' and (currentTag=="VSL" or currentTag=="VCL" or currentTag=="VSA" or currentTag=="VCA")):
		uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['v']+=1;
		uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['vRows'].append(i+1);
		uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['vTags'].append(currentTag);
	#Tag is counted under any condition.
	uniqueSSNList[currentSSN][currentPlanID]["tagCounts"][currentTag]+=1
	i+=1

#This following section is for tag comparison text output in the console.
hasAtLeastOneTagIssue=False
tagIssueStr ="\n"
tagIssueStr += "  VEL    VEA    VSL    VSA    VCL    VCA          SSN         ProductID\n"
tagIssueStr += "  ---    ---    ---    ---    ---    ---          ---------   ------------------------\n"
for currentSSN in uniqueSSNList:
	for currentPlanID in uniqueSSNList[currentSSN]:
		if "VSL" in productList[currentPlanID]['tagList'] or "VCL" in productList[currentPlanID]['tagList'] or "VSA" in productList[currentPlanID]['tagList'] or "VCA" in productList[currentPlanID]['tagList'] or ("VEL" in productList[currentPlanID]['tagList'] and "VEA" in productList[currentPlanID]['tagList']) :
			hasIssue=False
			if uniqueSSNList[currentSSN][currentPlanID]['childrenCount'] >0:
				reqChildrenTags = uniqueSSNList[currentSSN][currentPlanID]['childrenCount']+1
			else:
				reqChildrenTags = 0
			reqSpouseTags = uniqueSSNList[currentSSN][currentPlanID]['hasSpouse']*2
			myStr = ""
			if "VEL" in productList[currentPlanID]["tagList"] and uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VEL"]<1:
				hasIssue=True
			if "VEA" in productList[currentPlanID]["tagList"] and uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VEA"]<1:
				hasIssue=True
			if "VSL" in productList[currentPlanID]["tagList"] and uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VSL"]<reqSpouseTags:
				hasIssue=True
			if "VSA" in productList[currentPlanID]["tagList"] and uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VSA"]<reqSpouseTags:
				hasIssue=True	
			if "VCL" in productList[currentPlanID]["tagList"] and uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VCL"]<reqChildrenTags:
				hasIssue=True
			if "VCA" in productList[currentPlanID]["tagList"] and uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VCA"]<reqChildrenTags:
				hasIssue=True
			if hasIssue:
				if "VEL" in productList[currentPlanID]["tagList"]:
					myStr += "{:^7}".format(str(uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VEL"])+"|"+str(1))
				else:
					myStr += "       "
				if "VEA" in productList[currentPlanID]["tagList"]:
					myStr += "{:^7}".format(str(uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VEA"])+"|"+str(1))
				else:
					myStr += "       "
				if "VSL" in productList[currentPlanID]["tagList"]:
					myStr += "{:^7}".format(str(uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VSL"])+"|"+str(reqSpouseTags))
				else:
					myStr += "       "
				if "VSA" in productList[currentPlanID]["tagList"]:
					myStr += "{:^7}".format(str(uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VSA"])+"|"+str(reqSpouseTags))
				else:
					myStr += "       "
				if "VCL" in productList[currentPlanID]["tagList"]:
					myStr += "{:^7}".format(str(uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VCL"])+"|"+str(reqChildrenTags))
				else:
					myStr += "       "
				if "VCA" in productList[currentPlanID]["tagList"]:
					myStr += "{:^7}".format(str(uniqueSSNList[currentSSN][currentPlanID]["tagCounts"]["VCA"])+"|"+str(reqChildrenTags))
				else:
					myStr += "       "
				myStr += "        " + "{:<12}".format(str(currentSSN))+currentPlanID
				tagIssueStr+=myStr+"\n"
				hasAtLeastOneTagIssue=True			

#Start analyzing complete system export if it exists

if len(sys.argv)>3 and sys.argv[3]!="*":
	cseName = sys.argv[3]
	p = os.path.dirname(os.path.realpath('f.py'))
	p=p+"/"+os.pardir+"/complete_system_export/"

	if(len(cseName)<5 or cseName[-4:]!=".csv"):
		cseFullPath = p+cseName+".csv"
	else:
		cseFullPath = p+cseName

	data = pd.read_csv(cseFullPath, low_memory=False)
	i=0
	count=0
	activeEENotInXML="\n\n"+"{:<35}".format("Active EE not in XML SSN list") + "{:<15}".format("Hire Date")+"Eligibility Group"+"\n"
	activeEENotInXML+="-----------------------------      ----------     -------------------\n"
	activeEENotInTestFileJIRA="Portal/Test File Discrepancies:\n||Active EE not in Test File||Hire Date||Eligibility Group||\n"
	while i<len(data['primary.ssn']):
		if(data['employment.status'][i]=='inactive'):
			i+=1
			continue
		firstName = data['primary.nameFirst'][i];
		if(str(firstName[-3:])!="nan"):
			phiName = data['primary.nameFirst'][i][:1]+". "+data['primary.nameLast'][i]
		else:
			phiName = "<blank name>"
		currentSSN = data['primary.ssn'][i]
		if(str(currentSSN)[-3:]!="nan"):
			currentSSN=int(str(currentSSN).replace('-','').split('.')[0])
		else:
			currentSSN="<blank value>"
			phiName+=" <no SSN>"
		dateHire = str(data['employment.dateHire'][i])
		groupName = data['group.name'][i]
		if currentSSN not in uniqueSSNList:
			activeEENotInXML+="{:<35}".format(phiName) + "{:<15}".format(dateHire)+groupName+"\n"
			activeEENotInTestFileJIRA+="|"+phiName+"|"+dateHire+"|"+groupName+"|\n"
			count+=1
		i+=1
	activeEENotInXML+="\n\nTotal Active EEs not in Test File:"+str(count)
	activeEENotInTestFileJIRA+="\nTotal Active EEs not in Test File:"+str(count)+"\n\n\n"
	discrepancyReportFile.write(activeEENotInTestFileJIRA)
	print activeEENotInXML

# Read the csv file
data = pd.read_csv(psFullPath, low_memory=False)


#Run comparison script before original counts script changes things

#Here is where we count production support.
i=0

while i<len(data['Primary - SSN']):
	if('Product Waived (Y/N)' in data):  #We don't want to count waived products
		if(data['Product Waived (Y/N)'][i]=='yes'):
			i+=1
			continue
	currentSSN = data['Primary - SSN'][i]
	if(str(currentSSN)[-3:]!="nan"):
		currentSSN=int(str(currentSSN).replace('-','').split('.')[0])
	else:
		i+=1
		continue
	currentPlanID = data['ID'][i]
	currentDOB = str(data['Member - Date of Birth'][i])
	if(currentDOB[-3:]!="nan"):
		currentYOB=currentDOB[-2:]
	else:
		currentYOB="**"
	currentPerson = (data['Member - First Name'][i]+"_"+data['Member - Last Name'][i]).replace(',','')+"_"+currentYOB
	phiName = (data['Member - First Name'][i][:1]+". "+data['Member - Last Name'][i]).replace(',','')
	currentProduct = data['Product Name'][i]
	if data['Product Status'][i]=="confirmed":
		currentProduct = "*"+currentProduct
	currentPersonActive = data['Primary - Employment Status'][i][:1].upper()
	currentPersonType = employeeTypeMap[data['Member - Role'][i]]
	#Check if product end date equals the end of the current month

	dateparts = data['Product End Date'][i].split('/')
	if int(dateparts[0]) == int(now.month) and int(dateparts[2][-2:])==(int(str(now.year)[2:4])):
		currentProduct = "^"+currentProduct
	addPersonIfNotExist(currentSSN,currentPlanID,currentPerson,currentPersonType,phiName)
	uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['ps']+=1;
	uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['psRows'].append(i+2);
	uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['psProducts'].append(currentProduct);
	uniqueSSNList[currentSSN][currentPlanID]["people"][currentPerson]['active']=currentPersonActive;
	i+=1



#compare lists and generate output
#This is for stringbuilding. It stores max width for each index and uses that for formatting later.
#Each "currentProblem" is an array of strings, which is formatted later. "appendProblem" helps build this string
def appendProblem(currentProblem,index,currentString):
	if(len(currentString)>widths[index]):
		widths[index]=len(currentString)
	currentProblem.append(currentString)


#problemList is an array of arrays of strings, used for overall output of this section
problemList = []
widths = [0,0,0,0,0,0,0,0,0]

#Set up Column Titles...
currentProblem = []
appendProblem(currentProblem,0,"Name")
appendProblem(currentProblem,1,"T")
appendProblem(currentProblem,2,"A")
appendProblem(currentProblem,3,"v")
appendProblem(currentProblem,4,"ps")
appendProblem(currentProblem,5,"RowV")
appendProblem(currentProblem,6,"RowPS")
appendProblem(currentProblem,7,"EDI")
#9th element is not formatted, but can extend indefinitely. This is where we put the titles of products, which can have very long lengths.
currentProblem.append("Product Names")
problemList.append(currentProblem)
currentProblem = []
appendProblem(currentProblem,0,"----")
appendProblem(currentProblem,1,"-")
appendProblem(currentProblem,2,"-")
appendProblem(currentProblem,3,"-")
appendProblem(currentProblem,4,"--")
appendProblem(currentProblem,5,"----")
appendProblem(currentProblem,6,"-----")
appendProblem(currentProblem,7,"---")
currentProblem.append("-------------")
problemList.append(currentProblem)



for SSN in uniqueSSNList:
	for currentPlanID in uniqueSSNList[SSN]:
		for person in uniqueSSNList[SSN][currentPlanID]["people"]:
			currentPerson = uniqueSSNList[SSN][currentPlanID]["people"][person]

			#Here comes the magic line that cashes in on all the work we did building up counts.. this simple if statement.

			if(currentPerson['ps']!=currentPerson['v']):
				currentProblem = []
				appendProblem(currentProblem,0,currentPerson['phiName'])
				appendProblem(currentProblem,1,currentPerson['type'])
				appendProblem(currentProblem,2,currentPerson['active'])
				appendProblem(currentProblem,3,str(currentPerson['v']))
				appendProblem(currentProblem,4,str(currentPerson['ps']))
				appendProblem(currentProblem,5,str(currentPerson['vRows']))
				appendProblem(currentProblem,6,str(currentPerson['psRows']))

				currentString =""
				for tag in currentPerson['vTags']:
					currentString += tag+", "
				currentString = currentString[:-2]
				if len(currentString)==0:
					currentString="-"
				appendProblem(currentProblem,7,currentString)

				currentString = ""
				for product in currentPerson['psProducts']:
					currentString += product+", "
				currentString = currentString[:-2]

				currentProblem.append(currentString)
				problemList.append(currentProblem)
#create format strings from widths

#We have the max width of each section from the appendProblem function, so use it to build format strings
formats=[]
i=0
while(i<8):
	formats.append('{:<%s}'%(widths[i]+2))
	i+=1

totalStr=""
jiraReportsString="Production Support/Validator Discrepancies:\n"
#Use each format string to combine the array of strings into a single string
j=0;
for currentProblem in problemList:
	i=0
	currentString=""
	bracketStr=""
	while(i<8):
		if j==0:
			bracketStr="||"+currentProblem[i]
		else:
			bracketStr="|"+currentProblem[i]
		jiraReportsString+=bracketStr.decode('utf-8')
		currentString+=formats[i].format(currentProblem[i])

		i+=1
	currentString+=currentProblem[8]
	if j==0:
		bracketStr="||"+currentProblem[8]+"||\n"
	else:
		bracketStr="|"+currentProblem[8]+"|\n"
	jiraReportsString+=bracketStr.decode('utf-8')
	totalStr+=currentString+"\n"
	j+=1
#print(problemList)
#go back to Counts Script
errorFlag=False




#This is the rare bug mentioned at the beginning. Apparently the solution is to stringify at the beginning, but I did not implement this.












#Old counts script begins here. The first line was the previous pd.read_csv etc. If there is no UnicodeEncodeError, it was done on line 221.

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

print("\n\n")


#Only output countscompare stuff if there was no encode error.
if errorFlag==False:
	print("Variables")
	print("---------")
	print("Name : Person's first name concatenated with person's last name")
	print("T    : Type: E is employee, C is child, S is spouse P is Domestic Partner")
	print("A    : Employee Activity: I is inactive, A is active, U is unknown")
	print("v    : The number of times that the unique ssn,productID,name combination showed up in the validator")
	print("ps   : The number of times that the unique ssn,productID,name combination showed up in prod support")
	print("RowV : The rows in the validator(verification table) that the entries appear")
	print("RowPS: The rows in the production support report that the entries appear")
	print("EDI  : The EDI types for the corresponding entry in the validator report")
	print("Pr Nm: The product names that show up in the corresponding entries in the production support report")
	print("\n")
	print("Empty Primary Subscriber SSNs are ignored.")
	print("* in front of a product name means the product is confirmed (not enrolled). ")
	print("^ in front of a product name means the product is scheduled to end during the current month.")
	print("\n\n")

	discrepancyReportFile.write(jiraReportsString.encode('utf-8'))
	print(totalStr)
	print warnings
	if hasAtLeastOneTagIssue==True:
		print("\n\n")
		print("Tag Comparison")
		print("--------------")
		print("This section finds plans with less than expected EDI types in the validator report (usually stacking)")
		print("Only checks VEL/VEA/VSL/VSA/VCL/VCA EDI types")
		print("Tags present|Tags expected")
		print tagIssueStr
discrepancyReportFile.close()


