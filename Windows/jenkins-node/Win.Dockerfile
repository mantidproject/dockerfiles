# escape=`
# Use JNLP agent as base and install required tools
FROM mcr.microsoft.com/windows:10.0.17763.7434-amd64 AS full

RUN xcopy /y C:\Windows\System32\glu32.dll C:\GatheredDlls\ && `
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
RUN Start-Process -Wait msiexec.exe -ArgumentList @('/i', 'C:\TEMP\node-install.msi', '/l*vx', '"%TEMP%\MSI-node-install.log"', '/qn', 'ADDLOCAL=ALL')

# Install patched Microsoft OpenJDK 17.0.21.1
RUN Invoke-WebRequest -Uri 'https://aka.ms/download-jdk/microsoft-jdk-17.0.21.1-windows-x64.msi' -OutFile C:\TEMP\microsoft-jdk.msi; `
    $installer = Start-Process -FilePath msiexec.exe -Wait -PassThru -ArgumentList @('/i', 'C:\TEMP\microsoft-jdk.msi', '/qn', '/norestart', 'ADDLOCAL=FeatureMain,FeatureEnvironment,FeatureJavaHome', 'INSTALLDIR=C:\Java\jdk-17'); `
    if ($installer.ExitCode -ne 0) { throw "JDK installation failed with exit code $($installer.ExitCode)" }; `
    Remove-Item C:\TEMP\microsoft-jdk.msi

RUN Get-ChildItem -Path 'C:\Java', 'C:\Program Files\Microsoft' -Recurse -Filter java.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty FullName

# Ensure the patched JDK is used by the Jenkins agent
ENV JAVA_HOME="C:\Java\jdk-17"
ENV PATH="C:\Java\jdk-17\bin;${PATH}"

# Verify Java installation
RUN & "$env:JAVA_HOME\bin\java.exe" -version; `
    if ($LASTEXITCODE -ne 0) { throw "Java verification failed" }

# Enable long paths
RUN powershell New-ItemProperty `
                   -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
                   -Name "LongPathsEnabled" `
                   -Value 1 `
                   -PropertyType DWORD `
                   -Force

# Install chocolatey
ENV ChocolateyUseWindowsCompression false
ENV chocolateyVersion 1.4.0
RUN powershell Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
RUN powershell Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Force

# Install git
RUN choco install git.install -y --no-progress

# Create .bashrc file and set BASH_ENV var
COPY create_bashrc.bat C:\TEMP\
RUN powershell Start-Process -FilePath 'C:\TEMP\create_bashrc.bat'
ENV BASH_ENV C:\Users\Jenkins\.bashrc

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Install Visual Studio Build Tools
RUN `
    curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe `
    && (start /w vs_buildtools.exe --quiet --wait --norestart --nocache `
        --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" `
        --add Microsoft.VisualStudio.Component.VC.Tools.x86.x64 `
        --add Microsoft.VisualStudio.Component.VC.14.38.17.8.x86.x64 `
        --add Microsoft.VisualStudio.Component.Windows10SDK.19041 `
        || IF "%ERRORLEVEL%"=="3010" EXIT 0) `
    && del /q vs_buildtools.exe

# Start the agent process
ENTRYPOINT ["powershell.exe", "-f", "C:/ProgramData/Jenkins/jenkins-agent.ps1"]
