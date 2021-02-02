# Select base image.
FROM fedora:latest
# Takes app name from directory container Dockerfile.
ARG app

ARG usezsh
# Take username details from host
ARG user
# Base packages to be installed by apt.
ARG packages

# Install packages and configure container
RUN dnf update -y && \
    dnf install -y $packages && \
    useradd $user -G wheel && \
    sed -i 's/%wheel.*/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

#####################################################
# Developer Tools - Comment to disable in container #
#####################################################
# Automation #
##############
# Terraform | Define Terraform version and install Terraform
ARG terraformv
RUN if [ ! "${terraformv}" == "disabled" ]; then wget https://releases.hashicorp.com/terraform/${terraformv}/terraform_${terraformv}_linux_amd64.zip; unzip terraform_${terraformv}_linux_amd64.zip; mv terraform /usr/local/bin/; fi

# Packer | Define Packer version and install Packer
ARG packerv
RUN if [ ! "${packerv}" == "disabled" ]; then wget https://releases.hashicorp.com/packer/${packerv}/packer_${packerv}_linux_amd64.zip; unzip packer_${packerv}_linux_amd64.zip; cp packer /usr/local/bin/; fi

# Ansible | Latest
ARG ansiblev
RUN if [ ! "${ansiblev}" == "disabled" ]; then dnf install -y ${ansiblev}; fi

#######################
# Shell configuration #
#######################
# Install zsh and oh-my-zsh and set init user
USER $user
RUN if [ "$usezsh" == "true" ]; then sudo dnf install -y zsh util-linux-user; sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; echo 'eval $(ssh-agent)' >> /home/$user/.zshrc; sudo chsh -s /bin/zsh $user; else echo 'eval $(ssh-agent)' >> /home/$user/.bashrc; fi

###############
# Cloud CLI's #
###############
# Google Cloud CLI
USER $user
ARG gcloudv
RUN if [ ! "${gcloudv}" == "disabled" ]; then curl https://sdk.cloud.google.com > ~/install.sh && chmod +x ~/install.sh && bash ~/install.sh --disable-prompts --install-dir=~/; if [ "$usezsh" == "true" ]; then echo "source ~/google-cloud-sdk/path.zsh.inc" >> ~/.zshrc && echo "source ~/google-cloud-sdk/completion.zsh.inc" >> ~/.zshrc; else echo "source ~/google-cloud-sdk/path.bash.inc" >> ~/.zshrc && echo "source ~/google-cloud-sdk/completion.bash.inc" >> ~/.zshrc; fi; fi

# Configure working directory based upon Dockerfile directory name.
WORKDIR /home/$user/$app

# Set container entrypoint
ARG entry
ENV entryenv=$entry
ENTRYPOINT "$entryenv"
