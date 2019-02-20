# Jenkins nodes for Mantid in Docker

## Usage

1. Configure a node normally in Jenkins
2. Set *Remote root directory* to `/jenkins_workdir`
3. Set environment variables:
  - `BUILD_THREADS` => set based on system
  - `MANTID_DATA_STORE` => `/mantid_data`
  - `PARAVIEW_DIR` => `/paraview/build/ParaView-5.4.1` (adjust for current version)
4. Create the container (or replace an already deployed container) using
   `./deploy.sh agent_name agent_secret jenkins_url image_tag` (this can be done
   via `docker-machine`)

If the image is updated then run the above script again to recreate the node
(all build state is stored in the volumes which are persisted).

## Production use

The following uses are currently tested and in use:

- `mantidproject/jenkins-node:ubuntuxenial`
  - `flake8`
  - `doxygen`
  - `clang-format`
  - any build job that submits to `ubuntu-16.04-build`
- `mantidproject/jenkins-node:ubuntubionic`
  - cppcheck

Still to do/test:

- systemtests
- Ubuntu Bionic builds
- CentOS 7 builds
