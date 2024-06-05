#!/bin/bash

# Define the base URL for the API
customer="replace me"
# Define the token for authentication
pat='replace me'

base_url="https://api.$customer.coremedia.cloud"

environments=("uat" "uat2" "production")

containers=("cae-preview" "cae-live" "caefeeder-live" "caefeeder-preview" "content-feeder" "content-management-server" "headless-server-live" "headless-server-preview" "master-live-server" "replication-live-server" "studio-client" "solr" "studio-server" "user-changes" "workflow-server")

expToken=$(curl -sX POST "$base_url/v1/token" -H "Authorization: Bearer $pat" | jq -r .data.token)

# Loop over each environment
for env in "${environments[@]}"; do
  echo "Environment: $env"
  for container in "${containers[@]}"; do
    echo "  Container: $container"
    # Get the list of containers for this environment
    props=$(curl -s -H "Authorization: Bearer $expToken" "$base_url/v1/environments/$env/containers/$container/properties" | jq -r '.data.items[]');
    filename="$env-$container.properties"
    allProps=""
    for prop in $props; do
      # Get the value of the property
      propsValue=$(curl -s -H "Authorization: Bearer $expToken" "$base_url/v1/environments/$env/containers/$container/properties/$prop");
      #echo "    Property: $prop"  " -> Value: $propsValue"
      entry="$prop$propsValue"
      allProps=$allProps"\n"$entry
    done
    if [ -z "$allProps" ]
    then
      echo "no properties found for $env $container"
    else
       echo -e $allProps > $filename
       # sort keys alphabetically to make it easier to compare files
       sort $filename > $filename".sorted"
       rm $filename
    fi
  done
done
