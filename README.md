# Deploy A DigitalOcean Kubernetes Cluster With Gateway API, DNS, TLS, and Postgres

This repository provisions a DigitalOcean Kubernetes environment in two stages:

- `platform/`: creates the cluster and core platform components
- `utils/`: configures Gateway API routing, cert-manager certificates, and app-level utilities such as PostgreSQL clusters

The stack uses:

- DigitalOcean Kubernetes
- Cilium Gateway API
- `external-dns`
- `cert-manager`
- CloudNativePG
- DigitalOcean Spaces for state and Postgres backups

## Repository Layout

- `platform/` builds the cluster and core services
- `utils/` configures Gateway, HTTP routes, certificates, and application utilities
- `helm_charts/cluster-issuer/` contains the ClusterIssuer Helm chart used by cert-manager

## Prerequisites

- Terraform
- `kubectl`
- `doctl`
- `jq`
- a DigitalOcean account
- a DNS zone in DigitalOcean for your domain, for example `springauth.com`
- a DigitalOcean Spaces bucket for Terraform state and backups

Your domain must be delegated to DigitalOcean nameservers before certificate issuance can work.

## Configure Terraform State

The Terraform state is stored in DigitalOcean Spaces. Export your Spaces credentials before running `terraform init`:

```bash
export AWS_ACCESS_KEY_ID="your_spaces_access_key"
export AWS_SECRET_ACCESS_KEY="your_spaces_secret_key"
```

## Configure Platform Variables

Edit [production.auto.tfvars](/Users/sonamsamdupkhangsar/Documents/github/do-k8-terraform-1/platform/production.auto.tfvars) with your values.

Important fields:

- `domain_name`
- `top_level_domains`
- `digitalocean_token`
- `spaces_access_id`
- `spaces_secret_key`
- `bucket_endpoint_url`
- `spaces_region`
- `project_namespace`
- `cert_manager_namespace`

If the domain already exists in DigitalOcean DNS, keep:

```hcl
create_domain = false
```

## Deploy

### Option 1: Use the Makefile

From the repo root:

```bash
make platform-init
make platform-apply
make platform-output
make generate-utils-vars
make utils-init
make utils-apply
```

### Option 2: Run the Steps Manually

#### 1. Apply `platform/`

```bash
cd platform
terraform init
terraform plan
terraform apply
```

#### 2. Export platform outputs for `utils/`

```bash
terraform output -json > ../utils/platform-outputs.json
./convert_outputs_to_tfvars.sh
```

This generates `utils/utils.auto.tfvars` and copies the generated kubeconfig into `utils/` when available.

#### 3. Apply `utils/`

```bash
cd ../utils
terraform init
terraform plan
terraform apply
```

#### 4. Deploy your application workloads

Example:

```bash
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.11/samples/bookinfo/platform/kube/bookinfo.yaml
```

## Certificates and DNS

Certificates are issued through cert-manager using HTTP-01 via Gateway API.

The usual sequence is:

1. the Gateway gets a public address
2. `external-dns` creates `A` and `TXT` records
3. cert-manager creates temporary ACME solver `HTTPRoute` resources
4. the certificate becomes `Ready`
5. `gateway-tls-secret` is populated

The `HTTPRoute` resources in [httproute.tf](/Users/sonamsamdupkhangsar/Documents/github/do-k8-terraform-1/utils/httproute.tf) include explicit `external-dns` hostname annotations to make DNS publication more reliable.

## PostgreSQL

PostgreSQL clusters are defined through the reusable module in [main.tf](/Users/sonamsamdupkhangsar/Documents/github/do-k8-terraform-1/utils/pg-clusters/main.tf).

Root-level cluster declarations live in [postgres-applications.tf](/Users/sonamsamdupkhangsar/Documents/github/do-k8-terraform-1/utils/postgres-applications.tf) and are driven by the `postgres_clusters` variable in [variables.tf](/Users/sonamsamdupkhangsar/Documents/github/do-k8-terraform-1/utils/variables.tf).

This lets you define one Postgres cluster per application without copying raw Terraform resources.

## Verification Commands

### Gateway and routes

```bash
kubectl get gateway -n main
kubectl get gateway -n main -o yaml
kubectl get httproute -n main
kubectl get httproute -n main -o yaml
```

### DNS

```bash
dig bookinfo.springauth.com
dig hipstershop.springauth.com
dig NS springauth.com +short
```

### Certificates

```bash
kubectl get certificate -n main
kubectl get challenge -n main
kubectl describe certificate -n main letsencrypt-certificate
kubectl logs -n cert-manager deploy/cert-manager --tail=200
```

### external-dns

```bash
kubectl logs -n main deploy/external-dns --tail=200
```

### PostgreSQL

```bash
kubectl get pods -A
kubectl get pvc -A
```

## Destroy

Destroy `utils/` first, then `platform/`:

```bash
make utils-destroy
make platform-destroy
```

Or manually:

```bash
cd utils
terraform destroy

cd ../platform
terraform destroy
```

## Troubleshooting Notes

- If cert-manager reports `no such host` or `SERVFAIL`, start with DNS, not the certificate resource.
- If `external-dns` logs `All records are already up to date` but your hostname is `NXDOMAIN`, inspect the Gateway and `HTTPRoute` status closely.
- If the Gateway is not `Programmed=True`, DNS publication and certificate issuance will usually stall.
- If the domain already exists in DigitalOcean, do not try to recreate it. Use `create_domain = false`.

## Helpful Commands

Get Kubernetes versions from DigitalOcean:

```bash
doctl kubernetes options versions
```

Watch certificate readiness:

```bash
kubectl get certificate -n main -w
```

Watch ACME challenges:

```bash
kubectl get challenge -n main -w
```

Show the commit history for a file:

```bash
git log -p -- <filepath>
```
