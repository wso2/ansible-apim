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
│   │   └── apim.yml
│   ├── host_vars
│   │   ├── apim-control-plane_1.yml
│   │   ├── apim-gateway_1.yml
│   │   ├── apim-tm_1.yml
│   │   ├── apim_1.yml
│   └── inventory
├── docs
│   ├── images
│   │   ├── 3-fully-distributed-setup.png
│   │   ├── API-M-single-node-deployment.png
│   │   ├── P-H-2.png
│   │   ├── P-H-3.png
│   │   ├── P-M-1.png
│   │   └── P-S-1.png
│   ├── Pattern_1.md
│   ├── Pattern_2.md
│   ├── Pattern_3.md
│   ├── Pattern_4.md
│   └── Pattern_5.md
├── files
│   ├── lib
│   │   ├── amazon-corretto-11.0.14.1-linux-x64.tar.gz
│   └── packs
│   │   ├── wso2am-4.1.0.zip
│   ├── system
│   │   └── etc
│   │       ├── security
│   │       │   └── limits.conf
│   │       └── sysctl.conf
│   └── misc
├── issue_template.md
├── LICENSE
├── pull_request_template.md
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

Following instructions can be followed to deploy a all-in-one standard APIM deployment to tryout the product and for demonstrations purposes. If you want to deploy a production ready deployment pattern refer the documentation in the `docs` directory.


## Copying packs locally
Packs could be either copied to a local directory, or downloaded from a remote location.

Copy the following files to `files/packs` directory.

1. [WSO2 API Manager 4.1.0 package (.zip)](https://wso2.com/api-management/install/)

Copy the following files to `files/lib` directory.

1. [Amazon Corretto for Linux x64 JDK 11 (.tar.gz)](https://docs.aws.amazon.com/corretto/latest/corretto-11-ug/downloads-list.html)

Copy the miscellaneous files to `files/misc` directory. To enable file copying,  uncomment the `misc_file_list` in the yaml files under `group_vars` and add the miscellaneous files to the list.

## Downloading from remote location

In **group_vars**, change the values of the following variables in all groups:
1. The value of `pack_location` should be changed from "local" to "remote"
2. The value of `remote_jdk` should be changed to the URL in which the JDK should be downloaded from, and remove it as a comment.
3. The value of `remote_pack` should be changed to the URL in which the package should be downloaded from, and remove it as a comment.

## Running WSO2 API Management Ansible scripts

### 1. Run the existing scripts without customization
The existing Ansible scripts contain the configurations to set-up a single node WSO2 API Manager pattern. In order to deploy the pattern, you need to replace the `[ip_address]` and `[ssh_user]` given in the `inventory` file under `dev` folder by the IP of the location where you need to host the API Manager. An example is given below.
```
[apim]
apim_1 ansible_host=172.28.128.4 ansible_user=vagrant
```

Then, update the hostname in dev/host_vars/apim_1.yml with ansible_host, 172.28.128.4

Run the following command to run the scripts. Use `-K` to provide a password to become root. Configure `become_method:` in `ansible.cfg` when using an alternative to
`sudo`. If your host allows passwordless `sudo`, then omit the `-K` argument.

`ansible-playbook -K -i dev site.yml`

If you need to alter the configurations given, please change the parameterized values in the yaml files under `group_vars` and `host_vars`.

**NOTE:**
> If you have mounted the 'persistent artifacts' as guided [below](##configuration-guide), make sure to unmount the artifacts, prior to running the Ansible playbook as the playbook running process has a step to remove the existing setup. After completing the Ansible playbook running process, make sure to remount the artifacts.

> If the `client-truststore.jks` is monuted among the Gateway nodes, then make sure to copy the `client-truststore.jks` from the mount source to the `<ANSIBLE_HOME>/files/security/wso2am/` directory of the Ansible resources, prior to re-running the playbook.

### 2. Customize the WSO2 Ansible scripts

The templates that are used by the Ansible scripts are in j2 format in-order to enable parameterization.

The `deployment.toml.j2` file is added under `roles/apim/templates/carbon-home/repository/conf/`, in order to enable customizations. You can add any other customizations to `custom.yml` under tasks of each role as well.

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

## Previous versions of Ansible

The master branch of this repository contains the latest product version with the latest Ansible version. The Ansible resources for previous Ansible versions can be found in the branches. The following is an example.

#### Ansible resources for API Manager 4.0.0

Branch name: 4.0.x
