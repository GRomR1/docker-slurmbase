# Docker SLURM Cluster

This repository is part of the **Data Driven HPC** project and provides a set of
containers that can be used to run a SLURM HPC cluster as a set of Docker
containers. The project consists of three components:

1. [docker-slurmctld](https://github.com/datadrivenhpc/docker-slurmctld) provide
a SLURM controller or "head node".

2. [docker-slurmd](https://github.com/datadrivenhpc/docker-slurmd) provides a
SLURM compute node.

3. [docker-slurmbase](https://github.com/datadrivenhpc/docker-slurmctld) is the
base container from which both docker-slurmctld and docker-slurmd inherit.

This repository contains the container source files. The ready built container
images are available via DockerHub: https://hub.docker.com/r/datadrivenhpc.

The Docker SLURM cluster is configured with the following software packages:

- Ubuntu 16.04 LTS
- SLURM 16.05.3
- GlusterFS 3.8
- Open MPI 1.10.2

A user `ddhpc` is configured across all nodes for MPI job execution and a shared
GlusterFS volume *ddhpc* is mounted on all nodes as `/data/ddhpc`. The head node
runs an SSH server for accessing the cluster.

## Launch a New SLURM cluster

> If you are using Rancher, you can check out the compose files in the
> `rancher` subdirecotry.  

Create a new directory with a `docker-compose.yml` file:

```
slurmctld:
  environment:
    SLURM_CLUSTER_NAME: ddhpc
    SLURM_CONTROL_MACHINE: slurmctld
    SLURM_NODE_NAMES: slurmd_[1-4]
  tty: true
  hostname: slurmctld
  image: datadrivenhpc/slurmctld:latest
  links:
  - slurmd:SLURM_NODES
  stdin_open: true
slurmd:
  environment:
    SLURM_CONTROL_MACHINE: slurmctld
    SLURM_CLUSTER_NAME: ddhpc
    SLURM_NODE_NAMES: slurmd_[1-4]
  tty: true
  hostname: slurmd
  image: datadrivenhpc/slurmd
  stdin_open: true
  ```

**Configuration variables**:

  * `SLURM_CLUSTER_NAME`: the name of the SLURM cluster.
  * `SLURM_CONTROL_MACHINE`: the host name of the controller container. This should match `hostname` in the `slurmctld` section.
  * `SLURM_NODE_NAMES`: the host name(s) of the compute node container(s). This should match `hostname` in the `slurmd` section.
