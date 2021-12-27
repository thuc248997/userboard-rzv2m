FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
LICENSE = "CLOSED"

inherit autotools pkgconfig systemd

SYSTEMD_SERVICE_${PN} = "drpai_demo.service"
SYSTEMD_AUTO_ENABLE = "enable"

DEPENDS += " \
	drpai \
	comctl \
"
RDEPENDS_${PN} += " comctl"

SRC_URI_append = " \
	file://drpai_demo.service \
	file://drpai_demo.sh \
	file://src/* \
	file://tinyyolov2_cam/* \
"

S = "${WORKDIR}/src"

FILES_${PN} += " ${systemd_unitdir}/system ${sysconfdir}/systemd/system /home/root/app_tinyyolov2_mipi_hdmi /home/root/drpai_demo.sh /home/root/drpai_demo.service"
#FILES_${PN}-dev = ""
#TARGET_CC_ARCH += "${LDFLAGS}"
INSANE_SKIP_${PN} = "ldflags"
#INSANE_SKIP_${PN}-dev = "ldflags"

do_compile_prepend() {
        make -C ${S} clean
}

do_compile () {
        make -C ${S}
}

do_install () {
	install -d ${D}/home/root/app_tinyyolov2_mipi_hdmi/exe/tinyyolov2_cam
	install ${S}/sample_app_tinyyolov2_cam_hdmi ${D}/home/root/app_tinyyolov2_mipi_hdmi/exe
	install ${WORKDIR}/tinyyolov2_cam/* ${D}/home/root/app_tinyyolov2_mipi_hdmi/exe/tinyyolov2_cam
	chmod +x ${WORKDIR}/drpai_demo.sh
	install ${WORKDIR}/drpai_demo.sh ${D}/home/root

	install -d ${D}${systemd_unitdir}/system
	install -d ${D}${sysconfdir}/systemd/system
	install -m 0644 ${WORKDIR}/drpai_demo.service ${D}${systemd_unitdir}/system

	cd ${D}${sysconfdir}/systemd/system
	#ln -sf ../../../lib/systemd/system/drpai_demo.service .
	cd -
}

do_configure[noexec] = "1"
