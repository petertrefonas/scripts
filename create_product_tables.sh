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

# full path for generated formatted file
formatted=${reports}/formatted_xml_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for member detail report
member_detail=${reports}/member_detail_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for product table
product_table=${reports}/product_table_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for product join table
product_join=${reports}/product_join_${carrier_name}_${group_name}_${time_stamp}.txt

##### CREATE PRODUCT TABLE #####

2csv HealthCoverageDetail \
@HealthCoverageDetailSeqID \
@lateEnrollment \
@PlanID \
@PremiumAmount \
@EmployeePremiumAmount \
@EmployerPremiumAmount \
@AmountRequested \
@AmountApproved \
@BenefitBeginDate \
@BenefitEndDate \
@EnrollmentSignatureDate \
@ProductMaintenanceTypeCode \
@ProductMaintenanceEffective \
@CoverageLevelCode \
@InsuranceLineCode \
@PlanCoverageDescription \
@HealthCoverageCustomField1 \
@HealthCoverageCustomField2 \
@HealthCoverageCustomField3 \
@HealthCoverageCustomField4 \
@HealthCoverageCustomField5 \
@HealthCoverageEffectiveDate1 \
@HealthCoverageEffectiveDate2 \
@HealthCoverageEffectiveDate3 \
@HealthCoverageEffectiveDate4 \
@HealthCoverageEffectiveDate5 \
@PCPNamePrefix \
@Doctor \
@PrimaryCareProvider \
@Dentist \
@Hospital \
@Pharmacy \
@Laboratory \
@Facility \
@ManagedCareOrganization \
@ObstetricsGynecologyFacility \
@CoordinationBenefits \
@PlanID \
@PCPFullName \
@PCPServiceProviderNumber \
< ${member_detail} \
|  awk \
	-F "`printf ','`" \
	'{OFS="\t"} \
	{print \
	$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,\
	$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,\
	$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,\
	$31,$32,$33,$34,$35,$36,$37,$38,$39,$40}' \
| sort \
	-k1g \
> ${product_table}

chmod 777 ${product_table}

wait

cat ${product_table} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{print \
	$1,$7,$8,$9,$10,$12,$13,$14,$15,$16,$17,\
	$18,$19,$20,$21,$38,$39,$40}' \
> ${product_join}

chmod 777 ${product_join}
