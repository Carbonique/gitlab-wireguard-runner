#!/bin/sh

# 1. Get Pipeline IDs for all currently scheduled pipelines for project in which this pipeline runs.
curl --request GET \
     --header "PRIVATE-TOKEN:$PIPELINE_ACCESS_TOKEN" \
    "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/pipeline_schedules" | jq '.[] .id' > pipeline_id_list.txt

# 2. Remove all those scheduled pipelines.
while read p; do
  curl --request DELETE \
  --header "PRIVATE-TOKEN:$PIPELINE_ACCESS_TOKEN" \
 "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/pipeline_schedules/$p"
done <pipeline_id_list.txt

# 3. Remove temporary file in which pipeline ids are stored.
rm pipeline_id_list.txt



