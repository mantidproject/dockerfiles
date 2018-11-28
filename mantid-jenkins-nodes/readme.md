# Jenkins nodes for Mantid in Docker

Still to do:

- ccache (separate volume for cache?)
- Separate volume for external data?

## Usage

1. Configure a node normally in Jenkins
2. Set `/root` as the *Remote root directory* and use `/root` in place of
   anywhere you see a home directory
3. Create the container or replace an already deployed container using
   `./deploy.sh agent_name agent_secret jenkins_url image_tag`
4. If the image is updated then run the above script again to recreate the node
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

## ParaView

If ParaView is required (for builds and cppcheck jobs it is) then it is best to
build it on the container itsself rather than using the Jenkins jobs.

(for now until the ParaView build scripts no longer make assumptions about
who/where they are being run)
