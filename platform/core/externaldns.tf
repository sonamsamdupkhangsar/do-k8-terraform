resource "helm_release" "external_dns_release" {
  name       = "external-dns"
  # Reference the repository name defined in the helm_repository resource
  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  namespace = "backend"
  # It's good practice to ensure the secret exists before trying to deploy the chart
  #depends_on = [local.http_routes_yaml]
  
  # Use a heredoc string to insert the YAML values directly
  values = [<<EOF
env:
  - name: DO_TOKEN
    valueFrom:
      secretKeyRef:
        name: digitalocean-dns
        key: access-token      

provider:
  name: digitalocean

policy: sync
txtOwnerId: gateway-api

sources:
  - service
  - ingress
  - gateway-grpcroute
  - gateway-httproute
EOF
  ]
}