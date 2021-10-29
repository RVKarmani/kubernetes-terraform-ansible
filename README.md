# Kubernetes Cluster Setup with terraform and ansible

## Basic Setup
This project is used to create a kubernetes cluster with AWS EC2 instances using terraform for setting up the infrastructure and Ansible for configuring and setting up the nodes in the cluster with Kubernetes

- Create an IAM with admin access - this will be used for setting up the infrastructure

- Setup aws profile to be used with the AWS CLI
```
aws configure --profile [profile_name]
```

- Modify the value **PROFILE** in vars.json as well as the other parameters such as instance type, number of worker nodes, the sudo user to be used for the entire setup etc.

## Setting up infrastructure
There is a Makefile which can be used to setup the entire infrastructure and configure it
```
make help            Show this help.
make init            Init Terraform
make plan            Calculate infrastructure
make apply           Apply changes to infrastructure
destroy              Destroy infrastructure
configure            Setup nodes
```
The private and public keys will be generated and stored in the project's root directory

## Kubernetes
- The kubernetes is setup using `kubeadm`, `kubelet` and `kubectl` packages with `flannel` network

- To get list of available nodes - `kubectl get nodes`
