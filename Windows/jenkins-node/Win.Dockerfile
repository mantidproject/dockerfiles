# escape=`
# Use JNLP agent as base and install required tools
FROM mcr.microsoft.com/windows:10.0.17763.7434-amd64 AS full

RUN	xcopy /y C:\Windows\System32\glu32.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MF.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MFPlat.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MFReadWrite.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\dxva2.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\opengl32.dll C:\GatheredDlls\

FROM jenkins/inbound-agent:3301.v4363ddcca_4e7-3-jdk17-windowsservercore-ltsc2019
COPY --from=full C:\GatheredDlls\ C:\Windows\System32\

# Reset the shell.
SHELL ["cmd", "/S", "/C"]

# Install Node.js LTS
ADD https://nodejs.org/dist/v20.9.0/node-v20.9.0-x64.msi C:\TEMP\node-install.msi
SHELL ["powershell", "-NoProfile ", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]
RUN Start-Process -Wait msiexec.exe  -ArgumentList @('/i', 'C:\TEMP\node-install.msi', '/l*vx', '"%TEMP%\MSI-node-install.log"', '/qn', 'ADDLOCAL=ALL')

#Enable long paths
RUN powershell New-ItemProperty `
                   -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
                   -Name "LongPathsEnabled" `
                   -Value 1 `
                   -PropertyType DWORD `
                   -Force

#Install chocolatey
ENV ChocolateyUseWindowsCompression false
ENV chocolateyVersion 1.4.0
RUN powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
RUN powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

#Install git
RUN choco install git.install -y --no-progress

#Create .bashrc file and set BASH_ENV var
COPY create_bashrc.bat C:\TEMP\
RUN powershell Start-Process -FilePath 'C:\TEMP\create_bashrc.bat'
ENV BASH_ENV C:\Users\Jenkins\.bashrc

# Restore the default Windows shell for correct batch processing.  
SHELL ["cmd", "/S", "/C"]  

#Install visual studio build tools
RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    `
    # Install Build Tools with the Microsoft.VisualStudio.Workload.MSBuildTools workload, excluding workloads and components with known issues.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64;14.38.33135 `
        --add Microsoft.VisualStudio.Component.Windows10SDK `
        --add Microsoft.VisualStudio.Component.VC.CoreBuildTools `
        --add Microsoft.VisualStudio.Component.VC.v142.x86.x64 `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Cleanup
    && del /q vs_buildtools.exe

# Start the agent process
ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Jenkins/jenkins-agent.ps1"]
