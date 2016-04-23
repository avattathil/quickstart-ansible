# quickstart-ansible
This is the offical report for the quickstart-ansible AWS QuickStart

This Quick Start deploys the latest version of Ansible Tower on an EC2 instance that is running CentOS 7 or Red Hat Enterprise Linux (RHEL) 7. The installation is automated with a user data script that executes when the instance is launched via AWS CloudFormation. Ansible Tower installation files are installed directly from Ansible’s release server.

In addition to installing Ansible Tower, the Quick Start also deploys a Linux client into the Amazon VPC. The client is tagged with the key Tower. After you deploy the Quick Start, you’ll use this key to identify and manage the client in Ansible Tower. We’ll provide step-by-step instructions for doing that in step 5 of the deployment section.


Repo Contains:
- Cloudformation templates
- UserData Scripts
- Documentation

Components Created:
Creates AWS VPC in the region you choose when you launch the stack. A single, public VPC subnet is created in an Availability Zone.
One Ansible Tower instance is deployed into the VPC subnet.
One Linux client instance is deployed into the VPC subnet.


![alt tag](https://docs.aws.amazon.com/quickstart/latest/ansible-tower/images/ansible-architecture.png)

Published at:
- https://docs.aws.amazon.com/quickstart/latest/ansible-tower/welcome.html
