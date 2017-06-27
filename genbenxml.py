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
filepath = os.path.join(reports, "bengenOutput.xml")
summary_filepath = os.path.join(reports, "bengenSummary.txt")
if not os.path.exists(reports):
	os.makedirs(reports)
p=p+"/"+os.pardir+"/pending_beneficiaries/"
pbName = sys.argv[1]


if(len(pbName)<5 or pbName[-4:]!=".csv"):
	pbFullPath = p+pbName+".csv"
else:
	pbFullPath = p+pbName

uniqueSSNList={}
maxNameLength=0;
# Read the csv file

ACCEPTABLE_RELATIONSHIP_CODES = set([
"employee","spouse","common law","domestic partner","former spouse","sponsored dependent","dependent",
"child","adopted child","step child","overage dependent","grandchild","parent","student","disabled child",
"child via court order","dependent via legal custody","foster child","overage disabled dependent","other",
"grandparent","uncleaunt","nephewniece","cousin","adoptedchild","fosterchild","childinlaw","siblinginlaw",
"parentinlaw","sibling","ward","sponsoreddependent","dependentdependent","exspouse","guardian","caguardian",
"mother","father","collateraldependent","stepfather","stepmother","lifepartner","lifepartnersamesex","classii",
"handicappedchild","brother","sister","wife","husband","significantother","aunt","uncle","nephew","niece",
"brotherinlaw","sisterinlaw","son","daughter","exhusband","exwife","grandson","granddaughter","domesticpartner",
"1","19","4","6","5","25","53","7","8","9","10","12","11","14","13","15","23","26","31","38"])

changelog = "CHANGES: \n\n"
personsNeedingBenReplacement = []

data = pd.read_csv(pbFullPath, low_memory=False)
i=0
range5 = [1,2,3,4,5]
def toDateString(dateString):
	dateParts = dateString.split("/")
	month=int(dateParts[0])
	day=int(dateParts[1])
	year=int(dateParts[2])
	month=str(month)
	if len(month)<2:
		month="0"+month
	day=str(day)
	if len(day)<2:
		day="0"+day
	year=str(year)
	return year+month+day
def getIndividualBeneficiary(person,i,j):
	global changelog
	benType = str(data["Individual Beneficiary "+str(j)+" - Beneficiary Type"][i])
	if benType[-3:]=="nan":
		return False
	issues = []
	primary = str(data["Individual Beneficiary "+str(j)+" - Type"][i])
	firstName = str(data["Individual Beneficiary "+str(j)+" - First Name"][i])
	lastName = str(data["Individual Beneficiary "+str(j)+" - Last Name"][i])
	#relationship may have to be changed later, for now leave as is
	relationship = str(data["Individual Beneficiary "+str(j)+" - Relationship"][i])
	if relationship.lower() not in ACCEPTABLE_RELATIONSHIP_CODES:
		changelog+="Edited relationship code of "+firstName+" "+lastName+" (ben of "+person["firstName"]+" "+person["lastName"]+") from \""+relationship+"\" to \"Other\"\n"
		relationship = "Other"
		issues.append("REL")

	benSSN = str(data["Individual Beneficiary "+str(j)+" - SSN"][i])
	hasBenSSN = benSSN[-3:]!="nan"
	if hasBenSSN:
		benSSN = benSSN.replace('-','').split('.')[0]
		while len(benSSN)<9:
			benSSN="0"+benSSN
	else:
		benSSN = ""
		issues.append("SSN")
	street = str(data["Individual Beneficiary "+str(j)+" - Street"][i])
	suite = str(data["Individual Beneficiary "+str(j)+" - Suite"][i])
	hasSuite = suite[-3:]!="nan"
	city = str(data["Individual Beneficiary "+str(j)+" - City"][i])
	state = str(data["Individual Beneficiary "+str(j)+" - State"][i])
	zipcode = str(data["Individual Beneficiary "+str(j)+" - Zip Code"][i]).split('.')[0]
	while len(zipcode)<5:
		zipcode="0"+zipcode
	dateOfBirth = str(data["Individual Beneficiary "+str(j)+" - Date of Birth"][i])
	dateOfBirth = toDateString(dateOfBirth)
	phone = str(data["Individual Beneficiary "+str(j)+" - Phone"][i]).replace('-','')
	percent = str(int(str(data["Individual Beneficiary "+str(j)+" - Amount"][i]).split('.')[0]))
	person["issues"]+=issues
	ben = {
		"issues":issues,
		"benType":benType,
		"primary":primary,
		"firstName":firstName,
		"lastName":lastName,
		"relationship":relationship,
		"benSSN":benSSN,
		"hasBenSSN":hasBenSSN,
		"street":street,
		"suite":suite,
		"hasSuite":hasSuite,
		"city":city,
		"state":state,
		"zipcode":zipcode,
		"dateOfBirth":dateOfBirth,
		"phone":phone,
		"percent":percent,
	}
	return ben

