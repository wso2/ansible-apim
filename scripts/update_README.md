# Continuous Update Delivery for WSO2 API Manager

The update script is to be used by WSO2 subscription users such that products packs can be updated.

### Prerequisites
* Product packs should be provided in the `/files/packs` directory

### Usage
While executing the update script, provide the profile name. The pack corresponding to the profile will begin updating.
```bash
./update.sh -p <profile-name>
```
Any of the following profile names can be provided as arguments:
* apim
* apim-gateway
* apim-control-plane
* apim-tm

If any file that is used as a template is updated, a warning will be displayed. Update the relevant template files accordingly before pushing updates to the nodes.

Once the update process completed, it requires to execute the Ansible-playbook to apply the updated distributions to the deployment.
1. [Ansible Playbook guide](https://github.com/wso2/ansible-apim/blob/4.0.x/README.md)

There are two options to place the product distributions to the nodes,
1. Keeping the updated product distribution(`<Ansible_Home>/files/packs/`) in the host machine that runs the Ansible Playbook.(Updated packs will be copied from the Ansible host machine to each server during the playbook runtime)
Please find the sample configurations for `<Ansible_Home>/group_vars/apim.yml`.
```java
pack_location: local
```

2. Copying the updated product distribution from `<Ansible_Home>/files/packs/` of the host machine that runs the Ansible Playbook, to each node the servers will run after each WUM update and before executing the playbook.
In the below sample, it uses the remote location as `/mnt/`.
Please find the sample configurations for `<Ansible_Home>/group_vars/apim.yml`.
```java
pack_location: remote
remote_jdk: "/mnt/amazon-corretto-11.0.14.1-linux-x64.tar.gz"
remote_pack: "/mnt/wso2am-4.1.0.zip"
```

NOTES:
1. The same two options apply for the JDK distribution as configured above examples.
2. If you prefer updating the product distributions without any additional dev-ops work, please proceed with the first approach(copying from the Ansible host machine to each server during the playbook runtime)