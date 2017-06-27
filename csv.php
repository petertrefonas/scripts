<?php
function getHeaders()
{
    $headerStr = "RelationshipCode,MaintenanceTypeCode,MaintenanceReasonCode,BenefitStatusCode,EmploymentStatusCode,StudentStatusCode,IsHandicapped,IsSubscriber,SubscriberIdentifier,CustomField1,CustomField2,EmployerGroupField1,MemberLevelDatesMaintenanceEffective,EmploymentBegin,LastName,FirstName,MiddleName,SSN,MutuallyDefined,PhoneNumberDirect,PhoneNumberCellPhone,EmailAddress,WorkPhone,AddressLine1,City,ProvinceOrStateCode,PostalOrZipCode,DateOfBirth,GenderCode,MaritalStatusCode,JobTitle,FrequencyCode,MonetaryAmount,Quantity,SalaryEffectiveDate,HealthCode,OrganizationName,EmployerID,EmployerPhoneNumberDirect,EmployerAddressLine1,EmployerCity,EmployerProvinceOrStateCode,EmployerPostalOrZipCode,HealthCoverageMaintenanceTypeCode,InsuranceLineCode,PlanCoverageDescription,PlanID,CoverageLevelCode,LateEnrollment,EnrollmentSignatureDate,MaintenanceEffective,BenefitBegin,BenefitEnd,PremiumAmount,EmployeePremiumAmount,EmployerPremiumAmount,AmountRequested,AmountApproved,NamePrefix,";
    $counter = 1;
    while($counter < 6){
        $headerStr .= "BeneficiaryLastName ({$counter}),BeneficiaryFirstName ({$counter}),IdentificationNumber ({$counter}),BeneficiaryAddressLine1 ({$counter}),BeneficiaryCity ({$counter}),BeneficiaryProvinceOrStateCode ({$counter}),BeneficiaryPostalOrZipCode ({$counter}),BeneficiaryPhoneDirect ({$counter}),BeneficiaryDateOfBirth ({$counter}),BeneficiaryPercentage ({$counter}),BeneficiaryRelationshipCode ({$counter}),BeneficiaryType ({$counter}),";
        $counter++;
    }
    $headerStr .= "DreadDisease_MM_CO,AAW_MM_CO,Tobacco_MM_CO,MM_FATCA_CO,DIVIDEND_OPTION,AUTOMATIC_PREMIUM_LOAN,GroupName";
    $headers = array_unique(explode(',', $headerStr));
    return $headers;
}

