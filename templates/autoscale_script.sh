# #!/bin/bash

# # Don't make a mess of /
# mkdir -p /tmp/contrast
# cd /tmp/contrast

# region={{ teamserver_region }}
# # hard code to us-east-1, we don't need to replicate these artifacts
# agent_artifact_region=us-east-1
# # enforce contrast_data_directory for older bundles
# contrast_data_dir={{ teamserver_contrast_datadir }}

# # full bucket path ie contrast-production-artifacts/saas or contrast-internal-artifacts
# teamserver_bucket={{ teamserver_asg_bucket }}

# # full bucket path for agents
# teamserver_agent_bucket={{ agent_s3_bucket }}/{{ agent_s3_env}}/agents

# # AWS metadata url timeout :(
# # double timeout every try for 5 tries
# function retry_aws_cmd () {
#   local max_attempts=${ATTEMPTS-5}
#   local timeout=${TIMEOUT-1}
#   local attempt=0
#   local exitCode=0

#   while (( $attempt < $max_attempts ))
#   do
#     "$@"
#     exitCode=$?

#     if [[ $exitCode == 0 ]]
#     then
#       break
#     fi

#     echo "Command failed: Retrying in $timeout.." 1>&2
#     sleep $timeout
#     attempt=$(( attempt + 1 ))
#     timeout=$(( timeout * 2 ))
#   done

#   if [[ $exitCode != 0 ]]
#   then
#     echo "Unable to: ($@)" 1>&2
#   fi

#   return $exitCode
# }

# deploy () {
#   artifact=$1
#   # change user to tomcat to not change ownership of /opt/codedeploy dirs
#   runuser -l tomcat -c "/opt/codedeploy-agent/bin/codedeploy-local --bundle-location $artifact --type zip"
# }

# download_codedeploy_bundle () {
#     artifact=$1
#     required=$2
#     echo "Attempting to download version.txt from s3 ($teamserver_bucket)"
#     retry_aws_cmd aws s3 --region $region cp s3://"$teamserver_bucket"/"$artifact"/version.txt "$artifact"_version.txt
#     VERSION=$(cat "$artifact"_version.txt)
#     if [[ -z $VERSION ]]; then
#         return "Skipping.  Specified version not found"
#     fi

#     echo "Preparing to download latest deployed version of the artifact for $artifact"
#     if [[ $(retry_aws_cmd aws s3 --region $region ls s3://"$teamserver_bucket"/"$artifact"/"$VERSION"/latest.txt) ]]; then
#       echo "latest.txt is present"
#       retry_aws_cmd aws s3 --region $region cp s3://"$teamserver_bucket"/"$artifact"/"$VERSION"/latest.txt "$artifact"_latest.txt
#       latest_artifact=$(cat "$artifact"_latest.txt)

#       if [[ $(retry_aws_cmd aws s3 --region $region ls s3://"$teamserver_bucket"/"$artifact"/"$VERSION"/"$latest_artifact") ]]; then
#         echo "latest_artifact present"
#         retry_aws_cmd aws s3 --region $region cp s3://"$teamserver_bucket"/"$artifact"/"$VERSION"/"$latest_artifact" .

#         echo "Deploying $latest_artifact"
#         full_path_of_artifact=$(readlink -f $latest_artifact)
#         deploy $full_path_of_artifact

#         echo "Remove temporary placement of artifacts"
#         rm $latest_artifact
#       else
#         echo "latest_artifact not present"
#         return
#       fi
#     else
#       echo "latest.txt not present"
#       return
#     fi
# }

# echo "Now downloading TeamServer"
# download_codedeploy_bundle contrast-ui
# chown -R tomcat:tomcat /var/www/
# chmod 755 -R /var/www/
# download_codedeploy_bundle teamserver
