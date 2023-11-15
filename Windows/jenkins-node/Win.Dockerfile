# escape=`
# Use JNLP agent as base and install required tools
FROM mcr.microsoft.com/windows:10.0.17763.3887-amd64 AS full

RUN xcopy /y C:\Windows\System32\opengl32.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\glu32.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MF.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MFPlat.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\MFReadWrite.dll C:\GatheredDlls\ && `
	xcopy /y C:\Windows\System32\dxva2.dll C:\GatheredDlls\

FROM jenkins/inbound-agent:3192.v713e3b_039fb_e-3-jdk11-windowsservercore-ltsc2019
COPY --from=full C:\GatheredDlls\ C:\Windows\System32\

# Reset the shell.
SHELL ["cmd", "/S", "/C"]

# Install Node.js LTS
ADD https://nodejs.org/dist/v8.11.3/node-v8.11.3-x64.msi C:\TEMP\node-install.msi
RUN start /wait msiexec.exe /i C:\TEMP\node-install.msi /l*vx "%TEMP%\MSI-node-install.log" /qn ADDLOCAL=ALL

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
RUN powershell Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Force
RUN powershell -NoProfile -Command "iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))" && SET "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
RUN powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

#Install git
RUN choco install git.install -y --no-progress

#Create .bashrc file and set BASH_ENV var
COPY create_bashrc.bat C:\TEMP\
RUN powershell Start-Process -FilePath 'C:\TEMP\create_bashrc.bat'
ENV BASH_ENV C:\Users\Jenkins\.bashrc

#Install visual studio build tools
RUN `
    # Download the Build Tools bootstrapper.
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/16/release/vs_buildtools.exe `
    `
    # Install Build Tools with the Microsoft.VisualStudio.Workload.VCTools workload, excluding workloads and components with known issues.
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2019\BuildTools" `
        --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended`
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 `
        --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 `
        --remove Microsoft.VisualStudio.Component.Windows81SDK `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    `
    # Cleanup
    && del /q vs_buildtools.exe

# Start the agent process
ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Jenkins/jenkins-agent.ps1"]
