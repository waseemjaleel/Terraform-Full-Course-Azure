# Terraform with Azure - Complete Video Course 🚀

Welcome to the comprehensive Terraform with Azure video course! This repository contains all code samples and documentation corresponding to each video lesson.

## 🎯 Course Overview
This course consists of video lessons covering basic to advanced Terraform concepts with Azure cloud, including hands-on projects and real-world scenarios.

## 📋 Prerequisites
- Azure free account or subscription, follow this [video](https://youtu.be/bv3CWyaUeJI)
- Azure Fundamentals [Video Link](https://youtu.be/-pX5PjIYTJs)
- Visual Studio Code or preferred IDE
- Git installed and working knowledge of it
- Linux or Mac or WSL(Windows Subsystem for Linux)
- Linux and Shell scripting
- Basic understanding of YAML and JSON
- Networking Fundamentals
- IP Addressing [Video Link](https://youtu.be/G1azmL5-eQI)
- Docker and Kubernetes Fundamentals [Playlist Link](https://www.youtube.com/playlist?list=PLl4APkPHzsUUOkOv3i62UidrLmSB8DcGC)

## 📚 Course Curriculum

### Module 1: Core Concepts

#### Day1: Introduction to Terraform
- Understanding Infrastructure as Code (IaC)
- Why we need IaC
- What is Terraform and its benefits
- Challenges with the traditional approach
- Terraform Workflow
- Installing Terraform
- [Code Sample](/lessons/01-introduction/)

#### Day2: Terraform Provider
- Terraform Providers
- Provider version v/s Terraform core version
- Why version matters
- Version constraints
- Operators for versions
- [Code Sample](/lessons/02-terraform-provider/)

#### Day3: Resource Group and Storage Account
- Authentication and Authorization to Azure resources
- Creating resource groups
- Storage account management
- Understanding dependencies
- [Code Sample](/lessons/03-resource-storage/)

#### Day4: Backend Configuration
- How Terraform updates Infra
- Terraform state file
- State file best practices
- Remote backend setup
- State management
- [Code Sample](/lessons/04-backend-config/)

#### Day5: Variables
- Input variables
- Output variables
- Locals
- Variable files (tfvars)
- [Code Sample](/lessons/5-variables/)

#### Day6: File Structure
- Terraform file organization
- Sequence of file loading
- Best practices for structure
- [Code Sample](/lessons/05-file-structure/)

#### Video 7: Type constraints in Terraform
- String, number, bol
- Map, set, list, null
- Locals
- [Code Sample](/lessons/06-data-structures/)

#### Video 8: Meta-arguments
- Understanding count
- for_each loop
- for loop
- Practical examples
- [Code Sample](/lessons/07-for-each/)

#### Video 9: The Lifecycle meta-arguments
- create before destroy
- prevent destroy
- ignore changes
- replace triggered by
- customer condition

#### Video 10: Dynamic Blocks and expressions
- Dynamic blocks
- Conditional expressions
- Splat Expressions
- practical examples
- Code samples

#### Video 11: Functions in Terraform
- Built-in functions
- Practical examples
- tasks for practice
- [Code Sample](/lessons/11-functions-conditions/)


#### Video 12: Functions in Terraform(Continue..)
- Built-in functions
- Practical examples
- tasks for practice
- [Code Sample](/lessons/12-functions-conditions/)

#### Video 13: Data Sources
- Using data sources
- Practical examples
- [Code Sample](/lessons/13-data-sources/)
  
### Module 2: Azure resources using Terraform 

#### Video 14: High available/scalable Infrastructure Deployment ( Mini Project 1 )
- Creating Virtual Machines
- VM Scale Sets
- Network Security Groups
- Loadbalancer, Nat Gateway, Public IP , Autoscaling rules etc
- [Code Sample](/lessons/14-compute/)

#### Video 15: VNET and Peering ( Mini Project 2 )
- Virtual Network Creation
- VNet peering setup
- [Code Sample](/lessons/15-networking/)

#### Video 16: Azure AD Authentication ( Mini Project 3 )
- Authentication methods
- Service principals
- Managed identities
- [Code Sample](/lessons/16-auth/)

#### Video 17: Azure Web Apps ( Mini Project 4 )
- App Service creation
- Configuration
- Deployment
- [Code Sample](/lessons/17-webapps/)

#### Video 18: Azure Functions ( Mini Project 5 )
- Function App setup
- Configuration
- [Code Sample](/lessons/15-functions/)

#### Video 19: Terraform Provisioners ( Mini Project 6 )
- What are provisioners and their use case
- Local vs remote vs file provisioners
- Demo of all three provisioners
- [Code Sample](/lessons/28-miss-topics/)

#### Video 20: AKS Cluster ( Real-time Project 1)
- Kubernetes cluster setup
- Custom module usage
- Custom module creation for AKS, KeyVault, SPN etc
- [Code Sample](/lessons/20-aks/)

#### Video 21: Azure Policy and Governance ( Mini Project 7 )
- Policy creation
- Governance setup
- [Code Sample](/lessons/21-policy/)


#### Video 22: Azure SQL Database ( Mini Project 8 )
- Database creation
- Configuration
- [Code Sample](/lessons/22-sql/)

#### Video 23: Azure Monitoring ( Mini Project 9 )
- Metrics alerts
- Action Groups
- Log analytics workspace
- Log alerts
- [Code Sample](/lessons/23-monitoring/)

### Module 3: Advanced Concepts

#### Video 24: Terraform Modules (Real-time project 2)
- Public modules
- Custom modules
- Creating and publishing modules
- [Project Files](/projects/24-modules/)

#### Video 25: Terraform Cloud and Workspaces
- Cloud setup
- Workspace management
- [Code Sample](/lessons/25-terraform-cloud/)

#### Video 26: Azure DevOps with Terraform (Real-time project 3)
- CI/CD pipeline setup
- Automation
- [Project Files](/projects/26-devops/)

#### Video 27: 3-Tier Architecture (Real-time project 4)
- Complete architecture setup
- Best practices
- [Project Files](/projects/27-three-tier/)

#### Video 28: AKS Upgrade with Zero Downtime (Real-time project 5)
- Upgrade strategy
- Implementation
- [Project Files](/projects/28-aks-upgrade/)




## 📂 Repository Structure
```
├── lessons/
│   ├── 01-introduction/
│   ├── 02-terraform-provider/
│   └── ...
├── projects/
│   ├── 14-vmss/
│   ├── 15-vnetpeering/
│   ├── 16-azuread
│   └── 17-webapp
├── docs/
│   ├── setup.md
│   └── troubleshooting.md
└── README.md
```

## 🎓 Learning Path
1. Follow videos in sequence
2. Complete hands-on exercises
3. Implement projects
4. Practice with provided code samples

## 📝 License
MIT License - see the [LICENSE](LICENSE) file for details.

## 🔗 Resources
- [Terraform Documentation](https://www.terraform.io/docs)
- [Azure Documentation](https://docs.microsoft.com/azure)
- [Course Support Forum]()