function getColumn($data)
{
    $insuredMember = (array)$data->InsuredMember;
    $subscriberIdentifier = (array)$data->SubscriberIdentifier;
    $supplementalIdentifiers = (array)$data->SupplementalIdentifiers;
    $memberLevelDates = (array)$data->MemberLevelDates;
    $member = (array)$data->MemberDetail->Person->children('http://www.softcare.com/HIPAA/SC/0203');
    $identification = (array)$data->MemberDetail->Identification;
    $contactInfo = (array)$data->MemberDetail->ContactInformation->children('http://www.softcare.com/HIPAA/SC/0203');
    $contactDirectPhone = (array)$contactInfo['PhoneNumber'];
    $memberAddress = (array)$data->MemberDetail->Address->children('http://www.softcare.com/HIPAA/SC/0203');
    $demographicInformation = (array)$data->MemberDetail->DemographicInformation;
    $jobTitle = (array)$data->MemberDetail->JobTitle;
    $paymentInformation = (array)$data->MemberDetail->PaymentInformation->BillingAddress->children('http://www.softcare.com/HIPAA/SC/0203');
    $memberIncome = (array)$data->MemberDetail->MemberIncome;
    $memberHealthInformation = (array)$data->MemberDetail->MemberHealthInformation;
    $organization = (array)$data->Employer->Organization->children('http://www.softcare.com/HIPAA/SC/0203');
    $empIdentification = (array)$data->Employer->Identification;
    $employerContactInformation = (array)$data->Employer->EmployerContactInformation->children('http://www.softcare.com/HIPAA/SC/0203')->PhoneNumber;
    $empAddress = (array)$data->Employer->Address->children('http://www.softcare.com/HIPAA/SC/0203');
    $healthCoverage = (array)$data->HealthCoverageDetail->HealthCoverage;
    $healthCoverageAttr = (array)$data->HealthCoverageDetail->HealthCoverage->attributes();
    $healthCoverageAttr = $healthCoverageAttr['@attributes'];
    $coverageDates = (array)$data->HealthCoverageDetail->CoverageDates;
    $coverageAmounts = (array)$data->HealthCoverageDetail->CoverageAmounts;
    $coverageProvider = (array)$data->HealthCoverageDetail->CoverageProvider->PrimaryCareProvider->Person->children('http://www.softcare.com/HIPAA/SC/0203');
    $beneficiaryArray = (array) $data->HealthCoverageDetail->BeneficiaryDetail;
    $beneficiaryColumns = manageBenefiaryArray($beneficiaryArray);
    $surveyResponses = (array)$data->HealthCoverageDetail->SurveyResponses;
    $reportingCategory = (array)$data->ReportingCategory;
    $groupName = (array)$reportingCategory['Categories'];
    $groupName = $groupName['GroupName'];

    $column = [
        'RelationshipCode' => $insuredMember['RelationshipCode'],
        'MaintenanceTypeCode' => $insuredMember['MaintenanceTypeCode'],
        'MaintenanceReasonCode' => $insuredMember['MaintenanceReasonCode'],
        'BenefitStatusCode' => $insuredMember['BenefitStatusCode'],
        'EmploymentStatusCode' => $insuredMember['EmploymentStatusCode'],
        'StudentStatusCode' => $insuredMember['StudentStatusCode'],
        'IsHandicapped' => '',
        'IsSubscriber' => '',
        'SubscriberIdentifier' => $subscriberIdentifier[0],
        'CustomField1' => $supplementalIdentifiers['CustomField1'],
        'CustomField2' => $supplementalIdentifiers['CustomField2'],
        'EmployerGroupField1' => $supplementalIdentifiers['EmployerGroupField1'],
        'MemberLevelDatesMaintenanceEffective' => $memberLevelDates['MaintenanceEffective'],
        'EmploymentBegin' => $memberLevelDates['EmploymentBegin'],
        'LastName' => $member['LastName'],
        'FirstName' => $member['FirstName'],
        'MiddleName' => $member['MiddleName'],
        'SSN' => $identification['SSN'],
        'MutuallyDefined' => $identification['MutuallyDefined'],
        'PhoneNumberDirect' => $contactDirectPhone['Direct'],
        'PhoneNumberCellPhone' => $contactInfo['CellPhone'],
        'EmailAddress' => $contactInfo['EmailAddress'],
        'WorkPhone' => $contactInfo['WorkPhone'],
        'AddressLine1' => $memberAddress['AddressLine1'],
        'City' => $memberAddress['City'],
        'ProvinceOrStateCode' => $memberAddress['ProvinceOrStateCode'],
        'PostalOrZipCode' => $memberAddress['PostalOrZipCode'],
        'DateOfBirth' => $demographicInformation['DateOfBirth'],
        'GenderCode' => $demographicInformation['GenderCode'],
        'MaritalStatusCode' => $demographicInformation['MaritalStatusCode'],
        'JobTitle' => $jobTitle[0],
        'FrequencyCode' => $memberIncome['FrequencyCode'],
        'MonetaryAmount' => $memberIncome['MonetaryAmount'],
        'Quantity' => $memberIncome['Quantity'],
        'SalaryEffectiveDate' => $memberIncome['SalaryEffectiveDate'],
        'HealthCode' => $memberHealthInformation['HealthCode'],
        'OrganizationName' => $organization['OrganizationName'],
        'EmployerID' => $empIdentification['EmployerID'],
        'EmployerPhoneNumberDirect' => $employerContactInformation['Direct'],
        'EmployerAddressLine1' => $empAddress['AddressLine1'],
        'EmployerCity' => $empAddress['City'],
        'EmployerProvinceOrStateCode' => $empAddress['ProvinceOrStateCode'],
        'EmployerPostalOrZipCode' => $empAddress['PostalOrZipCode'],
        'HealthCoverageMaintenanceTypeCode' => $healthCoverage['MaintenanceTypeCode'],
        'InsuranceLineCode' => $healthCoverage['InsuranceLineCode'],
        'PlanCoverageDescription' => $healthCoverage['PlanCoverageDescription'],
        'PlanID' => $healthCoverage['PlanID'],
        'CoverageLevelCode' => $healthCoverage['CoverageLevelCode'],
        'LateEnrollment' => $healthCoverageAttr['lateEnrollment'],
        'EnrollmentSignatureDate' => $coverageDates['EnrollmentSignatureDate'],
        'MaintenanceEffective' => $coverageDates['MaintenanceEffective'],
        'BenefitBegin' => $coverageDates['BenefitBegin'],
        'BenefitEnd' => $coverageDates['BenefitEnd'],
        'PremiumAmount' => $coverageAmounts['PremiumAmount'],
        'EmployeePremiumAmount' => $coverageAmounts['EmployeePremiumAmount'],
        'EmployerPremiumAmount' => $coverageAmounts['EmployerPremiumAmount'],
        'AmountRequested' => $coverageAmounts['AmountRequested'],
        'AmountApproved' => $coverageAmounts['AmountApproved'],
        'NamePrefix' => $coverageProvider['NamePrefix'],
    ];

    $column = array_merge($column, $beneficiaryColumns);
    $column = array_merge($column, [
        'DreadDisease_MM_CO' => $surveyResponses['SurveyResponse'][0],
        'AAW_MM_CO' => $surveyResponses['SurveyResponse'][1],
        'Tobacco_MM_CO' => $surveyResponses['SurveyResponse'][2],
        'MM_FATCA_CO' => $surveyResponses['SurveyResponse'][3],
        'DIVIDEND_OPTION' => $surveyResponses['SurveyResponse'][4],
        'AUTOMATIC_PREMIUM_LOAN' => $surveyResponses['SurveyResponse'][5],
        'GroupName' => $groupName
    ]);
    return $column;
}


