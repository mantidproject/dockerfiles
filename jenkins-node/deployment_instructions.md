# Deployment

This describes how to deploy and managed a containerized build node.
Such a node can perform any Linux based jobs.

## Deployment

### RancherOS deployment

- Download the [RancherOS](https://rancher.com/rancher-os/) `.iso` and flash it to a USB stick (using `dd` for example).
- Prepare another (FAT32 formatted) USB stick with the `cloud-init.yml` file (see below).
- Boot from the USB stick with RancherOS on.
- TODO: install (https://rancher.com/docs/os/v1.x/en/installation/running-rancheros/server/install-to-disk/)
- Reboot the machine.
- SSH into the machine using it's hostname. If this works the hostname and SSH key configs have worked.
- TODO: deploy netdata

#### `cloud-init.yml`

[`cloud-init`](https://cloudinit.readthedocs.io/) is a framework used to automatically configure Linux machines (kind of like Ansible but a bit simpler).
This file controls what cloud-init will do to RancherOS after install.

The two main things we need to do are:
  - Setting the hostname
  - Adding SSH keys for all admins

The snippet below shows how this can be done:
```yaml
hostname: ndwXXXX
ssh_authorized_keys:
  - ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+vdIusbvn2f1ME6riwqwU2sfaYeRLYLkV5LAKiFHmOLHFnHtYX1DZ5YWOIlmmGfUx5azzFfxlOYjRAMn3S4JxD3/pyfYUjUJdT2rtQx1TGpI5whV24f0vTDbCxgtpgzBEsdRiQmVY+YpFbfh5hpknmBM2HBGNXZbLJe7PmIXklRNNKl2PkbB7QsVu4OnLcBKGQVRi2hcqCEtYgt9WtxuenvnAt+VHt5Gm2/n/bPFIotBUNYMoIrVjagilltn5KbyXOPNeXKyhZ5P0bYx/ejiQeCVwF3DedGjWES/cjF5LpmtAfNX01i+j13Oj9t01QZauvPUrK4tqEsApOcUt4gCcU062U5LjAgNCXL++2WUpem6y5JxpO9QqIYovsFpXsLvBPUlOHhYdcgUjKTdG5eRh96IWgu2Xo5hBvYHY11Em35tiVa3UNI4ZUKiNzOMe2D5bQkbUOjribxjcUxzpEvP4x+WIpHv9ww+5qvSkaHnnEko5gOloMd3iduKsJi/VTAFIR0L+WJadlEKIIjSOqAQVCo+yyCR2shE7n5oHTriCJ+q2HBqz6d39JBT1u/jNw7TqC42nO+yZ1BXCC3tzJLYhGrPX8AdAXbYLd2BL/9bOYuUX2D8CyvZlM0ujevudsAwsSKeFbLVqJKZ2R+/kDniU/LbojdCZsQrRSo7A1Ml0xw== dan_nixon
```

### Jenkins agent container deployment

TODO

### Jenkins setup

TODO

## Maintenance

TODO
