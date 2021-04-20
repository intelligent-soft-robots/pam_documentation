#!/bin/bash

mujoco_file=mujoco200_linux.zip
mujoco_url=https://www.roboti.us/download/${mujoco_file}
tmp_dir=/tmp/pam_mujoco_install
mpi_is_dir=/opt/mpi-is
mujoco_dir=/opt/mujoco

mkdir -p ${tmp_dir}
sudo mkdir -p ${mpi_is_dir}
sudo mkdir -p ${mujoco_dir}

cd ${tmp_dir}
wget ${mujoco_url}

sudo unzip ./${mujoco_file} -d ${mpi_is_dir}

sudo chown root:users ${mpi_is_dir}
sudo chown root:users ${mujoco_dir}
sudo chmod 775 ${mpi_is_dir}
sudo chmod 775 ${mujoco_dir}
sudo chmod g+s ${mpi_is_dir}
sudo chmod g+s ${mujoco_dir}

echo ""
echo "pam mujoco configuration files installed in: ${mpi_is_dir}"
echo ""
echo "please copy your mujoco license file mjkey.txt in: ${mujoco_dir}"
echo ""
