locals {
  # Define the HTTPRoutes YAML content directly within a local variable
  http_routes_yaml = <<-EOT
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: https-bookinfo-route
  namespace: ${var.project_namespace}
spec:
  # Attach to BOTH the HTTP (port 80) and HTTPS (port 443) listeners
  parentRefs:
  - name: tls-gateway
    sectionName: https-1 # Assumes this listener handles port 443 traffic
  hostnames:
  - "bookinfo.springauth.com"
  rules:
  # Rule 1: Route HTTPS traffic (received via 'https-1' listener) to the backend
  - matches:
    - path:
        type: PathPrefix
        value: /details
    backendRefs:
    - name: details
      port: 9080
    # Note: No explicit hostname filter needed here as the parentRef binding to 'https-1' 
    # listener implicitly means this rule only matches port 443 traffic for this hostname.
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: https-hipstershop-route
  namespace: ${var.project_namespace}
spec:
  parentRefs:
  - name: tls-gateway
    sectionName: https-2 # Assumes this listener handles port 443 traffic
  hostnames:
  - "hipstershop.springauth.com"
  rules:
  # Rule 2: Route HTTPS traffic (received via 'https-2' listener) to the backend
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: productpage
      port: 9080
---
# HTTP to HTTPS Redirect Route for bookinfo.springauth.com applies to all subdomains
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name:  http-bookinfo-https-redirect-route
  namespace: ${var.project_namespace}
spec:
  parentRefs:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: tls-gateway
    sectionName: http # Assumes this listener handles port 80 for bookinfo.springauth.com and all its subdomains
  rules:
  # Rule 1: Redirect everything else
  - filters:
    - type: RequestRedirect
      requestRedirect:
        port: 443
        scheme: https
        statusCode: 301  
---
# HTTP to HTTPS Redirect Route for https://hipstershop.springauth.com/ applies to subdomain
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: http-hipstershop-https-redirect-route
  namespace: ${var.project_namespace}
spec:
  parentRefs:
  - group: gateway.networking.k8s.io
    kind: Gateway
    name: tls-gateway
    sectionName: http-2 # Assumes this listener handles port 80 for hipstershop.springauth.com and all its subdomains
  rules:
  - filters:
    - type: RequestRedirect
      requestRedirect:
        port: 443
        scheme: https
        statusCode: 301           
EOT

  # Split the multi-document string into a list of individual YAML strings
  route_docs = split("\n---\n", local.http_routes_yaml)

  # Decode each string into a map and filter out any empty entries (e.g., blank lines)
  decoded_routes = [
    for doc in local.route_docs :
    try(yamldecode(doc), null)
  ]
  
  # Filter out any decoding errors or invalid structure if necessary (simplified)
  valid_routes = [
    for manifest in local.decoded_routes :
    manifest if manifest.kind != null && manifest.metadata != null
  ]
}

# Create a resource for each HTTPRoute found in the YAML
resource "kubernetes_manifest" "app_http_routes" {
  # Iterate over the list of valid route maps using a unique key for each
  for_each = {
    for manifest in local.valid_routes :
    # The key format ensures uniqueness: Kind.Namespace.Name
    "${manifest.kind}.${coalesce(manifest.metadata.namespace, "default")}.${manifest.metadata.name}" => manifest
  }

  # The manifest content for this specific resource instance is the value from the loop
  manifest = each.value
  
  # Ensure the Gateway exists before trying to apply the HTTPRoute that references it
  # Note: The resource name below should match your actual Gateway resource name in HCL.
  # depends_on = [ kubernetes_manifest.tls_gateway ] 
}
