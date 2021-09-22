# Select base image.
ARG fedorav
FROM fedora:${fedorav}

# Takes app name from directory container Dockerfile.
ARG app

ARG usezsh
# Take username details from host
ARG user
# Detect if Gitlab Runner
ARG runner
# Base packages to be installed by apt.
ARG packages

# Install packages and configure container
RUN dnf update -y && \
    dnf install -y $packages
    # useradd $user -G wheel && \
    # sed -i 's/%wheel.*/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers

# Install Python3 packages
ARG pip3
RUN pip3 install ${pip3}

# Configure user
RUN if [ "${runner}" == "false" ]; then dnf install -y sudo; useradd $user -G wheel; sed -i 's/%wheel.*/%wheel ALL=(ALL) NOPASSWD: ALL/' /etc/sudoers; fi

#####################################################
# Developer Tools - Comment to disable in container #
#####################################################
# Automation #
##############
# Terraform | Define Terraform version and install Terraform
ARG terraformv
RUN if [ ! "${terraformv}" == "disabled" ]; then dnf install -y dnf-plugins-core && dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && dnf install -y ${terraformv}; fi

# Packer | Define Packer version and install Packer
ARG packerv
RUN if [ ! "${packerv}" == "disabled" ]; then dnf install -y dnf-plugins-core && dnf config-manager --add-repo https://rpm.releases.hashicorp.com/fedora/hashicorp.repo && dnf install -y ${packerv}; fi

# Ansible | Latest
ARG ansiblev
RUN if [ ! "${ansiblev}" == "disabled" ]; then dnf install -y ${ansiblev}; fi

#######################
# Shell configuration #
#######################
# Install zsh and oh-my-zsh and set init user
USER $user
# RUN if [[ "${usezsh}" == "true" && "${runner}" == "false" ]]; then sudo dnf install -y zsh util-linux-user; sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; echo 'eval $(ssh-agent)' >> /home/$user/.zshrc; curl https://raw.githubusercontent.com/Rorasaurus/swann-container-zsh-theme/main/swann-container.zsh-theme > ~/.oh-my-zsh/themes/swann-container.zsh-theme; sed -i 's/ZSH_THEME=.*/ZSH_THEME="swann-container"/' ~/.zshrc; sudo chsh -s /bin/zsh $user; elif [ "${runner}" == "true" ]]; then echo 'eval $(ssh-agent)' >> /root/.bashrc; else echo 'eval $(ssh-agent)' >> /home/$user/.bashrc; fi
RUN if [[ "${usezsh}" == "true" && "${runner}" == "false" ]]; then sudo dnf install -y zsh util-linux-user; sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; echo 'eval $(ssh-agent)' >> /home/$user/.zshrc; curl https://raw.githubusercontent.com/Rorasaurus/swann-container-zsh-theme/main/swann-container.zsh-theme > ~/.oh-my-zsh/themes/swann-container.zsh-theme; sed -i 's/ZSH_THEME=.*/ZSH_THEME="swann-container"/' ~/.zshrc; sudo chsh -s /bin/zsh $user; else echo 'eval $(ssh-agent)' >> ~/.bashrc; fi

###############
# Cloud CLI's #
###############
# Google Cloud CLI
USER $user
ARG gcloudv
RUN curl https://sdk.cloud.google.com > ~/install.sh && \
    chmod +x ~/install.sh && \
    bash ~/install.sh --disable-prompts --install-dir=~/ && \
    if [[ "${usezsh}" == "true" && "${runner}" == "false" ]]; then echo "source ~/google-cloud-sdk/path.zsh.inc" >> ~/.zshrc && echo "source ~/google-cloud-sdk/completion.zsh.inc" >> ~/.zshrc; else echo "source ~/google-cloud-sdk/path.bash.inc" >> ~/.bashrc && echo "source ~/google-cloud-sdk/completion.bash.inc" >> ~/.bashrc; fi

# Secrets
ARG container_secrets
ARG gcp_secrets_file
ARG ansible_secrets_file
ENV GOOGLE_APPLICATION_CREDENTIALS=${container_secrets}/${gcp_secrets_file}
ENV ANSIBLE_VAULT=${container_secrets}/ansible/${ansible_secrets_file}

# Configure working directory based upon Dockerfile directory name.
ARG workdir
WORKDIR $workdir

# Set container entrypoint
ARG entry
ENV entryenv=$entry
ENTRYPOINT "$entryenv"
