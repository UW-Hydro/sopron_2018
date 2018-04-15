#!/bin/bash

# The script only needs to be run the very first time that you are setting up
# on geyser. It clones a number of github repositories, sets up the
# python environment needed for summa and takes about 10 minutes to run to
# completion. Once your environment is setup, you do not need to run this
# again

if [[ $HOSTNAME != *"geyser"* ]];
then
  echo "You need to execute this script on geyser."
  echo "Start an interactive session on geyser by typing: execgy"
  echo "Then rerun this script."
  exit ;
fi

# Change to the home directory
cd ${HOME}

# Check whether this script really needs to be run. Since it takes a while, it
# should not be run unnecessarily

if [[ -e miniconda3 && -e summa && -e sopron_2018 ]];
then
  echo "It looks like miniconda3, summa and sopron_2018 are already installed,"
  echo "so perhaps you do not need to run this script again (it takes a while)."
  echo "If you do want to run it again, please rename or delete the miniconda3,"
  echo "summa and sopron_2018 directories first."
  echo ""
  echo "The script will create the following directories"
  echo "./"
  echo "  miniconda3/"
  echo "  sopron_2018/"
  echo "  summa/"
  exit
fi

# Load the git module
module load git/2.10.0

# Get the workshop notebooks and setup files
git clone git://github.com/UW-Hydro/sopron_2018.git

# Get the SUMMA source code and use the default branch as the default
git clone -b sopron_2018 git://github.com/NCAR/summa.git

# compile SUMMA

# swap the default intel compiler for gfortran
module swap intel gnu/6.1.0

# load the lapack libraries
module load lapack

# Make SUMMA
cd ${HOME}/summa
make -f ${HOME}/sopron_2018/setup/Makefile-geyser
cd ${HOME}

# Download the Miniconda installer for the python environment
curl -O -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

# install miniconda
/bin/bash Miniconda3-latest-Linux-x86_64.sh -b

# create the pysumma environment
${HOME}/miniconda3/bin/conda env create -f ${HOME}/sopron_2018/setup/pysumma_env.yml

# pre-load the correct modules on geyser
# add the summa, sopron_2018, and miniconda3 path to your .bashrc and
if [[ ! -f ${HOME}/.bashrc ]];
then
  touch ${HOME}/.bashrc
fi

cat << EOF >> ~/.bashrc
if [[ \${HOSTNAME} = *"geyser"* ]];
then
  module swap intel gnu/6.1.0
  module load lapack
fi
export PATH="\${HOME}/summa/bin:\${HOME}/sopron_2018/setup:\${HOME}/miniconda3/bin:\$PATH"
EOF

# Set the prompt to something useful
cat << EOF >> ~/.bashrc
export PS1='\[\u@\h:\w> '
EOF

# Tell the user to source their bashrc
echo ""
echo "Installation succesfull - now type "
echo ""
echo "source ~/.bashrc"
echo ""
echo "Followed by"
echo ""
echo "source activate pysumma"
echo ""
