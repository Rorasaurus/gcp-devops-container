include config

# Container variables
CURR_DIR:=$(dir $(realpath $(lastword $(MAKEFILE_LIST))))
APP_DIR:=$(realpath $(CURR_PATH)../)
APP:=$(notdir $(APP_DIR))
IMAGE = "$(APP)"
CONTAINER = "$(APP)-container"
USER = $(shell whoami)

# Configure shell
ifeq ($(USE-ZSH), true)
ENTRY = "/bin/zsh"
else
ENTRY = "/bin/bash"
endif

# Configure Container Registry path
ifeq ($(CI_REGISTRY_IMAGE), undefined)
	CONTAINER_REGISTRY_PATH := $(shell git remote get-url origin | sed -e 's/:/\:5500\//g' | sed -e 's/ssh\/\/\///g' | sed -e 's/.git@//g' | sed -e 's/.git//g')
else
	CONTAINER_REGISTRY_PATH := ${CI_REGISTRY_IMAGE}
endif

# Detect OS
UNAME_S := $(shell uname -s)
ifeq ($(UNAME_S),Linux)
USER_HOME := "/home/$(USER)"
endif
ifeq ($(UNAME_S),Darwin)
USER_HOME := "/Users/$(USER)"
endif

# Configure container
ifeq ($(DOCKER), true)
RUNTIME = "docker"
else ifeq ($(DOCKER), false)
RUNTIME = "podman"
endif

# Configure Terraform
ifeq ($(TERRAFORM), latest)
TERRAFORMV = terraform
else ifeq ($(TERRAFORM), disabled)
TERRAFORMV = disabled
else
TERRAFORMV = "terraform-$(TERRAFORM).x86_64"
endif

# Configure Packer
ifeq ($(PACKER), latest)
PACKERV = packer
else ifeq ($(PACKER), disabled)
PACKERV = disabled
else
PACKERV = "packer-$(PACKER).x86_64"
endif

# Configure Ansible
ifeq ($(ANSIBLE), latest)
ANSIBLEV = ansible
else ifeq ($(ANSIBLE), disabled)
ANSIBLEV = disabled
else
ANSIBLEV = "ansible-$(ANSIBLE).fc$(FEDORA).noarch"
endif

# Configure gcloud - Somewhat pointless but more of a placeholder
ifeq ($(GCLOUD), latest)
GCLOUDV = latest
else ifeq ($(GCLOUD), disabled)
GCLOUDV = disabled
endif

build:
	@echo "Building with..."
	@echo "Fedora				: $(FEDORA)"
	@echo "Terraform			: $(TERRAFORM)"
	@echo "Packer				: $(PACKER)"
	@echo "Ansible				: $(ANSIBLE)"
	-@sleep 3
	@$(RUNTIME) build \
		--build-arg fedorav=$(FEDORA) \
		--build-arg app=$(APP) \
		--build-arg user=$(USER) \
		--build-arg terraformv=$(TERRAFORMV) \
		--build-arg packerv=$(PACKERV) \
		--build-arg ansiblev=$(ANSIBLEV) \
		--build-arg gcloudv=$(GCLOUD) \
		--build-arg packages=$(PACKAGES) \
		--build-arg pip3=$(PIP3) \
		--build-arg usezsh=$(USE-ZSH) \
		--build-arg entry=$(ENTRY) \
		--build-arg container_secrets=$(CONTAINER_SECRETS_DIR) \
		--build-arg gcp_secrets_file=$(GCP_SECRETS_FILE) \
		--build-arg ansible_secrets_file=$(ANSIBLE_SECRETS_FILE) \
		--build-arg runner="false" \
		--build-arg workdir="/home/$(USER)/$(APP)" \
	-t $(IMAGE) .
	@$(RUNTIME) run --init -it --name $(CONTAINER) --hostname=$(CONTAINER) \
		-e "TERM=xterm-256color" \
		--volume $(APP_DIR):/home/$(USER)/$(APP):Z \
		--volume $(HOST_SECRETS_DIR):$(CONTAINER_SECRETS_DIR):Z \
		--volume $(HOST_SSH_DIR):$(CONTAINER_SSH_DIR):Z \
		--userns=keep-id \
		$(IMAGE)

