# Continuous Update Delivery for WSO2 API Manager

The update script is to be used by WSO2 subscription users such that products packs can be updated.

### Prequisites
* Product packs should be provided in the `/files/packs` directory

### Usage
While executing the update script, provide the profile name. The pack corresponding to the profile will begin updating.
```bash
./update.sh -p <profile-name>
```
Any of the following profile names can be provided as arguments:
* apim
* apim-gateway
* apim-km
* apim-publisher
* apim-devportal
* apim-tm
* apim-analytics
* apim-analytics-dashboard
* apim-analytics-worker

If any file that is used as a template is updated, a warning will be displayed. Update the relevant template files accordingly before pushing updates to the nodes.
