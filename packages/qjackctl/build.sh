TERMUX_PKG_HOMEPAGE=https://qjackctl.sourceforge.io
TERMUX_PKG_DESCRIPTION="JACK Audio Connection Kit Qt GUI Interface"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_LICENSE="GPL-2.0"
TERMUX_PKG_VERSION=0.9.91
TERMUX_PKG_SRCURL=git+https://github.com/rncbc/qjackctl
TERMUX_PKG_GIT_BRANCH=qjackctl_${TERMUX_PKG_VERSION//./_}
TERMUX_PKG_DEPENDS="alsa-lib, hicolor-icon-theme, jack, qt6-qtbase, qt6-qtsvg, qt6-qttools"
TERMUX_PKG_BUILD_DEPENDS="qt6-qtbase-cross-tools, qt6-qttools-cross-tools"
TERMUX_PKG_AUTO_UPDATE=true
# TODO: enable system tray and xunique below line when QSharedMemoryPosix leakage issue is fixed by implementing the libandroid-sysv-semaphore for Android 14+ (https://github.com/termux/termux-packages/issues/20571)
# TODO: enable alsa seq when userspace seq server is available
TERMUX_PKG_EXTRA_CONFIGURE_ARGS="-DQT_HOST_PATH=$TERMUX_PREFIX/opt/qt6/cross/lib/qt6 -DCONFIG_SYSTEM_TRAY=no -DCONFIG_XUNIQUE=no -DCONFIG_ALSA_SEQ=no"
