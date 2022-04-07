# Customize WSO2 Ansible resources to deploy API Manager Pattern 2

This document provides instructions to customize the WSO2 API Manager Ansible resources in order to deploy API Manager Pattern 2.

![API Manager Pattern 2](images/Pattern-2.png "API Manager Pattern 2")

# Setting up Java
The Ansible scripts are capable of installing java from a given JDK installer from the local file system or from the remote location. Java installation can be disabled if necessary from the `group_vars`.

Copy the following files to `files/lib` directory.

1. [Amazon Corretto JDK 11 for Linux x64 (.tar.gz)](https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/downloads-list.html)

## Adding miscellaneous files
If additional files needs to be added to the VMs, copy the miscellaneous files to `files/misc` directory. To enable file copying,  uncomment the `misc_file_list` in the yaml files under `group_vars` and add the miscellaneous files to the list.

## Packs to be Copied

Copy the following files to `files/packs` directory.

1. [WSO2 API Manager 4.1.0 package (.zip)](https://wso2.com/api-management/install/)
2. [WSO2 Micro Integrator 4.1.0 package (.zip)](https://github.com/wso2/micro-integrator/releases/tag/v4.1.0)

## Database configurations

In a production environment we recommend using an external database to store WSO2 application data. Follow the below steps to configure the database.

1. Copy the relevant JDBC driver needed into `files/lib` directory.
   e.g : [MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/5.1.html)
2. Update the database configurations in all the files under [group_vars](../dev/group_vars). In the files update `Datasource configurations section` and the `jdbc_driver` parameter.

## Customize the WSO2 Ansible scripts

The followings are the roles needed to deploy API Manager pattern 2.
- apim
- micro-integrator

### 1. Customize the [inventory](../dev/inventory) file

#### Replace the inventory file content with the followings.

```
[apim]
apim_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim_2 ansible_host=[ip_address] ansible_user=[ssh_user]

[micro-integrator]
micro-integrator_1 ansible_host=[ip_address] ansible_user=[ssh_user]
micro-integrator_2 ansible_host=[ip_address] ansible_user=[ssh_user]
micro-integrator_3 ansible_host=[ip_address] ansible_user=[ssh_user]
micro-integrator_4 ansible_host=[ip_address] ansible_user=[ssh_user]
```
> NOTE: Replace `[ip_address]` and `[ssh_user]` appropriately.

### 2. Modify the [site.yml](../site.yml) file

```
---
# This playbook deploys the whole application stack in this site.

- name: Apply common configuration to all nodes
  hosts: all
  roles:
    - common

- name: Apply API Manager configuration to apim nodes
  hosts:
    - apim_1
    - apim_2
  roles:
    - apim
    
- name: Apply Micro Integrator configuration to MI nodes
  hosts:
    - micro-integrator_1
    - micro-integrator_2
    - micro-integrator_3
    - micro-integrator_4
  roles:
    - micro-integrator
```

### 3. Customize the roles for API Manager pattern 2

```
.
└── dev
    ├── group_vars
    │   ├──  apim.yml
    │   ├──  micro-integrator.yml
    ├── host_vars
    │   ├── apim_1.yml
    │   ├── apim_2.yml
    │   ├── micro-integrator_1.yml
    │   ├── micro-integrator_2.yml
    │   ├── micro-integrator_3.yml
    │   ├── micro-integrator_4.yml
    └── inventory

```
API Manager pattern 2 contains 2 groups and the configurations specific for each group should be in the respective yaml file under [group_vars](../dev/group_vars) folder. Configurations specific to each host should be added to the corresponding yaml file under [host_vars](../dev/host_vars) folder.

Most commonly changed values are parameterized in the above files. If further changes are required, the values should be parameterized and added to the files accordingly.

#### i. Customize `apim` role

Navigate to [carbon-home](../roles/apim/templates/carbon-home) of the `apim` role. All the files required to deploy the API Manager active-active combination are here. Follow the instructions in the following documents to modify the files.
- [Configuring an active-active deployment](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/single-node/configuring-an-active-active-deployment/)

#### ii. Customize `micro-integrator` role

Navigate to [carbon-home](../roles/micro-integrator/templates/carbon-home) of the `micro-integrator` role. All the files required to deploy the Micro Integrator are here. Follow the instructions in the following document to modify the files.
- [Configuring Micro Integrator deployment](https://apim.docs.wso2.com/en/latest/reference/config-catalog-mi/)

### 4. Further customization

Uncomment the following line in `main.yml` under the role you want to customize and add the necessary changes.
```
- import_tasks: custom.yml
```
