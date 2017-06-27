#! /bin/sh -e

##### FILE PARAMETER THAT ARE REQUIRED TO BE PASSED #####

# Name of carrier who is providing the products
carrier_name=$1
# Name of the employer or broker (multi-tenant file)
group_name=$2
# Provides unique file for multiple runs (1 min or more apart)
time_stamp=$3

# provides basis for date comparison
maxBirthDateYear=`date -v -9465d +"%Y"`
maxBirthDateMonth=`date -v -9465d +"%m"`
maxBirthDateDay=`date -v -9465d +"%d"`
year=`date +"%Y"`
birth_max=$((year-90))
birth_min=$((year-14))

#### Paths ####

# this is a static script meant for individuals who are not familiar with running a script
home=/Users/$USER/Desktop/XML_Validator

# path were reports will be stored
reports=${home}/reports

#### FILES ####

# full path for verification table
verify_table=${reports}/verification_table_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for JIRA missing data report
missing_data=${reports}/missing_data_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for vol life table
vol_life_table=${reports}/vol_life_table_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for vol life check
vol_life_check=${reports}/vol_life_check_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for member table
member_table=${reports}/member_table_${carrier_name}_${group_name}_${time_stamp}.txt

file_detail=${reports}/file_detail_${carrier_name}_${group_name}_${time_stamp}.txt
TAB=$'\t'
vendorList="$(cat ${file_detail} | grep -Z 'PayerName:	' | sed 's;PayerName:	;;g' | uniq | tr '\n' ' ' )"
cat ${verify_table} \
| grep -v "Plan_Coverage_Description" \
| awk \
	-F "`printf '\t'`" \
	-v min=${birth_min} \
	-v max=${birth_max} \
	-v yr=${maxBirthDateYear} \
	-v mth=${maxBirthDateMonth} \
	-v day=${maxBirthDateDay} \
	-v vendorList="${vendorList}" \
	-v currentEE="" \
	-v currentName="" \
	'{OFS="\t"}{ \
	if($4 =="18") currentEE=substr($7,0,1)". "$8; 
	if($4 =="18") currentName=currentEE;\
	else currentName=substr($7,0,1)". "$8" (dep of "currentEE")";\
	if($6 != $27) print "Incorrect Member & Product Maintenance Type Codes",$1,$16,$17,$4,currentName; \
	if($9 != ""&& $4 =="19" && $9 != "Birth_Date" && (substr($9,0,4) < yr||(substr($9,0,4) == yr && substr($9,5,2) < mth)||(substr($9,0,4) == yr && substr($9,5,2) == mth && substr($9,7,2) <=day))) \
		print "Child is 26 or older",$1,$16,$17,$4,currentName, $9, " ", $29; \
	if($3 == "") print "No SSN",$1,$16,$17,$4,currentName, $3; \
    if($3 !="" && (match($3,"[^0-9]") != "0" || length($3) != "9" || substr($3,0,3)=="000" || substr($3,0,3)=="666" || substr($3,4,2)=="00" || substr($3,6,4)=="0000" || $3 ~ /000000000|111111111|222222222|333333333|444444444|555555555|666666666|777777777|888888888|999999999|123456789|987654321|012345678|876543210|123121234/)) \
        print "Invalid SSN",$1,$16,$17,$4,currentName, $3; \
 	else if($3 !="" && $3 ~ /000000|111111|222222|333333|444444|555555|666666|777777|888888|999999|123456|234567|012345|345678|456789|987654|876543|765432|654321|543210/) \
		print "Likely Invalid SSN",$1,$16,$17,$4,currentName, $3; \
	if($2 == $3 && $4 != "18") print "Dependent & Subscriber SSN Identical",$1,$16,$17,$4,currentName; \
	if($7 =="" || $7 ~ /TEST|Test|test/) print "First Name",$1,$16,$17,$4,currentName; \
	if($8 =="" || $8 ~ /TEST|Test|test/) print "Last Name",$1,$16,$17,$4,currentName; \
	if($9 =="" || length($9) !="8" || substr($9,0,4) < max || (substr($9,0,4) >= min && $4 =="18")) \
		print "Date of Birth",$1,$16,$17,$4,currentName, $9; \
	if($2 == "") print "Subscriber Id",$1,$16,$17,$4,currentName; \
	if($21 != "" && $6 !="024") print "Inactive Employee with Active Products",$1,$16,$17,$4,currentName, " ",$21, " ", $30; \
	if($12 == "") print "Address Line 1",$1,$16,$17,$4,currentName; \
	if($13 == ""|| match($13,"[0-9]") != "0") print "Address City",$1,$16,$17,$4,currentName; \
	if($14 == "" || length($14) != "2") print "Address State",$1,$16,$17,$4,currentName; \
    if($15 == "" || match($15,"[^0-9]") != "0" || length($15) != "5") print "Address Zip",$1,$16,$17,$4,currentName; \
	if($20 == "" && $4 =="18") print "Hire Date",$1,$16,$17,$4,currentName; \
	if($10 == "" || $10 !~ /M|F/ || length($10) > 1) print "Gender",$1,$16,$17,$4,currentName; \
	if($11 == "" && $4 =="18") print "Marital Status",$1,$16,$17,$4,currentName; \
	if($25 == "" && $4 =="18") print "Employment Begin Date",$1,$16,$17,$4,currentName; \
	if($22 == "" && $4 =="18") print "Missing Salary",$1,$16,$17,$4,currentName,$18; \
	if($22 != "" && $4 !="18") print "Dependent has Salary",$1,$16,$17,$4,currentName,$18,$22; \
	if($28 == "") print "Benefit Begin Date",$1,$16,$17,$4,currentName; \
	if($29 == "") print "Benefit End Date",$1,$16,$17,$4,currentName; \
	if($22 > 1000000) print "Salary is beyond one million",$1,$16,$17,$4,currentName,$18,$22; \
	if($22 <= 15000 && $22 !="") print "Salary is less than 15k",$1,$16,$17,$4,currentName,$18,$22; \
	if($23 == "" && $24=="" && $25 =="" && $28 =="" && $29 =="" && $30 =="") print "Product",$1,$16,$17,$4,currentName; \
	if($44 != "" && vendorList ~ /Guardian/ && (length($44) < 6 || length($44) > 7 || match(gsub(/D/,"0",$44),"[^0-9]") != "0")) print "Guardian PCP Number",$1,$16,$17,$4,currentName,$44; \
	if($45 == "" && $25 ~ /VEL|VEA|VSL|VSA|VCL|VCA|VCI/) print "Missing Amount Requested",$1,$16,$17,$4,currentName,$45,$46; \
	}' \
| sort -t$'\t' -k1,1d -k2,2g\
| uniq \
>${missing_data}