def getIndividualTrust(person,i,j):
	benType = str(data["Trust Beneficiary "+str(j)+" - Beneficiary Type"][i])
	if benType[-3:]=="nan":
		return False
	issues=[]
	issues.append("TST")
	primary = str(data["Trust Beneficiary "+str(j)+" - Type"][i])
	trustName = str(data["Trust Beneficiary "+str(j)+" - Trust Name"][i])
	benSSN = ""
	hasBenSSN = False
	street = str(data[" Trust Beneficiary "+str(j)+" - Street"][i])
	suite = str(data[" Trust Beneficiary "+str(j)+" - Suite"][i])
	hasSuite = suite[-3:]!="nan"
	city = str(data[" Trust Beneficiary "+str(j)+" - City"][i])
	state = str(data[" Trust Beneficiary "+str(j)+" - State"][i])
	zipcode = str(data[" Trust Beneficiary "+str(j)+"  - Zip Code"][i]).split('.')[0]
	while len(zipcode)<5:
		zipcode="0"+zipcode
	trustDate = str(data[" Trust Beneficiary "+str(j)+"  - Trust Date"][i])
	trustDate = toDateString(trustDate)
	phone = str(data[" Trust Beneficiary "+str(j)+"  - Phone"][i]).replace('-','')
	percent = str(int(str(data[" Trust Beneficiary "+str(j)+" - Amount"][i]).split('.')[0]))
	person["issues"]+=issues
	ben = {
		"issues":issues,
		"benType":benType,
		"primary":primary,
		"trustName":trustName,
		"benSSN":benSSN,
		"hasBenSSN":hasBenSSN,
		"street":street,
		"suite":suite,
		"hasSuite":hasSuite,
		"city":city,
		"state":state,
		"zipcode":zipcode,
		"trustDate":trustDate,
		"phone":phone,
		"percent":percent,
	}
	return ben
def getIndividualOrganization(person,i,j):
	benType = str(data["Organization Beneficiary "+str(j)+" - Beneficiary Type"][i])
	if benType[-3:]=="nan":
		return False
	issues=[]
	issues.append("ORG")
	primary = str(data["Organization Beneficiary "+str(j)+" - Type"][i])
	orgName = str(data[" Organization Beneficiary "+str(j)+" - Organization Name"][i])
	benSSN = ""
	hasBenSSN = False
	street = str(data[" Organization Beneficiary "+str(j)+" - Street"][i])
	suite = str(data[" Organization Beneficiary "+str(j)+" - Suite"][i])
	hasSuite = suite[-3:]!="nan"
	city = str(data[" Organization Beneficiary "+str(j)+" - City "][i])
	state = str(data[" Organization Beneficiary "+str(j)+" - State"][i])
	zipcode = str(data[" Organization Beneficiary "+str(j)+" - Zip Code"][i]).split('.')[0]
	while len(zipcode)<5:
		zipcode="0"+zipcode
	phone = str(data[" Organization Beneficiary "+str(j)+" - Phone"][i]).replace('-','')
	percent = str(int(str(data[" Organization Beneficiary "+str(j)+" - Amount"][i]).split('.')[0]))
	person["issues"]+=issues
	ben = {
		"issues":issues,
		"benType":benType,
		"primary":primary,
		"orgName":orgName,
		"benSSN":benSSN,
		"hasBenSSN":hasBenSSN,
		"street":street,
		"suite":suite,
		"hasSuite":hasSuite,
		"city":city,
		"state":state,
		"zipcode":zipcode,
		"phone":phone,
		"percent":percent,
	}
	return ben

output = ""
output+= "<en:Envelope xmlns:en=\"http://www.softcare.com/HIPAA/SC/Enrollment/0301\" xmlns:sc=\"http://www.softcare.com/HIPAA/SC/0203\" xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\" xsi:schemaLocation=\"http://www.softcare.com/HIPAA/SC/0203 ../schema/types/common-types_0203.xsd http://www.softcare.com/HIPAA/SC/Enrollment/0301 ../schema/Enrollment_0301_rc2.xsd\">"
def writeAddressBlock(ben):
	global output
	output+="<en:Address>"
	output+="<en:AddressLine1>"+ben['street']+"</en:AddressLine1>"
	if ben['hasSuite']:
		output+="<en:AddressLine2>"+ben['suite']+"</en:AddressLine2>"
	output+="<en:City>"+ben['city']+"</en:City>"
	output+="<en:ProvinceOrStateCode>"+ben['state']+"</en:ProvinceOrStateCode>"
	output+="<en:PostalOrZipCode>"+ben['zipcode']+"</en:PostalOrZipCode>"
	output+="</en:Address>"
