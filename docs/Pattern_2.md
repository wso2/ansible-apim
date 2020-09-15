# Customize WSO2 Ansible resources to deploy API Manager Pattern 2

This document provides instructions to customize the WSO2 API Manager Ansible resources in order to deploy API Manager Pattern 2.

![API Manager Pattern 2](images/P-M-1.png "API Manager Pattern 2")

## Packs to be Copied

Copy the following files to `files` directory.

1. [WSO2 API Manager package](https://wso2.com/api-management/install/)
2. [WSO2 API Manager Analytics package](https://wso2.com/api-management/install/analytics/)
3. [MySQL Connector/J](https://dev.mysql.com/downloads/connector/j/5.1.html)

## Customize the WSO2 Ansible scripts

The followings are the roles needed to deploy API Manager pattern 2.

- apim
- apim-gateway
- apim-km
- apim-analytics-worker

### 1. Customize the [inventory](../dev/inventory) file

#### Replace the inventory file content with the followings.

```
[apim]
apim_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim_2 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-gateway_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-gateway_2 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-km_1 ansible_host=[ip_address] ansible_user=[ssh_user]
apim-km_2 ansible_host=[ip_address] ansible_user=[ssh_user]

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

- name: Apply API-M keymanager configuration to keymanager nodes
  hosts:
    - apim-km_1
    - apim-km_2
  roles:
    - apim-km

- name: Apply API Manager configuration to apim nodes
  hosts:
    - apim_1
    - apim_2
  roles:
    - apim

- name: Apply API Manager gateway configuration to gateway nodes
  hosts:
    - apim-gateway_1
    - apim-gateway_2
  roles:
    - apim-gateway
```

### 3. Customize the roles for API Manager pattern 2

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
    │   └── apim-km_2.yml
    └── inventory

```
API Manager pattern 2 contains 2 groups and the configurations specific for each group should be in the respective yaml file under [group_vars](../dev/group_vars) folder. Configurations specific to each host should be added to the corresponding yaml file under [host_vars](../dev/host_vars) folder.

Most commonly changed values are parameterized in the above files. If further changes are required, the values should be parameterized and added to the files accordingly.

#### i. Customize `apim` role

Navigate to [carbon-home](../roles/apim/templates/carbon-home) of the `apim` role. All the files required to deploy the API Manager Pub-DevPortal-TM combination are here. Follow the instructions in the following documents to modify the files.
- [Publisher](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-64-configure-and-start-the-api-publisher)
- [Developer Portal](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-65-configure-and-start-the-developer-portal)
- [Traffic Manager](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-63-configure-and-start-the-traffic-manager)

#### ii. Customize `apim-gateway` role

Navigate to [carbon-home](../roles/apim-gateway/templates/carbon-home) of the `apim-gateway` role. Follow the instructions in the [document](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-66-configure-and-start-the-gateway) and modify the files.

> NOTE: The guideline to configure both internal and external gateways are the same. But as these gateways are in different networks and have different configurations.

#### iii. Customize `apim-km` role

Navigate to [carbon-home](../roles/apim-km/templates/carbon-home) of the `apim-km` role. Follow the instructions in the [document](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/deploying-wso2-api-m-in-a-distributed-setup/#step-62-configure-and-start-the-key-manager) and modify the files.

#### iv. Customize `apim-analytics-worker` role

Navigate to [carbon-home](../roles/apim-analytics-worker/templates/carbon-home) of the `apim-analytics-worker` role. All the files required to deploy the API Manager analytics are here. Follow the instructions in the following files to modify the files.
- [Minimum HA deployment](https://apim.docs.wso2.com/en/latest/install-and-setup/setup/distributed-deployment/configure-apim-analytics/active-active/)

### 4. Further customization

Uncomment the following line in `main.yml` under the role you want to customize and add the necessary changes.
```
- import_tasks: custom.yml
```
