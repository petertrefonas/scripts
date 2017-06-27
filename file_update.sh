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

support_files=${home}/scripts/support_files

#### FILES ####

# location of file to update 
list_of_files=${support_files}/list_of_files.txt

# new list of file
top_25=${support_files}/list_of_files_${carrier_name}_${group_name}_${time_stamp}.txt

file_update=${time_stamp}_${carrier_name}_${group_name}

##### UPDATE LIST OF FILES #####

cat ${list_of_files} | sort -grk1 | head -24 > ${top_25} 

wait

cat ${list_of_files} > ${list_of_files}

wait

echo ${time_stamp} "|" ${carrier_name}_${group_name}_${time_stamp} | tr "|" "\t" >> ${list_of_files}

wait

cat ${top_25} | sort -grk1 | uniq >> ${list_of_files}

wait

rm ${top_25}

chmod 777 ${list_of_files}
