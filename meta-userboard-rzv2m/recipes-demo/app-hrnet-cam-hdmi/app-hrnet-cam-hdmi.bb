FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
LICENSE = "CLOSED"

inherit autotools pkgconfig systemd

DEPENDS += " \
	drpai \
	comctl \
"
RDEPENDS_${PN} += " comctl"

SRC_URI_append = " \
	file://src/* \
	file://hrnet_cam/* \
"

S = "${WORKDIR}/src"

FILES_${PN} += " /home/root/app_hrnet_cam_hdmi"
INSANE_SKIP_${PN} = "ldflags"

do_compile_prepend() {
        make -C ${S} clean
}

do_compile () {
        make -C ${S}
}

do_install () {
	install -d ${D}/home/root/app_hrnet_cam_hdmi/exe/hrnet_cam
	install ${S}/sample_app_hrnet_cam_hdmi ${D}/home/root/app_hrnet_cam_hdmi/exe
	install ${WORKDIR}/hrnet_cam/* ${D}/home/root/app_hrnet_cam_hdmi/exe/hrnet_cam
}

do_configure[noexec] = "1"
