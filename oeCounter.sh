currentDir="$PWD"

psDir=${currentDir/%scripts/excel_reports}
array=($psDir/*)
firstPS=${array[0]}
IFS='/' read -ra b <<< "$firstPS"
prod_support=${b[${#b[@]}-1]}

oeDir=${currentDir/%scripts/open_enrollment}
array=($oeDir/*)
firstOE=${array[0]}
IFS='/' read -ra b <<< "$firstOE"
open_enrollment=${b[${#b[@]}-1]}

intDir=${currentDir/%scripts/integrations}
array=($intDir/*)
firstINT=${array[0]}
IFS='/' read -ra b <<< "$firstINT"
integrations=${b[${#b[@]}-1]}

if [[ ${#integrations} -gt 4 && ${integrations: -4} = ".csv" ]]; then
	echo "Using integrations file: $integrations"
else
	echo "Using wrong integrations file: $integrations"
	exit
fi
if [[ ${#open_enrollment} -gt 4 && ${open_enrollment: -4} = ".csv" ]]; then
	echo "Using open_enrollment file: $open_enrollment"
else
	echo "Using wrong open_enrollment file: $open_enrollment"
	exit
fi
if [[ ${#prod_support} -gt 4 && ${prod_support: -4} = ".csv" ]]; then
	echo "Using prod_support file: $prod_support"
	usingPS=true
else
	usingPS=false
fi
if [ "$usingPS" = true ] ; then
	python oeCounter.py "$prod_support" "$open_enrollment" "$integrations"
else
	python oeCounter.py "INVALID" "$open_enrollment" "$integrations"	
fi
