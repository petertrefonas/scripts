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
# coverage level report
coverage_level=${reports}/coverage_level_report_${carrier_name}_${group_name}_${time_stamp}.txt

#### CREATE COVERAGE LEVEL REPORT ####

cat ${verify_table} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{print $2,$25,$4,$26}' \
| sort \
	-k1 \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	if($3 == "19") \
		print $1,$2,$3,$4,"8","0","0","0","1"; \
	else if($3 == "18") \
		print $1,$2,$3,$4,"1","1","0","0","0"; \
	else if($3 == "01") \
		print $1,$2,$3,$4,"2","0","1","0","0"; \
	else if($3 == "53") \
		print $1,$2,$3,$4,"4","0","0","1","0" \
	}'\
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	if($4 =="ee") \
		print $1,$2,$3,$4,$5,"1",$6,$7,$8,$9; \
	if($4 =="ee+sp") \
		print $1,$2,$3,$4,$5,"3",$6,$7,$8,$9; \
	if($4 =="ee+dp") \
		print $1,$2,$3,$4,$5,"5",$6,$7,$8,$9; \
	if($4 =="ee+ch") \
		print $1,$2,$3,$4,$5,"9",$6,$7,$8,$9; \
	if($4 =="ee+chs") \
		print $1,$2,$3,$4,$5,"17",$6,$7,$8,$9; \
	if($4 =="ee+sp+ch") \
		print $1,$2,$3,$4,$5,"11",$6,$7,$8,$9; \
	if($4 =="ee+sp+chs") \
		print $1,$2,$3,$4,$5,"19",$6,$7,$8,$9; \
	if($4 =="ee+dp+ch") \
		print $1,$2,$3,$4,$5,"13",$6,$7,$8,$9; \
	if($4 =="ee+dp+chs") \
		print $1,$2,$3,$4,$5,"21",$6,$7,$8,$9 \
	}' \
| filter \
	-u 0,1,5 -s 4,6,7,8,9 -p 0,1,4,5,6,7,8,9 \
| sort \
| awk \
	-F "`printf '\t'`" \
	'BEGIN \
	{printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n", \
	"Subscriber_Id",\
	"Insurance_Line_Code",\
	"Member_Count",\
	"Product_Count",\
	"Subscriber_Count",\
	"Spouse_Count",\
	"Domestic_Partner_Count",\
	"Dependent_Count",\
	"Coverage_Level_Test"\
	}\
	{OFS="\t"}\
	{\
	if($3 == $4) \
		print $1,$2,$3,$4,$5,$6,$7,$8,"PASS"; \
	else if($3 =="2" && $5 =="2") \
		print $1,$2,$3,$4,$5,$6,$7,$8,"PASS"; \
	else if(($3-($8-2)*8 == $4) || ($2 ~ /VCL|VCA|VSL|VSA/ && $3/2 == $4) || ($5 =="2" && $6=="2")) \
		print $1,$2,$3,$4,$5,$6,$7,$8,"PASS"; \
	else print $1,$2,$3,$4,$5,$6,$7,$8,"FAIL"}' \
> ${coverage_level}

chmod 777 ${coverage_level}
