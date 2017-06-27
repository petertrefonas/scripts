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

# full path for member table
member_table=${reports}/member_table_${carrier_name}_${group_name}_${time_stamp}.txt

# full path for member join table
member_join=${reports}/member_join_${carrier_name}_${group_name}_${time_stamp}.txt

##### CREATE MEMBER TABLE #####

2csv MemberLevelDetail \
@MemberSeqID \
@SubscriberIdentifier \
@SSN \
@StudentStatusCode \
@RelationshipCode \
@isSubscriber \
@EmploymentStatusCode \
@EnrollmentSignatureDate \
@MemberMaintenanceTypeCode \
@MemberMaintenanceReasonCode \
@MemberMaintenanceEffective \
@NamePrefix \
@FirstName \
@MiddleName \
@LastName \
@NameSuffix \
@MemberDateOfBirth \
@isHandicapped \
@HealthCode \
@GenderCode \
@MaritalStatusCode \
@ReportingCategory \
@CategoryName \
@GroupName \
@EmploymentBegin \
@EmploymentEnd \
@MemberQuantity \
@MemberSalary \
@MemberFrequencyCode \
@SalaryEffectiveDate \
@EmployerID \
@EmployerName \
@EmployerAddressLine1 \
@EmployerAddressLine2 \
@EmployerAddressCity \
@EmployerAddressStateCode \
@EmployerZipCode \
@EmployerDirectPhone \
@MemberCellPhone \
@MemberDirectPhone \
@MemberWorkPhone \
@EmailAddress \
@AddressLine1 \
@AddressLine2 \
@AddressCity \
@AddressStateCode \
@AddressZipCode \
@MailingAddressLine1 \
@MailingAddressLine2 \
@MailingAddressCity \
@MailingStateCode \
@MailingPostalOrZipCode \
@BillingAddressLine1 \
@BillingAddressLine2 \
@BillingStateCode \
@BillingAddressCity \
@BillingPostalOrZipCode \
@BenefitStatusCode \
@ReceivedDate \
@EmployerGroupField1 \
@EmployerGroupField2 \
@EmployerGroupField3 \
@EmployerGroupField4 \
@EmployerGroupField5 \
@MemberCustomField1 \
@MemberCustomField2 \
@MemberCustomField3 \
@MemberCustomField4 \
@MemberCustomField5 \
@MemberEffectiveDate1 \
@MemberEffectiveDate2 \
@MemberEffectiveDate3 \
@MemberEffectiveDate4 \
@MemberEffectiveDate5 \
@MutuallyDefinedID \
@JobTitle \
< ${member_detail} \
| awk \
	-F "`printf ','`" \
	'{OFS="\t"} \
	{print \
	$1,$2,$3,$4,$5,$6,$7,$8,$9,$10,\
	$11,$12,$13,$14,$15,$16,$17,$18,$19,$20,\
	$21,$22,$23,$24,$25,$26,$27,$28,$29,$30,\
	$31,$32,$33,$34,$35,$36,$37,$38,$39,$40,\
	$41,$42,$43,$44,$45,$46,$47,$48,$49,$50,\
	$51,$52,$53,$54,$55,$56,$57,$58,$59,$60,\
	$61,$62,$63,$64,$65,$66,$67,$68,$69,$70,\
	$71,$72,$73,$74,$75,$76}' \
| sort \
	-k1g \
> ${member_table}

chmod 777 ${member_table}

wait

cat ${member_table} \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{print \
	$1,$2,$3,$5,$6,$9,$13,$15,$17,$20,\
	$21,$23,$24,$25,$26,$28,$31,$32,$43,$45,\
	$46,$47,$65,$66,$67,$68,$69}' \
> ${member_join}

chmod 777 ${member_join}
