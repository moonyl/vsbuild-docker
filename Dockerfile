# escape=`
# Let us use PowerShell line continuation.

FROM mcr.microsoft.com/dotnet/framework/sdk:4.8

# Restore the default Windows shell for correct batch processing.
SHELL ["cmd", "/S", "/C"]

# Download the Visual Studio Build Tools bootstrapper.
ADD https://aka.ms/vs/16/release/vs_buildtools.exe C:\Temp\vs_buildtools.exe

# Use the latest release channel.
ADD https://aka.ms/vs/16/release/channel C:\Temp\VisualStudio.chman

# For help on command-line syntax:
# https://docs.microsoft.com/en-us/visualstudio/install/use-command-line-parameters-to-install-visual-studio
# Install MSVC C++ compiler, CMake, and MSBuild.
RUN C:\Temp\vs_buildtools.exe `
    --quiet --wait --norestart --nocache `
    --installPath C:\BuildTools `
    --channelUri C:\Temp\VisualStudio.chman `
    --installChannelUri C:\Temp\VisualStudio.chman `
    --add Microsoft.VisualStudio.Workload.VCTools;includeRecommended `
    --add Microsoft.Component.MSBuild `
 || IF "%ERRORLEVEL%"=="3010" EXIT 0

ENV GIT_VERSION 2.23.0
ENV GIT_PATCH_VERSION 1
#https://github.com/git-for-windows/git/releases/download/v2.23.0.windows.1/MinGit-2.23.0-busybox-64-bit.zip
RUN powershell -Command $ErrorActionPreference = 'Stop' ; `
    [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12 ; `
    Invoke-WebRequest -UseBasicParsing $('https://github.com/git-for-windows/git/releases/download/v{0}.windows.{1}/MinGit-{0}-busybox-64-bit.zip' -f $env:GIT_VERSION, $env:GIT_PATCH_VERSION) -OutFile 'mingit.zip' ; `
    Expand-Archive mingit.zip -DestinationPath c:\mingit ; `
    Remove-Item mingit.zip -Force ; `
    setx /M PATH $('c:\mingit\cmd;{0}' -f $env:PATH)

# Start developer command prompt with any other commands specified.
ENTRYPOINT ["C:\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&"]

# Default to PowerShell if no other command specified.
CMD ["powershell.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]
