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

# full path for file detail
file_detail=${reports}/file_detail_${carrier_name}_${group_name}_${time_stamp}.txt

# update counts file
counts=${reports}/member_and_product_counts_${carrier_name}_${group_name}_${time_stamp}.txt

# what the new counts file with header will be names
member_counts=${reports}/member_counts_${carrier_name}_${group_name}_${time_stamp}.txt

# missing data reports
missing_data=${reports}/missing_data_${carrier_name}_${group_name}_${time_stamp}.txt

# place header and rename file
member_missing_data=${reports}/member_missing_data_${carrier_name}_${group_name}_${time_stamp}.txt

# JIRA member and product counts
jcounts=${reports}/JIRA_member_and_product_counts_${carrier_name}_${group_name}_${time_stamp}.txt

# JIRA missing report
jmissing_data=${reports}/JIRA_missing_data_${carrier_name}_${group_name}_${time_stamp}.txt

# member table
member_table=${reports}/member_table_${carrier_name}_${group_name}_${time_stamp}.txt
members_table=${reports}/members_table_${carrier_name}_${group_name}_${time_stamp}.txt

# product table
product_table=${reports}/product_table_${carrier_name}_${group_name}_${time_stamp}.txt
products_table=${reports}/products_table_${carrier_name}_${group_name}_${time_stamp}.txt

# member detail
member_detail=${reports}/member_detail_${carrier_name}_${group_name}_${time_stamp}.txt

# coverage level checks
coverage_level=${reports}/coverage_level_report_${carrier_name}_${group_name}_${time_stamp}.txt

# provide counts of employees to eliminate employees missing employer paid products that are miscounted
employees=`cat ${file_detail} | awk '{OFS="\t"}{if($1 =="EmployeeTotal:") print "employee total",$2}' | filter -u 0 -s 1 -p 1`

# files to delete
formatted=${reports}/formatted_xml_${carrier_name}_${group_name}_${time_stamp}.txt
member_detail=${reports}/member_detail_${carrier_name}_${group_name}_${time_stamp}.txt
member_join=${reports}/member_join_${carrier_name}_${group_name}_${time_stamp}.txt
product_join=${reports}/product_join_${carrier_name}_${group_name}_${time_stamp}.txt
vol_life_check=${reports}/vol_life_check_${carrier_name}_${group_name}_${time_stamp}.txt

# add groupX and trading partner to file detail
cat ${member_detail} \
| grep "/Envelope/GROUPX=\|/Envelope/TRADINGPARTNER=" \
| sed 's;/Envelope/;;g' \
| tr "=" "\t" \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{print $1":",$2}'\
>> ${file_detail}

# add valid missing ancillary products counts to counts file
cat ${missing_data} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{print "Missing",$1,$5,"1"}' \
| sort \
| filter \
	-u 0,1,2 -s 3 -p 0,1,2,3 \
| sort \
>> ${counts}


wait

# coverage level fail counts

cat ${coverage_level} \
| grep -v "Coverage_Level_Test" \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	if($9 =="FAIL") \
		print "Coverage_Level",$9,$2,"1"\
	}'\
| sort \
| filter \
	-u 0,1,2 -s 3 -p 0,1,2,3 \
>> ${counts}

# create JIRA compliant table of member counts
cat ${counts} \
| sort \
	-k1 \
| awk \
	-F "`printf '\t'`" \
	'BEGIN \
	{printf "||%s||%s||%s||%s||\n", "Table","Category","Attribute","Count"}\
	{OFS="|"}\
	{print "|"$1,$2,$3,$4"|"}' \
> ${jcounts}

chmod 777 ${jcounts}

wait

# create JIRA table of missing data

cat ${missing_data} \
| sort \
	-k1 \
| awk \
	-F "`printf '\t'`" \
	'BEGIN \
	{printf "||%s||%s||%s||%s||%s||%s||\n", \
	"Missing","Employer","Employer_Id","Member_Id","Relationship_Code","Name"\
	}\
	{\
	OFS="|"\
	}\
	{\
	print "|"$1,$3,$4,$2,$5,$6"|"\
	}'\
> ${jmissing_data}

chmod 777 ${jmissing_data}

wait

#create missing table with header and call is member missing data
cat ${missing_data} \
| awk \
	-F "`printf '\t'`" \
	'BEGIN \
	{printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
	"Missing","Employer","Employer_Id","Member_Id","Relationship_Code","Name", "Supplemental 1", "Supplemental 2", "Supplemental 3", "Supplemental 4"\
	}\
	{\
	OFS="\t"\
	}\
	{\
	print $1,$3,$4,$2,$5,$6,$7,$8,$9,$10\
	}'\
> ${member_missing_data}

chmod 777 ${member_missing_data}

wait

# add header to counts file and rename to member_counts
cat ${counts} \
| sort \
	-k1 \
