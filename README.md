 # Splunk Honeypot

 This is a project for deploying and monitoring honeypots with splunk.

 This project currently consists of the following:

- Splunk (https://github.com/splunk/docker-splunk)

- Traefik reverse proxy for kibana access (https://github.com/traefik/traefik)

- Cowrie SSH Honeypot (https://github.com/cowrie/cowrie)

# Deployment

This application stack uses docker compose and is intended to be deployed with Terraform on AWS or Azure. Manual installation is however possible.

## Terraform (AWS/Azure)

- Install Terraform
- Install AWS Cli / Azure Cli
- Setup credentials
- Clone splunk-honeypot repo
- Open terminal in directory "./splunk-honeypot/terraform/aws" or "./splunk-honeypot/terraform/azure" and run 'terraform init'
- Run 'terraform apply' and supply variables or alternatively create terraform.tfvars file beforehand in chosen directory.
- On apply:
  - SSH private and public keys are automatically created and outputted to "./keys/"
  - Access for SSH, Splunk and the Traefik dashboard is provided in output
- Have a coffee (Wait around 10 mins for setup to complete)
  - Check progress by sshing into the instance with the created private key file
    - Run 'sudo systemctl status splunk-honeypot' to check the service status
    - Run 'docker ps' to check docker status
    - Once 'docker ps' shows the containers are running wait a couple of minutes for splunk to finish starting.
- Access Splunk with the reverse proxy user and the password variables provided and the outputted url
- Login to splunk as Admin with the Admin password set with a variable.
- View the Cowrie Dashboard and watch the attacks come in.

### Sample terraform.tfvars

```
traefikUser = "user_for_proxy_to_traefik_dashboard"
traefikPassword = "password_for_proxy_to_traefik_dashboard"
splunkProxyUser = "user_for_proxy_to_splunk"
splunkProxyPassword = "password_for_proxy_to_splunk"
splunkAdminPassword = "password_for_splunk_admin_account"
```

## Manual Installation

Manual installation is available for ubuntu 20.04 systems (other ubuntu/debian versions are untested). SSH port is automatically changed to 50220 (can be changed by modifying setup script), port 80 needs opening up to the world with the host setup within a dmz. Cloud installation through terraform is recommended.

- git clone --depth=1 https://github.com/lluked/splunk-honeypot ~/splunk-honeypot
- cd ~/splunk-honeypot
- sudo ./bin/setup.sh
