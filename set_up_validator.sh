#! /bin/sh -e

#### Install Programs Needed for Validator to Work ####

#### Paths ####

home=/Users/$USER/Desktop/XML_Validator
scripts=${home}/scripts
exe_files=${scripts}/exe_files

#### copy files to user bin ####

#sudo cp ${exe_files}/* /usr/local/bin

if [ ! -f /usr/local/bin/filter ]; then

sudo cp ${exe_files}/* /usr/bin/

fi

wait

if [ ! -f /usr/local/bin/brew ]; then

ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

fi

wait

brew update

wait

brew doctor

wait

if [ ! -f /usr/local/bin/xml2 ]; then

brew install xml2

fi

sudo easy_install pip

#set up packages

sudo pip install numpy
sudo pip install pandas
sudo pip install openpyxl
sudo pip install lxml

brew doctor