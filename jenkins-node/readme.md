# Jenkins nodes for Mantid in Docker

This describes how to deploy and managed a containerized build node.
Such a node can perform any Linux based jobs.

## Deployment

### RancherOS deployment

- Download the [RancherOS](https://rancher.com/rancher-os/) `.iso` and flash it to a USB stick (using [`dd`](https://linux.die.net/man/1/dd) for example).
- Prepare another (FAT32 formatted) USB stick with the `cloud-init.yml` file (see [below](#cloud-inityml)).
- Boot from the USB stick with RancherOS on.
- Copy the completed `cloud-init.yml` file to the second USB stick, mount this on the machine being deployed and copy it to `$HOME`.
- [Install RancherOS to disk](https://rancher.com/docs/os/v1.x/en/installation/running-rancheros/server/install-to-disk/).
- Remove both USB sticks and reboot the machine.
- SSH into the machine using it's hostname.
  If this works the hostname and SSH key configs have worked.
- Download the [`deploy_netdata.sh`](./bin/deploy_netdata.sh) and [`deploy.sh`](./bin/deploy.sh) scripts.
- Execute `deploy_netdata.sh`, this will deploy [Netdata](https://www.netdata.cloud/) on this machine.
  This can be used for remote monitoring.

#### `cloud-init.yml`

[`cloud-init`](https://cloudinit.readthedocs.io/) is a framework used to automatically configure Linux machines (kind of like Ansible but a bit simpler).
This file controls what cloud-init will do to RancherOS after install.

The two main things we need to do are:
  - Setting the hostname
  - Adding SSH keys for all admins

The snippet below shows how this can be done (make sure to update the hostname and ensure SSH keys are correct):
```yaml
hostname: ndwXXXX
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+vdIusbvn2f1ME6riwqwU2sfaYeRLYLkV5LAKiFHmOLHFnHtYX1DZ5YWOIlmmGfUx5azzFfxlOYjRAMn3S4JxD3/pyfYUjUJdT2rtQx1TGpI5whV24f0vTDbCxgtpgzBEsdRiQmVY+YpFbfh5hpknmBM2HBGNXZbLJe7PmIXklRNNKl2PkbB7QsVu4OnLcBKGQVRi2hcqCEtYgt9WtxuenvnAt+VHt5Gm2/n/bPFIotBUNYMoIrVjagilltn5KbyXOPNeXKyhZ5P0bYx/ejiQeCVwF3DedGjWES/cjF5LpmtAfNX01i+j13Oj9t01QZauvPUrK4tqEsApOcUt4gCcU062U5LjAgNCXL++2WUpem6y5JxpO9QqIYovsFpXsLvBPUlOHhYdcgUjKTdG5eRh96IWgu2Xo5hBvYHY11Em35tiVa3UNI4ZUKiNzOMe2D5bQkbUOjribxjcUxzpEvP4x+WIpHv9ww+5qvSkaHnnEko5gOloMd3iduKsJi/VTAFIR0L+WJadlEKIIjSOqAQVCo+yyCR2shE7n5oHTriCJ+q2HBqz6d39JBT1u/jNw7TqC42nO+yZ1BXCC3tzJLYhGrPX8AdAXbYLd2BL/9bOYuUX2D8CyvZlM0ujevudsAwsSKeFbLVqJKZ2R+/kDniU/LbojdCZsQrRSo7A1Ml0xw== dan_nixon
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT63lsPMt6o8zgbPnns7XMY+hiLhLa8Gq5GPJdja+ulB6YIUdJ1YHORLQYwcY5tCnI8kT3eocB6Camq9OAOskn3f1a1jf6G5jAhcahsqu95MH5bp1YfGRNIWNtkpFwYoptdwyx+Bbge+11+qGCZfXf6jYKPctS3VL//xgk7QtKlz0D/Et/Gwoy3U9KjkCEYw3LeSisq8aSyHtxbeilAw6eH2wG96q3Ht34sGr/PbdcT+FkPo0eMUQGBHkb5gxjr/+7OqrOdx1wqceNB2Lr7av39uuNX1vZdSqCbiQoJ2qmPfGU03vJKqz74cW3ho2eHRlKcSpETwjz418mdf4WH83b martyn_gigg
```

### Jenkins setup

- Provision a node in Jenkis [as usual](http://developer.mantidproject.org/JenkinsConfiguration.html) with the following changes:
  - Set *Remote root directory* to `/jenkins_workdir`
  - Set environment variables:
    - `BUILD_THREADS` => set based on system
    - `MANTID_DATA_STORE` => `/mantid_data`
    - `PARAVIEW_DIR` => `/paraview/build/ParaView-5.4.1` (adjust for current version)
- Once at the connect agent screen use `deploy.sh` to create the container (run with no parameters to see usage)
- You should see the agent become available in Jenkins and it should now be ready for use.

## Maintenance

- RancherOS mostly takes care of itself.
- You can monitor the systen via Netdata at `http://[hostname]:19999`.
  Useful things this can tell you include:
    - Has the RAM been exhausted (see *System Overview* > *ram*)
    - Is the system oversubscribed (see *System Overview* > *load*)
    - Is there plenty of free disk space (see *Disks*)
    - Has the data room cooling failed (see *CPUs* > *throttling*)
    - Has anything bad happened in the past (see *Alarms* > *Log*)
- To update Netdata run the `deploy_netdata.sh` script again.
  It will pull a new image if available, stop the existing container and start another.
  The Netdata web UI will show a notification when there are updates available.
- To update the Jenkins node image run the `deploy.sh` script again with the same parameters as it was first deployed with.
  It will pull a new image if available, stop the existing container and start another.
