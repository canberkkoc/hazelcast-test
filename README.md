# Challenge Report

## Directory Structure

``` bash
hazelcast-example/ 
├── kubernetes.tf -> Kubernetes workload resources
├── main.tf -> Provider definitions
├── README.md
├── values -> Helm value files + examples
│ ├── ingress.yaml -> Ingress controller chart values
│ ├── prometheus-operator.yaml -> Prometheus operator chart values
│ ├── secret-example.yaml -> Vault secret creation example
│ └── vault.yaml -> Vault chart values
├── vars.tf -> Variable definitions
└── versions.tf -> Provider versions
```

## Environment

``` bash
Distributor ID:	Ubuntu
Description:	Ubuntu 20.04.4 LTS
Release:	20.04
Codename:	focal

$ terraform version
Terraform v1.1.9

$ minikube version
minikube version: v1.25.2
commit: 362d5fdc0a3dbee389b3d3f1034e8023e72bd3a7

$ kubectl version
Client Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.0", GitCommit:"ab69524f795c42094a6630298ff53f3c3ebab7f4", GitTreeState:"clean", BuildDate:"2021-12-07T18:16:20Z", GoVersion:"go1.17.3", Compiler:"gc", Platform:"linux/amd64"}
Server Version: version.Info{Major:"1", Minor:"23", GitVersion:"v1.23.3", GitCommit:"816c97ab8cff8a1c72eccca1026f7820e93e0d25", GitTreeState:"clean", BuildDate:"2022-01-25T21:19:12Z", GoVersion:"go1.17.6", Compiler:"gc", Platform:"linux/amd64"}

``` 

## Preparation

Install minikube as described at documentations https://minikube.sigs.k8s.io/docs/start/
|| https://phoenixnap.com/kb/install-minikube-on-ubuntu

### Run Minikube

``` bash 
minikube start
```

### Populate Kubernetes Variables

Code snippet basically clear variables related to Kubernetes and recreate for new environment.

``` bash 
$ sed -i  "/certificate_authority_data/d;/client_certificate_data/d;/client_key_data/d;9,/server/d" terraform.tfvars && \
kubectl config view --flatten -o=jsonpath='{"certificate_authority_data = "}{"\""}{.clusters[?(@.name=="minikube")].cluster.certificate-authority-data}{"\""}{"\n"}{"\n"}{"client_certificate_data = "}{"\""}{.users[?(@.name=="minikube")].user.client-certificate-data}{"\""}{"\n"}{"\n"}{"client_key_data = "}{"\""}{.users[?(@.name=="minikube")].user.client-key-data}{"\""}{"\n"}{"\n"}{"server = "}{"\""}{.clusters[?(@.name=="minikube")].cluster.server}{"\""}{"\n"}' >> terraform.tfvars
```

## Terraform Apply

``` bash 
$ terraform init
$ terraform plan
$ terraform apply -auto-approve
$ terraform destroy -auto-approve
```

## Proxying Ingress to Reach Services

``` bash 
kubectl port-forward -n ingress CONTROLLER-POD 8000:80
```

## Vault Unsealing

Vault helm deployed as described at
documentation https://learn.hashicorp.com/tutorials/vault/kubernetes-minikube?in=vault/kubernetes
After install you have to unseal the Vault to add or retrieve secrets. Due to having one node minikube cluster I didn't
use HA on vault.

There are two ways to do it. First one from UI:

![image](https://user-images.githubusercontent.com/5826958/168450022-ee756d0c-a31e-4a76-b283-2326f4a1baae.png)


Second one from command line:

``` bash 
$ kubectl exec -n vault vault-0 -- vault operator init -key-shares=1 -key-threshold=1 -format=json > cluster-keys.json
$ VAULT_UNSEAL_KEY=$(cat cluster-keys.json | jq -r ".unseal_keys_b64[]")
$ kubectl exec -n vault vault-0 -- vault operator unseal $VAULT_UNSEAL_KEY
```

After unsealing the Vault you can use UI from your browser at

```
http://localhost:8000
```

![Screenshot from 2022-05-15 01-16-40](https://user-images.githubusercontent.com/5826958/168449996-785c58a6-6ab3-4d53-a768-76d6c57e3b0d.png)

## Accessing Prometheus Stack

You can access the Prometheus and Alertmanager via:

```
http://localhost:8000/prometheus
http://localhost:8000/alertmanager
```

Using basic auth credentials:

```
Username: admin
Password: test
```

## Notes

Basic auth credentials stored with  ```extraSecret``` section at prometheus-operator.yaml Helm values. I can't manage to
use web.yml file as described at documentation https://prometheus.io/docs/guides/basic-auth/ with operator yaml so I
used ingress basic auth method.

Vault ingress must use the "/" path to work as they don't implement custom paths to work at the moment.

Used for_each loop to take namespaces because of code repetition

### Resources
https://prometheus.io/docs/guides/basic-auth/  
https://minikube.sigs.k8s.io/docs/start/  
https://github.com/prometheus-community/helm-charts/issues/1255#issuecomment-925009435
https://www.vaultproject.io/docs/auth/userpass
https://itnext.io/k8s-monitor-pod-cpu-and-memory-usage-with-prometheus-28eec6d84729


