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

XML=${home}/XML

reports=${home}/reports

excel=${home}/excel_reports

complete_system_export=${home}/complete_system_export

open_enrollment=${home}/open_enrollment

integrations=${home}/integrations

pending_beneficiaries=${home}/pending_beneficiaries

#####  remove files  ####

rm -f ${excel}/*

rm -f ${XML}/*

rm -f ${reports}/*

rm -f ${complete_system_export}/*

rm -f ${open_enrollment}/*

rm -f ${integrations}/*

rm -f ${pending_beneficiaries}/*

