#! /bin/sh -e

##### FILE PARAMETER THAT ARE REQUIRED TO BE PASSED #####

# Name of carrier who is providing the products
carrier_name=$1
# Name of the employer or broker (multi-tenant file)
group_name=$2
# Provides unique file for multiple runs (1 min or more apart)
time_stamp=$3

#### Paths ####

# this is a static script meant for individuals who are not familiar with running a script
home=/Users/$USER/Desktop/XML_Validator

# path were reports will be stored
reports=${home}/reports

#### FILES ####

# full path for verification table
verify_table=${reports}/verification_table_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for file detail
file_detail=${reports}/file_detail_${carrier_name}_${group_name}_${time_stamp}.txt

# create counts file
counts=${reports}/member_and_product_counts_${carrier_name}_${group_name}_${time_stamp}.txt

# create JIRA table of counts
jcounts=${reports}/JIRA_member_and_product_counts_${carrier_name}_${group_name}_${time_stamp}.txt

##### COUNTS #####


# create main table for counts

cat ${verify_table} \
| grep -v "Plan_Coverage_Description" \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}{\
	if($4 != "") print "Member",$1,"Relationship_Code",$4,"0"; \
	if($6 != "") print "Member",$1,"Maintenance_Type_Code",$6,"0"; \
	if($10 != "") print "Member",$1,"Gender",$10,"0"; \
	if($11 != "") print "Member",$1,"Marital_Status",$11,"0"; \
	if($18 != "") print "Member",$1,"Group_Name",$18,"0"; \
	if($1 != "") print "Member",$1,"Member Total","Total_Members","0"; \
	if($36 != "") print "Member",$1,"Custom_Field_1",$36,"0"; \
	if($37 != "") print "Member",$1,"Custom_Field_2",$37,"0"; \
	if($38 != "") print "Member",$1,"Custom_Field_3",$38,"0"; \
	if($39 != "") print "Member",$1,"Custom_Field_4",$39,"0"; \
	if($40 != "") print "Member",$1,"Custom_Field_5",$40,"0"; \
	if($1 != "") print "Product",0,"Member Total","Total_Products",$41; \
	if($24 != "") print "Product",0,"Plan_Coverage_Description",$24,$41; \
	if($25 != "") print "Product",0,"Insurance_Line_Code",$25,$41; \
	if($26 != "") print "Product",0,"Coverage_Level",$26,$41; \
	if($27 != "") print "Product",0,"Maintenance_Type_Code",$27,$41; \
	if($31 != "") print "Product",0,"Custom_Field_1",$31,$41; \
	if($32 != "") print "Product",0,"Custom_Field_2",$32,$41; \
	if($33 != "") print "Product",0,"Custom_Field_3",$33,$41; \
	if($34 != "") print "Product",0,"Custom_Field_4",$34,$41; \
	if($35 != "") print "Product",0,"Custom_Field_5",$35,$41}' \
| sort \
| filter \
	-u 0,1,2,3 -s 4 -p 0,1,2,3,4 \
| sort \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{if($1 =="Member") print $1,$3,$4,"1"; \
	else print $1,$3,$4,$5}' \
| sort \
| filter \
	-u 0,1,2 -s 3 -p 0,1,2,3 \
| sort \
> ${counts}

chmod 777 ${counts}

wait

# Test to make sure product maintenance types are greater than or equal to member maintenance types
cat ${counts} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{if($1 == "Product" && $2 =="Maintenance_Type_Code" && $3 !="001") \
		print $1,$2,$3,$4,$4,0; \
	if($1 == "Member" && $2 =="Maintenance_Type_Code" && $3 !="001") \
		print $1,$2,$3,$4,0,$4}' \
| cut \
	-f2,3,5,6 \
| filter \
	-u 0,1 -s 2,3 -p 0,1,2,3 \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{if($3 >= $4) \
		print "Product Greater Than Member",$1,$2,"Passed"; \
		else print "Product Greater Than Member",$1,$2,"Failed"}'\
>> ${counts}

wait

# test to see if there are missing tax id numbers

cat ${file_detail} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	if($1 ~ /SponsorNameFederalTaxIdentifier/ && $2 =="") print "File_Detail","Missing","Employer_EIN","1"; \
	if($1 ~ /PayerNameFederalTaxIdentifier/ && $2 =="") print "File_Detail","Missing","Payer_EIN","1"}' \
>> ${counts}

wait

# counts of coverage level categories
cat ${counts} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	if($1 =="Product" && $2 == "Coverage_Level" && $3 == "ee") \
		print $1,"Coverage_Level_Category","ee",$4; \
	if($1 =="Product" && $2 == "Coverage_Level" && $3 ~ /sp/) \
		print $1,"Coverage_Level_Category","sp",$4; \
	if($1 =="Product" && $2 == "Coverage_Level" && $3 ~ /dp/) \
		print $1,"Coverage_Level_Category","dp",$4; \
	if($1 =="Product" && $2 == "Coverage_Level" && $3 ~ /ch/ && $3 !~ /chs/) \
		print $1,"Coverage_Level_Category","ch",$4; \
	if($1 =="Product" && $2 == "Coverage_Level" && $3 ~ /chs/) \
		print $1,"Coverage_Level_Category","chs",$4}' \
| sort \
| filter \
	-u 0,1,2 -s 3 -p 0,1,2,3 \
| sort \
>> ${counts}

