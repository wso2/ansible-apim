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
: ${version:="3.2.0"}
: ${packs_dir:=$(pwd)/../files/packs}

usage() { echo "Usage: $0 -p <profile_name>" 1>&2; exit 1; }

unzip_pack() {
    if [[ -d ${packs_dir}/${1} ]]
    then
        echo "The current directory contains a directory ${1}. Please move the directory to another location."
    fi
    echo "Unzipping ${1}.zip..."
    unzip -q ${packs_dir}/${1}.zip
}

update_pack() {
    if ! [ -x "$(command -v zip)" ]; then
        echo 'Error: zip is not installed.' >&2
        rm -rf ${packs_dir}/${1}
        exit 1
    fi
    rm ${packs_dir}/${1}.zip
    cd ${packs_dir}
    echo "Repackaging ${1}..."
    zip -qr ${1}.zip ${1}
    rm -rf ${1}
}

print_conflicts() {
    conflict_files=$(sed -n '/^Modified/p' ${updates_dir}/output.txt | sed -e 's/.*Conflicts: \[\(.*\)].*/\1/' )

    if [[ ! -z "$conflict_files" ]]
    then
      IFS=' '
      read -a strarr <<< "$conflict_files"
      for filepath in "${strarr[@]}";
      do
        echo ${filepath}
      done

      echo "Conflicts are found in the above file(s). Please review the above file(s), resolve conflicts, and save with .final extension. Then re-run the update script."
    fi
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
    apim)
        pack="wso2am-"${version}
        updated_roles=("apim" "apim-gateway" "apim-km" "apim-publisher" "apim-devportal" "apim-tm")
        ;;
    apim-gateway)
        pack="wso2am-"${version}
        updated_roles=("apim" "apim-gateway" "apim-km" "apim-publisher" "apim-devportal" "apim-tm")
        ;;
    apim-km)
        pack="wso2am-"${version}
        updated_roles=("apim" "apim-gateway" "apim-km" "apim-publisher" "apim-devportal" "apim-tm")
        ;;
    apim-publisher)
        pack="wso2am-"${version}
        updated_roles=("apim" "apim-gateway" "apim-km" "apim-publisher" "apim-devportal" "apim-tm")
        ;;
    apim-devportal)
        pack="wso2am-"${version}
        updated_roles=("apim" "apim-gateway" "apim-km" "apim-publisher" "apim-devportal" "apim-tm")
        ;;
    apim-tm)
        pack="wso2am-"${version}
        updated_roles=("apim" "apim-gateway" "apim-km" "apim-publisher" "apim-devportal" "apim-tm")
        ;;
    apim-analytics)
        pack="wso2am-analytics-"${version}
        updated_roles=("apim-analytics-worker" "apim-analytics-dashboard")
        ;;
    apim-analytics-dashboard)
        pack="wso2am-analytics-"${version}
        updated_roles=("apim-analytics-worker" "apim-analytics-dashboard")
        ;;
    apim-analytics-worker)
        pack="wso2am-analytics-"${version}
        updated_roles=("apim-analytics-worker" "apim-analytics-dashboard")
        ;;
    *)
        echo "Invalid profile. Please provide one of the following profiles:
            apim
            apim-gateway
            apim-km
            apim-publisher
            apim-devportal
            apim-tm
            apim-analytics
            apim-analytics-dashboard
            apim-analytics-worker"
        exit 1
        ;;
esac

carbon_home=${packs_dir}/${pack}

# Create updates directory if it doesn't exist
updates_dir=$(pwd)/update_logs/${pack}
if [[ ! -d ${updates_dir} ]]
then
  mkdir -p ${updates_dir}
fi

# Getting update status
# 0 - first/last update successful
# 1 - Error occurred in last update
# 2 - Update tool has been updated
# 3 - conflicts encountered in last update
status=0
if [[ -f ${updates_dir}/status ]]
then
  status=$(cat ${updates_dir}/status)
fi

cd ${packs_dir}
if [[ ${status} -ne 3 ]]
  then
    unzip_pack ${pack}
fi

# Move into binaries directory
cd ${carbon_home}/bin

# Run update
echo "Running WSO2 Update tool"
if [[ ${status} -eq 0 ]] || [[ ${status} -eq 1 ]] || [[ ${status} -eq 2 ]]
then
  echo "Validating credentials"
  ./wso2update_linux --template "Modified: {{.Modified}}, Conflicts: {{.Conflicts}}" 2>&1 | tee ${updates_dir}/output.txt
  update_status=${PIPESTATUS[0]}
elif [[ ${status} -eq 3 ]]
then
  echo "Resolving conflicts"
  ./wso2update_linux --continue --template "Modified: {{.Modified}}, Conflicts: {{.Conflicts}}" 2>&1 | tee ${updates_dir}/output.txt
  update_status=${PIPESTATUS[0]}

  # Handle user running update script without resolving conflicts
  if [[ ${update_status} -eq 1 ]]
  then
    echo "Error occurred while attempting to resolve conflicts."
    rm -rf ${packs_dir}/${pack}
    exit 1
  fi
else
  echo "status file is invalid. Please delete or clear file content."
  rm -rf ${packs_dir}/${pack}
  exit 1
fi

# Handle the In-place tool being updated
if [[ ${update_status} -eq 2 ]]
then
    echo "Update tool has been updated. Running update again."
    ./wso2update_linux --template "Modified: {{.Modified}}, Conflicts: {{.Conflicts}}" 2>&1 | tee ${updates_dir}/output.txt
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
  echo ""
  echo "Conflicts encountered. Please resolve conflicts in ${packs_dir}/${pack} and run the update script again."
  print_conflicts
else
  echo "Update error occurred. Stopped with exit code ${update_status}"
  rm -rf ${packs_dir}/${pack}
  exit ${update_status}
fi

# Get list of merged files
if [[ ${update_status} -ne 1 ]] # If update is successful
then
  modified_files=$(sed -n '/^Modified/p' ${updates_dir}/output.txt | sed -e 's/.*Modified: \[\(.*\)], Conflicts.*/\1/')
fi

if [[ ! -z "$modified_files" ]]
then
# Get the list of modified files
  IFS=' '
  read -a strarr <<< "$modified_files"
  for line in "${strarr[@]}";
  do
    filepath=${line##*${pack}/}

    for role in "${updated_roles[@]}"
    do
      template_file=${packs_dir}/../../roles/${role}/templates/carbon-home/${filepath}.j2
      if [[ -f ${template_file} ]]
      then
        updated_templates+=(${template_file##*${packs_dir}/../../})
      fi
    done
  done

# Display template files to be changed
  if [[ -n ${updated_templates} ]]
  then
    DATE=`date +%Y-%m-%d`
    update_file_name="update_${DATE}.log"
    echo
    echo "Update has made changes to the following files. Please update the templates accordingly before running the next update." | tee -a ${updates_dir}/${update_file_name}
    printf '%s\n' "${updated_templates[@]}" | tee -a ${updates_dir}/${update_file_name}
  fi
fi
