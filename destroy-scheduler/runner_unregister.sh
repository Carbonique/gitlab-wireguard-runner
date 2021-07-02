#!/bin/sh

#1. Get id's from runner starting with name 'wireguard-runner'
curl --header "PRIVATE-TOKEN: $PIPELINE_ACCESS_TOKEN" "https://gitlab.com/api/v4/runners" | jq '.[] | select(.description|startswith("wireguard-runner")) | .id' > runner_id_list

#2. Unregister runners with those ID's
while read id; do
    curl --request DELETE --header "PRIVATE-TOKEN: $PIPELINE_ACCESS_TOKEN" "https://gitlab.com/api/v4/runners/${id}"
done <runner_id_list

rm runner_id_list



