define DOCKER_ANSIBLE_AMI
	docker run --rm \
	 -v $(OUTPUT_DIR):/output \
	 -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	 -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	 -e AWS_DEFAULT_REGION=us-west-2 \
	 -e BUILD_NUMBER=$(BUILD_NUMBER) \
	 -e BRANCH=$(BRANCH) \
	 bowtie-lite-ansible $(1)
endef

define DOCKER_TERRAFORM
	docker run --rm \
	 -v $(shell pwd):/output \
	 -e AWS_ACCESS_KEY_ID=$(AWS_ACCESS_KEY_ID) \
	 -e AWS_SECRET_ACCESS_KEY=$(AWS_SECRET_ACCESS_KEY) \
	 -e AWS_DEFAULT_REGION=us-west-2 \
	 -e ENV=$(2) \
	 bowtie-lite-terraform $(1) \
	   -var 'min_capacity=$(MIN_CAPACITY)' \
		 -var 'current_capacity=$(CURRENT_CAPACITY)' \
		 -var 'ami=$(BOWTIE_AMI)'
endef

build_ami:
	cd packer &&\
	  packer build ami.json

plan_vpc:
	cd terraform/example &&\
	  terraform get &&\
	  terraform plan -var "ami=$(1)"

graph_vpc:
	cd terraform/example &&\
	  terraform get &&\
	  terraform graph -module-depth=-1 

build_vpc:
	cd terraform/example &&\
	  terraform get &&\
	  terraform apply -var "ami=$(1)"


.PHONY: \
	build_ami \
	plan_vpc \
	graph_vpc \
	build_vpc
