# adapted from https://docs.docker.com/engine/examples/running_ssh_service/
FROM python:3.11

RUN apt-get update && apt-get install -y openssh-server
RUN pip3 install pyarrow pydantic rdkit p_tqdm
RUN mkdir /var/run/sshd
# RUN --mount=type=secret,id=ROOT_PASSWORD \
#   export ROOT_PASSWORD=$(cat /run/secrets/ROOT_PASSWORD) && \
#   echo "root:$ROOT_PASSWORD" | chpasswd
# RUN sed -i 's/#*PermitRootLogin prohibit-password/PermitRootLogin yes/g' /etc/ssh/sshd_config
RUN mkdir -p /root/.ssh/
RUN --mount=type=secret,id=SSH_KEY_1 \
   echo "$(cat /run/secrets/SSH_KEY_1)" >> /root/.ssh/authorized_keys
RUN --mount=type=secret,id=SSH_KEY_2 \
   echo "$(cat /run/secrets/SSH_KEY_2)" >> /root/.ssh/authorized_keys

# SSH login fix. Otherwise user is kicked off after login
RUN sed -i 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' /etc/pam.d/sshd

ENV NOTVISIBLE="in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

EXPOSE 22
CMD ["/usr/sbin/sshd", "-D"]