build-wsl:
	@echo "Building with..."
	@echo "Fedora				: $(FEDORA)"
	@echo "Terraform			: $(TERRAFORM)"
	@echo "Packer				: $(PACKER)"
	@echo "Ansible				: $(ANSIBLE)"
	-@sleep 3
	@$(RUNTIME) build \
		--build-arg fedorav=$(FEDORA) \
		--build-arg app=$(APP) \
		--build-arg user=$(USER) \
		--build-arg terraformv=$(TERRAFORMV) \
		--build-arg packerv=$(PACKERV) \
		--build-arg ansiblev=$(ANSIBLEV) \
		--build-arg gcloudv=$(GCLOUD) \
		--build-arg packages=$(PACKAGES) \
		--build-arg pip3=$(PIP3) \
		--build-arg usezsh=$(USE-ZSH) \
		--build-arg entry=$(ENTRY) \
		--build-arg container_secrets=$(CONTAINER_SECRETS_DIR) \
		--build-arg gcp_secrets_file=$(GCP_SECRETS_FILE) \
		--build-arg ansible_secrets_file=$(ANSIBLE_SECRETS_FILE) \
		--build-arg runner="false" \
		--build-arg workdir="/home/$(USER)/$(APP)" \
	-t $(IMAGE) .
	@$(RUNTIME) run --init -it --name $(CONTAINER) --hostname=$(CONTAINER) \
		-e "TERM=xterm-256color" \
		--volume $(APP_DIR):/home/$(USER)/$(APP):Z \
		--volume $(HOST_SECRETS_DIR):$(CONTAINER_SECRETS_DIR):Z \
		--volume $(HOST_SSH_DIR):$(CONTAINER_SSH_DIR):Z \
		$(IMAGE)

build-mac:
	@echo "Building with..."
	@echo "Fedora				: $(FEDORA)"
	@echo "Terraform			: $(TERRAFORM)"
	@echo "Packer				: $(PACKER)"
	@echo "Ansible				: $(ANSIBLE)"
	-@sleep 3
	@$(RUNTIME) build \
		--build-arg fedorav=$(FEDORA) \
		--build-arg app=$(APP) \
		--build-arg user=$(USER) \
		--build-arg terraformv=$(TERRAFORMV) \
		--build-arg packerv=$(PACKERV) \
		--build-arg ansiblev=$(ANSIBLEV) \
		--build-arg gcloudv=$(GCLOUD) \
		--build-arg packages=$(PACKAGES) \
		--build-arg pip3=$(PIP3) \
		--build-arg usezsh=$(USE-ZSH) \
		--build-arg entry=$(ENTRY) \
		--build-arg container_secrets=$(CONTAINER_SECRETS_DIR) \
		--build-arg gcp_secrets_file=$(GCP_SECRETS_FILE) \
		--build-arg ansible_secrets_file=$(ANSIBLE_SECRETS_FILE) \
		--build-arg runner="false" \
		--build-arg workdir="/home/$(USER)/$(APP)" \
	-t $(IMAGE) .
	@$(RUNTIME) run --init -it --name $(CONTAINER) --hostname=$(CONTAINER) \
		-e "TERM=xterm-256color" \
		--volume $(APP_DIR):/home/$(USER)/$(APP):Z \
		--volume $(HOST_SECRETS_DIR):$(CONTAINER_SECRETS_DIR):Z \
		--volume $(HOST_SSH_DIR):$(CONTAINER_SSH_DIR):Z \
		$(IMAGE)

build-runner:
	@echo "Building with..."
	@echo "Fedora				: $(FEDORA)"
	@echo "Terraform			: $(TERRAFORM)"
	@echo "Packer				: $(PACKER)"
	@echo "Ansible				: $(ANSIBLE)"
	-@sleep 3
	@$(RUNTIME) build \
		--build-arg fedorav=$(FEDORA) \
		--build-arg app=$(APP) \
		--build-arg user=root \
		--build-arg terraformv=$(TERRAFORMV) \
		--build-arg packerv=$(PACKERV) \
		--build-arg ansiblev=$(ANSIBLEV) \
		--build-arg gcloudv=$(GCLOUD) \
		--build-arg packages=$(PACKAGES) \
		--build-arg pip3=$(PIP3) \
		--build-arg usezsh=false \
		--build-arg entry="/bin/bash" \
		--build-arg container_secrets="/root/.secrets" \
		--build-arg gcp_secrets_file=$(GCP_SECRETS_FILE) \
		--build-arg ansible_secrets_file=$(ANSIBLE_SECRETS_FILE) \
		--build-arg runner="true" \
		--build-arg workdir='/root' \
		-t $(CONTAINER_REGISTRY_PATH) .

# Delete image and container
prune:
	-@$(RUNTIME) rm $(CONTAINER)
	-@$(RUNTIME) rmi $(IMAGE)

# Start existing container
start:
	@$(RUNTIME) start -ai $(CONTAINER)

print-vars:
	-@echo $(ENTRY)
	-@echo $(PACKAGES)