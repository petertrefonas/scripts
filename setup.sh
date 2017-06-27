
#!/usr/bin/env bash


#     NEED XML_VALIDATOR FOLDER ON DESKTOP BEFORE THIS IS RUN

#Need these commands: 2csv (??), xml2 (installed), filter (custom), cut(custom? default?)

home=/Users/$USER/Desktop/XML_Validator
scripts=${home}/scripts
exe_files=${scripts}/exe_files


# Remove cached credentials
sudo -K

#Install command-line xcode
echo "------------------------------"
echo "Installing command-line Xcode."
wait
sudo xcode-select --install

wait
echo "------------------------------"
echo "Installing homebrew."

sudo ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
wait
brew update
wait
brew doctor
wait
brew install xml2
wait
echo "------------------------------"
echo "Setting up custom commands."

if [ ! -f /usr/local/bin/filter ]; then

sudo cp ${exe_files}/filter /usr/local/bin/

fi

if [ ! -f /usr/local/bin/2csv ]; then

sudo cp ${exe_files}/2csv /usr/local/bin/

fi

if [ ! -f /usr/local/bin/2html ]; then

sudo cp ${exe_files}/2html /usr/local/bin/

fi

if [ ! -f /usr/local/bin/2to3 ]; then

sudo cp ${exe_files}/2to3 /usr/local/bin/

fi

if [ ! -f /usr/local/bin/2to3-2 ]; then

sudo cp ${exe_files}/2to3-2 /usr/local/bin/

fi

if [ ! -f /usr/local/bin/2xml ]; then

sudo cp ${exe_files}/2xml /usr/local/bin/

fi

if [ ! -f /usr/local/bin/xml2 ]; then

sudo cp ${exe_files}/xml2 /usr/local/bin/

fi

if [ ! -f /usr/local/bin/xmlif ]; then

sudo cp ${exe_files}/xmlif /usr/local/bin/

fi

if [ ! -f /usr/local/bin/xmlto ]; then

sudo cp ${exe_files}/xmlto /usr/local/bin/

fi

if [ ! -f /usr/local/bin/_DS_Store ]; then

sudo cp ${exe_files}/_DS_Store /usr/local/bin/

fi


echo "------------------------------"
echo "Setting up pip."

# Install pip
sudo easy_install pip
wait
#set up packages
echo "------------------------------"
echo "Setting up pandas and dependencies."

sudo pip install numpy
wait
sudo pip install pandas
wait
sudo pip install openpyxl --upgrade
wait
sudo pip install lxml
wait


brew doctor


chmod 755 xml_validator.sh
chmod 755 oeCounter.sh
chmod 755 remove_PHI.sh

cd ~
touch .bash_profile
echo "cd desktop/xml_validator/scripts" > .bash_profile
echo "alias a=./oeCounter.sh" >> .bash_profile
echo "alias z=./xml_validator.sh" >> .bash_profile
echo "alias q=./remove_PHI.sh" >> .bash_profile

cd desktop/xml_validator/scripts


echo "------------------------------"
echo "All set"

