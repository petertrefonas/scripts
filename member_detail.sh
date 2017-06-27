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

##### SET UP MEMBER DETAIL FILE WHICH IS BASIS OF TABLES ####

cat ${formatted} \
| sed 's;/en:Envelope/en:Enrollment/en:Detail;;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Identification/en:MutuallyDefined;/MemberLevelDetail/@MutuallyDefinedID;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:JobTitle;/MemberLevelDetail/@JobTitle;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Address/sc:City;/MemberLevelDetail/@AddressCity;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Address/sc:AddressLine1;/MemberLevelDetail/@AddressLine1;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Address/sc:AddressLine2;/MemberLevelDetail/@AddressLine2;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Address/sc:ProvinceOrStateCode;/MemberLevelDetail/@AddressStateCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Address/sc:PostalOrZipCode;/MemberLevelDetail/@AddressZipCode;g' \
| sed 's;/en:MemberLevelDetail/en:InsuredMember/en:BenefitStatusCode;/MemberLevelDetail/@BenefitStatusCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:PaymentInformation/en:BillingAddress/sc:City;/MemberLevelDetail/@BillingAddressCity;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:PaymentInformation/en:BillingAddress/sc:AddressLine1;/MemberLevelDetail/@BillingAddressLine1;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:PaymentInformation/en:BillingAddress/sc:AddressLine2;/MemberLevelDetail/@BillingAddressLine2;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:PaymentInformation/en:BillingAddress/sc:PostalOrZipCode;/MemberLevelDetail/@BillingPostalOrZipCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:PaymentInformation/en:BillingAddress/sc:ProvinceOrStateCode;/MemberLevelDetail/@BillingStateCode;g' \
| sed 's;/en:MemberLevelDetail/en:ReportingCategory/en:CategoryName;/MemberLevelDetail/@CategoryName;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:ContactInformation/sc:EmailAddress;/MemberLevelDetail/@EmailAddress;g' \
| sed 's;/en:MemberLevelDetail/en:Employer/en:Address/sc:City;/MemberLevelDetail/@EmployerAddressCity;g' \
| sed 's;/en:MemberLevelDetail/en:Employer/en:Address/sc:AddressLine1;/MemberLevelDetail/@EmployerAddressLine1;g' \
| sed 's;/en:MemberLevelDetail/en:Employer/en:Address/sc:AddressLine2;/MemberLevelDetail/@EmployerAddressLine2;g' \
| sed 's;/en:MemberLevelDetail/en:Employer/en:Address/sc:ProvinceOrStateCode;/MemberLevelDetail/@EmployerAddressStateCode;g' \
| sed 's;/en:MemberLevelDetail/en:Employer/en:EmployerContactInformation/sc:PhoneNumber/sc:Direct;/MemberLevelDetail/@EmployerDirectPhone;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:EmployerGroupField1;/MemberLevelDetail/@EmployerGroupField1;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:EmployerGroupField2;/MemberLevelDetail/@EmployerGroupField2;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:EmployerGroupField3;/MemberLevelDetail/@EmployerGroupField3;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:EmployerGroupField4;/MemberLevelDetail/@EmployerGroupField4;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:EmployerGroupField5;/MemberLevelDetail/@EmployerGroupField5;g' \
| sed 's;/en:MemberLevelDetail/en:Employer/en:Identification/en:EmployerID;/MemberLevelDetail/@EmployerID;g' \
| sed 's;/en:MemberLevelDetail/en:Employer/en:Organization/sc:OrganizationName;/MemberLevelDetail/@EmployerName;g' \
| sed 's;/en:MemberLevelDetail/en:Employer/en:Address/sc:PostalOrZipCode;/MemberLevelDetail/@EmployerZipCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberLevelDates/en:EmploymentBegin;/MemberLevelDetail/@EmploymentBegin;g' \
| sed 's;/en:MemberLevelDetail/en:MemberLevelDates/en:EmploymentEnd;/MemberLevelDetail/@EmploymentEnd;g' \
| sed 's;/en:MemberLevelDetail/en:InsuredMember/en:EmploymentStatusCode;/MemberLevelDetail/@EmploymentStatusCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberLevelDates/en:EnrollmentSignatureDate;/MemberLevelDetail/@EnrollmentSignatureDate;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Person/sc:FirstName;/MemberLevelDetail/@FirstName;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:DemographicInformation/en:GenderCode;/MemberLevelDetail/@GenderCode;g' \
| sed 's;/en:MemberLevelDetail/en:ReportingCategory/en:Categories/en:GroupName;/MemberLevelDetail/@GroupName;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:MemberHealthInformation/en:HealthCode;/MemberLevelDetail/@HealthCode;g' \
| sed 's;/en:MemberLevelDetail/en:InsuredMember/@isHandicapped;/MemberLevelDetail/@isHandicapped;g' \
| sed 's;/en:MemberLevelDetail/en:InsuredMember/@isSubscriber;/MemberLevelDetail/@isSubscriber;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Person/sc:LastName;/MemberLevelDetail/@LastName;g' \
| sed 's;/en:MemberLevelDetail/en:MailingAddress/sc:City;/MemberLevelDetail/@MailingAddressCity;g' \
| sed 's;/en:MemberLevelDetail/en:MailingAddress/sc:AddressLine1;/MemberLevelDetail/@MailingAddressLine1;g' \
| sed 's;/en:MemberLevelDetail/en:MailingAddress/sc:AddressLine2;/MemberLevelDetail/@MailingAddressLine2;g' \
| sed 's;/en:MemberLevelDetail/en:MailingAddress/sc:PostalOrZipCode;/MemberLevelDetail/@MailingPostalOrZipCode;g' \
| sed 's;/en:MemberLevelDetail/en:MailingAddress/sc:ProvinceOrStateCode;/MemberLevelDetail/@MailingStateCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberLevelDates/en:MaintenanceEffective;/MemberLevelDetail/@MemberMaintenanceEffective;g' \
| sed 's;/en:MemberLevelDetail/en:InsuredMember/en:MaintenanceReasonCode;/MemberLevelDetail/@MemberMaintenanceReasonCode;g' \
| sed 's;/en:MemberLevelDetail/en:InsuredMember/en:MaintenanceTypeCode;/MemberLevelDetail/@MemberMaintenanceTypeCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:DemographicInformation/en:MaritalStatusCode;/MemberLevelDetail/@MaritalStatusCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:ContactInformation/sc:CellPhone;/MemberLevelDetail/@MemberCellPhone;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField1;/MemberLevelDetail/@MemberCustomField1;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField2;/MemberLevelDetail/@MemberCustomField2;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField3;/MemberLevelDetail/@MemberCustomField3;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField4;/MemberLevelDetail/@MemberCustomField4;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField5;/MemberLevelDetail/@MemberCustomField5;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:DemographicInformation/en:DateOfBirth;/MemberLevelDetail/@MemberDateOfBirth;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:ContactInformation/sc:PhoneNumber/sc:Direct;/MemberLevelDetail/@MemberDirectPhone;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField1EffectiveDate;/MemberLevelDetail/@MemberEffectiveDate1;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField2EffectiveDate;/MemberLevelDetail/@MemberEffectiveDate2;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField3EffectiveDate;/MemberLevelDetail/@MemberEffectiveDate3;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField4EffectiveDate;/MemberLevelDetail/@MemberEffectiveDate4;g' \
| sed 's;/en:MemberLevelDetail/en:SupplementalIdentifiers/en:CustomField5EffectiveDate;/MemberLevelDetail/@MemberEffectiveDate5;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:MemberIncome/en:FrequencyCode;/MemberLevelDetail/@MemberFrequencyCode;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:MemberIncome/en:Quantity;/MemberLevelDetail/@MemberQuantity;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:MemberIncome/en:MonetaryAmount;/MemberLevelDetail/@MemberSalary;g' \
| sed 's;/en:MemberLevelDetail/en:DisabilityInformation;/MemberLevelDetail/@MemberSeqID=;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:ContactInformation/sc:WorkPhone;/MemberLevelDetail/@MemberWorkPhone;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Person/sc:MiddleName;/MemberLevelDetail/@MiddleName;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Person/sc:NamePrefix;/MemberLevelDetail/@NamePrefix;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Person/sc:NameSuffix;/MemberLevelDetail/@NameSuffix;g' \
| sed 's;/en:MemberLevelDetail/en:MemberLevelDates/en:ReceivedDate;/MemberLevelDetail/@ReceivedDate;g' \
| sed 's;/en:MemberLevelDetail/en:InsuredMember/en:RelationshipCode;/MemberLevelDetail/@RelationshipCode;g' \
| sed 's;/en:MemberLevelDetail/en:ReportingCategory;/MemberLevelDetail/@ReportingCategory;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:MemberIncome/en:SalaryEffectiveDate;/MemberLevelDetail/@SalaryEffectiveDate;g' \
| sed 's;/en:MemberLevelDetail/en:MemberDetail/en:Identification/en:SSN;/MemberLevelDetail/@SSN;g' \
| sed 's;/en:MemberLevelDetail/en:InsuredMember/en:StudentStatusCode;/MemberLevelDetail/@StudentStatusCode;g' \
| sed 's;/en:MemberLevelDetail/en:SubscriberIdentifier;/MemberLevelDetail/@SubscriberIdentifier;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageAmounts/en:AmountApproved;/MemberLevelDetail/HealthCoverageDetail/@AmountApproved;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageAmounts/en:AmountRequested;/MemberLevelDetail/HealthCoverageDetail/@AmountRequested;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageDates/en:BenefitBegin;/MemberLevelDetail/HealthCoverageDetail/@BenefitBeginDate;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageDates/en:BenefitEnd;/MemberLevelDetail/HealthCoverageDetail/@BenefitEndDate;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoordinationBenefits;/MemberLevelDetail/HealthCoverageDetail/@CoordinationBenefits;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CoverageLevelCode;/MemberLevelDetail/HealthCoverageDetail/@CoverageLevelCode;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:Dentist/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@Dentist;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:Doctor/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@Doctor;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageAmounts/en:EmployeePremiumAmount;/MemberLevelDetail/HealthCoverageDetail/@EmployeePremiumAmount;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageAmounts/en:EmployerPremiumAmount;/MemberLevelDetail/HealthCoverageDetail/@EmployerPremiumAmount;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageDates/en:EnrollmentSignatureDate;/MemberLevelDetail/HealthCoverageDetail/@EnrollmentSignatureDate;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:Facility/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@Facility;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField1;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageCustomField1;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField2;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageCustomField2;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField3;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageCustomField3;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField4;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageCustomField4;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField5;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageCustomField5;g' \
| sed 's;/MemberLevelDetail/HealthCoverageDetail/@BenefitBeginDate/@format=CCYYMMDD;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageDetailSeqID=;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField1EffectiveDate;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageEffectiveDate1;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField2EffectiveDate;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageEffectiveDate2;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField3EffectiveDate;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageEffectiveDate3;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField4EffectiveDate;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageEffectiveDate4;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:CustomField5EffectiveDate;/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageEffectiveDate5;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:Hospital/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@Hospital;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:InsuranceLineCode;/MemberLevelDetail/HealthCoverageDetail/@InsuranceLineCode;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:Laboratory/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@Laboratory;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/@lateEnrollment;/MemberLevelDetail/HealthCoverageDetail/@lateEnrollment;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageDates/en:MaintenanceEffective;/MemberLevelDetail/HealthCoverageDetail/@ProductMaintenanceEffective;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:MaintenanceTypeCode;/MemberLevelDetail/HealthCoverageDetail/@ProductMaintenanceTypeCode;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:ManagedCareOrganization/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@ManagedCareOrganization;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:ObstetricsGynecologyFacility/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@ObstetricsGynecologyFacility;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:PrimaryCareProvider/en:Person/sc:NamePrefix;/MemberLevelDetail/HealthCoverageDetail/@PCPNamePrefix;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:Pharmacy/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@Pharmacy;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:PlanCoverageDescription;/MemberLevelDetail/HealthCoverageDetail/@PlanCoverageDescription;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:HealthCoverage/en:PlanID;/MemberLevelDetail/HealthCoverageDetail/@PlanID;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageAmounts/en:PremiumAmount;/MemberLevelDetail/HealthCoverageDetail/@PremiumAmount;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:PrimaryCareProvider/en:ProviderChangeReason;/MemberLevelDetail/HealthCoverageDetail/@PrimaryCareProvider;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/Beneficiary;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/@percentage;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@Beneficiarypercentage;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/@type;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@type;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/en:Person/en:LastName;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@BeneficiaryLastName;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/en:Person/en:FirstName;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@BeneficiaryFirstName;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/en:IdentificationNumber;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@BeneficiaryIdentificationNumber;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/en:Address/en:AddressLine1;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@BeneficiaryAddressLine1;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/en:Address/en:AddressLine2;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@BeneficiaryAddressLine2;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/en:Address/en:City;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@BeneficiaryCity;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/en:Address/en:ProvinceOrStateCode;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@BeneficiaryProvinceOrStateCode;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:BeneficiaryDetail/en:Beneficiary/en:Address/en:PostalOrZipCode;/MemberLevelDetail/HealthCoverageDetail/BeneficiaryDetail/@BeneficiaryPostalOrZipCode;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:PrimaryCareProvider/en:Person/sc:FullName;/MemberLevelDetail/HealthCoverageDetail/@PCPFullName;g' \
| sed 's;/en:MemberLevelDetail/en:HealthCoverageDetail/en:CoverageProvider/en:PrimaryCareProvider/en:Identification/en:ServiceProviderNumber;/MemberLevelDetail/HealthCoverageDetail/@PCPServiceProviderNumber;g' \
| sed 's;,;;g' \
| sed 's;en:;;g' \
| awk \
	-F "`printf '\t'`" \
	-v v=0 \
	'{OFS="\t"}\
	{if($1 ~ /@isHandicapped/) print v++, $0; \
	else print v, $0}' \
| awk \
	-F "`printf '\t'`" \
	'{OFS="\t"}\
	{\
	if($2 == "/MemberLevelDetail/@MemberSeqID=") print $1,$2$1; \
	else if($2 =="/MemberLevelDetail/HealthCoverageDetail/@HealthCoverageDetailSeqID=") print $1,$2$1; \
	else if($2 ~ /@BeneficiaryPercentage/) print $1,$2$1; \
	else print $1,$2}' \
| cut \
	-f2 \
> ${member_detail} 

chmod 777 ${member_detail}
