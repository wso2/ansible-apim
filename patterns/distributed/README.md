# WSO2 API Management Ansible scripts

This repository contains the Ansible scripts for installing and configuring WSO2 API Management.

## Supported Operating Systems

- Ubuntu 16.04 or higher
- CentOS 7

## Supported Ansible Versions

- Ansible 2.5 or higher

## Directory Structure
```
.
├── dev
│   ├── group_vars
│   │   └──apim.yml
│   ├── host_vars
│   │   ├── apim-control-plane_1.yml
│   │   ├── apim-gateway_1.yml
│   │   └── apim-tm_1.yml
│   └── inventory
├── files
│   ├── lib
│   │   ├── amazon-corretto-17.0.6.10.1-linux-x64.tar.gz
│   │   └── mysql-connector-j-8.0.31.jar
│   └── packs
│   │   └── wso2am-4.2.0.zip
│   ├── system
│   │   └── etc
│   │       ├── security
│   │       │   └── limits.conf
│   │       └── sysctl.conf
│   └── misc
├── README.md
├── roles
│   ├── apim
│   │   ├── tasks
│   │   └── templates
│   ├── apim-control-plane
│   │   ├── tasks
│   │   └── templates
│   ├── apim-tm
│   │   ├── tasks
│   │   └── templates
│   └── common
│       └── tasks
├── scripts
│   ├── update.sh
│   └── update_README.md
└── site.yml

```

Following instructions can be followed to deploy a distributed APIM deployment pattern.


## Copying packs locally
Packs could be either copied to a local directory, or downloaded from a remote location.

Copy the following files to `files/packs` directory.

1. [WSO2 API Manager 4.2.0 package](https://wso2.com/api-management/install/)

Copy the following files to `files/lib` directory.

2. [Amazon Corretto for Linux x64 JDK](https://docs.aws.amazon.com/corretto/latest/corretto-17-ug/downloads-list.html)

Copy the miscellaneous files to `files/misc` directory. To enable file copying,  uncomment the `misc_file_list` in the yaml files under `group_vars` and add the miscellaneous files to the list.

## Downloading from remote location

In **group_vars**, change the values of the following variables in all groups:
1. The value of `pack_location` should be changed from "local" to "remote"
2. The value of `remote_jdk` should be changed to the URL in which the JDK should be downloaded from, and remove it as a comment.
3. The value of `remote_pack` should be changed to the URL in which the package should be downloaded from, and remove it as a comment.

## Running Ansible scripts
1. Configure an Ansible setup with three hosts.
2. Replace `ansible_host` and `ansible_user` configurations given in `dev/inventory` file according to your Ansible hosts. An example is given below.

```
[apim]
apim-tm_1               ansible_host=tm.apim.com     ansible_user=ubuntu
apim-gateway_1          ansible_host=gw.apim.com     ansible_user=ubuntu
apim-control-plane_1    ansible_host=cp.apim.com     ansible_user=ubuntu
```

3. Download the relevant JDBC driver into `files/lib` directory.
4. Open `dev/host_vars/apim.yaml` and update the following configurations.
  - Change the hostnames according to you Ansible hosts.
  - Change the DB configurations.
  - Change the JDBC driver name.

5. Run the following command to execute playbook.

`ansible-playbook -i dev site.yml`

If you need to alter the configurations given, please change the parameterized values in the yaml files under `group_vars` and `host_vars`.

**NOTE:**
> If you have mounted the 'persistent artifacts' as guided [below](##configuration-guide), make sure to unmount the artifacts, prior to running the Ansible playbook as the playbook running process has a step to remove the existing setup. After completing the Ansible playbook running process, make sure to remount the artifacts.

> If the `client-truststore.jks` is monuted among the Gateway nodes, then make sure to copy the `client-truststore.jks` from the mount source to the `<ANSIBLE_HOME>/files/security/wso2am/` directory of the Ansible resources, prior to re-running the playbook.

### 2. Customize the WSO2 Ansible scripts

The templates that are used by the Ansible scripts are in j2 format in-order to enable parameterization.

The `deployment.toml.j2` file is added under `roles/apim-<profile>/templates/carbon-home/repository/conf/`, in order to enable customizations. You can add any other customizations to `custom.yml` under tasks of each role as well.

#### Step 1
Uncomment the following line in `main.yml` under the role you want to customize.
```
- import_tasks: custom.yml
```

#### Step 2
Add the configurations to the `custom.yml`. A sample is given below.

```
- name: "Copy custom file"
  template:
    src: path/to/example/file/example.xml.j2
    dest: destination/example.xml.j2
  when: "(inventory_hostname in groups['am'])"
```

Follow the steps mentioned under `docs` directory to customize/create new Ansible scripts and deploy the recommended patterns.

#### Including custom Keystore and Truststore
If custom keystores and truststores are needed to be added, uncomment the below list in the yml file
```
# security_file_list:
#   - { src: '{{ security_file_location }}/wso2am-analytics/client-truststore.jks',
#       dest: '{{ carbon_home }}/resources/security/client-truststore.jks' }
#   - { src: '{{ security_file_location }}/wso2am-analytics/wso2carbon.jks',
#       dest: '{{ carbon_home }}/resources/security/wso2carbon.jks' }
```
Then save the changed file and add the required files under `files/security/<product-home>/<path-to-file>`

## Performance Tuning

System configurations can be changed through Ansible to optimize OS level performance. Performance tuning can be enabled by changing `enable_performance_tuning` in `dev/group_vars/apim.yml` to `true`.

System files that will be updated when performance tuning are enabled is available in `files/system`. Update the configuration values according to the requirements of your deployment.

## Configuration Guide

Refer the below documentation on configuring key-stores for APIM and APIM-Analytics
1. [WSO2 API Manager key-stores configuration guide](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/security/configuring-keystores/configuring-keystores-in-wso2-api-manager/)

Refer the below documentation on configuring persistent artifacts of the servers.
1. [Persistent artifacts of the servers](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/reference/common-runtime-and-configuration-artifacts/)

Refer the below documentation on configuring Load-Balancers for your deoloyment.
1. [Load balancer configurations](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/setting-up-proxy-server-and-the-load-balancer/configuring-the-proxy-server-and-the-load-balancer/)