function manageBenefiaryArray($beneficiaryArray)
{

    $beneficiaryColumns = [];
    $counter = 0;
    while($counter < 5)
    {
        $keyCounter = $counter + 1;
        if(gettype($beneficiaryArray['Beneficiary'])=="object" && $counter==0)
        {
            $beneficiary = (array)$beneficiaryArray['Beneficiary'][$counter]->Person;
            $beneficiaryIdentification = (array)$beneficiaryArray['Beneficiary'][$counter]->IdentificationNumber;

            $beneficiaryAddress = (array) $beneficiaryArray['Beneficiary'][$counter]->Address;
            if (!$beneficiaryAddress && sizeof($beneficiaryAddress) > 0){
                $beneficiaryAddress = (array)$beneficiaryArray['Beneficiary'][$counter]->Address->children('http://www.softcare.com/HIPAA/SC/0203');
            }
            $beneficiaryDateOfBirth = (array)$beneficiaryArray['Beneficiary'][$counter]->DateOfBirth;
            $beneficiaryPhoneDirect = (array)$beneficiaryArray['Beneficiary'][$counter]->ContactInformation;
            $beneficiaryAttr = (array)$beneficiaryArray['Beneficiary'][$counter]->attributes();
            $beneficiaryAttr = $beneficiaryAttr['@attributes'];
            $beneficiaryColumns = array_merge($beneficiaryColumns, [
                'BeneficiaryLastName (1)' => $beneficiary['LastName'],
                'BeneficiaryFirstName (1)' => $beneficiary['FirstName'],
                'IdentificationNumber (1)' => $beneficiaryIdentification[0],
                'BeneficiaryAddressLine1 (1)' => $beneficiaryAddress['AddressLine1'],
                'BeneficiaryCity (1)' => $beneficiaryAddress['City'],
                'BeneficiaryProvinceOrStateCode (1)' => $beneficiaryAddress['ProvinceOrStateCode'],
                'BeneficiaryPostalOrZipCode (1)' => $beneficiaryAddress['PostalOrZipCode'],
                'BeneficiaryPhoneDirect (1)' => $beneficiaryPhoneDirect['Direct'],
                'BeneficiaryDateOfBirth (1)' => $beneficiaryDateOfBirth['0'],
                'BeneficiaryPercentage (1)' => $beneficiaryAttr['percentage'],
                'BeneficiaryRelationshipCode (1)' => $beneficiaryAttr['relationshipCode'],
                'BeneficiaryType (1)' => $beneficiaryAttr['type'],
            ]);
        }
        elseif(gettype($beneficiaryArray['Beneficiary'])=="array" && sizeof($beneficiaryArray['Beneficiary']) > $counter)
        {
            $beneficiary = (array)$beneficiaryArray['Beneficiary'][$counter]->Person;
            $beneficiaryIdentification = (array)$beneficiaryArray['Beneficiary'][$counter]->IdentificationNumber;

            $beneficiaryAddress = (array) $beneficiaryArray['Beneficiary'][$counter]->Address;
            if (!$beneficiaryAddress && sizeof($beneficiaryAddress) > 0){
                $beneficiaryAddress = (array)$beneficiaryArray['Beneficiary'][$counter]->Address->children('http://www.softcare.com/HIPAA/SC/0203');
            }
            $beneficiaryDateOfBirth = (array)$beneficiaryArray['Beneficiary'][$counter]->DateOfBirth;
            $beneficiaryPhoneDirect = (array)$beneficiaryArray['Beneficiary'][$counter]->ContactInformation;
            $beneficiaryAttr = (array)$beneficiaryArray['Beneficiary'][$counter]->attributes();
            $beneficiaryAttr = $beneficiaryAttr['@attributes'];
            $beneficiaryColumns = array_merge($beneficiaryColumns, [
                'BeneficiaryLastName ('.$keyCounter.')' => $beneficiary['LastName'],
                'BeneficiaryFirstName ('.$keyCounter.')' => $beneficiary['FirstName'],
                'IdentificationNumber ('.$keyCounter.')' => $beneficiaryIdentification[0],
                'BeneficiaryAddressLine1 ('.$keyCounter.')' => $beneficiaryAddress['AddressLine1'],
                'BeneficiaryCity ('.$keyCounter.')' => $beneficiaryAddress['City'],
                'BeneficiaryProvinceOrStateCode ('.$keyCounter.')' => $beneficiaryAddress['ProvinceOrStateCode'],
                'BeneficiaryPostalOrZipCode ('.$keyCounter.')' => $beneficiaryAddress['PostalOrZipCode'],
                'BeneficiaryPhoneDirect ('.$keyCounter.')' => $beneficiaryPhoneDirect['Direct'],
                'BeneficiaryDateOfBirth ('.$keyCounter.')' => $beneficiaryDateOfBirth['0'],
                'BeneficiaryPercentage ('.$keyCounter.')' => $beneficiaryAttr['percentage'],
                'BeneficiaryRelationshipCode ('.$keyCounter.')' => $beneficiaryAttr['relationshipCode'],
                'BeneficiaryType ('.$keyCounter.')' => $beneficiaryAttr['type'],
            ]);
        }
        else{
            $beneficiaryColumns = array_merge($beneficiaryColumns, [
                'BeneficiaryLastName ('.$keyCounter.')' => null,
                'BeneficiaryFirstName ('.$keyCounter.')' => null,
                'IdentificationNumber ('.$keyCounter.')' => null,
                'BeneficiaryAddressLine1 ('.$keyCounter.')' => null,
                'BeneficiaryCity ('.$keyCounter.')' => null,
                'BeneficiaryProvinceOrStateCode ('.$keyCounter.')' => null,
                'BeneficiaryPostalOrZipCode ('.$keyCounter.')' => null,
                'BeneficiaryPhoneDirect ('.$keyCounter.')' => null,
                'BeneficiaryDateOfBirth ('.$keyCounter.')' => null,
                'BeneficiaryPercentage ('.$keyCounter.')' => null,
                'BeneficiaryRelationshipCode ('.$keyCounter.')' => null,
                'BeneficiaryType ('.$keyCounter.')' => null,
            ]);
        }
        $counter++;
    }
    return $beneficiaryColumns;
}


$fileOpen = fopen("../XML/{$argv[1]}", 'r');
$rowData = fread($fileOpen, filesize("../XML/{$argv[1]}"));
fclose($fileOpen);
$xml = simplexml_load_string($rowData, NULL, NULL, "http://www.softcare.com/HIPAA/SC/Enrollment/0301");
header('Content-Type: application/excel');
header("Content-Disposition: attachment; filename=\"../reports/massMutualBeneficiaries_{$argv[2]}_{$argv[3]}_{$argv[4]}.txt\"");
$csv = fopen("../reports/massMutualBeneficiaries_{$argv[2]}_{$argv[3]}_{$argv[4]}.txt", 'w');
$headers = getHeaders();
fwrite($csv,implode("\t",$headers)."\n");
//fputcsv($csv, $headers, "\t", '"');
foreach ($xml->Enrollment->Detail as $details) {
    $column = @getColumn($details->MemberLevelDetail);
    fwrite($csv,implode("\t",$column)."\n");
    //fputcsv($csv, $column, "\t", '"');
}
fclose($csv);
?>



