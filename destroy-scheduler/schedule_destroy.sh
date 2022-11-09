#!/bin/sh

# 1. Remove all scheduled destroys
${CI_PROJECT_DIR}/destroy-scheduler/remove_all_scheduled_destroys.sh

# 2. Get current minute
currentminute=$(date +"%M")

# 3. Schedule destroy pipeline to kick off in 59 minutes. 
    # Note 1: Could have been 1 hour, in which case you could use the current minute 
    # (As cron trigger for that minute already passed). But for safety, I took 59 minutes.
    # Note 2: Be aware GitLab free tier only runs cron jobs every 5 minutes! (Which is not a problem for my use case)
    # Note 3: Would be better to use [[ ]], but we need sh compatibility for Alpine Linux
if [ $currentminute -eq 0 ] ; then
    cronminute=59
else 
    cronminute="$(($currentminute - 1))"
fi

# 4. Sent request to API
curl --request POST --header "PRIVATE-TOKEN:$PIPELINE_ACCESS_TOKEN" \
    --form description="Destroy runners" \
    --form ref="main" \
    --form cron="$cronminute * * * *" --form cron_timezone="$TIMEZONE" \
    --form active="true" "https://gitlab.com/api/v4/projects/$CI_PROJECT_ID/pipeline_schedules"