def writeIndividualBeneficiary(ben):
	global output
	output+="<en:Beneficiary percentage=\""+ben['percent']+"\" relationshipCode=\""+ben['relationship']+"\" type=\""+ben['primary']+"\">"
	output+="<en:Person>"
	output+="<en:LastName>"+ben['lastName']+"</en:LastName>"
	output+="<en:FirstName>"+ben['firstName']+"</en:FirstName>"
	output+="</en:Person>"
	output+="<en:IdentificationNumber>"+ben['benSSN']+"</en:IdentificationNumber>"
	writeAddressBlock(ben)
	output+="<en:ContactInformation>"
	output+="<en:Direct>"+ben['phone']+"</en:Direct>"
	output+="</en:ContactInformation>"
	output+="<en:DateOfBirth format=\"CCYYMMDD\">"+ben['dateOfBirth']+"</en:DateOfBirth>"
	output+="</en:Beneficiary>"
def writeIndividualTrust(ben):
	global output
	output+="<en:Beneficiary percentage=\""+ben['percent']+"\" type=\""+ben['primary']+"\">"
	output+="<en:Trust>"
	output+="<en:TrustName>"+ben['trustName']+"</en:TrustName>"
	output+="</en:Trust>"
	output+="<en:IdentificationNumber></en:IdentificationNumber>"
	writeAddressBlock(ben)
	output+="<en:ContactInformation>"
	output+="<en:Direct>"+ben['phone']+"</en:Direct>"
	output+="</en:ContactInformation>"
	output+="<en:DateOfBirth format=\"CCYYMMDD\">"+ben['trustDate']+"</en:DateOfBirth>"
	output+="</en:Beneficiary>"
def writeIndividualOrganization(ben):
	global output
	output+="<en:Beneficiary percentage=\""+ben['percent']+"\" type=\""+ben['primary']+"\">"
	output+="<en:Organization>"
	output+="<en:OrganizationName>"+ben['orgName']+"</en:OrganizationName>"
	output+="</en:Organization>"
	output+="<en:IdentificationNumber></en:IdentificationNumber>"
	writeAddressBlock(ben)
	output+="<en:ContactInformation>"
	output+="<en:Direct>"+ben['phone']+"</en:Direct>"
	output+="</en:ContactInformation>"
	output+="</en:Beneficiary>"
def writePerson(person):
	global output
	output+="<en:MemberLevelDetail>"
	output+="<en:SubscriberIdentifier>"+person['SSN']+"</en:SubscriberIdentifier>"
	output+="<en:MemberDetail>"
	output+="<en:Person>"
	output+="<sc:LastName>"+person['lastName']+"</sc:LastName>"
	output+="<sc:FirstName>"+person['firstName']+"</sc:FirstName>"
	output+="</en:Person>"
	output+="</en:MemberDetail>"
	output+="<en:HealthCoverageDetail>"
	output+="<en:BeneficiaryDetail>"
	for ben in person['bens']['ind']:
		writeIndividualBeneficiary(ben)
	for ben in person['bens']['trust']:
		writeIndividualTrust(ben)
	for ben in person['bens']['org']:
		writeIndividualOrganization(ben)
	output+="</en:BeneficiaryDetail>"
	output+="</en:HealthCoverageDetail>"
	output+="</en:MemberLevelDetail>"
while i<len(data['SSN']):
	currentSSN = data['SSN'][i]
	firstName = data['First Name'][i]
	lastName = data['Last Name'][i]
	if len(firstName+" "+lastName)>maxNameLength:
		maxNameLength = len(firstName+" "+lastName)
	currentSSN = data['SSN'][i]
	productStatus = data['Product Status'][i]
	if productStatus != "confirmed" and productStatus != "enrolled":
		i+=1
		continue
	if(str(currentSSN)[-3:]!="nan"):
		currentSSN=str(currentSSN).replace('-','').split('.')[0]
		while len(currentSSN)<9:
			currentSSN="0"+currentSSN
	else:
		i+=1
		continue
	currentPerson={"firstName":firstName,"lastName":lastName,"SSN":currentSSN,"bens":{"ind":[],"trust":[],"org":[]},"issues":[]}
	for j in range5:
		ben = getIndividualBeneficiary(currentPerson,i,j)
		if ben:
			currentPerson["bens"]["ind"].append(ben)
		trust = getIndividualTrust(currentPerson,i,j)
		if trust:
			#print trust
			currentPerson["bens"]["trust"].append(trust)
		org = getIndividualOrganization(currentPerson,i,j)
		if org:
			#print org
			currentPerson["bens"]["org"].append(org)
	if len(currentPerson["issues"])>0:
		personsNeedingBenReplacement.append(currentPerson)
		writePerson(currentPerson)
	i+=1

changelog+="\n\nPersons needing beneficiary replacement: \n"
maxNameLength+=4
for person in personsNeedingBenReplacement:
	changelog+=("{:<"+str(maxNameLength)+"}").format(person["firstName"]+" "+person["lastName"])
	for issue in person["issues"]:
		changelog+=issue +"  "
	changelog = changelog[:-2]
	changelog+="\n"
file = open(filepath, "w")

output+="</en:Envelope>"
file.write(output)
file.close()
summary_file = open(summary_filepath, "w")
summary_file.write(changelog)
summary_file.close()
