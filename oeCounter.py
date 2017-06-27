from openpyxl import load_workbook
import sys
import pandas as pd
import os
import datetime
from collections import OrderedDict

def toDateObject(dateString):
	dateParts = dateString.split("/")
	if (len(dateParts)<3):
		dateParts = dateParts[0].split("-")
		month=int(dateParts[1])
		day=int(dateParts[2])
		year=int(dateParts[0])
	else:
		month=int(dateParts[0])
		day=int(dateParts[1])
		year=int(dateParts[2])
	return datetime.date(year,month,day)
def dashesToSlashes(dateString):
	dateParts = str(dateString).split("-")
	month=dateParts[1]
	day=dateParts[2]
	year=dateParts[0]
	outputString=month+"/"+day+"/"+year
	return outputString

now = datetime.datetime.now()
nowMinus60 = now - datetime.timedelta(days=60)
now = toDateObject(str(now).split(" ")[0])
nowMinus60 = toDateObject(str(nowMinus60).split(" ")[0])


psName = sys.argv[1]
oeName = sys.argv[2]
intName = sys.argv[3]



p = os.path.dirname(os.path.realpath('f.py'))
reports=p+"/"+os.pardir+"/reports/"
filepath = os.path.join(reports, "renewal_reporting_aid.txt")
if not os.path.exists(reports):
	os.makedirs(reports)
aaFile = open(filepath, "w")

p = os.path.dirname(os.path.realpath('f.py'))
reports=p+"/"+os.pardir+"/reports/"
filepath = os.path.join(reports, "OE_counts.txt")
if not os.path.exists(reports):
	os.makedirs(reports)
psFile = open(filepath, "w")


#Production support
if psName != "INVALID":
	p = os.path.dirname(os.path.realpath('f.py'))
	p=p+"/"+os.pardir+"/excel_reports/"
	if(len(psName)<5 or psName[-4:]!=".csv"):
		psFullPath = p+psName+".csv"
	else:
		psFullPath = p+psName

#Open Enrollment Report
p = os.path.dirname(os.path.realpath('f.py'))
p=p+"/"+os.pardir+"/open_enrollment/"
if(len(oeName)<5 or oeName[-4:]!=".csv"):
	oeFullPath = p+oeName+".csv"
else:
	oeFullPath = p+oeName

#Integrations Report
p = os.path.dirname(os.path.realpath('f.py'))
p=p+"/"+os.pardir+"/integrations/"
if(len(intName)<5 or intName[-4:]!=".csv"):
	intFullPath = p+intName+".csv"
else:
	intFullPath = p+intName

data = pd.read_csv(intFullPath, low_memory=False, header=None)
if data[0][0] == "Vendor" and data[2][0] == "Long Name": #HR integrations report
	new_header = data.iloc[0] #grab the first row for the header
	data = data[1:] #take the data less the header row
	data.index = range(len(data))
	data.columns = new_header #set the header row as the df header
elif len(data.columns) == 13: #Advisor integrations report
	data.columns = ["Employer Name","Vendor","Market Product ID","Long Name","Short Name","Nickname","EDI Type","EDI Status","Start Date","End Date","Marketplace","Takeover","Employer Product ID"]
else: #Unsure what this is
	raise ValueError("Invalid integrations report. Verify first column starts with Vendor (HR integrations) or #columns == 13 (Advisor integrations)")
