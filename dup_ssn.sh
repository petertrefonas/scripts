#! /bin/sh -e

##### FILE PARAMETER THAT ARE REQUIRED TO BE PASSED #####

# Name of carrier who is providing the products
carrier_name=$1
# Name of the employer or broker (multi-tenant file)
group_name=$2
# Provides unique file for multiple runs (1 min or more apart)
time_stamp=$3

# provides basis for date comparison
year=`date +"%Y"`
birth_max=$((year-90))
birth_min=$((year-14))

#### Paths ####

# this is a static script meant for individuals who are not familiar with running a script
home=/Users/$USER/Desktop/XML_Validator

# path were reports will be stored
reports=${home}/reports

#### FILES ####

# full path for JIRA missing data report
missing_data=${reports}/missing_data_${carrier_name}_${group_name}_${time_stamp}.txt


# full path for member table
member_table=${reports}/member_table_${carrier_name}_${group_name}_${time_stamp}.txt


cat ${member_table} \
| grep -v Employer_name \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	if($3 != "" && length($3) == "9" && substr($3,0,3)!="000"&&substr($3,0,3)!="666"&&substr($3,4,2)!="00"&&substr($3,6,4)!="0000" && $3 !~ /000000000|111111111|222222222|333333333|444444444|555555555|666666666|777777777|888888888|999999999/ && $3 !~ /123456789|987654321|012345678|876543210|123121234/) \
			print "Duplicate SSN","N/A",$32,$31,"N/A",$3,1 \
	}' \
| sort \
| filter \
	-u 0,1,2,3,4,5 \
	-s 6 \
	-p 0,1,2,3,4,5,6 \
| sort \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($7 > "1")print $1,$2,$3,$4,$5,$6\
	}' \
>>${missing_data}
