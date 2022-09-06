# Dockerfiles

A collection of dockerfiles used by developers and CI for
[mantid](https://github.com/mantidproject/mantid):

- [development](./development): An image providing an environment setup for
  Mantid development.
- [jenkins-node](./jenkins-node): Builds on the development image and adds the
  JNLP service agent so the container acts as a Jenkins node.
- [mantid](./mantid): A production image containing mantid.
