#This script runs automatically as part of the validator script
#This script can also be run manually by typing ./checkXML.sh XML_NAME




currentDir="$PWD"
home=/Users/$USER/Desktop/XML_Validator

# XML name
xml_name=$1
# Name of carrier who is providing the products
carrier_name=$2
# Name of the employer or broker (multi-tenant file)
group_name=$3
# Provides unique file for multiple runs (1 min or more apart)
time_stamp=$4

# path where xml files will be stored
XML=${home}/XML

# path were reports will be stored
reports=${home}/reports

# create new report text file
unique_matches=${reports}/unique_matches_${carrier_name}_${group_name}_${time_stamp}.txt

# XML file name
file=${XML}/${xml_name}

#Store XML data in variable
foo=$(<$file)


# Checks XML for ` ~ | * ^
# Checks XML for any non-ASCII values
# Not checking for : ,
# Checking for : , would take a lot more work to differentiate false positives (: all over xml, comma is in addresses)

echo $foo | grep -o --color=always "[\\\`~|*^]\|[^ -~]\+" | sort | uniq -c | sort -nr > ${unique_matches}
echo $foo | grep -o --color=always "\&\#12[8-9];" | sort | uniq -c | sort -nr >> ${unique_matches}
echo $foo | grep -o --color=always "\&\#1[3-9][0-9];" | sort | uniq -c | sort -nr >> ${unique_matches}
echo $foo | grep -o --color=always "\&\#[2-9][0-9][0-9];" | sort | uniq -c | sort -nr >> ${unique_matches}

# Displays only if unusual characters are found

foo=$(<$unique_matches)
if [[ ${#foo} -gt 0 ]]; then
	echo "Unusual Characters in XML:"
	echo $foo
fi