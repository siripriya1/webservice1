#! /bin/bash -e

IMAGE_NAME=
TAG_NAME="latest"
IS_MOCK=

usage() {
  cat << EOF
usage: docker-push-wrapper.sh
  --image-name <value>
  [--tag-name <value> (default: latest)]
EOF
}

while [ "$1" != "" ]; do
    case $1 in
        --image-name )        shift
                          IMAGE_NAME=$1
                          ;;
        --tag-name )        shift
                          TAG_NAME=${1}
                          ;;
        --mock )        IS_MOCK="1"
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

if [ -z "$IMAGE_NAME" ]; then
  usage
  exit 1
fi


EC2_REGION="us-east-1"
DOCKER_LOGIN="$(aws ecr get-login --no-include-email --region $EC2_REGION)"

$DOCKER_LOGIN

PASSWORD=$(echo $DOCKER_LOGIN | cut -d' ' -f6)
ECR_URL=$(echo $DOCKER_LOGIN | cut -d' ' -f7 | sed 's~https://~~')
echo "ECR_URL: $ECR_URL"

DESCRIBE_RESULT=$(aws ecr describe-repositories --region "$EC2_REGION" --repository-names "$IMAGE_NAME" | jq ".repositories[]" | jq -r 'select(.repositoryName == "'${IMAGE_NAME}'")')
echo "$DESCRIBE_RESULT"
if [ -z "$DESCRIBE_RESULT" ]; then
  echo "NOT FOUND"
  aws ecr create-repository --region "$EC2_REGION" --repository-name "$IMAGE_NAME"
else
  echo "FOUND"
fi

if [ ! -z "$IS_MOCK" ]; then
  docker pull "${ECR_URL}/${IMAGE_NAME}:${TAG_NAME}"
  docker tag "${ECR_URL}/${IMAGE_NAME}:${TAG_NAME}" "${IMAGE_NAME}:latest"
fi

docker tag "${IMAGE_NAME}:${TAG_NAME}" "${ECR_URL}/${IMAGE_NAME}:${TAG_NAME}"
docker push "${ECR_URL}/${IMAGE_NAME}:${TAG_NAME}"
