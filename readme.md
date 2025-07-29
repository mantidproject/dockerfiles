# Dockerfiles

A collection of dockerfiles and ansible scripts used by developers and CI for
[mantid](https://github.com/mantidproject/mantid). 

The images are split into folders by OS with documentation for editing and deploying setups available in each folder.

## Troubleshooting

### Windows Interpreter Errors

When running playbooks on Windows machines, incorrect line endings can result in `bad interpreter` errors.

To fix this (when using WSL):

```sh
sudo apt install dos2unix
```
```sh
dos2unix <PATH_TO_SCRIPT>
```
