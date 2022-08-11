#!/usr/bin/env bash

set -e

TF_PARALLELISM=${TF_PARALLELISM:-10}
TF_STATE_BUCKET=${TF_STATE_BUCKET:-}
TF_STATE_DYNAMODB_TABLE=${TF_STATE_DYNAMODB_TABLE:-}
TF_TERRAFORM_EXECUTABLE=${TF_TERRAFORM_EXECUTABLE:-terraform}
TF_ENVIRONMENT_ID=${TF_ENVIRONMENT_ID:-}
TF_AUTO_APPLY_SAVED_PLAN=${TF_AUTO_APPLY_SAVED_PLAN:-}
TF_VAR_terraform_state_location=${TF_VAR_terraform_state_location:-}
TF_SKIP_BACKEND_INIT=${TF_SKIP_BACKEND_INIT:-}

# Local tf.sh.env
if [ -f tf.sh.env ]; then
    # Load default Environment Variables
    echo "Set default from tf.sh.env"
    export $(cat tf.sh.env | grep -v '#' | awk '/=/ {print $1}')
fi

if [ -z "${TF_STATE_PATH}" ]; then TF_STATE_PATH=${TF_STATE_PATH:-}; fi
if [ -z "${TF_STATE_FILE_NAME}" ]; then TF_STATE_FILE_NAME=${TF_STATE_FILE_NAME:-main.tfstate}; fi
if [ -z "${TF_DATA_DIR_PER_ENV}" ]; then TF_DATA_DIR_PER_ENV=${TF_DATA_DIR_PER_ENV:-true}; fi
if [ -z "${HASH_COMMAND}" ]; then HASH_COMMAND=${HASH_COMMAND:-sha1sum}; fi

# Set terraform version
[ -e ./.terraform_executable ] && export TF_TERRAFORM_EXECUTABLE="$(cat .terraform_executable)"

if [ "$#" -eq 0 ] || [ "$*" == "-h" ] || [ "$*" == "-h" ]; then
    echo "This is a Terraform wrapper to dynamically pick different state files for different environment"
    echo "Wrapper will attempt to pick defaults and setup a correct bucket"
    echo "All script argumetns will be passed to Terraform"
    echo ""
    echo "WARNING: If we are applying changes, do not ask for interactive approval"
    echo ""
    echo "Example:"
    echo "tf plan"
    echo "tf plan -destroy"
    echo "tf apply"
    echo "tf apply -destroy"
    echo ""
    echo "tf will indentify your env based on current AWS account id and region"
    echo ""
    echo "For apply saved plan please set TF_AUTO_APPLY_SAVED_PLAN variable with any value"
    echo "Example:"
    echo "TF_AUTO_APPLY_SAVED_PLAN=true ./tf.sh apply plan.tfplan"
    echo ""
    echo "WARNING: This plan will be applied without any confirmation"
    echo ""
    exit 0
fi

if [ -z "${AWS_DEFAULT_REGION}" ]; then
    echo "Define env variable AWS_DEFAULT_REGION (should be your region name, ex us-east-1) and try again"
    exit 1
fi

if [ -z "${TF_ENVIRONMENT_ID}" ]; then
    if [ -z $(which aws) ]; then
        echo "aws cli is required to identify environment id. https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html"
        exit 1
    fi
    export AWS_ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
    if [ -z "${AWS_ACCOUNT_ID}" ]; then
        echo "Can't determine aws account id by running 'aws sts get-caller-identity'. Please make sure that you have valid credentials and try again"
        echo "Or provide your own TF_ENVIRONMENT_ID"
        exit 1
    fi
    export TF_ENVIRONMENT_ID="${AWS_ACCOUNT_ID}-${AWS_DEFAULT_REGION}"
    echo "Based on aws config assuming TF_ENVIRONMENT_ID=${TF_ENVIRONMENT_ID}"
else
    echo "Using user provided TF_ENVIRONMENT_ID=${TF_ENVIRONMENT_ID}"
fi

# Enable TF_DATA_DIR_PER_ENV
[ "${TF_DATA_DIR_PER_ENV}" == "true" ] && export TF_DATA_DIR=".terraform.${TF_ENVIRONMENT_ID}"

