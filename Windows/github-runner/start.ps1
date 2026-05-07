# Must provide the github organisation, repo, runner name, and a runner registration token
$Organization = $env:ORGANIZATION
$Repository = $env:REPOSITORY
$RunnerName = $env:RUNNER_NAME
$RegToken = $env:REG_TOKEN

Set-Location C:\actions-runner

#
# .\config.cmd --help
#
# Config Options:
#  --unattended           Disable interactive prompts for missing arguments. Defaults will be used for missing options
#  --url string           Repository to add the runner to. Required if unattended
#  --token string         Registration token. Required if unattended
#  --name string          Name of the runner to configure
#  --runnergroup string   Name of the runner group to add this runner to (defaults to the default runner group)
#  --labels string        Custom labels that will be added to the runner.
#  --work string          Relative runner work directory (default _work)
#  --replace              Replace any existing runner with the same name (default false)
#  --ephemeral            Configure the runner to only take one job and then let the service un-configure the runner after the job finishes (default false)
#

.\config.cmd `
    --unattended `
    --url "https://github.com/$Organization/$Repository" `
    --token $RegToken `
    --name $RunnerName `
    --replace `
    --labels $RunnerName

$env:REG_TOKEN = $null

.\run.cmd
