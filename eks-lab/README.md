# EKS cluster with Terraform

EKS cluster provisioned with [terraform-aws-modules/eks/aws](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/latest) (v21) + VPC module.

- Region: eu-central-1
- Kubernetes: 1.34
- Managed node group: 2 × t3.small (AL2023), private subnets in 2 AZs
- Addons: vpc-cni, coredns, kube-proxy, eks-pod-identity-agent

## Usage

```
terraform init
terraform apply
aws eks update-kubeconfig --region eu-central-1 --name lab-eks
kubectl get nodes
```

## Result

```
$ kubectl get nodes
NAME                                          STATUS   ROLES    AGE   VERSION
ip-10-0-1-78.eu-central-1.compute.internal    Ready    <none>   8m    v1.34.11-eks-f4fc4f1
ip-10-0-2-198.eu-central-1.compute.internal   Ready    <none>   8m    v1.34.11-eks-f4fc4f1
```

Test workload (nginx behind LoadBalancer):

![nginx](docs/nginx.png)
