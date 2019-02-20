# Jenkins nodes for Mantid in Docker

## Usage

1. Configure a node normally in Jenkins
2. Set *Remote root directory* to `/root`
3. (Use `/root` in place of anywhere you see a home directory)
4. Set the `PARAVIEW_DIR` environment variable to
   `/paraview_build/ParaView-5.4.1` (ParaView is included in this directory from
   the [mantid-development](../mantid-development/readme.md) image)
5. Set the `MANTID_DATA_STORE` environment variable to `/mantid_data`
6. Create the container or replace an already deployed container using
   `./deploy.sh agent_name agent_secret jenkins_url image_tag`
7. If the image is updated then run the above script again to recreate the node
   (all build state is stored in the volumes which are persisted)

## Production use

The following uses are currently tested and in use:

- `mantidproject/jenkins-node:ubuntuxenial`
  - flake8
  - doxygen
  - clang-format
- `mantidproject/jenkins-node:ubuntubionic`
  - cppcheck

Other configurations *may* work but are untested.
