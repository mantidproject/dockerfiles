# Jenkins nodes for Mantid in Docker

This describes how to deploy and managed a containerized build node.
Such a node can perform any Linux based jobs.

## Deployment

Things to note:
- RancherOS (by default) has a single user `rancher`
- This user has no password
- This user is a sudoer
- Access is only possible via key authenticated SSH
- Local login is only possible by selecting a specific boot option

### RancherOS deployment

- Download the [RancherOS](https://rancher.com/rancher-os/) `.iso` and flash it to a USB stick (using [`dd`](https://linux.die.net/man/1/dd) for example).
- Prepare another (FAT32 formatted) USB stick with the `cloud-init.yml` file (see [below](#cloud-inityml)).
- Boot from the USB stick with RancherOS on.
- Copy the completed `cloud-init.yml` file to the second USB stick, mount this on the machine being deployed and copy it to `$HOME`.
- [Install RancherOS to disk](https://rancher.com/docs/os/v1.x/en/installation/running-rancheros/server/install-to-disk/).
- Remove both USB sticks and reboot the machine.
- SSH into the machine using it's hostname.
  If this works the hostname and SSH key configs have worked.
- Run `copy_to_node.sh rancher@[hostname]`. This will copy the required files to the host.
- Execute `deploy_netdata.sh [webook url suffix]`, where `[webook url suffix]` is obtained from Slack, this will deploy [Netdata](https://www.netdata.cloud/) on this machine.
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
  # Dan Nixon
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+vdIusbvn2f1ME6riwqwU2sfaYeRLYLkV5LAKiFHmOLHFnHtYX1DZ5YWOIlmmGfUx5azzFfxlOYjRAMn3S4JxD3/pyfYUjUJdT2rtQx1TGpI5whV24f0vTDbCxgtpgzBEsdRiQmVY+YpFbfh5hpknmBM2HBGNXZbLJe7PmIXklRNNKl2PkbB7QsVu4OnLcBKGQVRi2hcqCEtYgt9WtxuenvnAt+VHt5Gm2/n/bPFIotBUNYMoIrVjagilltn5KbyXOPNeXKyhZ5P0bYx/ejiQeCVwF3DedGjWES/cjF5LpmtAfNX01i+j13Oj9t01QZauvPUrK4tqEsApOcUt4gCcU062U5LjAgNCXL++2WUpem6y5JxpO9QqIYovsFpXsLvBPUlOHhYdcgUjKTdG5eRh96IWgu2Xo5hBvYHY11Em35tiVa3UNI4ZUKiNzOMe2D5bQkbUOjribxjcUxzpEvP4x+WIpHv9ww+5qvSkaHnnEko5gOloMd3iduKsJi/VTAFIR0L+WJadlEKIIjSOqAQVCo+yyCR2shE7n5oHTriCJ+q2HBqz6d39JBT1u/jNw7TqC42nO+yZ1BXCC3tzJLYhGrPX8AdAXbYLd2BL/9bOYuUX2D8CyvZlM0ujevudsAwsSKeFbLVqJKZ2R+/kDniU/LbojdCZsQrRSo7A1Ml0xw== dan_nixon

  # David Fairbrother
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC5Fj72ig/DBf8YoRjRB49IL3acksLtkE/4RGYAb6ZSyhmPmVZ6Xuqy0O5cOR+7Tfw3EIjbWGVUks+Ss7+/U2eYecpcgpA6n4k5PPF3AJU8xB1kkbogvolxqkYgE+TVKu6XLefZQqyGuSSywPKk8RwjkStelu+jbrdkqlw80x8K+ZQk8/cCYAZFzAUte5meenxPBR/zk9QmivJe8WzfJ+fuPwQEHYWKSlewXCqzaV30SCn5B7ebl4qxhCnDU3yhXtHVh0FFOvwTipMGIkLHVGAgi50v49eEBkYQ4f5z6pXrdq74WAz9WPa0foEUpKFcJSlnbdJOekkMVodNyZBqzackAVME/Ms/o4O8JYzRaAO8Q6Zada/3tWmXMW+FQfCdp8q82HUnoLSf4IMfRSTneRhq8NE5KY/JlvSLvdPUReTGqREgNVuejr/fYeNg+qjN4dyKVpPNXg+95+DDFwUezghlXRwrXFCQ7iKFWTCmzmSMmMDl+3UHU24NMKnpfdOo5Wq0N8sKBLCccS8RjOkj+cl8hK0GTz2N9d7aPBWt3ZoHtssipqmazzAcMlSzBD18eBMewKcXBusZtv+BbZSnKuiedsRHe689iG/S3Y6l8WPAjk7lH0R5DeoUYNn9xVTcn5+j9oCASSZKq1q58m/w8fvJeC7Aw7b/zJPLe9fcTlm6BQ== DavidFair@stfc

  # Martyn Gigg
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDT63lsPMt6o8zgbPnns7XMY+hiLhLa8Gq5GPJdja+ulB6YIUdJ1YHORLQYwcY5tCnI8kT3eocB6Camq9OAOskn3f1a1jf6G5jAhcahsqu95MH5bp1YfGRNIWNtkpFwYoptdwyx+Bbge+11+qGCZfXf6jYKPctS3VL//xgk7QtKlz0D/Et/Gwoy3U9KjkCEYw3LeSisq8aSyHtxbeilAw6eH2wG96q3Ht34sGr/PbdcT+FkPo0eMUQGBHkb5gxjr/+7OqrOdx1wqceNB2Lr7av39uuNX1vZdSqCbiQoJ2qmPfGU03vJKqz74cW3ho2eHRlKcSpETwjz418mdf4WH83b martyn_gigg

  # Stephen Smith
  - ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEA0m295WADAavgnQPX8AquCp3at0jr8zG8y/XI8v5p1IkmIH56CPA6ZPeaoctbwDBZcGLXcnYhpVSezrYBhXyWD0F/T7VAxLtMVmnm1zKnHs7kJbQndop0qPoABtdu8nwkLBwjPr3NKRGZJmsyLqbIHvLLdrBjWTGkWHQHVCE9mKPd3bwPyXw4YJvGycuuP/fAup37qoUkDuca5zh/P0HcAlKBP3NOorjW8zi1iy5erwPZgJx44fDwXWTW7Q6kpgdzDTDk2OtrjA+lIPsCzaGAtygcKVibiR4WSm6mMQu52O59vnTcn+SImzY7425C/T+uFL0u0n6bCyNqjrbSQygHhQ== rsa-key-20200316

  # Samuel Jones
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDE973x4riglYeO/8QRF2Pbr0rb7W4Q40apqJf1UUnBnKZ04wPmPq9R+20JDt/YpX4i+Nfxv8peFu6+wqrdHLbNWTnQoUq+jWGass5MzadWhaW8Bc8BRuMgCx3dBxLnHKAH9Lrr9PKhY99w2573B8sb5SdJKDJQMCqjpVlQKtgOaJEHZ3iE9eBKDj0z+FveIpA/huLFPXeLmYc3u/DpGgkc59x5xnLPuh4Va0IJ+9DEsru5NYFLVACVW8QsNozWYONs/2xUjO4uL1Ue5wfFoRWU87lgJ8YZNXj1aszrJD4i51cD8Zar1dbHc2CHMDF0oyJBpXd6IfN4F5R4MUVizmtD Samuel_Jones
```

### Jenkins setup

- Provision a node in Jenkis [as usual](http://developer.mantidproject.org/JenkinsConfiguration.html) with the following changes:
  - Set *Remote root directory* to `/jenkins_workdir`
  - Set environment variables:
    - `BUILD_THREADS` => set based on system
    - `MANTID_DATA_STORE` => `/mantid_data`
- Once at the connect agent screen use `deploy.sh` to create the container (run with no parameters to see usage)
- You should see the agent become available in Jenkins and it should now be ready for use.

## Maintenance

- RancherOS mostly takes care of itself.
- Watchtower will automatically deploy any updated images pushed upstream that use the same tag.
  So if your prototyping/testing check your pushing to a local repo and not the Mantid docker.
- An occasional `docker system prune` will remove unsued Docker objects that hog disk space.
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
