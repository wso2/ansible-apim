# Customize WSO2 Ansible resources to deploy API Manager Pattern 1

This document provides instructions to customize the WSO2 API Manager Ansible resources in order to deploy API Manager Pattern 1.

![API Manager Pattern 1](images/P-S-1.png "API Manager Pattern 1")

## Packs to be Copied

Copy the following files to `files` directory.

1. [WSO2 API Manager package](https://wso2.com/api-management/install/)
2. [WSO2 API Manager Analytics package](https://wso2.com/api-management/install/analytics/)
3. [MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/5.1.html)

## Customize the WSO2 Ansible scripts

The followings are the roles needed to deploy API Manager pattern 1.

- apim
- apim-analytics-worker

### 1. Customize the [inventory](../dev/inventory) file

#### Replace the inventory file content with the followings.

```
[apim]
apim_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim_2 ansible_host=[ip_address] ansible_user=[ssh_user]

[apim-analytics]
apim-analytics-worker_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-analytics-worker_2 ansible_host=[ip_address] ansible_user=[ssh_user]
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

- name: Apply API Manager Analytics worker configuration to apim-analytics-worker nodes
  hosts:
    - apim-analytics-worker_1
    - apim-analytics-worker_2
  roles:
    - apim-analytics-worker

- name: Apply API Manager configuration to apim nodes
  hosts:
    - apim_1
    - apim_2
  roles:
    - apim
```

### 3. Customize the roles for API Manager pattern 1

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
    │   └── apim-analytics-worker_2.yml
    └── inventory

```
API Manager pattern 1 contains 2 groups and the configurations specific for each group should be in the respective yaml file under [group_vars](../dev/group_vars) folder. Configurations specific to each host should be added to the corresponding yaml file under [host_vars](../dev/host_vars) folder.

Most commonly changed values are parameterized in the above files. If further changes are required, the values should be parameterized and added to the files accordingly.

#### i. Customize `apim` role

Navigate to [carbon-home](../roles/apim/templates/carbon-home) of the `apim` role. All the files required to deploy the API Manager active-active combination are here. Follow the instructions in the following document to modify the files.
- [Configuring an active-active deployment](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/single-node/configuring-an-active-active-deployment/)

#### ii. Customize `apim-analytics-worker` role

Navigate to [carbon-home](../roles/apim-analytics-worker/templates/carbon-home) of the `apim-analytics-worker` role. All the files required to deploy the API Manager analytics are here. Follow the instructions in the following files to modify the files.
- [Configure Analytics](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/configure-apim-analytics/active-active/)
- [Minimum HA deployment](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/single-node/configuring-an-active-active-deployment/)

### 4. Further customization

Uncomment the following line in `main.yml` under the role you want to customize and add the necessary changes.
```
- import_tasks: custom.yml
```
