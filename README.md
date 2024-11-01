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

#### Day5: File Structure
- Terraform file organization
- Best practices for structure
- [Code Sample](/lessons/05-file-structure/)

#### Video 6: Data Structures in Terraform
- String, number, bol
- Map, set, list, null
- Locals
- Dynamic blocks
- [Code Sample](/lessons/06-data-structures/)

#### Video 7: For Each Loop
- Understanding for_each
- Practical examples
- [Code Sample](/lessons/07-for-each/)

#### Video 8: Data Sources
- Using data sources
- Practical examples
- [Code Sample](/lessons/08-data-sources/)

#### Video 9: Functions and Conditional Expressions
- Built-in functions
- Conditional expressions
- Splat Expressions
- [Code Sample](/lessons/9-functions-conditions/)

#### Video 10: Variables
- Input variables
- Output variables
- Variable files (tfvars)
- [Code Sample](/lessons/10-variables/)

### Module 2: Azure resources using Terraform

#### Video 11: VM, VMSS, NSG
- Creating Virtual Machines
- VM Scale Sets
- Network Security Groups
- [Code Sample](/lessons/11-compute/)

#### Video 12: VNET and Peering
- Virtual Network creation
- VNet peering setup
- [Code Sample](/lessons/12-networking/)

#### Video 13: Azure AD Authentication
- Authentication methods
- Service principals
- Managed identities
- [Code Sample](/lessons/13-auth/)

#### Video 14: Azure Web Apps
- App Service creation
- Configuration
- Deployment
- [Code Sample](/lessons/14-webapps/)

#### Video 15: Azure Functions
- Function App setup
- Configuration
- [Code Sample](/lessons/15-functions/)

#### Video 16: AKS Cluster
- Kubernetes cluster setup
- Custom modules usage
- [Code Sample](/lessons/16-aks/)

#### Video 17: Load Balancer and Traffic Manager
- Load balancer setup
- Traffic manager configuration
- [Code Sample](/lessons/17-loadbalancer/)

#### Video 18: Azure Policy and Governance
- Policy creation
- Governance setup
- [Code Sample](/lessons/18-policy/)

#### Video 19: Azure App Gateway
- App Gateway setup
- Configuration
- [Code Sample](/lessons/19-appgateway/)

#### Video 20: Azure SQL Database
- Database creation
- Configuration
- [Code Sample](/lessons/20-sql/)

#### Video 21: Azure Monitoring
- Metrics alerts
- Action groups
- Log analytics workspace
- Log alerts
- [Code Sample](/lessons/21-monitoring/)

### Module 3: Advanced Concepts

#### Video 22: Terraform Modules (Project 1)
- Public modules
- Custom modules
- Creating and publishing modules
- [Project Files](/projects/01-modules/)

#### Video 23: Terraform Cloud and Workspaces
- Cloud setup
- Workspace management
- [Code Sample](/lessons/23-terraform-cloud/)

#### Video 24: Azure DevOps with Terraform (Project 2)
- CI/CD pipeline setup
- Automation
- [Project Files](/projects/02-devops/)

#### Video 25: 3-Tier Architecture (Project 3)
- Complete architecture setup
- Best practices
- [Project Files](/projects/03-three-tier/)

#### Video 26: AKS Upgrade with Zero Downtime (Project 4)
- Upgrade strategy
- Implementation
- [Project Files](/projects/04-aks-upgrade/)

#### Video 27: Best Practices
- Code organization
- Security practices
- Performance optimization
- [Code Sample](/lessons/29-best-practices/)

#### Video 28: Advanced Deployment
- Using provisioners
- Git clone integration
- kubectl implementation
- [Code Sample](/lessons/28-advanced-deployment/)

## 📂 Repository Structure
```
├── lessons/
│   ├── 01-introduction/
│   ├── 02-terraform-provider/
│   └── ...
├── projects/
│   ├── 01-modules/
│   ├── 02-devops/
│   ├── 03-three-tier/
│   └── 05-cloud-infra/
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
