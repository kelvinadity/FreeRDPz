# Base image menggunakan Windows Server Core
FROM mcr.microsoft.com/windows/servercore:ltsc2019

# Direktori kerja
WORKDIR /app

# Download Ngrok dan skrip
RUN powershell -Command \
    Invoke-WebRequest -Uri https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-windows-amd64.zip -OutFile ngrok.zip; \
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/XenosShell/FreeRDP/master/start.bat -OutFile start.bat; \
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/XenosShell/FreeRDP/master/wallpaper.png -OutFile wallpaper.png; \
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/XenosShell/FreeRDP/master/wallpaper.bat -OutFile wallpaper.bat; \
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/XenosShell/FreeRDP/master/loop.bat -OutFile loop.bat; \
    Expand-Archive -Path ngrok.zip -DestinationPath ngrok

# Set environment variable for Ngrok auth token
ARG NGROK_AUTH_TOKEN
ENV NGROK_AUTH_TOKEN=${NGROK_AUTH_TOKEN}

# Enable RDP and configure firewall
RUN powershell -Command \
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server' -Name "fDenyTSConnections" -Value 0; \
    Enable-NetFirewallRule -DisplayGroup "Remote Desktop"; \
    Set-ItemProperty -Path 'HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp' -Name "UserAuthentication" -Value 1; \
    Copy-Item -Path wallpaper.png -Destination C:\Users\Public\Desktop\wallpaper.png; \
    Copy-Item -Path wallpaper.bat -Destination C:\Users\Public\Desktop\wallpaper.bat

# Start Ngrok and RDP
CMD powershell -Command \
    ./ngrok/ngrok.exe authtoken $Env:NGROK_AUTH_TOKEN; \
    Start-Process Powershell -ArgumentList '-Noexit -Command ".\ngrok\ngrok.exe tcp --region ap 3389"'; \
    cmd /c start.bat; \
    cmd /c loop.bat
