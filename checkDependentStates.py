from openpyxl import load_workbook
import sys
import pandas as pd
import os
#Get path to excel reports folder for input (used so that countscompare.py doesn't need full path when calling individually)

p = os.path.dirname(os.path.realpath('f.py'))
p=p+"/"+os.pardir+"/excel_reports/"

vName = sys.argv[1]

if(len(vName)<6 or vName[-5:]!=".xlsx"):
	vFullPath = p+vName+".xlsx"
else:
	vFullPath = p+vName



#Load data from Validator Report

wb1 = load_workbook(vFullPath)
ws=wb1['Members Table']
data = pd.DataFrame(ws.values)

idMap ={};
i=1
while i<len(data[0]):
	currentMemberID=data[0][i]
	depID=data[74][i]
	idMap[currentMemberID]=depID
	i+=1

ws=wb1['Verification Table']
data = pd.DataFrame(ws.values)

#Convert to pandas dataframe for easier accessibility




uniqueSSNList={}
def addStateIfNotExist(currentSSN,currentPersonName,currentPersonType,currentState,currentMemberID):
	if(currentSSN in uniqueSSNList):
		if(currentState not in uniqueSSNList[currentSSN]["stateList"]):
			uniqueSSNList[currentSSN]["stateList"].append(currentState);
	else:
		uniqueSSNList[currentSSN] = {"eeName":"ee","eeMemberID":"ee","eeState":"ee","stateList":[],"depMaps":[],"depIDList":[]}
		uniqueSSNList[currentSSN]["stateList"].append(currentState);
	if currentPersonType == "18":
		uniqueSSNList[currentSSN]["eeName"]=currentPersonName
		uniqueSSNList[currentSSN]["eeMemberID"]=currentMemberID
		uniqueSSNList[currentSSN]["eeState"]=currentState
	else:
		uniqueSSNList[currentSSN]["depMaps"].append({currentMemberID:currentState})
i=1
while i<len(data[1]):
	currentPersonType = str(data[3][i])
	currentMemberID = str(data[0][i])
	currentPersonName = (data[6][i][:1]+". "+data[7][i]).replace(',','')
	currentSSN = data[1][i]
	currentState = data[13][i]
	addStateIfNotExist(currentSSN,currentPersonName,currentPersonType,currentState,currentMemberID)
	i+=1

depStateMap={}

for currentSSN in uniqueSSNList:
	if len(uniqueSSNList[currentSSN]["stateList"])>1:
		for depMap in uniqueSSNList[currentSSN]["depMaps"]:
			for currentMemberID in depMap:
				if depMap[currentMemberID]!=uniqueSSNList[currentSSN]["eeState"]:
					depID = idMap[currentMemberID]
					if depID not in uniqueSSNList[currentSSN]["depIDList"]:
						uniqueSSNList[currentSSN]["depIDList"].append(depID)
						depStateMap[depID]=uniqueSSNList[currentSSN]["eeState"]

if len(depStateMap) > 0:

	totalStr ="\n\n"+ '{:<20}'.format("Employees")+"EE   Deps           Dep IDs\n"
	totalStr += '{:<20}'.format("------------")+"--   -----          --------\n"
	for currentSSN in uniqueSSNList:
		if len(uniqueSSNList[currentSSN]["depIDList"])>0:
			myStr = '{:<20}'.format(uniqueSSNList[currentSSN]["eeName"])+uniqueSSNList[currentSSN]["eeState"]+"   "
			states = ""
			for state in uniqueSSNList[currentSSN]["stateList"]:
				if state != uniqueSSNList[currentSSN]["eeState"]:
					states += state+" "
			myStr += '{:<15}'.format(states)
			for depID in uniqueSSNList[currentSSN]["depIDList"]:
				myStr += depID + "  "
			totalStr+=myStr+"\n"
	print totalStr

	JEXL = 'depStateMap = {'
	JEXL2 = 'depStateList = ['
	for depID in depStateMap:
		JEXL += '"'+depID+'":"'+depStateMap[depID]+'",'
		JEXL2 += '"'+depID+'",'
	JEXL = JEXL[:-1]
	JEXL2 = JEXL2[:-1]
	JEXL += '};'
	JEXL2 += '];'
	print "initialMemberState = ????? | get(\"addressState\"); memberID = ????? | get(\"_id\"); "
	print JEXL2
	print JEXL
	print "memberState = (memberID in depStateList?depStateMap[memberID]:initialMemberState);"

else:
	print "\n\nEmployees and dependents have matching states."

