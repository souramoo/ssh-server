# adapted from https://docs.docker.com/engine/examples/running_ssh_service/
FROM python:3.11
USER root

RUN apt-get update && apt-get install -y openssh-server net-tools  
RUN pip3 install pyarrow pydantic rdkit p_tqdm
RUN mkdir /var/run/sshd
# RUN --mount=type=secret,id=ROOT_PASSWORD \
#   export ROOT_PASSWORD=$(cat /run/secrets/ROOT_PASSWORD) && \
#   echo "root:$ROOT_PASSWORD" | chpasswd
# RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
#RUN echo "Port 30022" >> /etc/ssh/sshd_config

RUN mkdir -p /root/.ssh/
RUN --mount=type=secret,id=SSH_KEY_1 \
   echo "$(cat /run/secrets/SSH_KEY_1)" >> /root/.ssh/authorized_keys
RUN --mount=type=secret,id=SSH_KEY_2 \
   echo "$(cat /run/secrets/SSH_KEY_2)" >> /root/.ssh/authorized_keys

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY ./run.sh /root/run.sh

RUN chmod +x /root/run.sh

# install gcloud cli
RUN apt install -y apt-transport-https ca-certificates gnupg curl sudo tmux lsb-release

RUN echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo gpg --dearmor -o /usr/share/keyrings/cloud.google.gpg && apt-get update -y && apt-get install google-cloud-sdk -y


RUN GCSFUSE_REPO=gcsfuse-`lsb_release -c -s` echo "deb [signed-by=/usr/share/keyrings/cloud.google.asc] https://packages.cloud.google.com/apt $GCSFUSE_REPO main" | sudo tee /etc/apt/sources.list.d/gcsfuse.list

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

RUN apt update && apt install -y gcsfuse

EXPOSE 22
CMD ["/root/run.sh"]