| awk \
	-F "`printf '\t'`" \
	'BEGIN \
	{printf "%s\t%s\t%s\t%s\n", "Table","Category","Attribute","Count"}\
	{OFS="\t"}\
	{print $1,$2,$3,$4}' \
> ${member_counts}

chmod 777 ${member_counts}

wait

cat ${product_table} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	BEGIN\
	{printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",\
	"Member_Id", \
	"late_Enrollment", \
	"Plan_Id ", \
	"Premium_Amount", \
	"Employee_Premium_Amount", \
	"Employer_Premium_Amount", \
	"Amount_Requested", \
	"Amount_Approved", \
	"Benefit_Begin_Date", \
	"Benefit_End_Date", \
	"Enrollment_Signature_Date", \
	"Product_Maintenance_Type_Code", \
	"Product_Maintenance_Effective", \
	"Coverage_Level_Code", \
	"Insurance_Line_Code", \
	"Plan_Coverage_Description", \
	"CustomField1", \
	"CustomField2", \
	"CustomField3", \
	"CustomField4", \
	"CustomField5", \
	"EffectiveDate1", \
	"EffectiveDate2", \
	"EffectiveDate3", \
	"EffectiveDate4", \
	"EffectiveDate5", \
	"PCP_Name_Prefix ", \
	"Doctor", \
	"Primary_Care_Provider", \
	"Dentist", \
	"Hospital", \
	"Pharmacy", \
	"Laboratory", \
	"Facility ", \
	"Managed_Care_Organization", \
	"Obstetrics_Gynecology_Facility", \
	"Coordination_Benefits", \
	"Plan_ID" \
	}\
	{print \
	$1,$2,$3,$4,$5,$6,$7,$8,$9,$10, \
	$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,\
	$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,\
	$31,$32,$33,$34,$35,$36,$37,$38}' \
> ${products_table}

chmod 777 ${products_table}

wait

cat ${member_table} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	BEGIN \
	{printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",\
	"Member_Id", \
	"Subscriber_Id", \
	"SSN", \
	"Student_Status_Code", \
	"Relationship_Code", \
	"Is_Subscriber", \
	"Employment_Status_Code", \
	"Enrollment_Status_Signature", \
	"Maintenance_Type_Code", \
	"Maintinance_Type_Reason", \
	"Maintenance_Effective", \
	"Prefix", \
	"First_Name", \
	"Middle_Name", \
	"Last_Name", \
	"Suffix", \
	"Date_Of_Birth", \
	"Is_Handicapped", \
	"Health_Code", \
	"Gender", \
	"Marital_Status", \
	"Reporting_Category", \
	"Category_Name", \
	"Group_Name", \
	"Employment_Begin_Date", \
	"Employment_End_Date", \
	"Quantity", \
	"Salary", \
	"Frequency_Code", \
	"Salary_Effective_Date", \
	"Employer_Id", \
	"Employer_name", \
	"Employer_Address_Line1", \
	"Employer_Address_Line2", \
	"Employer_City", \
	"Employer_State", \
	"Employer_Zip", \
	"Employer_Direct_Phone", \
	"Member_Cell_Phone", \
	"Member_Direct_Phone", \
	"Member_Work_Phone", \
	"Member_Email_Address", \
	"Member_Address_Line1", \
	"Member_Address_Line2", \
	"Member_Address_City", \
	"Member_State", \
	"Member_Zip", \
	"Mailing_Address_Line1", \
	"Mailing_Address_Line2", \
	"Mailing_City", \
	"Mailing_State", \
	"Mailing_Zip", \
	"Billing_Address_Line1", \
	"Billing_Address_Line2", \
	"Billing_State", \
	"Billing_City", \
	"Billing_Zip", \
	"Benefit_Status_Code", \
	"Received_Date", \
	"EmployerGroupField1", \
	"EmployerGroupField2", \
	"EmployerGroupField3", \
	"EmployerGroupField4", \
	"EmployerGroupField5", \
	"CustomField1", \
	"CustomField2", \
	"CustomField3", \
	"CustomField4", \
	"CustomField5", \
	"EffectiveDate1", \
	"EffectiveDate2", \
	"EffectiveDate3", \
	"EffectiveDate4", \
	"EffectiveDate5", \
	"Mutually_Defined_ID", \
	"Job_Title" \
	}\
	{\
	print \
	$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,\
	$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,\
	$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,\
	$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,\
	$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,\
	$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,\
	$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,\
	$71,$72,$73,$74,$75,$76}' \
> ${members_table}

chmod 777 ${members_table}

wait

#rm ${formatted}
#rm ${member_detail}
#rm ${member_join}
#rm ${product_join}
#rm ${missing_data}
#rm ${counts}
#rm ${product_table}
#rm ${member_table}
#rm ${vol_life_check}
