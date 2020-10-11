# Deploying API Manager Pattern 3

This document provides instructions required to deploy API Manager Pattern 3.

![API Manager Pattern 3](images/3-fully-distributed-setup.png "API Manager Pattern 3")

## Setting up Java
The Ansible scripts are capable of installing java from a given JDK installer from the local file system or from the remote location. Java installation can be disabled if necessary from the `group_vars`. 

Copy the following files to `files/lib` directory.

1. [Amazon Corretto for Linux x64 JDK](https://docs.aws.amazon.com/corretto/latest/corretto-8-ug/downloads-list.html)

## Adding miscellaneous files
If additional files needs to be added to the VMs, copy the miscellaneous files to `files/misc` directory. To enable file copying,  uncomment the `misc_file_list` in the yaml files under `group_vars` and add the miscellaneous files to the list.

## Packs to be Copied

Copy the following files to `files` directory. (Packs must be copied as per the required components). You need to add the ZIP Archive of the WSO2 distributions.

1. [WSO2 API Manager package](https://wso2.com/api-management/install/) to files/packs
2. [WSO2 API Manager Analytics package](https://wso2.com/api-management/install/analytics/) to files/packs

## Database configurations

In a production environment we recommend using an external database to store WSO2 application data. Follow the below steps to configure the database. 

1. Copy the relevant JDBC driver needed into `files/lib` directory.
e.g : [MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/5.1.html)
2. Update the database configurations in all the files under [group_vars](../dev/group_vars). In the files update `Datasource configurations section` and the `jdbc_driver` parameter. 


## Keystore configurations

Inorder to change the default keystores of the WSO2 server follow the instructions below.

1. Add the primary, internal, tls keystore and the client-trustore under files/security/<product-home>.
2. Uncomment the Keystore Configurations sections in all the files under [group_vars](../dev/group_vars) and if the keystore names are different from the defaults make sure these changes are done.

## Customize the WSO2 Ansible scripts

The followings are the roles needed to deploy API Manager pattern 3.

- apim-devportal
- apim-publisher
- apim-gateway
- apim-tm
- apim-km
- apim-analytics-worker
- apim-analytics-dashboard

### 1. Customize the [inventory](../dev/inventory) file

#### Replace the inventory file content with the followings.

```
[apim]
apim-devportal_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-publisher_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-gateway_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-gateway_2 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-tm_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-tm_2 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-km_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-km_2 ansible_host=[ip_address] ansible_user=[ssh_user]

[apim-analytics]
apim-analytics-worker_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-analytics-dashboard_1 ansible_host=[ip_address] ansible_user=[ssh_user]
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

- name: Apply API Manager Analytics worker configuration to apim-analytics-worker node
  hosts:
    - apim-analytics-worker_1
  roles:
    - apim-analytics-worker

- name: Apply API Manager Analytics dashboard configuration to apim-analytics-dashboard node
  hosts:
    - apim-analytics-dashboard_1
  roles:
    - apim-analytics-dashboard

- name: Apply API-M keymanager configuration to keymanager nodes
  hosts:
    - apim-km_1
    - apim-km_2
  roles:
    - apim-km

- name: Apply API Manager Devportal configuration to apim-devportal nodes
  hosts:
    - apim-devportal_1
  roles:
    - apim-devportal

- name: Apply API Manager Publisher configuration to apim-publisher nodes
  hosts:
    - apim-publisher_1
  roles:
    - apim-publisher

- name: Apply API Manager traffic manager configuration to gateway nodes
  hosts:
    - apim-tm_1
    - apim-tm_2
  roles:
    - apim-tm

- name: Apply API Manager gateway configuration to gateway nodes
  hosts:
    - apim-gateway_1
    - apim-gateway_2
  roles:
    - apim-gateway
```

### 3. Customize the roles for API Manager pattern 3
API Manager pattern 3 contains 2 groups and the configurations specific for each group should be in the respective yaml file under [group_vars](../dev/group_vars) folder. Configurations specific to each host should be added to the corresponding yaml file under [host_vars](../dev/host_vars) folder.

```
.
└── dev
    ├── group_vars
    │   ├── apim-analytics.yml
    │   └── apim.yml
    ├── host_vars
    │   ├── apim_1.yml
    │   ├── apim_2.yml
    │   ├── apim-analytics-worker_1.yml
    │   ├── apim-analytics-worker_2.yml
    │   ├── apim-gateway_1.yml
    │   ├── apim-gateway_2.yml
    │   ├── apim-km_1.yml
    │   ├── apim-km_2.yml
    │   ├── apim-tm_1.yml
    │   └── apim-tm_2.yml
    └── inventory

```
Most commonly changed values are parameterized in the above files. If further changes are required, the values should be parameterized and added to the files accordingly.

#### i. Customize `apim-devportal` role

Navigate to [carbon-home](../roles/apim-devportal/templates/carbon-home) of the `apim-devportal` role. Follow the instructions in the following documents to modify the files.
- [Developer Portal](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-65-configure-and-start-the-developer-portal)

#### ii. Customize `apim-publisher` role

Navigate to [carbon-home](../roles/apim-devportal/templates/carbon-home) of the `apim-devportal` role. Follow the instructions in the following documents to modify the files.
- [Publisher](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-64-configure-and-start-the-api-publisher)

#### iii. Customize `apim-gateway` role

Navigate to [carbon-home](../roles/apim-gateway/templates/carbon-home) of the `apim-gateway` role. Follow the instructions in the [document](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-66-configure-and-start-the-gateway) and modify the files.

#### iv. Customize `apim-tm` role

Navigate to [carbon-home](../roles/apim-tm/templates/carbon-homel) of the `apim-tm` role. Follow the instructions in the [document](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-63-configure-and-start-the-traffic-manager) and modify the files.

#### v. Customize `apim-km` role

Navigate to [carbon-home](../roles/apim-km/templates/carbon-home) of the `apim-km` role. Follow the instructions in the [document](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-62-configure-and-start-the-key-manager) and modify the files.

#### vi. Customize `apim-analytics-worker` role

Navigate to [carbon-home](../roles/apim-analytics-worker/templates/carbon-home) of the `apim-analytics-worker` role. All the files required to deploy the API Manager analytics are here. Follow the instructions in the following files to modify the files.
- [Minimum HA deployment](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/configure-apim-analytics/active-active/)

### 4. Further customization

Uncomment the following line in `main.yml` under the role you want to customize and add the necessary changes.
```
- import_tasks: custom.yml
```