#vendor, long name used as indices
vendorList={}
i=0
while i<len(data['Long Name']):
	vendor = data['Vendor'][i]
	longName = data['Long Name'][i]
	if vendor not in vendorList:
		vendorList[vendor]={}
	if longName in vendorList[vendor]:
		raise NameError('Duplicate Product Long Names')
	vendorList[vendor][longName]={'EDI Status':data['EDI Status'][i],'Product Dates':{},'EE OE Date Counts':{},'EE Product Status Counts':{}}
	vendorList[vendor][longName]['EE OE Date Counts']['Start']={}
	vendorList[vendor][longName]['EE OE Date Counts']['End']={}
	vendorList[vendor][longName]['Product Dates']['Start']=str(data['Start Date'][i])
	vendorList[vendor][longName]['Product Dates']['End']=str(data['End Date'][i])
	#Count using OE enrollment report
	vendorList[vendor][longName]['EE Product Status Counts']['Open']=0
	vendorList[vendor][longName]['EE Product Status Counts']['Selected']=0
	vendorList[vendor][longName]['EE Product Status Counts']['Closed / Waived']=0
	vendorList[vendor][longName]['EE Product Status Counts']['Confirmed']=0
	#Count using production support
	vendorList[vendor][longName]['EE Product Status Counts']['Enrolled']=0
	i+=1

data = pd.read_csv(oeFullPath, low_memory=False)
i=0
while i<len(data['Product - Vendor Name']):
	vendor = data['Product - Vendor Name'][i]
	longName = data['Product - Name'][i]
	status = data['Product - Status'][i]


	if vendor not in vendorList:
		i+=1
		continue
	if longName not in vendorList[vendor]:
		i+=1
		continue
	oeStartDate = str(data['Open Enrollment Start'][i])
	oeEndDate = str(data['Open Enrollment End'][i])
	if(str(oeStartDate)[-3:]!="nan"):
		oeStartDate=toDateObject(oeStartDate)
	else:
		oeStartDate=toDateObject("01/01/1970")
	if(str(oeEndDate)[-3:]!="nan"):
		oeEndDate=toDateObject(oeEndDate)
	else:
		oeEndDate=toDateObject("01/01/1970")
	if str(oeEndDate) not in vendorList[vendor][longName]['EE OE Date Counts']['End']:
		vendorList[vendor][longName]['EE OE Date Counts']['End'][str(oeEndDate)]=0;
	vendorList[vendor][longName]['EE OE Date Counts']['End'][str(oeEndDate)]+=1
	if status == "closed" or status == "waived":
		vendorList[vendor][longName]['EE Product Status Counts']['Closed / Waived']+=1
	if status == "open":
		vendorList[vendor][longName]['EE Product Status Counts']['Open']+=1
	if status == "selected":
		vendorList[vendor][longName]['EE Product Status Counts']['Selected']+=1
	if status == "confirmed":
		vendorList[vendor][longName]['EE Product Status Counts']['Confirmed']+=1
	i+=1

if psName != "INVALID":
	data = pd.read_csv(psFullPath, low_memory=False)
	i=0
	while i<len(data['Vendor']):
		vendor = data['Vendor'][i]
		longName = data['Product Name'][i]
		if vendor not in vendorList:
			i+=1
			continue
		if longName not in vendorList[vendor]:
			i+=1
			continue
		status = data['Product Status'][i]
		waived = data['Product Waived (Y/N)'][i]
		active = data['Primary - Employment Status'][i]
		personType = data['Member - Role'][i]
		if personType == "employee" and active == "active" and waived == "no" and status == "enrolled":
			vendorList[vendor][longName]['EE Product Status Counts']['Enrolled']+=1
		i+=1

#Counts by Vendor:

