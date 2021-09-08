# Google Cloud Aviatrix - Terraform Module

## Descriptions
This Terraform module allows you to launch the Aviatrix Controller and create the Aviatrix access account connecting to the Controller in Google Cloud Platform.

## Prerequisites
1. [Terraform 0.13](https://www.terraform.io/downloads.html) - execute terraform files
2. [Google Cloud command-line interface (GCloud CLI)](https://cloud.google.com/sdk/docs/install) - GCloud authentication
3. [Python3](https://www.python.org/downloads/) - execute `aviatrix_controller_init.py` python scripts

## Available Modules
 Module  | Description |
| ------- | ----------- |
|[aviatrix_controller_build](./aviatrix_controller_build) |Builds the Aviatrix Controller VM on Google Cloud |
|[aviatrix_controller_initialize](./aviatrix_controller_initialize) | Initializes the Aviatrix Controller (setting admin email, setting admin password, upgrading controller version, and setting access account) |


## Procedures for Building and Initializing a Controller in Google Cloud
### 1. Create the Python virtual environment and install required dependencies in the terminal
``` shell
 python3 -m venv venv
```
This command will create the virtual environment. In order to use the virtual environment, it needs to be activated by the following command
``` shell
 source venv/bin/activate
```
In order to run the `aviatrix_controller_init.py` python script, dependencies listed in `requirements.txt` need to be installed by the following command
``` shell
 pip install -r requirements.txt
```

### 2. Authenticating to Google Cloud
#### 2a. Using the Gcloud CLI in the terminal
The easiest way to authenticate is to run:
``` shell
gcloud auth application-default login
```
This command will open the default browser and load Google Cloud sign in page

#### 2b. Using a Service Account 
Alternatively, a Google Cloud Service Account can be used with Terraform to authenticate. Download the JSON key file from an existing Service Account or from a newly created one. Supply the key to Terraform using the `GOOGLE_APPLICATION_CREDENTIALS` environment variable.
```shell
export GOOGLE_APPLICATION_CREDENTIALS={{path to key file}}
```
More information about using a Service Account to authenticate can be found in the Google Terraform documentation [here](https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials).

### 3. Enabling Google Compute Engine API
The Google Compute Engine API must be enabled in order to create the Aviatrix Controller.

#### 3a. Using the Google Console
To enable the Google Compute Engine API using the Google Console:
1. Go to the [Google Compute Engine API page](https://console.cloud.google.com/apis/library/compute.googleapis.com?project=_)
2. From the projects list, select the project you want to use.
3. On the API page, click ENABLE.

More detailed information about enabling APIs can be found in Google's Cloud API documentation [here](https://cloud.google.com/apis/docs/getting-started#enabling_apis).

####3b. Using Terraform
Alternatively, the Google Compute Engine API can be enabled using Terraform. Using the `google_project_service` resource to enable an API requires [Service Usage API](https://console.cloud.google.com/apis/library/serviceusage.googleapis.com?project=_) to be enabled.

**enable_api.tf**
```hcl
provider "google" {
  project = "<< project id >>"
  region  = "<< GCloud region to launch resources >>"
  zone    = "<< GCloud zone to launch resources >>"
}

resource google_project_service "compute_service" {
  service = "compute.googleapis.com"
}
```
*Execute*
```shell
terraform init
terraform apply
```

### 4. Build the Controller VM on Google Cloud

**build_controller.tf**
```
provider "google" {
  version = "<< terraform version >>"
  project = "<< project id >>"
  region  = "<< GCloud region to launch resources >>"
  zone    = "<< GCloud zone to launch resources >>"
}

module "aviatrix_controller_build" {
  source          = "github.com/AviatrixSystems/terraform-module-gcp.git//aviatrix-controller-build"
  
  // please only use lower case letters, numbers and hyphens in the controller_name
  controller_name = "<< your Aviatrix Controller name >>"
}

output "avx_controller_public_ip" {
  value = module.aviatrix_controller_build.public_ip
}

output "avx_controller_private_ip" {
  value = module.aviatrix_controller_build.private_ip
}
```
*Execute*
```shell
cd aviatrix_controller_build
terraform init
terraform apply
cd ..
```
### 5. Initialize the Controller

**controller_init.tf**
```
provider "google" {
  version = "<< terraform version >>"
  project = "<< project id >>"
  region  = "<< GCloud region to launch resources >>"
  zone    = "<< GCloud zone to launch resources >>"
}

module "aviatrix_controller_initialize" {
  source                              = "github.com/AviatrixSystems/terraform-module-gcp.git//aviatrix-controller-initialize"
  avx_controller_public_ip            = "<< public ip address of the Aviatrix Controller >>"
  avx_controller_private_ip           = "<< private ip address of the Aviatrix Controller >>"
  avx_controller_admin_email          = "<< your admin email address for the Aviatrix Controller >>"
  avx_controller_admin_password       = "<< your admin password for the Aviatrix Controller >>"
  gcloud_project_credentials_filepath = "<< absolute path to Google Cloud project credentials >>"
  access_account_name                 = "<< your account name mapping to your GCloud account >>"
  aviatrix_customer_id                = "<< your customer license id >>"
  controller_version                  = "<< desired controller version. defaults to 'latest' >>"
}
```
*Execute*
```shell
cd aviatrix_controller_initialize
terraform init
terraform apply
cd ..
```

### Putting it all together
The controller buildup and initialization can be done using a single terraform file.
```
provider "google" {
  version = "<< terraform version >>"
  project = "<< project id >>"
  region  = "<< GCloud region to launch resources >>"
  zone    = "<< GCloud zone to launch resources >>"
}

module "aviatrix_controller_build" {
  source          = "github.com/AviatrixSystems/terraform-module-gcp.git//aviatrix-controller-build"
  // please only use lower case letters, numbers and hyphens in the controller_name
  controller_name = "<< your Aviatrix Controller name >>"
}

module "aviatrix_controller_initialize" {
  source                              = "github.com/AviatrixSystems/terraform-module-gcp.git//aviatrix-controller-initialize"
  avx_controller_public_ip            = module.aviatrix-controller-build.public_ip
  avx_controller_private_ip           = module.aviatrix-controller-build.private_ip
  avx_controller_admin_email          = "<< your admin email address for the Aviatrix Controller >>"
  avx_controller_admin_password       = "<< your admin password for the Aviatrix Controller >>"
  gcloud_project_credentials_filepath = "<< absolute path to Google Cloud project credentials >>"
  access_account_name                 = "<< your account name mapping to your GCloud account >>"
  aviatrix_customer_id                = "<< your customer license id >>"
  controller_version                  = "<< desired controller version. defaults to 'latest' >>"
}

output "avx_controller_public_ip" {
  value = module.aviatrix_controller_build.public_ip
}
```
*Execute*
```shell
terraform init
terraform apply
```
