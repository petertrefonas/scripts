from openpyxl import load_workbook
import sys
import pandas as pd
import os
#Get path to excel reports folder for input (used so that countscompare.py doesn't need full path when calling individually)

p = os.path.dirname(os.path.realpath('f.py'))
p=p+"/"+os.pardir+"/excel_reports/"
if len(sys.argv)>1:
	vName = sys.argv[1]
else:
	sys.exit("Error - missing validator report path. Syntax = python checkMatchingAmounts.py <validator path> <spouse_multiplier> <child_multiplier>")
if len(sys.argv)>2:
	SPOUSE_MULTIPLIER = sys.argv[2]
else:
	SPOUSE_MULTIPLIER = 0
	print "Missing argument <spouse_multiplier>"
if len(sys.argv)>3:
	CHILD_MULTIPLIER = sys.argv[3]
else:
	CHILD_MULTIPLIER = 0
	print "Missing argument <child_multiplier>"

if(len(vName)<6 or vName[-5:]!=".xlsx"):
	vFullPath = p+vName+".xlsx"
else:
	vFullPath = p+vName



#Load data from Validator Report

wb1 = load_workbook(vFullPath)
productsTable=wb1['Products Table']
verificationTable=wb1['Verification Table']
#Convert to pandas dataframe for easier accessibility


data = pd.DataFrame(verificationTable.values)




volLifeList = ["VEL","VEA","VCL","VCA","VSL","VSA"]

memberIDList={}
doubleTagList=[]
eeMap={}

i=1
while i<len(data[0]):
	currentPersonType = str(data[3][i])
	currentPersonName = (data[6][i][:1]+". "+data[7][i]).replace(',','')
	currentMemberID = str(data[0][i])
	if currentPersonType == "18":
		eeMap[currentMemberID]=currentPersonName
	i+=1
data = pd.DataFrame(productsTable.values)

totalStr = '{:<20}'.format("Employee Name")+"ID     Problem       EDI Type: Amount Requested\n"
totalStr += "-------------       --     -------       --------------------------\n"
jiraStr = "||Employee Name||ID||Problem||Edi Type: Amount Requested||\n"
def addMemberIfNotExist(currentMemberID,currentEDIType,currentAmountRequested):
	if(currentMemberID in memberIDList):
		if(currentEDIType not in memberIDList[currentMemberID]):
			memberIDList[currentMemberID][currentEDIType]=currentAmountRequested;
		else:
			doubleTagList.append(currentMemberID)
	else:
		memberIDList[currentMemberID] = {};
		memberIDList[currentMemberID][currentEDIType]=currentAmountRequested;
i=1
def addToTotalStr(currentMemberID,problem):
	myStr = '{:<20}'.format(eeMap[currentMemberID])+'{:<7}'.format(currentMemberID)+'{:<14}'.format(problem)
	for ediType in memberIDList[currentMemberID]:
		myStr += ediType+": "+str(memberIDList[currentMemberID][ediType])+" | ";
	return myStr[:-2]+"\n"
def addToJiraStr(currentMemberID,problem):
	myStr = "|"+eeMap[currentMemberID]+"|"+currentMemberID+"|"+problem+"|"
	for ediType in memberIDList[currentMemberID]:
		myStr += ediType+": "+str(memberIDList[currentMemberID][ediType])+"|";
	return myStr+"\n"
while i<len(data[0]):
	currentMemberID = str(data[0][i])
	if currentMemberID in eeMap:
		currentEDIType = str(data[14][i])
		if(currentEDIType in volLifeList):
			if str(data[6][i])[-3:]!="nan":
				currentAmountRequested = int(data[6][i])
				addMemberIfNotExist(currentMemberID,currentEDIType,currentAmountRequested);
			else:
				print "EE "+eeMap[currentMemberID]+" is missing Amount Requested for a vol life edi type"
	i+=1
print "Members with discrepancies in amount requested:"

for currentMemberID in memberIDList:
	if "VEL" in memberIDList[currentMemberID] and "VEA" in memberIDList[currentMemberID] and memberIDList[currentMemberID]["VEL"]!=memberIDList[currentMemberID]["VEA"]:
		totalStr+=addToTotalStr(currentMemberID,"VEA!=VEL");
		jiraStr+=addToJiraStr(currentMemberID,"VEA!=VEL");
	elif "VCL" in memberIDList[currentMemberID] and "VCA" in memberIDList[currentMemberID] and memberIDList[currentMemberID]["VCL"]!=memberIDList[currentMemberID]["VCA"]:
		totalStr+=addToTotalStr(currentMemberID,"VCA!=VCL");
		jiraStr+=addToJiraStr(currentMemberID,"VCA!=VCL");
	elif "VSL" in memberIDList[currentMemberID] and "VSA" in memberIDList[currentMemberID] and memberIDList[currentMemberID]["VSL"]!=memberIDList[currentMemberID]["VSA"]:
		totalStr+=addToTotalStr(currentMemberID,"VSA!=VSL");
		jiraStr+=addToJiraStr(currentMemberID,"VSA!=VSL");
	elif "VSL" in memberIDList[currentMemberID] and SPOUSE_MULTIPLIER>0 and "VEL" in memberIDList[currentMemberID] and int(memberIDList[currentMemberID]["VSL"]) > int(float(SPOUSE_MULTIPLIER)*int(memberIDList[currentMemberID]["VEL"])):
		totalStr+=addToTotalStr(currentMemberID,"VSL>"+str(SPOUSE_MULTIPLIER)+"*VEL");
		jiraStr+=addToJiraStr(currentMemberID,"VSL>"+str(SPOUSE_MULTIPLIER)+"*VEL");
	elif "VCL" in memberIDList[currentMemberID] and CHILD_MULTIPLIER>0 and "VEL" in memberIDList[currentMemberID] and int(memberIDList[currentMemberID]["VCL"]) > int(float(CHILD_MULTIPLIER)*int(memberIDList[currentMemberID]["VEL"])):
		totalStr+=addToTotalStr(currentMemberID,"VCL>"+str(CHILD_MULTIPLIER)+"*VEL");
		jiraStr+=addToJiraStr(currentMemberID,"VCL>"+str(CHILD_MULTIPLIER)+"*VEL");

if len(doubleTagList)>0:
	print "Found Double Tags Please Investigate"
print totalStr
print "\n"
print jiraStr