for vendor in vendorList:
	oeEndDateSums={}
	statusSums={}
	productStatusSums={}
	totalSum=0
	renewingProducts=""
	warnings=""
	if psName == "INVALID":
		warnings+= "No Production Support -- Ignore Enrolled\n"
	for longName in vendorList[vendor]:
		if toDateObject(vendorList[vendor][longName]['Product Dates']['Start'])<nowMinus60:
			continue
		renewingProducts+=longName+"\n"
		if longName not in productStatusSums:
			productStatusSums[longName]={"EDI Status":vendorList[vendor][longName]['EDI Status'],"Begin Date":vendorList[vendor][longName]['Product Dates']['Start'],"Status":{}}
		if vendorList[vendor][longName]['EDI Status'] != "off":
			warnings+="WARNING: "+ longName +" has status: " + vendorList[vendor][longName]['EDI Status']+"\n"
		for oeEndDate in vendorList[vendor][longName]['EE OE Date Counts']['End']:
			if " eoi" in longName.lower():
				continue
			if oeEndDate not in oeEndDateSums:
				oeEndDateSums[oeEndDate]=0
			oeEndDateSums[oeEndDate]+=vendorList[vendor][longName]['EE OE Date Counts']['End'][oeEndDate]
			totalSum+=vendorList[vendor][longName]['EE OE Date Counts']['End'][oeEndDate]
		for status in vendorList[vendor][longName]['EE Product Status Counts']:
			if status not in statusSums:
				statusSums[status]=0
			if status not in productStatusSums[longName]["Status"]:
				productStatusSums[longName]["Status"][status]=0
			if " eoi" in longName.lower():
				productStatusSums[longName]["Status"][status]="-"
				continue
			elif psName == "INVALID" and status == "Enrolled":
				productStatusSums[longName]["Status"][status]="-"
				statusSums[status]="-"
				continue
			statusSums[status]+=vendorList[vendor][longName]['EE Product Status Counts'][status]
			productStatusSums[longName]["Status"][status]+=vendorList[vendor][longName]['EE Product Status Counts'][status]
	renewingProducts="\n".join(sorted(renewingProducts[:-1].split("\n")))+"\n"
	warnings+="\n"
	productStatusSums = OrderedDict(sorted(productStatusSums.items(), key=lambda t:t));
	orderedOEEndDateSums = OrderedDict(sorted(oeEndDateSums.items(), key=lambda t:toDateObject(t[0])));
	oeDate = "Unassigned"
	partialSum=0
	for date in orderedOEEndDateSums:
		partialSum+=orderedOEEndDateSums[date]
		if partialSum>= 0.9*totalSum:
			oeDate = date
			break
	dashString = "--------------------"
	psVeryTopString=""
	if totalSum>0:
		percentComplete = int(float(statusSums['Confirmed']+statusSums['Closed / Waived'])/totalSum*100)
		percentClosed = int(float(statusSums['Closed / Waived'])/totalSum*100)
		print dashString+dashString+dashString+dashString
		print "{:<40}".format(vendor) +"OE End Date: "+"{:<20}".format(oeDate)+str(percentComplete)+"% complete.\n"
		psVeryTopString="||"+vendor+"||OE End Date:|"+dashesToSlashes(oeDate)+"||Percent Complete:|"+str(percentComplete)+"%||"
		print dashString+dashString+dashString+dashString
	else:
		print dashString+dashString+dashString+dashString
		print vendor
		psVeryTopString="||"+vendor+"||"
		print dashString+dashString+dashString+dashString
		print "No values found!"
		continue
	oeDatePlusTwo=toDateObject(oeDate) + datetime.timedelta(days=2)
	oeDatePlusOne=toDateObject(oeDate) + datetime.timedelta(days=1)
	mondayRenewal=""
	tuesdayRenewal=""
	wednesdayRenewal=""
	thursdayRenewal=""
	fridayRenewal=""

	i=0
	while (mondayRenewal=="" or tuesdayRenewal=="" or wednesdayRenewal=="" or thursdayRenewal=="" or fridayRenewal=="") and i<10:
		if oeDatePlusTwo.weekday() == 0:
			mondayRenewal=dashesToSlashes(oeDatePlusTwo)
		elif oeDatePlusTwo.weekday() == 1:
			tuesdayRenewal=dashesToSlashes(oeDatePlusTwo)
		elif oeDatePlusTwo.weekday() == 2:
			wednesdayRenewal=dashesToSlashes(oeDatePlusTwo)
		elif oeDatePlusTwo.weekday() == 3:
			thursdayRenewal=dashesToSlashes(oeDatePlusTwo)
		elif oeDatePlusTwo.weekday() == 4:
			fridayRenewal=dashesToSlashes(oeDatePlusTwo)
		oeDatePlusTwo += datetime.timedelta(days=1)
		i+=1

	nowPlusTwo=now + datetime.timedelta(days=2)
	nowPlusOne=now + datetime.timedelta(days=1)
	mondayRenewalAlt=""
	tuesdayRenewalAlt=""
	wednesdayRenewalAlt=""
	thursdayRenewalAlt=""
	fridayRenewalAlt=""

	i=0
	while (mondayRenewalAlt=="" or tuesdayRenewalAlt=="" or wednesdayRenewalAlt=="" or thursdayRenewalAlt=="" or fridayRenewalAlt=="") and i<10:
		if nowPlusTwo.weekday() == 0:
			mondayRenewalAlt=dashesToSlashes(nowPlusTwo)
		elif nowPlusTwo.weekday() == 1:
			tuesdayRenewalAlt=dashesToSlashes(nowPlusTwo)
		elif nowPlusTwo.weekday() == 2:
			wednesdayRenewalAlt=dashesToSlashes(nowPlusTwo)
		elif nowPlusTwo.weekday() == 3:
			thursdayRenewalAlt=dashesToSlashes(nowPlusTwo)
		elif nowPlusTwo.weekday() == 4:
			fridayRenewalAlt=dashesToSlashes(nowPlusTwo)
		nowPlusTwo += datetime.timedelta(days=1)
		i+=1



	aaFile.write(vendor+"\n"+dashString+"\n")
	aaFile.write(warnings)
	oeDate=dashesToSlashes(oeDate)
	aaFile.write("OE End Date: "+oeDate+"   OE is currently " +str(percentComplete)+"% complete.\n")
	if now < oeDatePlusOne:
		aaFile.write("Possible renewal dates: Monday: "+mondayRenewal+" Tuesday: "+tuesdayRenewal+" Wednesday: "+wednesdayRenewal+" Thursday: "+thursdayRenewal+" Friday: "+fridayRenewal+"\n\n")
	else:
		aaFile.write("Possible renewal dates: Monday: "+mondayRenewalAlt+" Tuesday: "+tuesdayRenewalAlt+" Wednesday: "+wednesdayRenewalAlt+" Thursday: "+thursdayRenewalAlt+" Friday: "+fridayRenewalAlt+"\n\n")		
	if now < oeDatePlusOne and percentClosed < 90:
		aaFile.write("@AM\nThis group's renewal OE ends on "+oeDate+". The renewal file will be sent to the carrier on {{Renewal File Date}}. Please be sure to have the client process all renewal elections (including elections for employees who did not finish checking out) prior to {{Renewal File Date}} so that we can send a complete renewal file.\n")
		aaFile.write("\nRenewing EDI products:\n-------------\n"+renewingProducts)
		aaFile.write("\n@PS\nRenewal OE ends on "+oeDate+". Please send the renewal file on {{Renewal File Date}} if OE has been completed and processed before then. No changes to products. EDI is OFF for renewal products.")
	elif percentComplete >=90:
		aaFile.write("@AM\nPlease note that the renewal file for this connection will be sent on {{Renewal File Date}}\n")
		aaFile.write("\nRenewing EDI products:\n-------------\n"+renewingProducts)
		aaFile.write("\n@PS\nRenewal OE has been completed and processed. Please send the renewal file on {{Renewal File Date}}. No changes to products. EDI has been turned ON for renewal products.")
	else:
		aaFile.write("@AM\nThis group's renewal OE has been completed but needs to be processed. The renewal file will be sent to the carrier on {{Renewal File Date}}. Please be sure to have the client process all renewal elections (including elections for employees who did not finish checking out) prior to {{Renewal File Date}} so that we can send a complete renewal file.\n")
		aaFile.write("\nRenewing EDI products:\n-------------\n"+renewingProducts)
		aaFile.write("\n@PS\nRenewal OE is complete but has not been processed. Please send the renewal file on {{Renewal File Date}} if OE has been processed before then. No changes to products. EDI is OFF for renewal products.")
	aaFile.write("\n\n")
	maxLongNameLength = 40
	for longName in productStatusSums:
		if (len(longName)+5)>maxLongNameLength:
			maxLongNameLength=(len(longName)+5)
	statusSumsStringTop=("{:<"+str(maxLongNameLength)+"}").format("Product Long Name")
	psFileTop="||Product Long Name||"
	psFileMiddle=""
	psFileBot="|-----|"
	psFileAfterBot="|-----|"
	statusSumsStringBot=("{:<"+str(maxLongNameLength)+"}").format("----------")
	for status in statusSums:
		statusSumsStringBot+=("{:^"+str(len(status)+2)+"}").format("-----")
		psFileBot+="-----|"
		psFileAfterBot+="-----|"
	statusSumsStringBot+="\n"+("{:<"+str(maxLongNameLength)+"}").format("Total")
	psFileBot+="\n|Total||"
	for status in statusSums:
		statusSumsStringTop+=status+"  "
		psFileTop+=status+"||"
		statusSumsStringBot+=("{:^"+str(len(status)+2)+"}").format(statusSums[status])
		psFileBot+=str(statusSums[status])+"||"
	statusSumsStringTop+="EDI Status  Start Date"
	psFileTop+="EDI Status||Start Date||\n|-----|"
	statusSumsStringTop+="\n"+("{:<"+str(maxLongNameLength)+"}").format("----------")
	for status in statusSums:
		statusSumsStringTop+=("{:^"+str(len(status)+2)+"}").format("-----")
		psFileTop+="-----|"
	statusSumsStringTop+="   -----      -----"
	psFileTop+="-----|"
	psFileTop+="-----|"
	statusSumsStringMiddle=""
	for longName in productStatusSums:
		statusSumsStringMiddle+=("{:<"+str(maxLongNameLength)+"}").format(longName)
		psFileMiddle+="|"+longName+"||"
		for status in productStatusSums[longName]["Status"]:
			statusSumsStringMiddle+=("{:^"+str(len(status)+2)+"}").format(productStatusSums[longName]["Status"][status])
			psFileMiddle+=str(productStatusSums[longName]["Status"][status])+"||"
		statusSumsStringMiddle+=("{:^"+str(len("EDI Status")+2)+"}").format(productStatusSums[longName]["EDI Status"])
		psFileMiddle=psFileMiddle[:-1]+str(productStatusSums[longName]["EDI Status"])+"|"
		statusSumsStringMiddle+=productStatusSums[longName]["Begin Date"]
		psFileMiddle+=str(productStatusSums[longName]["Begin Date"])+"|\n"
		statusSumsStringMiddle+="\n"
	psFile.write(psVeryTopString+"\n"+psFileTop+"\n"+psFileMiddle+psFileBot+"\n"+psFileAfterBot+"\n")
	aaFile.write(psVeryTopString+"\n"+psFileTop+"\n"+psFileMiddle+psFileBot+"\n"+psFileAfterBot+"\n")
	print statusSumsStringTop
	print (statusSumsStringMiddle+statusSumsStringBot+"\n")
	print "------------------"
	print "Total Product OE End Dates by Date"
	print "------------------\n"
	dateStringTop=""
	dateStringMiddle=""
	dateStringBot=""
	psFileTop="||"
	psFileMiddle="|"
	psFileBot="||"
	for date in orderedOEEndDateSums:
		dateStringTop+=date+"  "
		psFileTop+=dashesToSlashes(date)+"||"
		dateStringMiddle+=("{:^"+str(len(date)+2)+"}").format("-------")
		psFileMiddle+="----"+"|"
		dateStringBot+=("{:^"+str(len(date)+2)+"}").format(orderedOEEndDateSums[date])
		psFileBot+=str(orderedOEEndDateSums[date])+"||"
	print dateStringTop
	print dateStringMiddle
	print dateStringBot+"\n"
	psFile.write(psFileTop+"\n"+psFileMiddle+"\n"+psFileBot+"\n\n\n\n")
	aaFile.write(psFileTop+"\n"+psFileMiddle+"\n"+psFileBot+"\n\n\n\n")
print dashString
aaFile.close()
psFile.close()
#vendor, long name used as indices
	