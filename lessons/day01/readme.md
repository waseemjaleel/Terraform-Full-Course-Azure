# Good Notes

Providers are plugins

What is Infra as a Code
- Provisioning your infra through code
- Why ?
- azure, login to portal and create
- why pain to write code for drag and drop
- let me explain
- you have to provision the infra to deploy a three tier application
Time taken: 2 hours
- its good , personal project
- 4 environment ?  8 hours
no big deal
- 100s of server to be deployed
tricky?
That's not it
- to save the cost , decomission every day(not possible) keep running and keep accumulating the cost
- Identical environment, works on y machine
- Automate the provisioning, manage and destroy the infra
- reliable, efficiecny and security

Diagram: Manual process vs automated

Benefits:
- Consistent environment
- easy to track cost
- write once, deploy many (single code base)
- Time saving
- Human error
- cost saving
- version control, changes are tracked in git
- automated cleanup/scheduled destruction
- easy to setup and destroy
- developer can focus on app development
- easy to create identical production env for troubleshooting


# What is Terraform
IaaC tool that helps doing all these tasks

# How it works
Write your terraform files --> Run terraform commands --> calls the target cloud provider API to provison the infra using Terraform Provider

init --> validate --> plan --> apply --> destroy

# Install Terraform
https://developer.hashicorp.com/terraform/install
uname -a

```
brew install hashicorp/tap/terraform
Error: No developer tools installed.
Install the Command Line Tools:
  xcode-select --install
```
popup will appear, install using that

terraform -install-autocomplete
alias tf=terraform

terraform -version
