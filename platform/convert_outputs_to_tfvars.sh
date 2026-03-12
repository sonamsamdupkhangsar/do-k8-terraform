#!/bin/bash
# Converts platform-outputs.json to utils.auto.tfvars for Terraform

jq -r 'to_entries[] | "\(.key) = \(.value.value|@json)"' ../utils/platform-outputs.json > ../utils/utils.auto.tfvars

# Append Spaces credentials from production.tfvars if present
# Append Spaces credentials and other required vars from production.tfvars if present


# Copy single-line properties
grep -E '^(spaces_access_id|spaces_secret_key|bucket_endpoint_url|spaces_region|digitalocean_token)\s*=' ../platform/production.auto.tfvars >> ../utils/utils.auto.tfvars

# Copy kubeconfig file to utils folder
KUBECONFIG_FILE=$(jq -r '.kube_config_filename.value' ../utils/platform-outputs.json 2>/dev/null)
if [ -n "$KUBECONFIG_FILE" ] && [ -f "../platform/$KUBECONFIG_FILE" ]; then
	cp "../platform/$KUBECONFIG_FILE" ../utils/
fi
