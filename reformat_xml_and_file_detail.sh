#! /bin/sh -e

##### FILE PARAMETER THAT ARE REQUIRED TO BE PASSED #####

# XML name
xml_name=$1
# Name of carrier who is providing the products
carrier_name=$2
# Name of the employer or broker (multi-tenant file)
group_name=$3
# Provides unique file for multiple runs (1 min or more apart)
time_stamp=$4

#### Paths ####

# this is a static script meant for individuals who are not familiar with running a script
home=/Users/$USER/Desktop/XML_Validator

# path where xml files will be stored
XML=${home}/XML

# path were reports will be stored
reports=${home}/reports

support_files=${home}/scripts/support_files

#### FILES ####
# xml file
file=${XML}/${xml_name}

# full path for generated formatted file
formatted=${reports}/formatted_xml_${carrier_name}_${group_name}_${time_stamp}.txt
# full path for file detail
file_detail=${reports}/file_detail_${carrier_name}_${group_name}_${time_stamp}.txt
# location of file to update 
list_of_files=${support_files}/list_of_files.txt
# new list of file
new_list_of_files=${support_files}/list_of_files_${carrier_name}_${group_name}_${time_stamp}.txt

unique_matches=${reports}/unique_matches_${carrier_name}_${group_name}_${time_stamp}.txt

##### CONVERT XML TO FILE PATHS #####
xml2 < ${file} > ${formatted}

wait

#### CREATE FILE DETAIL REPORT WHICH IS HEADER OF XML ####

cat ${formatted} \
| grep '/en:Envelope/en:Enrollment/en:Header/' \
| sed 's;.*/en:Envelope;;g' \
| sed 's;.*/en:Enrollment;;g' \
| sed 's;.*/en:Header;;g' \
| sed 's;/en:TransactionIdentification/;;g' \
| sed 's;/en:;;g' \
| sed 's;en:;;g' \
| tr "=" "\t" \
| grep \
	-v CCYYMMDD \
| grep \
	-v HHMM \
| sed 's;NameName;Name;g' \
| sed 's;CreationDateTime/sc:Date;CreationDate;g' \
| sed 's;CreationDateTime/sc:Time;CreationTime;g' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{print \
	$1":",$2}' \
> ${file_detail}

chmod 777 ${file_detail}
