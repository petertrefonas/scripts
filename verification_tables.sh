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

# full path for product join table
product_join=${reports}/product_join_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for member join table
member_join=${reports}/member_join_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for verification table
verify_table=${reports}/verification_table_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for vol life table
vol_life_table=${reports}/vol_life_table_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for vol life check
vol_life_check=${reports}/vol_life_check_${carrier_name}_${group_name}_${time_stamp}.txt


#### CREATE VERIFICATION TABLE FOR JEXL CODES WITH MOST USED FIELDS

join -1 1 -2 1 -t "`printf '\t'`" -a1 ${product_join} ${member_join} \
| awk\
	-F "`printf '\t'`" \
	'{OFS="\t"} \
	{print \
	$1,$19,$20,$21,$22,$23,$24,$25,$26,$27,$28,\
	$36,$37,$38,$39,$35,$34,$30,$29,$31,$32,\
	$33,$16,$10,$9,$8,$6,$7,$4,$5,$11,$12,\
	$13,$14,$15,$40,$41,$42,$43,$44,"1",substr($24,0,1)". "$25,$17,$18,$2,$3}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	BEGIN\
	{printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",\
	"Member_Id", \
	"Subscriber_Id", \
	"SSN", \
	"Relationship_Code", \
	"Is_Subscriber", \
	"Member_Maintenance_Type_Code", \
	"First_Name", \
	"Last_Name", \
	"Birth_Date", \
	"Gender", \
	"Marital_Status", \
	"Street_Address", \
	"City", \
	"State", \
	"Zip", \
	"Employer_Name", \
	"Employer_ID", \
	"Group_Name", \
	"Category_Name", \
	"Employee_Start_Date", \
	"Employee_End_Date", \
	"Salary", \
	"Plan_ID", \
	"Plan_Coverage_Description", \
	"Insurance_Line_Code", \
	"Coverage_Level", \
	"Product_Maintenance_Type_Code", \
	"Maintenance_Effective_Date", \
	"Product_Begin_Date", \
	"Product_End_Date", \
	"Product_Custom_Field_1", \
	"Product_Custom_Field_2", \
	"Product_Custom_Field_3", \
	"Product_Custom_Field_4", \
	"Product_Custom_Field_5", \
	"Member_Custom_Field_1", \
	"Member_Custom_Field_2", \
	"Member_Custom_Field_3", \
	"Member_Custom_Field_4", \
	"Member_Custom_Field_5", \
	"Count_For_Reports", \
	"PHI_Name", \
	"PCP_Name", \
	"PCP_Number", \
	"Amount_Requested", \
	"Amount_Approved" \
	}\
	{print \
	$1,$2,$3,$4,$5,$6,$7,$8,$9,$10, \
	$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,\
	$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,\
	$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,$41,$42,$43,$44,$45,$46}' \
> ${verify_table}

wait

cat ${verify_table} \
| grep \
	-v Member_Id \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		print $1,$2,$16,$17,$18,$4,substr($7,0,1)". "$8,$22,$25\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "BL") print $1,$2,$3,$4,$5,$6,$7,$8,$9,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "BA") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "STD") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "LTD") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "VEL") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "VEA") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,"0" \
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "VSL") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "VSA") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"} \
	{\
		if($9 == "VCL") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "VCA") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "VSTD") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "VLTD") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($8 != "") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($9 == "DEN") print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,"1"; \
		else print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,"0"\
	}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		print $1,$2,$3,$4,$5,$6,$7,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21,$22,$23\
	}' \
| sort \
| filter \
	-u 0,1,2,3,4,5,6 \
	-s 7,8,9,10,11,12,13,14,15,16,17,18,20 \
	-p 0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20 \
| sort -k1,1g\
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	BEGIN\
	{printf "%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n",\
	"Member_Id",\
	"Subscriber_Id",\
	"Employer_Name",\
	"Employer_Id",\
	"Eligibility_Group",\
	"Relationship_Type_Code",\
	"PHI_Name",\
	"Has_BL",\
	"Has_BA",\
	"Has_STD",\
	"Has_LTD",\
	"Has_VEL",\
	"Has_VEA",\
	"Has_VSL",\
	"Has_VSA",\
	"Has_VCL",\
	"Has_VCA",\
	"Has_VSTD",\
	"Has_VLTD",\
	"Has_Salary",\
	"Has_DEN"
	}\
	{\
		print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,$21\
	}'\
> ${vol_life_table}

wait

cat ${vol_life_table} \
| grep -v Member_Id \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"} \
	{\
		print "Employer Paid Sum",$8,$9,$10,$11,$12,$13,$14,$15,$16,$17 \
	}' \
| filter \
	-u 0 \
	-s 1,2,3,4,5,6,7,8,9,10 \
	-p 0,1,2,3,4,5,6,7,8,9,10 \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
		if($2 == "0" || $3 =="0") print "BL_&_BA"; \
		if($4 == "0" || $5 =="0") print "STD_&_LTD"; \
		if($6 == "0" || $7 =="0") print "VEL_&_VEA"; \
		if($8 == "0" || $9 =="0") print "VSL_&_VSA"; \
		if($10 == "0" || $11 =="0") print "VCL_&_VCA" \
	}'\
>${vol_life_check}

chmod 777 ${verify_table}
chmod 777 ${vol_life_table}
chmod 777 ${vol_life_check}