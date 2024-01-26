# Thanks to Chillheart (https://github.com/Chilledheart/mojo-docker-images) for the original Dockerfile!

FROM ubuntu:22.04
ARG userid=1000
ARG groupid=1000
ARG username=mojo

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update -qq && apt-get upgrade -y && \
    apt-get install -y apt-utils curl sudo git && \
    apt-get install -y libedit2 libncurses-dev apt-transport-https \
      ca-certificates gnupg libxml2-dev python3 python3-pip python3-dev python3.10-venv && \
    apt-get clean

RUN mkdir ~/.gnupg && chmod 600 ~/.gnupg && echo "disable-ipv6" >> ~/.gnupg/dirmngr.conf

RUN groupadd -g $groupid $username \
    && useradd -m -s /bin/bash -u $userid -g $groupid $username \
    && mkdir -p /home/$username && chown $userid:$groupid /home/$username
RUN echo "$username ALL=(ALL:ALL) NOPASSWD: ALL" > /etc/sudoers.d/$username

RUN echo "export HOME=/home/$username" >> /home/$username/.bashrc
RUN echo 'export MODULAR_HOME="$HOME/.modular"' >> /home/$username/.bashrc
RUN echo 'export PATH="$HOME/.modular/pkg/packages.modular.com_mojo/bin:$PATH"' >> /home/$username/.bashrc

WORKDIR /home/$username/

COPY .mojoenv ./.mojoenv

COPY docker/run.sh ./run.sh
RUN chmod +x ./run.sh

USER $username

EXPOSE 8080

CMD ["./run.sh"]