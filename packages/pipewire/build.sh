TERMUX_PKG_HOMEPAGE=https://pipewire.org/
TERMUX_PKG_DESCRIPTION="A server and user space API to deal with multimedia pipelines"
TERMUX_PKG_LICENSE="MIT, LGPL-2.1, LGPL-3.0, GPL-2.0"
TERMUX_PKG_LICENSE_FILE="COPYING, LICENSE"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="1.4.9"
TERMUX_PKG_SRCURL="https://gitlab.freedesktop.org/pipewire/pipewire/-/archive/${TERMUX_PKG_VERSION}/pipewire-${TERMUX_PKG_VERSION}.tar.bz2"
TERMUX_PKG_SHA256=e606aa3f6d53ec4c56fe35034d35cadfe0bbea1a5275e4e006dd7d1abaec6b92
TERMUX_PKG_DEPENDS="ffmpeg, glib, libc++, lua54, libopus, libsndfile, libwebrtc-audio-processing, lilv, ncurses, openssl, readline, pulseaudio, alsa-lib, oboe"
TERMUX_PKG_BUILD_DEPENDS="jack2"
TERMUX_PKG_AUTO_UPDATE=true

# 'media-session' session-managers is disabled as it requires alsa.
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="
-Dgstreamer=disabled
-Dgstreamer-device-provider=disabled
-Dtests=disabled
-Dexamples=disabled
-Dpipewire-alsa=enabled
-Dalsa=enabled
-Dpipewire-jack=enabled
-Djack=disabled
-Djack-devel=true
-Ddbus=disabled
-Dsession-managers=['wireplumber']
-Dffmpeg=enabled
-Dwireplumber:system-lua=true
-Dwireplumber:system-lua-version=54
"

termux_step_pre_configure() {
	# Our aaudio modules need libaaudio.so from a later android api version:
	if [ $TERMUX_PKG_API_LEVEL -lt 26 ]; then
		local _libdir="$TERMUX_PKG_TMPDIR/libaaudio"
		rm -rf "${_libdir}"
		mkdir -p "${_libdir}"
		cp "$TERMUX_STANDALONE_TOOLCHAIN/sysroot/usr/lib/$TERMUX_HOST_PLATFORM/26/libaaudio.so" \
			"${_libdir}"
		LDFLAGS+=" -L${_libdir}"
	fi
	cp $TERMUX_PKG_BUILDER_DIR/module-*.c* $TERMUX_PKG_SRCDIR/src/modules
	cp $TERMUX_PKG_BUILDER_DIR/module-protocol-pulse/* $TERMUX_PKG_SRCDIR/src/modules/module-protocol-pulse/modules

	local _WRAPPER_BIN="${TERMUX_PKG_BUILDDIR}/_wrapper/bin"
	mkdir -p "${_WRAPPER_BIN}"
	if [[ "${TERMUX_ON_DEVICE_BUILD}" == "false" ]]; then
		sed "s|^export PKG_CONFIG_LIBDIR=|export PKG_CONFIG_LIBDIR=${TERMUX_PREFIX}/opt/glib/cross/lib/x86_64-linux-gnu/pkgconfig:|" \
			"${TERMUX_STANDALONE_TOOLCHAIN}/bin/pkg-config" \
			> "${_WRAPPER_BIN}/pkg-config"
		chmod +x "${_WRAPPER_BIN}/pkg-config"
		export PKG_CONFIG="${_WRAPPER_BIN}/pkg-config"
	fi
	export PATH="${_WRAPPER_BIN}:${PATH}"

	sed -i "s/'-Werror=strict-prototypes',//" ${TERMUX_PKG_SRCDIR}/meson.build
	CFLAGS+=" -Dindex=strchr -Drindex=strrchr"
}

termux_step_post_make_install() {
	mkdir -p "$TERMUX_PREFIX/etc/pipewire/pipewire-pulse.conf.d"
	mkdir -p "$TERMUX_PREFIX/etc/alsa/conf.d"
	ln -st "$TERMUX_PREFIX/etc/alsa/conf.d" $TERMUX_PREFIX/share/alsa/alsa.conf.d/99-pipewire-default.conf
	ln -st "$TERMUX_PREFIX/etc/alsa/conf.d" $TERMUX_PREFIX/share/alsa/alsa.conf.d/50-pipewire.conf
	for file in "$PREFIX"/lib/pipewire*/jack/*; do
		ln -sft "$PREFIX/lib" "$file"
	done
	for file in "$PREFIX"/lib/libjack*.so; do
		ln -srf "$file" "$file.0"
	done
}
