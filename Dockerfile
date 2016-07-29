FROM ubuntu:16.04

ENV SLURM_VER=16.05.3

RUN apt-get update && apt-get -y  dist-upgrade
RUN apt-get install -y munge curl gcc make bzip2 supervisor python libmunge-dev \
    libmunge2 lua5.3 lua5.3-dev  libopenmpi-dev openmpi-bin gfortran

RUN curl -fsL http://www.schedmd.com/download/total/slurm-${SLURM_VER}.tar.bz2 | tar xfj - -C /opt/ && \
    cd /opt/slurm-${SLURM_VER}/ && \
    ./configure && make && make install

ADD etc/supervisord.d/munged.conf /etc/supervisor/conf.d/munged.conf

ADD etc/munge/munge.key /etc/munge/munge.key

RUN mkdir /var/run/munge && \
    chown root /var/lib/munge && \
    chown root /etc/munge && chmod 600 /var/run/munge && \
    chmod 755  /run/munge && \
    chmod 600 /etc/munge/munge.key

RUN useradd -u 2001 -d /home/slurm slurm
ADD etc/slurm/slurm.conf /usr/local/etc/slurm.conf

ENV LD_LIBRARY_PATH=/usr/local/lib/
