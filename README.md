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
make destroy              Destroy infrastructure
make configure            Setup nodes
```
The private and public keys will be generated and stored in the project's root directory

## Kubernetes
- The kubernetes is setup using `kubeadm`, `kubelet` and `kubectl` packages with `flannel` network
- To get list of available nodes - `kubectl get nodes`

### Setting up kubernetes dashboard
The below information has been taken from the following reference link - https://upcloud.com/community/tutorials/deploy-kubernetes-dashboard/

#### Deploying kubernetes dashboard
- To create ssh tunnel - `ssh -i terraform_key.pem -L localhost:8001:127.0.0.1:8001 kube-user@<master_public_IP>`
- To apply kubernetes-dashboard service - `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml`
- To get all pods and verify if dashboard is running or not run - `kubectl get pods -A`

#### Creating admin user
- Create new directory for configuration files - `mkdir ~/dashboard && cd ~/dashboard`
- Create `dashboard-admin.yaml` file and add the following content
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```
- To deploy the admin role run - `kubectl apply -f ~/dashboard/dashboard-admin.yaml`
- To get admin token - `kubectl get secret -n kubernetes-dashboard $(kubectl get serviceaccount admin-user -n kubernetes-dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode`
To run the above command if sudo is needed - first run `sudo -s` to open root console then run the above command
- Copy this token and keep it for accessing the dashboard

#### Accessing dashboard
- Run `kubectl proxy` to create proxy service on the cluster
- This will start to serve on `localhost:8001`
- Now to access the dashboard - `http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/`
- It will ask for token - provide the above saved token
- To create read-only user create `dashboard-read-only.yaml` file

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: read-only-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  annotations:
    rbac.authorization.kubernetes.io/autoupdate: "true"
  labels:
  name: read-only-clusterrole
  namespace: default
rules:
- apiGroups:
  - ""
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - extensions
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
- apiGroups:
  - apps
  resources: ["*"]
  verbs:
  - get
  - list
  - watch
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: read-only-binding
roleRef:
  kind: ClusterRole
  name: read-only-clusterrole
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: read-only-user
  namespace: kubernetes-dashboard
```
- To deploy the admin role run - `kubectl apply -f ~/dashboard/dashboard-read-only.yaml`
- To get token  - `kubectl get secret -n kubernetes-dashboard $(kubectl get serviceaccount read-only-user -n kubernetes-dashboard -o jsonpath="{.secrets[0].name}") -o jsonpath="{.data.token}" | base64 --decode`

#### Cleanup
- To cleanup roles, run
```
kubectl delete -f dashboard-admin.yaml
kubectl delete -f dashboard-read-only.yaml
```
- To disable dashboard, run `kubectl delete -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0/aio/deploy/recommended.yaml`

#### Management script
- The `dashboard.sh` script in resources folder can be used to start, stop or check dashboard status.
- It can be put in the dashboard folder created above
- To give proper permissions to the script run `chmod +x ~/dashboard/dashboard.sh`
- To create symbolic link to use the script anywhere run `sudo ln -s ~/dashboard/dashboard.sh /usr/local/bin/dashboard`
- The various functions are - 
    * Start the dashboard and show the tokens `dashboard start`
    * Check whether the dashboard is running or not and output the tokens if currently set. `dashboard status`
    * Stop the dashboard `dashboard stop`