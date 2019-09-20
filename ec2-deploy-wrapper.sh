#! /bin/bash -e


STACK_PREFIX=
DEPLOY_ENV=
IMAGE_NAME=
EC2_REGION=
TAG_NAME=
DESIRED_COUNT="1"
CLUSTER=
S3_BUCKET=
SERVICE_NAME_OVERRIDE=
IS_GATEWAY=
IS_API=
TARGET_STACK_NAME_OVERRIDE=
TARGET_CLUSTER_STACK=
TARGET_CLUSTER_LOGICAL_ID=
TARGET_GROUP_STACK=
TARGET_GROUP_LOGICAL_ID=

usage() {
  cat << EOF
usage: ec2-deploy-wrapper.sh
  --deploy-env <value>
  --image-name <value>
  --tag-name <value>
  --s3-bucket <value>
  --gateway
  --api
  --target-cluster-stack <value>
  --target-cluster-logical_id <value>
  --target-group-stack <value>
  --target-group-logical_id <value>
  [--service-name <value> (default: image-name)]
  [--stack-name-prefix <value> (default: dynamic lookup)]
  [--region <value> (default: dynamic lookup)]
  [--desired-count <value> (default: 1)]
  [--cluster <value> (default: dynamic lookup)]
  [--stack-name-override <value>]

EOF
}

while [ "$1" != "" ]; do
    case $1 in
         --gateway )
                          IS_GATEWAY="1"
                          ;;
        --api )
                          IS_API="1"
                          ;;
        --stack-name-override )        shift
                          TARGET_STACK_NAME_OVERRIDE=$1
                          ;;
        --service-name )        shift
                          SERVICE_NAME_OVERRIDE=$1
                          ;;
        --stack-name-prefix )        shift
                          STACK_PREFIX=$1
                          ;;
        --deploy-env )        shift
                          DEPLOY_ENV=${1,,}
                          ;;
        --image-name )        shift
                          IMAGE_NAME=${1,,}
                          ;;
        --region )        shift
                          EC2_REGION=$1
                          ;;
        --tag-name )        shift
                          TAG_NAME=$1
                          ;;
        --desired-count )        shift
                          DESIRED_COUNT=$1
                          ;;
        --cluster )        shift
                          CLUSTER=$1
                          ;;
	    --target-cluster-stack )   shift
                  		  TARGET_CLUSTER_STACK=$1
                  		  ;;
	    --target-cluster-logical_id )   shift
                  		  TARGET_CLUSTER_LOGICAL_ID=$1
                  		  ;;
	    --target-group-stack )   shift
                  		  TARGET_GROUP_STACK=$1
                  		  ;;
	    --target-group-logical_id )   shift
                  		  TARGET_GROUP_LOGICAL_ID=$1
                  		  ;;                  		                    		                    		                     
        -h | --help )     usage
                          exit
                          ;;
        * )               echo "Unknown option: $1"
                          usage
                          exit 1
    esac
    shift
done

[ ! -z "$DEPLOY_ENV" ] || ( echo "Missing --deploy-env" && usage && exit 1)
[ ! -z "$IMAGE_NAME" ] || ( echo "Missing --image-name" && usage && exit 1)
[ ! -z "$TAG_NAME" ] || ( echo "Missing --tag-name" && usage && exit 1)
[ ! -z "$TARGET_CLUSTER_STACK" ] || ( echo "Missing --target-cluster-stack" && usage && exit 1)
[ ! -z "$TARGET_CLUSTER_LOGICAL_ID" ] || ( echo "Missing --target-cluster-logical_name" && usage && exit 1)
[ ! -z "$TARGET_GROUP_STACK" ] || ( echo "Missing --target-group-stack" && usage && exit 1)
[ ! -z "$TARGET_GROUP_LOGICAL_ID" ] || ( echo "Missing --target-group-logical_name" && usage && exit 1)

if [ -z "$IS_GATEWAY" ] && [ -z "$IS_API" ]; then
  echo "Missing --is-gateway or --is-api" && usage && exit 1
fi

if [ ! -z "$IS_GATEWAY" ] && [ ! -z "$IS_API" ]; then
  echo "Only one of --is-gateway or --is-api" && usage && exit 1
