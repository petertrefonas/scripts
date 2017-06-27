#! /bin/sh -e

##### FILE PARAMETER THAT ARE REQUIRED TO BE PASSED #####

# Name of file
name=$1
# Name of Carrier
carrier=$2
# Name of Group
group=$3

#### Paths ####

# this is a static script meant for individuals who are not familiar with running a script
home=/Users/$USER/Desktop/XML_Validator

files=${home}/834_files

file=${files}/${name}

#### FILES ####

# location of file to update 

validation_folder=${home}/834_validation
output=${validation_folder}/834_counts_${carrier}_${group}.txt


##### UPDATE LIST OF FILES #####

cat ${file} \
| tr "~" "\n" \
| tr "*" "\t" \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	if($1 == "QTY") \
		print 2,$1,$2,$3; \
	if($1 == "GS") \
		print 1,$1,$4,"1"; \
	if($1 =="HD") \
		print 3,$1":Maintenance_Code",$2,"1"; \
	if($1 =="HD") \
		print 3,$1":EDI_TYPE",$4,"1"; \
	if($1 =="HD") \
		print 3,$1":Plan_Coverage_Desc",$5,"1"; \
        if($1 =="HD") \
                print 3,$1":Insurance_Line_Code",$6,"1"; \
	if($1 =="REF" && $2 != "0F") \
		print 4,$1,$2":"$3,"1"}' \
| filter \
	-u 0,1,2 -s 3 -p 0,1,2,3 \
| sort \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	print $2,$3,$4}' \
> ${output}