if [ -z "${TF_STATE_BUCKET}" ]; then
    # Use hashed environment id to avoid account id/region disclosure via S3 DNS name
    # in this way it is hard to predict the bucket name and attacker won't be able to
    # setup buckets in advance to capture your state file
    HASHED_ENVIRONMENT_ID=$(echo -n ${TF_ENVIRONMENT_ID} | "${HASH_COMMAND}" | awk '{print $1}')
    export TF_STATE_BUCKET="terraform-state-${HASHED_ENVIRONMENT_ID}"
fi

if [ -z "${TF_STATE_DYNAMODB_TABLE}" ]; then
    HASHED_ENVIRONMENT_ID=$(echo -n ${TF_ENVIRONMENT_ID} | "${HASH_COMMAND}" | awk '{print $1}')
    export TF_STATE_DYNAMODB_TABLE="terraform-state-${HASHED_ENVIRONMENT_ID}"
fi

if [ -z "${TF_STATE_PATH}" ]; then
    # Check if we are in git repo
    GIT_REPO_TEST=$(git rev-parse --git-dir 2>/dev/null || true)
    if [ -z "${GIT_REPO_TEST}" ]; then
        echo "tf expects you to run inside git repo since it will be using git repo name as part of the state"
        exit 1
    fi

    # Try to get remote repo name
    # we can't use just local repo name because jenkins pipelines
    # clone repos to directories with abracadabra names which are not the same
    # as actual repo name
    if [ ! -z "$(git config --get remote.origin.url)" ]; then
        REPO_NAME=$(basename -s .git $(git config --get remote.origin.url))
        echo "Using remote repo name \"${REPO_NAME}\" as a part of Terraform state path"
    else
        # If there are no remote repo then fall back to local repo directory name
        REPO_NAME=$(basename $(git rev-parse --show-toplevel))
        echo "Can not find remote repo name. Using local repo name \"${REPO_NAME}\" as a part of Terraform state path"
    fi
    export TF_STATE_PATH="terraform/${REPO_NAME}/${TF_STATE_FILE_NAME}"
fi

if [ -z "${TF_VAR_terraform_state_location}" ]; then
    # Set terraform variable terraform_state_location for tags
    export TF_VAR_terraform_state_location="s3://${TF_STATE_BUCKET}/${TF_STATE_PATH}"
fi

echo "Using remote state s3://${TF_STATE_BUCKET}/${TF_STATE_PATH}"
echo "Using lock table ${TF_STATE_DYNAMODB_TABLE}"

set -x

# Allow to skip terraform init with new backend
if [ -z "${TF_SKIP_BACKEND_INIT}" ]; then
    ${TF_TERRAFORM_EXECUTABLE} init -backend-config "key=${TF_STATE_PATH}" -backend-config "bucket=${TF_STATE_BUCKET}" -backend-config "region=${AWS_DEFAULT_REGION}" -backend-config "dynamodb_table=${TF_STATE_DYNAMODB_TABLE}" -backend-config "encrypt=true"
else
    echo "Skipping terraform backend initialization.."
fi

# figure out which env file to use
if [ -e ./${TF_ENVIRONMENT_ID}.tfvars ]; then
    # If we are not applying saving plan, add -var-file
    if [ -z "${TF_AUTO_APPLY_SAVED_PLAN}" ]; then
        export TF_CLI_ARGS_plan="-var-file=./${TF_ENVIRONMENT_ID}.tfvars"
        export TF_CLI_ARGS_import="-var-file=./${TF_ENVIRONMENT_ID}.tfvars"
        export TF_CLI_ARGS_destroy="-var-file=./${TF_ENVIRONMENT_ID}.tfvars"
        export TF_CLI_ARGS_refresh="-var-file=./${TF_ENVIRONMENT_ID}.tfvars"
        # If we are applying changes, do not ask for interactive approval. Work for any apply commands (-destroy, -refresh-only and etc)
        export TF_CLI_ARGS_apply="-var-file=./${TF_ENVIRONMENT_ID}.tfvars -auto-approve"
    fi
fi

${TF_TERRAFORM_EXECUTABLE} $*