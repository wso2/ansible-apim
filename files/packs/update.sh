#!/bin/bash
# ----------------------------------------------------------------------------
#
# Copyright (c) 2019, WSO2 Inc. (http://www.wso2.org) All Rights Reserved.
#
# WSO2 Inc. licenses this file to you under the Apache License,
# Version 2.0 (the "License"); you may not use this file except
# in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing,
# software distributed under the License is distributed on an
# "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
# KIND, either express or implied.  See the License for the
# specific language governing permissions and limitations
# under the License.
#
# ----------------------------------------------------------------------------

set -e

# Build artifacts and versions
: ${version:="2.6.0"}
: ${cwd:=$(pwd)}

usage() { echo "Usage: $0 -p <profile_name>" 1>&2; exit 1; }

unzip_pack() {
    if [[ -d ${cwd}/${1} ]]
    then
        echo "The current directory contains a directory ${1}. Please move the directory to another location."
    fi
    echo "Unzipping ${1}.zip..."
    unzip -q ${cwd}/${1}.zip
}

update_pack() {
    if ! [ -x "$(command -v zip)" ]; then
        echo 'Error: zip is not installed.' >&2
        rm -rf ${cwd}/${1}
        exit 1
    fi
    rm ${cwd}/${1}.zip
    cd ${cwd}
    echo "Repackaging ${1}..."
    zip -qr ${1}.zip ${1}
    rm -rf ${1}
}

while getopts ":p:" o; do
    case "${o}" in
        p)
            profile=${OPTARG}
            ;;
        *)
            usage
            ;;
    esac
done
shift $((OPTIND-1))

if [[ -z "${profile}" ]]; then
    usage
fi

# Set variables relevant to each profile
case "${profile}" in
    apim-analytics-dashboard)
        pack="wso2am-analytics-"${version}
        ;;
    apim-analytics-worker)
        pack="wso2am-analytics-"${version}
        ;;
    apim)
        pack="wso2am-"${version}
        ;;
    apim-ex-gateway)
        pack="wso2am-"${version}
        ;;
    apim-gateway)
        pack="wso2am-"${version}
        ;;
    apim-km)
        pack="wso2am-"${version}
        ;;
    apim-publisher)
        pack="wso2am-"${version}
        ;;
    apim-store)
        pack="wso2am-"${version}
        ;;
    apim-tm)
        pack="wso2am-"${version}
        ;;
    apim-is-as-km)
        pack="wso2is-km-5.7.0"
        ;;
    *)
        echo "Invalid profile. Please provide one of the following profiles:
            apim
            apim-ex-gateway
            apim-gateway
            apim-km
            apim-publisher
            apim-store
            apim-tm
            apim-analytics-dashboard
            apim-analytics-worker
            apim-is-as-km"
        exit 1
        ;;
esac

carbon_home=${cwd}/${pack}

# Create updates directory if it doesn't exist
updates_dir=${cwd}/updates/${pack}
if [[ ! -d ${updates_dir} ]]
then
  mkdir -p ${updates_dir}
fi

# Getting update status
# 0 - first/last update successful
# 1 - Error occurred in last update
# 2 - In-place has been updated
# 3 - conflicts encountered in last update
status=0
if [[ -f ${updates_dir}/status ]]
then
  status=$(cat ${updates_dir}/status)
fi

# Check if user has a WSO2 subscription
while :
do
  read -p "Do you have a WSO2 subscription? (Y/n) "
  echo
  if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z "$REPLY" ]]
  then
    # The pack should not be unzipped if a conflict is being resolved
    if [[ ${status} -ne 3 ]]
    then
        unzip_pack ${pack}
    fi

    if [[ ! -f ${carbon_home}/bin/update_linux ]]
    then
      echo "Update executable not found. Please download package for subscription users from website."
      echo "Don't have a subscription yet? Sign up for a free-trial subscription at https://wso2.com/subscription/free-trial"
      rm -rf ${cwd}/${pack}
      exit 1
    else
      break
    fi
  elif [[ $REPLY =~ ^[Nn]$ ]]
  then
    echo "Don't have a subscription yet? Sign up for a free-trial subscription at https://wso2.com/subscription/free-trial"
    exit 0
  else
    echo "Invalid input provided."
    sleep .5
  fi
done

# Move into binaries directory
cd ${carbon_home}/bin

# Run in-place update
if [[ ${status} -eq 0 ]] || [[ ${status} -eq 1 ]] || [[ ${status} -eq 2 ]]
then
  ./update_linux --verbose 2>&1 | tee ${updates_dir}/output.txt
  update_status=${PIPESTATUS[0]}
elif [[ ${status} -eq 3 ]]
then
  ./update_linux --verbose --continue 2>&1 | tee ${updates_dir}/output.txt
  update_status=${PIPESTATUS[0]}

  # Handle user running update script without resolving conflicts
  if [[ ${update_status} -eq 1 ]]
  then
    echo "Error occurred while attempting to resolve conflicts."
    rm -rf ${cwd}/${pack}
    exit 1
  fi
else
  echo "status file is invalid. Please delete or clear file content."
  rm -rf ${cwd}/${pack}
  exit 1
fi

# Handle the In-place tool being updated
if [[ ${update_status} -eq 2 ]]
then
    echo "In-place tool has been updated. Running update again."
    ./update_linux --verbose 2>&1 | tee ${updates_dir}/output.txt
    update_status=${PIPESTATUS[0]}
fi

# Update status
echo ${update_status} > ${updates_dir}/status
if [[ ${update_status} -eq 0 ]]
then
  echo
  echo "Update completed successfully."
  update_pack ${pack}
elif [[ ${update_status} -eq 3 ]]
then
  echo "Conflicts encountered. Please resolve conflicts in ${cwd}/${pack} and run the update script again."
else
  echo "Update error occurred. Stopped with exit code ${update_status}"
  rm -rf ${cwd}/${pack}
  exit ${update_status}
fi

# Get list of merged files
if [[ ${update_status} -eq 0 ]] # If update is successful
then
  sed -n '/Merge successful for the following files./,/Successfully completed merging files/p' ${updates_dir}/output.txt > ${updates_dir}/merged_files.txt
elif [[ ${update_status} -eq 3 ]] # If conflicts were encountered during update
then
  sed -n '/Merge successful for the following files./,/Merging/p' ${updates_dir}/output.txt > ${updates_dir}/merged_files.txt
fi

if [[ -s ${updates_dir}/merged_files.txt ]]
then
  sed -i '1d' ${updates_dir}/merged_files.txt # Remove first line from file
  sed -i '$ d' ${updates_dir}/merged_files.txt # Remove last line from file

  while read -r line; do
    filepath=${line##*${pack}/}
    template_file=${cwd}/../../roles/${profile}/templates/carbon-home/${filepath}.j2
    if [[ -f ${template_file} ]]
    then
      updated_templates+=(${template_file##*${cwd}/../../})
    fi
  done < ${updates_dir}/merged_files.txt

  # Display template files to be changed
  if [[ -n ${updated_templates} ]]
  then
    DATE=`date +%Y-%m-%d`
    update_file_name="update_${DATE}.log"
    echo
    echo "Update has made changes to the following files. Please update the templates accordingly before pushing." | tee -a ${updates_dir}/${update_file_name}
    printf '%s\n' "${updated_templates[@]}" | tee -a ${updates_dir}/${update_file_name}
  fi
fi
