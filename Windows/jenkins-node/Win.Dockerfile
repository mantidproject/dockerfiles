# escape=`
# Use JNLP agent as base and install required tools

ARG FROM_IMAGE=jenkins/inbound-agent:4.13-2-jdk11-windowsservercore-ltsc2019
FROM ${FROM_IMAGE}

# Reset the shell.
SHELL ["cmd", "/S", "/C"]

# Set up environment to collect install errors.
COPY Install.cmd C:\TEMP\
ADD https://aka.ms/vscollect.exe C:\TEMP\collect.exe

# Install Node.js LTS
ADD https://nodejs.org/dist/v8.11.3/node-v8.11.3-x64.msi C:\TEMP\node-install.msi
RUN start /wait msiexec.exe /i C:\TEMP\node-install.msi /l*vx "%TEMP%\MSI-node-install.log" /qn ADDLOCAL=ALL

# Download channel for fixed install.
ARG CHANNEL_URL=https://aka.ms/vs/16/release/channel
ADD ${CHANNEL_URL} C:\TEMP\VisualStudio.chman

# Download and install Build Tools for Visual Studio 2019 for native desktop workload.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\TEMP\vs_buildtools.exe
RUN C:\TEMP\Install.cmd C:\TEMP\vs_buildtools.exe --quiet --wait --norestart --nocache `
    --channelUri C:\TEMP\VisualStudio.chman `
    --installChannelUri C:\TEMP\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended`
    --installPath C:\BuildTools

#Enable long paths
RUN powershell New-ItemProperty `
                   -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
                   -Name "LongPathsEnabled" `
                   -Value 1 `
                   -PropertyType DWORD `
                   -Force

#Install git
ENV ChocolateyUseWindowsCompression false 
RUN powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
RUN powershell -NoProfile -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
RUN choco install git.install -y --no-progress
RUN powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

#Create .bashrc file and set BASH_ENV var
COPY create_bashrc.bat C:\TEMP\
RUN powershell Start-Process -FilePath 'C:\TEMP\create_bashrc.bat'
ENV BASH_ENV C:\Users\Jenkins\.bashrc

# Start the agent process
ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Jenkins/jenkins-agent.ps1"]