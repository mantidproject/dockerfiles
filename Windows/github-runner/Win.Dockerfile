# escape=`
# Build stage to gather DLLs only available in the full Windows image
FROM mcr.microsoft.com/windows:10.0.17763.7434-amd64 AS full

RUN	xcopy /y C:\Windows\System32\glu32.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MF.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MFPlat.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MFReadWrite.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\dxva2.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\opengl32.dll C:\GatheredDlls\

FROM mcr.microsoft.com/windows/servercore:ltsc2019
COPY --from=full C:\GatheredDlls\ C:\Windows\System32\

# Set the GitHub runner version
ARG RUNNER_VERSION="2.333.1"

# Add label for transparency.
# "org.opencontainers.image.source" is a standard key for pointing to the source used to build this docker image.
LABEL org.opencontainers.image.source=https://github.com/mantidproject/dockerfiles

SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

# Install Chocolatey
ENV ChocolateyUseWindowsCompression=false
ENV chocolateyVersion=1.4.0
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
RUN Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Install Git
RUN choco install git.install -y --no-progress

# Install Python 3, and gzip (required by unit report workflow EnricoMi/publish-unit-test-result-action)
RUN choco install python3 gzip -y --no-progress

# Add Git bash to PATH so shell: bash works in GitHub Actions
RUN [System.Environment]::SetEnvironmentVariable('Path', `
    'C:\Program Files\Git\bin;' + [System.Environment]::GetEnvironmentVariable('Path', 'Machine'), `
    'Machine')

# Enable long paths
RUN New-ItemProperty `
        -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
        -Name "LongPathsEnabled" `
        -Value 1 `
        -PropertyType DWORD `
        -Force

# Install Visual Studio Build Tools
RUN Invoke-WebRequest -Uri "https://aka.ms/vs/17/release/vs_buildtools.exe" -OutFile vs_buildtools.exe; `
    $proc = Start-Process -Wait -PassThru vs_buildtools.exe -ArgumentList @( `
        '--quiet', '--wait', '--norestart', '--nocache', `
        '--installPath', 'C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools', `
        '--add', 'Microsoft.VisualStudio.Component.VC.Tools.x86.x64', `
        '--add', 'Microsoft.VisualStudio.Component.Windows10SDK.19041' `
    ); `
    if ($proc.ExitCode -ne 0 -and $proc.ExitCode -ne 3010) { exit $proc.ExitCode }; `
    Remove-Item vs_buildtools.exe

# Download and extract the GitHub Actions runner
RUN New-Item -ItemType Directory -Path C:\actions-runner | Out-Null; `
    Invoke-WebRequest `
        -Uri "https://github.com/actions/runner/releases/download/v$($env:RUNNER_VERSION)/actions-runner-win-x64-$($env:RUNNER_VERSION).zip" `
        -OutFile C:\actions-runner\actions-runner-win-x64.zip; `
    Expand-Archive -Path C:\actions-runner\actions-runner-win-x64.zip -DestinationPath C:\actions-runner; `
    Remove-Item C:\actions-runner\actions-runner-win-x64.zip

# Copy the start script
COPY start.ps1 C:\actions-runner\start.ps1

ENTRYPOINT ["powershell.exe", "-NonInteractive", "-f", "C:\\actions-runner\\start.ps1"]
