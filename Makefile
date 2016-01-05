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

remove_vpc:
	cd terraform/example &&\
		terraform get &&\
		terraform destroy -var "ami=$(1)"

.PHONY: \
	build_ami \
	plan_vpc \
	graph_vpc \
	build_vpc
