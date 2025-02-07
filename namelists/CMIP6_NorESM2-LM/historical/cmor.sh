#!/bin/bash

CMOR_ROOT=$(cd $(dirname $0) && cd ../../.. && pwd)
source ${CMOR_ROOT}/workflow/cmorRun1memb.sh

# initialize
login0=false
login1=false
login2=false
login3=false

# set active
login0=true
#login1=true
#login2=true
#login3=true

# initialize
#version=v20190815
#version=v20190815b
#version=v20190917
#version=v20190917b
#version=v20190920
#version=v20191108
#version=v20191108b
#version=v20200218
version=v20210119

expid=historical
model=NorESM2-LM

# --- Use input arguments if exits
if [ $# -ge 1 ] 
then
     while test $# -gt 0; do
         case "$1" in
             -m=*)
                 model=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -e=*)
                 expid=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             -v=*)
                 version=$(echo $1|sed -e 's/^[^=]*=//g')
                 shift
                 ;;
             * )
                 echo "ERROR: option $1 not allowed."
                 echo "*** EXITING THE SCRIPT"
                 exit 1
                 ;;
         esac
    done
fi
# --- 

echo "--------------------"
echo "EXPID: $expid       "
echo "--------------------"

echo "                    "
echo "START CMOR...       "
echo "$(date)             "
echo "                    "

if $login0
then
#----------------
# historical ensemble 1 part 1
#----------------
CaseName=NHIST_f19_tn14_20190625
real=1
#login0
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#----------------
# historical ensemble 1 part 2
#----------------
CaseName=NHIST_f19_tn14_20190710
real=1
#login1
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login1
then
#----------------
# historical ensemble 2 part 1
#----------------
CaseName=NHIST_02_f19_tn14_20190801
real=2
#login0
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#----------------
# historical ensemble 2 part 2
#----------------
CaseName=NHIST_02_f19_tn14_20190813
real=2
#login1
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

if $login2
then
#----------------
# historical ensemble 3 part 1
#----------------
CaseName=NHIST_03_f19_tn14_20190801
real=3
#login2
years1=(1849 $(seq 1860 10 1940))
years2=(1859 $(seq 1869 10 1949))

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#----------------
# historical ensemble 3 part 2
#----------------
CaseName=NHIST_03_f19_tn14_20190813
real=3
#login3
years1=($(seq 1950 10 2000) 2010)
years2=($(seq 1959 10 2009) 2014)

runcmor -c=$CaseName -m=$model -e=$expid -v=$version -r=$real -yrs1="${years1[*]}" -yrs2="${years2[*]}" -mpi=DMPI
#---
fi
#---

wait
echo "         "
echo "CMOR DONE"
echo "$(date)  "
echo "~~~~~~~~~"

# PrePARE QC check, create links and update sha256sum
${CMOR_ROOT}/workflow/cmorPost.sh -m=${model} -e=${expid} -v=${version} --verbose=false
