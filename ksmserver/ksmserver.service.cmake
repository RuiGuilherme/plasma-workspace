[Unit]
Description=KDE Session Management Server
Wants=kcminit.service

[Service]
ExecStart=@CMAKE_INSTALL_FULL_BINDIR@/ksmserver
# This magic minus sign means don't fail if exit code is non-zero...
ExecStartPost=-@QtBinariesDir@/qdbus org.kde.KSplash /KSplash org.kde.KSplash.setStage ksmserver
BusName=org.kde.ksmserver

[Install]
WantedBy=plasma-core.target