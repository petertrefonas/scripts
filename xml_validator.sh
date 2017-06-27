#! /bin/sh -e

##### FILE PARAMETER THAT ARE REQUIRED TO BE PASSED #####

# XML file name
xml_name=$1
# Name of carrier who is providing the products


#This section takes the file it finds in the xml_validator/XML directory and uses it as the source XML
#XML must be in format TEST_CarrierName_GroupName_Date (TEST_Guardian_Inspro_20161023)
currentDir="$PWD"
xmlDir=${currentDir/%scripts/XML}
array=($xmlDir/*)
firstXML=${array[0]}
IFS='/' read -ra b <<< "$firstXML"
xml_name=${b[${#b[@]}-1]}

IFS='_' read -ra b <<< "$xml_name"

#Assume Eno file names
if [[ ${#b[@]} -ne 4 ]]; then
	IFS='.' read -ra b <<< "$xml_name"
	carrier_name=${b[0]}
	IFS='_' read -ra b <<< "${b[1]}"
	group_name=${b[0]}
#Old naming convention
else
	carrier_name=${b[1]}
	group_name=${b[2]}
fi




#This section takes the file it finds in the xml_validator/excel_reports directory and uses it as the source production support report
psDir=${currentDir/%scripts/excel_reports}
array=($psDir/*)
firstPS=${array[0]}
IFS='/' read -ra b <<< "$firstPS"
prod_support=${b[${#b[@]}-1]}

pbDir=${currentDir/%scripts/pending_beneficiaries}
array=($pbDir/*)
firstPB=${array[0]}
IFS='/' read -ra b <<< "$firstPB"
pending_beneficiaries=${b[${#b[@]}-1]}

cseDir=${currentDir/%scripts/complete_system_export}
array=($cseDir/*)
firstCSE=${array[0]}
IFS='/' read -ra b <<< "$firstCSE"
complete_system_export=${b[${#b[@]}-1]}

#Check if files are definitely wrong
if [[ ${#xml_name} -gt 4 && ${xml_name: -4} = ".xml" ]]; then
	:
else
	echo "Using wrong XML file:$xml_name"
	exit
fi
if [[ ${#complete_system_export} -gt 4 && ${prod_support: -4} = ".csv" ]]; then
	usingCSE=true
else
	echo "Not using complete system export - file not found"
	usingCSE=false
fi
if [[ ${#prod_support} -gt 4 && ${prod_support: -4} = ".csv" ]]; then
	usingPS=true
else
	echo "Not using production support report - file not found"
	usingPS=false
fi
if [[ ${#pending_beneficiaries} -gt 4 && ${pending_beneficiaries: -4} = ".csv" ]]; then
	usingPB=true
	echo "Using pending beneficiaries report (only with confirmed elections)"
else
	usingPB=false
fi



# Provides unique file for multiple runs (1 min or more apart)
time_stamp=`date +"%Y-%m-%d-%H-%M"`

wait

# Scripts to call

./file_update.sh ${carrier_name} ${group_name} ${time_stamp} &
./reformat_xml_and_file_detail.sh ${xml_name} ${carrier_name} ${group_name} ${time_stamp} &

wait

./member_detail.sh ${carrier_name} ${group_name} ${time_stamp} &

wait

./create_member_tables.sh ${carrier_name} ${group_name} ${time_stamp} &
./create_product_tables.sh ${carrier_name} ${group_name} ${time_stamp} &

wait

./verification_tables.sh ${carrier_name} ${group_name} ${time_stamp} &

wait

./counts.sh ${carrier_name} ${group_name} ${time_stamp} &
./missing.sh ${carrier_name} ${group_name} ${time_stamp} &

wait

./coverage_level.sh ${carrier_name} ${group_name} ${time_stamp} &
./dup_ssn.sh ${carrier_name} ${group_name} ${time_stamp} &

wait
./create_reports.sh ${carrier_name} ${group_name} ${time_stamp} &

wait

#pat's MassMutual script (modified for command line input)
file_detail=/Users/$USER/Desktop/XML_Validator/reports/file_detail_${carrier_name}_${group_name}_${time_stamp}.txt

#MassMutual ID
IDList="$(cat ${file_detail} | grep -Z 'PayerNameMaxwellID:	' | sed 's;PayerNameMaxwellID:	;;g' | uniq | tr '\n' ' ' )"
if echo "$IDList" | grep "558d94309b22128f141f1bf4" > ../reports/vendorIds_${carrier_name}_${group_name}_${time_stamp}.txt; then
	echo "MassMutual vendor ID in vendor ID list - running MassMutual scripts"
	php csv.php ${xml_name} ${carrier_name} ${group_name} ${time_stamp} &
	wait
fi
echo "$IDList" > ../reports/vendorIds_${carrier_name}_${group_name}_${time_stamp}.txt

#new validator report composition
python autoRunner.py ${carrier_name} ${group_name} ${time_stamp} &

wait



#new counts script (automatically run)
if [ "$usingPS" = true ] ; then
	python countscompare.py "${prod_support}" ../excel_reports/${carrier_name}_${group_name}_${time_stamp}.xlsx "${complete_system_export}"&
	wait
fi
if [ "$usingPB" = true ] ; then
	python genbenxml.py "${pending_beneficiaries}"
	wait
fi

./checkXML.sh ${xml_name} ${carrier_name} ${group_name} ${time_stamp} &
wait



open ../excel_reports/${carrier_name}_${group_name}_${time_stamp}.xlsx
echo "----------------------------------"
echo "XML: $xml_name"
if [ "$usingPS" = true ] ; then
	echo "PS: $prod_support"
fi
if [ "$usingCSE" = true ] ; then
	echo "CSE: $complete_system_export"
fi


#Check for bad characters



