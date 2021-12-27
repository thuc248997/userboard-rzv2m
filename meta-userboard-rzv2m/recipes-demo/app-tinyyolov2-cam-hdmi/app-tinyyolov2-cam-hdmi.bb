FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
LICENSE = "CLOSED"

inherit pkgconfig

DEPENDS += " \
	drpai \
	comctl \
"
RDEPENDS_${PN} += " comctl"

SRC_URI_append = " \
	file://drpai_demo.service \
	file://drpai-demo.sh \
	file://src/* \
	file://tinyyolov2_cam/* \
"

S = "${WORKDIR}/src"

FILES_${PN} += " /home/root/app_tinyyolov2_mipi_hdmi /home/root/drpai-demo.sh"
#FILES_${PN}-dev = ""
#TARGET_CC_ARCH += "${LDFLAGS}"
INSANE_SKIP_${PN} = "ldflags"
#INSANE_SKIP_${PN}-dev = "ldflags"


do_compile_prepend() {
	make clean
}

do_compile () {
        make -C ${S}
}

do_install () {
	install -d ${D}/home/root/app_tinyyolov2_mipi_hdmi/exe/tinyyolov2_cam
	install ${S}/sample_app_tinyyolov2_cam_hdmi ${D}/home/root/app_tinyyolov2_mipi_hdmi/exe
	install ${WORKDIR}/tinyyolov2_cam/* ${D}/home/root/app_tinyyolov2_mipi_hdmi/exe/tinyyolov2_cam
	install ${WORKDIR}/drpai-demo.sh ${D}/home/root

	install -d ${D}/lib/systemd/system
        install ${WORKDIR}/drpai_demo.service ${D}/lib/systemd/system

        cd ${D}${sysconfdir}/systemd/system
        #ln -sf ../../../lib/systemd/system/outdoor_demo.service
        cd -
}

do_configure[noexec] = "1"
