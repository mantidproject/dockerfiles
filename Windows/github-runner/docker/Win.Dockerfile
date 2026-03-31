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
ARG RUNNER_VERSION="2.321.0"

# Add label for transparency.
# "org.opencontainers.image.source" is a standard key for pointing to the source used to build this docker image.
LABEL org.opencontainers.image.source=https://github.com/mantidproject/dockerfiles

# Reset the shell
SHELL ["cmd", "/S", "/C"]

# Install Node.js LTS
ADD https://nodejs.org/dist/v20.9.0/node-v20.9.0-x64.msi C:\TEMP\node-install.msi
SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Start-Process -Wait msiexec.exe -ArgumentList @('/i', 'C:\TEMP\node-install.msi', '/l*vx', '"%TEMP%\MSI-node-install.log"', '/qn', 'ADDLOCAL=ALL')

# Enable long paths
RUN New-ItemProperty `
        -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
        -Name "LongPathsEnabled" `
        -Value 1 `
        -PropertyType DWORD `
        -Force

# Install Chocolatey
ENV ChocolateyUseWindowsCompression=false
ENV chocolateyVersion=1.4.0
RUN Set-ExecutionPolicy Bypass -Scope Process -Force; `
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
    iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
RUN Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Install git
RUN choco install git.install -y --no-progress

# Restore the default Windows shell
SHELL ["cmd", "/S", "/C"]

# Install Visual Studio Build Tools
RUN `
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    `
    # Install MS Build Tools and MSVC
    # MSVC 14.38.17.8 installed to avoid bug with 14.4*
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        --add Microsoft.VisualStudio.Component.VC.14.38.17.8.x86.x64 `
        --add Microsoft.VisualStudio.Component.Windows10SDK.19041 `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Cleanup
    && del /q vs_buildtools.exe

# Download and extract the GitHub Actions runner
SHELL ["powershell", "-NoProfile", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN $runnerVersion = $env:RUNNER_VERSION; `
    New-Item -ItemType Directory -Path C:\actions-runner | Out-Null; `
    Invoke-WebRequest `
        -Uri "https://github.com/actions/runner/releases/download/v$runnerVersion/actions-runner-win-x64-$runnerVersion.zip" `
        -OutFile C:\actions-runner\actions-runner-win-x64.zip; `
    Expand-Archive -Path C:\actions-runner\actions-runner-win-x64.zip -DestinationPath C:\actions-runner; `
    Remove-Item C:\actions-runner\actions-runner-win-x64.zip

# Copy the start script
COPY start.ps1 C:\actions-runner\start.ps1

SHELL ["cmd", "/S", "/C"]

ENTRYPOINT ["powershell.exe", "-NonInteractive", "-f", "C:\\actions-runner\\start.ps1"]
