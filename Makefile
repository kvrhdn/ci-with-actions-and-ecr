PROJECT=hello-world

USER=${PROJECT}-ci

AWS_ACCOUNT=436315329878
AWS_REGION=eu-west-1

# Setup infra

create_ecr:
	aws ecr create-repository --repository-name ${PROJECT} --region ${AWS_REGION}

	aws ecr put-lifecycle-policy						\
		--repository-name ${PROJECT}					\
		--region ${AWS_REGION}						\
		--lifecycle-policy-text file://infra/ecr-lifecycle.json

create_user:
	aws iam create-user --user-name ${USER}

	# ensure the resource defined in iam-policy-access-ecr.json matches with your repository
	aws iam put-user-policy							\
		--user-name ${USER}						\
		--policy-name ecr-${PROJECT}					\
		--policy-document file://infra/iam-policy-access-ecr.json

	aws iam create-access-key --user-name ${USER}

	echo "Add AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY to the secrets of your repository"

# Interact with AWS ECR

REPOSITORY=${AWS_ACCOUNT}.dkr.ecr.${AWS_REGION}.amazonaws.com/${PROJECT}

ecr_login:
	aws ecr get-login-password --region ${AWS_REGION} | docker login -u AWS --password-stdin ${REPOSITORY}

# ecr get-login changed between v1 and v2
# https://docs.aws.amazon.com/cli/latest/userguide/cliv2-migration.html#cliv2-migration-ecr-get-login
ecr_login_cli_v1:
	aws ecr get-login --no-include-email | sh

ecr_latest_version:
	aws ecr describe-images							\
		--repository-name ${PROJECT}					\
		--region ${AWS_REGION}						\
		--query 'sort_by(imageDetails,&imagePushedAt)[-1]'		\
	| jq '.imageTags[0]'

ecr_pull_latest:
	docker pull ${REPOSITORY}:$(shell make -s ecr_latest_version)
