FROM ubuntu:16.04
MAINTAINER Ole Weidner <ole.weidner@ed.ac.uk>

ENV SLURM_VER=16.05.3

# Create users, set up SSH keys (for MPI)
RUN useradd -u 2001 -d /home/slurm slurm
RUN useradd -u 6000 -ms /bin/bash ddhpc
ADD etc/sudoers.d/ddhpc /etc/sudoers.d/ddhpc
ADD home/ddhpc/ssh/config /home/ddhpc/.ssh/config
ADD home/ddhpc/ssh/id_rsa /home/ddhpc/.ssh/id_rsa
ADD home/ddhpc/ssh/id_rsa.pub /home/ddhpc/.ssh/id_rsa.pub
ADD home/ddhpc/ssh/authorized_keys /home/ddhpc/.ssh/authorized_keys
RUN chown -R ddhpc:ddhpc /home/ddhpc/.ssh/
RUN chmod 400 /home/ddhpc/.ssh/*

# Install packages
RUN apt-get update && apt-get -y  dist-upgrade
RUN apt-get install -y munge curl gcc make bzip2 supervisor python python-dev \
    libmunge-dev libmunge2 lua5.3 lua5.3-dev libopenmpi-dev openmpi-bin \
    gfortran vim python-mpi4py python-numpy python-psutil sudo psmisc \
    software-properties-common python-software-properties iputils-ping \
    openssh-server openssh-client


# Download, compile and install SLURM
RUN curl -fsL http://www.schedmd.com/download/total/slurm-${SLURM_VER}.tar.bz2 | tar xfj - -C /opt/ && \
    cd /opt/slurm-${SLURM_VER}/ && \
    ./configure && make && make install
ADD etc/slurm/slurm.conf /usr/local/etc/slurm.conf


# Configure OpenSSH
# Also see: https://docs.docker.com/engine/examples/running_ssh_service/
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile
RUN mkdir /var/run/sshd
RUN echo 'ddhpc:ddhpc' | chpasswd
# SSH login fix. Otherwise user is kicked off after login
RUN sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd
ADD etc/supervisord.d/sshd.conf /etc/supervisor/conf.d/sshd.conf


# Configure GlusterFS
# RUN add-apt-repository ppa:gluster/glusterfs-3.8 && \
#     apt-get update -y && \
#     apt-get install -y glusterfs-server
#
# RUN mkdir -p /data/ddhpc
# ADD etc/supervisord.d/glusterd.conf /etc/supervisor/conf.d/glusterd.conf


# Configure munge (for SLURM authentication)
ADD etc/munge/munge.key /etc/munge/munge.key
RUN mkdir /var/run/munge && \
    chown root /var/lib/munge && \
    chown root /etc/munge && chmod 600 /var/run/munge && \
    chmod 755  /run/munge && \
    chmod 600 /etc/munge/munge.key
ADD etc/supervisord.d/munged.conf /etc/supervisor/conf.d/munged.conf

EXPOSE 22