chmod 777 ${missing_data}

wait

bl_check=`cat ${vol_life_check} | grep "BL_&_BA"`
lstd_check=`cat ${vol_life_check} | grep "STD_&_LTD"`
vol_emp_check=`cat ${vol_life_check} | grep "VEL_&_VEA"`
vol_spo_check=`cat ${vol_life_check} | grep "VSL_&_VSA"`
vol_chd_check=`cat ${vol_life_check} | grep "VCL_&_VCA"`

wait

cat ${vol_life_table} \
| awk \
	-F "`printf '\t'`" \
	-v bl=${bl_check} \
	-v ls=${lstd_check} \
	-v ev=${vol_emp_check} \
	-v sv=${vol_spo_check} \
	-v cv=${vol_chd_check} \
	'{OFS="\t"}\
	{\
		if($7 != $8 && bl !="BL_&_BA") print "BL & BA Discrepancy",$3,$4,$1,$5,$6; \
		if($9 != $10 && ls !="STD_&_LTD") print "STD & LTD Discrepancy",$3,$4,$1,$5,$6; \
		if($11 != $12 && ev !="VEL_&_VEA") print "VEL & VEA Discrepancy",$3,$4,$1,$5,$6; \
		if($13 != $14 && sv !="VSL_&_VSA") print "VSL & VSA Discrepancy",$3,$4,$1,$5,$6; \
		if($15 != $16 && cv !="VCL_&_VCA") print "VCL & VCA Discrepancy",$3,$4,$1,$5,$6 \
	}'\
>>${missing_data}	

wait

cat ${member_table} \
| awk \
	-F "`printf '\t'`" \
'{OFS="\t"}\
	{\
	if($7 =="TE"&& $26=="" && $9=="030") \
		print "Inactive Employee",$32,$31,$1,$5,substr($13,0,1)". "$15 \
	}'\
>>${missing_data}