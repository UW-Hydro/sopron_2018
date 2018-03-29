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
git clone -b develop git://github.com/NCAR/summa.git

# Download the Miniconda installer for the python environment
curl -O -L https://repo.continuum.io/miniconda/Miniconda3-latest-Linux-x86_64.sh

# install miniconda
/bin/bash Miniconda3-latest-Linux-x86_64.sh -b

# add the miniconda3 path to your .bashrc and source the ~/.bashrc
cat << EOF >> ~/.bashrc
export PATH="${HOME}:$PATH"
EOF
source ${HOME}/.bashrc

# create the pysumma environment
conda env create -f ${HOME}/sopron_2018/setup/pysumma_env.yml

# compile SUMMA

# swap the default intel compiler for gfortran
module swap intel gnu/6.1.0

# load the lapack libraries
module load lapack

# Make SUMMA
cd ${HOME}/summa
make -f sopron_2018/setup/Makefile-geyser
cd ${HOME}

# add the summa/bin directory to the path and source the ~/.bashrc again
cat << EOF >> ${HOME}/.bashrc
export PATH="${HOME}/summa/bin:$PATH"
EOF
