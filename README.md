
- [About](#about)
- [Why is this useful?](#why-is-this-useful)
- [How the template works](#how-the-template-works)
- [Requirements](#requirements)
- [How to get started](#how-to-get-started)
    - [1. Add vars to the implementation project](#1-add-vars-to-the-implementation-project)
    - [2. Add wireguard configs to your implementation project.](#2-add-wireguard-configs-to-your-implementation-project)
    - [3. Include the template in your implementation .gitlab-ci.yml](#3-include-the-template-in-your-implementation-gitlab-ciyml)
    - [4. Configure projects.](#4-configure-projects)

# About

This project provides a template for deploying AWS t2.micro GitLab-Runners with Wireguard installed. The project deploys through public GitLab runners and has to be 
implemented in another GitLab repo. [See instructions.](#how-to-get-started)

The runners can deploy to a LAN through the Wireguard server. Ideally, the Wireguard server would be a router or a device
not targeted by the GitLab pipelines, but deploying on the Wireguard server would work as well.

# Why is this useful?

The project is aimed at selfhosters and tinkerers wanting to use GitLab CI for deploying their applications or infrastructure.
The project aims to:

1. Minimize costs by only spinning up runners when needed and by scheduling a destroy of the GitLab runners after a certain amount of time
2. Maximize security by using Wireguard so you don't need to open many ports
3. Maximize ease of use by providing a template which can be implemented in a `.gitlab-ci.yml` file.

# How the template works
The template works in the following way:

1. Deploy the specified amount of GitLab-Runners on AWS using Terraform
2. Install GitLab-Runner and Wireguard on these runners using Ansible
3. Schedule to destroy the runners in 1 hour.
4. 1 hour later: destroy the runners.

When the pipeline is triggered again within the hour after deploying, any existing scheduled destroys will be cancelled and a new destroy will be scheduled
in 1 hour.

# Requirements
The following items should be present and will not be covered by this project.

1. Wireguard server (including port forwarding)
2. Wireguard client configs (one config needed per runner)
3. AWS access keys
4. SSH keypair

# How to get started

For various reasons I have seperated public templates and my own implementation of these templates.
This way I can keep my implementations in a private project, which prevents secrets from (accidentaly) leaking, etcetera.

To implement the project one would need to do the following:

### 1. Add vars to the implementation project

I would strongly recommend to store the following vars as GitLab secrets.

| Variable name                    | Description                                                     |
|----------------------------------|-----------------------------------------------------------------|
| SSH_PRIVATE_KEY                  | SSH private key                                                 |
| SSH_PUBLIC_KEY                   | SSH public key                                                  |
| AWS_ACCESS_KEY_ID                | AWS access key                                                  |
| AWS_SECRET_ACCESS_KEY            | AWS secret access key                                           |
| PIPELINE_ACCESS_TOKEN            | GitLab API token needed for scheduling and cancelling pipelines |
| GITLAB_RUNNER_REGISTRATION_TOKEN | GitLab runner registration token for registring runners         |

### 2. Add wireguard configs to your implementation project.

For every GitLab runner there should be a file `wireguard-encrypted-config-[<NUMBER OF RUNNER>]` in the directory `wireguard-configs`.
E.g. if you want three runners, you would need the following setup:
```
.
└── wireguard-configs/
    ├── wireguard-encrypted-config-0
    ├── wireguard-encrypted-config-1
    └── wireguard-encrypted-config-2
```

I recommend encrypting these configs in which case you would need to provide encryption password to Ansible. Again, I recommend to store the var as a GitLab secret.

| Variable name                    | Description                          |
|----------------------------------|--------------------------------------|
| ANSIBLE_VAULT_PASSWORD           | Wireguard config encryption password |


### 3. Include the template in your implementation .gitlab-ci.yml

The following would be enough to trigger everything. Optionally, you can overrule certain variables.

``` yml
include:
  remote: "https://gitlab.com/pipeline-templates/gitlab-wireguard-runner/-/raw/main/.gitlab-ci.yml"

```


| Variable                   | Description                                                      | Default                            |
|----------------------------|------------------------------------------------------------------|------------------------------------|
| TF_STATE_NAME              | Name for the Terraform state                                     | runner                             |
| TF_VAR_SSH_PUBLIC_KEY      | Public key used for connecting to the AWS instances              | $SSH_PUBLIC_KEY                    |
| TF_VAR_NUMBER_OF_RUNNERS   | Number of runners                                                | 1                                  |
| WIREGUARD_CONFIG_DIRECTORY | Directory of Wireguard configs                                   | ${CI_PROJECT_DIR}/wireguard-config |
| TIMEZONE                   | Timezone used in pipeline schedules, for a list of timezones [see](https://api.rubyonrails.org/classes/ActiveSupport/TimeZone.html) UTC                                |
| TF_VAR_AWS_REGION               | AWS region to deploy in                                    | eu-west-1 |

``` yml
include:
  remote: "https://gitlab.com/pipeline-templates/gitlab-wireguard-runner/-/raw/main/.gitlab-ci.yml"

variables:
    TIMEZONE: Europe/Berlin
    TF_VAR_NUMBER_OF_RUNNERS: 4

#Only deploy if triggered through GitLab web console
workflow:
  rules:
    - if: '$CI_PIPELINE_SOURCE == "web"'
      when: always
```

### 4. Configure projects.

Disable GitLab public runners and enable your own [runners](https://docs.gitlab.com/13.12/ee/ci/runners/#disable-shared-runners).