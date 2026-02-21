TERMUX_SUBPKG_DESCRIPTION="pipewire - PulseAudio server"
TERMUX_SUBPKG_INCLUDE="
bin/pipewire-pulse
etc/pipewire/pipewire-pulse.conf.d
lib/pipewire-*/libpipewire-module-protocol-pulse.so
lib/pipewire-*/libpipewire-module-pulse-tunnel.so
share/pipewire/pipewire-pulse.conf*
"