fi

randomString() {
  echo `cat /dev/urandom | tr -dc 'a-z' | fold -w 21 | head -n 1`
}

if [ -z "$EC2_REGION" ]; then
  EC2_AVAIL_ZONE=$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
  EC2_REGION="`echo \"$EC2_AVAIL_ZONE\" | sed -e 's:\([0-9][0-9]*\)[a-z]*\$:\\1:'`"
fi
aws configure set default.region "$EC2_REGION"
aws configure set region "$EC2_REGION"

##########
CONTAINER_NAME="${IMAGE_NAME}"

if [ -z "$STACK_PREFIX" ]; then
  INSTANCE_ID=$(curl http://169.254.169.254/latest/meta-data/instance-id)
  RESOURCE_TAGS=$(aws ec2 describe-tags --filters "Name=resource-id,Values=${INSTANCE_ID}")
  STACK_PREFIX=$(echo "${RESOURCE_TAGS}" | jq ".Tags[]" | jq 'select(.Key == "StackPrefix")' | jq -r ".Value")
fi

if [ ! -z "${SERVICE_NAME_OVERRIDE}" ]; then
  SERVICE_NAME="${SERVICE_NAME_OVERRIDE}${DEPLOY_ENV}"
else
  SERVICE_NAME="${IMAGE_NAME}${DEPLOY_ENV}"
fi

CLUSTER_STACK_NAME="${TARGET_CLUSTER_STACK}"
TASK_NAME="${IMAGE_NAME}-${DEPLOY_ENV}"

if [ -z "$TARGET_STACK_NAME_OVERRIDE" ]; then
  TARGET_STACK_NAME="${STACK_PREFIX}${IMAGE_NAME}-${DEPLOY_ENV}"
else
  TARGET_STACK_NAME="${TARGET_STACK_NAME_OVERRIDE}"
fi

STACK_DATA=$(aws cloudformation describe-stacks \
  --stack-name ${TARGET_STACK_NAME} \
  || echo "")

TARGET_CLUSTER=$(aws cloudformation describe-stack-resource \
  --stack-name "${CLUSTER_STACK_NAME}" \
  --logical-resource-id "${TARGET_CLUSTER_LOGICAL_ID}" \
  | jq -r ".StackResourceDetail.PhysicalResourceId")
  
CLOUD_WATCH_LOGS_GROUP=$(aws cloudformation describe-stack-resource \
  --stack-name "${CLUSTER_STACK_NAME}" \
  --logical-resource-id "cloudWatchLogsGroup" \
  | jq -r ".StackResourceDetail.PhysicalResourceId")  

if [ -z "$STACK_DATA" ]; then
  echo "STACK EMPTY"
  echo "Creating ${DEPLOY_ENV} Stack: ${TARGET_STACK_NAME}"

  TARGET_GROUP=$(aws cloudformation describe-stack-resource \
  --stack-name "${TARGET_GROUP_STACK}" \
  --logical-resource-id "${TARGET_GROUP_LOGICAL_ID}" \
  | jq -r ".StackResourceDetail.PhysicalResourceId")

  # TODO move password loading into base docker
  if [ ! -z "$IS_GATEWAY" ]; then
    aws cloudformation create-stack \
        --stack-name "${TARGET_STACK_NAME}" \
        --template-body file://ecs-${CONTAINER_NAME}.yaml \
         --parameters \
          "ParameterKey=ServicesCluster,ParameterValue=${TARGET_CLUSTER}" \
          "ParameterKey=ServiceName,ParameterValue=${SERVICE_NAME}" \
          "ParameterKey=ContainerName,ParameterValue=${CONTAINER_NAME}" \
          "ParameterKey=ContainerTag,ParameterValue=${TAG_NAME}" \
          "ParameterKey=TargetGroup,ParameterValue=${TARGET_GROUP}" \
          "ParameterKey=CloudWatchLogsGroup,ParameterValue=${CLOUD_WATCH_LOGS_GROUP}" \
        --tags \
          "Key=KS,Value=True" \
          "Key=StackPrefix,Value=${IMAGE_NAME}" \
          "Key=StackType,Value=${DEPLOY_ENV}" \
          "Key=CanPromote,Value=true" \
        --timeout-in-minutes 10  
    fi

    if [ ! -z "$IS_API" ]; then
      aws cloudformation create-stack \
        --stack-name "${TARGET_STACK_NAME}" \
        --template-body file://ecs-${CONTAINER_NAME}.yaml \
        --parameters \
            "ParameterKey=ServicesCluster,ParameterValue=${TARGET_CLUSTER}" \
            "ParameterKey=ServiceName,ParameterValue=${SERVICE_NAME}" \
            "ParameterKey=ContainerName,ParameterValue=${CONTAINER_NAME}" \
            "ParameterKey=ContainerTag,ParameterValue=${TAG_NAME}" \
            "ParameterKey=TargetGroup,ParameterValue=${TARGET_GROUP}" \
            "ParameterKey=CloudWatchLogsGroup,ParameterValue=${CLOUD_WATCH_LOGS_GROUP}" \
          --tags \
            "Key=KS,Value=True" \
            "Key=StackPrefix,Value=${IMAGE_NAME}" \
            "Key=StackType,Value=${DEPLOY_ENV}" \
            "Key=CanPromote,Value=true" \
          --timeout-in-minutes 10  
    fi

  echo "Waiting for ${TARGET_STACK_NAME} completion"
  aws cloudformation wait stack-create-complete \
    --stack-name "${TARGET_STACK_NAME}"
  echo "${TARGET_STACK_NAME} complete!"
else
  echo "STACK_EXISTS: ${STACK_DATA}"
  if [ -z "${CLUSTER}" ]; then
    CLUSTER=$(aws cloudformation describe-stack-resource \
      --stack-name "${CLUSTER_STACK_NAME}" \
      --logical-resource-id "${TARGET_CLUSTER_LOGICAL_ID}" \
      | jq -r ".StackResourceDetail.PhysicalResourceId")
  fi
  TASK_DEF=$(aws ecs describe-task-definition --task-definition "${TASK_NAME}")
  REVISION=$(echo "${TASK_DEF}" | jq .taskDefinition.revision)


  DOCKER_LOGIN=$(aws ecr get-login --no-include-email )
  ECR_URL=$(echo "${DOCKER_LOGIN}" | cut -d' ' -f7 | sed 's~https://~~')

  EDITED_TASK_DEF=`echo "${TASK_DEF}" \
    | jq ".taskDefinition" \
    | jq ".containerDefinitions[0].image = \"${ECR_URL}/${CONTAINER_NAME}:${TAG_NAME}\"" \
    | jq "del(.revision)" \
    | jq "del(.status)" \
    | jq "del(.taskDefinitionArn)" \
    | jq "del(.compatibilities)" \
    | jq "del(.requiresAttributes)"`

  FAMILY=`echo "${EDITED_TASK_DEF}" | jq -r ".family"`
  echo "${EDITED_TASK_DEF}" > updated-task-def.json
  aws ecs register-task-definition --family "${FAMILY}" --cli-input-json file://updated-task-def.json
  UPDATED_TASK_DEF=$(aws ecs describe-task-definition --task-definition "${TASK_NAME}" )
  OLDREVISION=${REVISION}
  echo "Old Task revision :${OLDREVISION}"
  REVISION=$(echo "${UPDATED_TASK_DEF}" | jq .taskDefinition.revision)
  
  aws ecs deregister-task-definition --task-definition ${TASK_NAME}:${OLDREVISION}

  DESIRED_COUNT=`aws ecs describe-services --services "${SERVICE_NAME}" --cluster "${CLUSTER}"  | jq ".services[].desiredCount"`

  if [ "${DESIRED_COUNT}" = "0" ]; then
    DESIRED_COUNT="1"
    echo "One : ${DESIRED_COUNT}"
  fi
  aws ecs update-service --cluster "${CLUSTER}" --service "${SERVICE_NAME}" --task-definition "${FAMILY}:${REVISION}" --desired-count "${DESIRED_COUNT}"
  aws ecs describe-services --services "${SERVICE_NAME}" --cluster "${CLUSTER}"
fi
