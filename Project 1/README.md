# 🌐 Azure Terraform Infrastructure Repository

**Welcome to the Azure Terraform repository!** 🚀  
This project demonstrates the use of Infrastructure as Code (IaC) to manage, provision, and automate resources in Microsoft Azure using Terraform. Whether you're an experienced DevOps engineer or just starting with cloud automation, you'll find this repository useful and easy to navigate.

---

## 📂 Repository Structure

### 1. `.github/workflows/`
- **Purpose**: Contains GitHub Actions workflows for CI/CD.  
- **File**: `AzureTerraform.yml`  
  - Automates execution of Terraform commands (e.g., `init`, `plan`, and `apply`) whenever code is pushed.  
  - Ensures a smooth, hands-free deployment process with Terraform and Azure.  
  - **Highlights**:  
    - Runs on `ubuntu-latest`.  
    - Includes steps for formatting, validation, planning, and applying Terraform configurations.

---

### 2. `Project 1/Provisioning`
- **Purpose**: Contains the Terraform configuration files for provisioning Azure resources.
- **Files and Folders**:
  - **`main.tf`**: The heart of the project ❤️. Defines the Azure resources you want to create (e.g., VMs, networks, logic apps).  
  - **`variables.tf`**: Holds variable definitions for reusable and dynamic configurations.  
  - **`terraform.tfvars`**: Actual values for the variables (subscription IDs, resource groups, VM names, etc.).  
  - **`extractVM.sh`**: A Bash script that fetches the VM name from Azure Sentinel alerts using KQL queries. Great for automating VM isolation during incidents. 🛡️  
  - **`KQL-query.txt`**: Stores the KQL query used in Azure Log Analytics to detect malicious activities.

**Key Highlights**:
- Automates infrastructure provisioning using Terraform.  
- Combines Azure Sentinel automation with Log Analytics for threat detection and response.  
- Follows best practices with reusable variables.

---

### 3. `security/`
- **Purpose**: Contains configurations and resources related to security policies.
- **Key Features**:
  - Handles RBAC assignments, ensuring only authorized users and managed identities can interact with Azure resources.  
  - Manages roles like Contributor for automation processes.

---

## 🌟 Key Features of This Repository

### Terraform and Azure Integration 🛠️
- Leverages Terraform to automate Azure resource provisioning.  
- Defines everything in code, making deployments consistent and repeatable.

### Azure Sentinel Automation ⚡
- Integrates Azure Sentinel for monitoring and responding to threats.  
- Includes logic apps to automate responses, like VM isolation when a threat is detected.

### CI/CD Pipelines 🚀
- Utilizes GitHub Actions to automate the Terraform workflow.  
- Ensures code quality with steps like `terraform validate` and `terraform fmt` before applying configurations.

### Bash Automation 🖥️
- Includes a Bash script (`extractVM.sh`) to fetch VM names dynamically based on Sentinel alerts—perfect for dynamic scenarios.

### Well-Organized Structure 📂
- Easy-to-navigate folders and files, making it beginner-friendly yet powerful for advanced users.

---

## 🤔 How to Use This Repository

1. **Clone the Repo**:
   ```bash
   git clone https://github.com/AbduSalam1st/AzureTerraform.git
   cd AzureTerraform
