FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
LICENSE = "CLOSED"

inherit autotools pkgconfig

DEPENDS += " \
        drpai \
        comctl \
"
RDEPENDS_${PN} += " comctl"

APP_MODEL = "resnet50_cam"
APP_NAME = "resnet50_cam"

SRC_URI_append = " \
        file://src/* \
        file://${APP_MODEL}/* \
        file://synset_words_imagenet.txt \
"


S = "${WORKDIR}/src"

FILES_${PN} += " /home/root/app_${APP_NAME}"
INSANE_SKIP_${PN} = "ldflags"

do_compile_prepend() {
        make -C ${S} clean
}

do_compile () {
        make -C ${S}
}

do_install () {
        install -d ${D}/home/root/app_${APP_NAME}/exe/${APP_MODEL}
        install ${S}/sample_app_${APP_NAME} ${D}/home/root/app_${APP_NAME}/exe
        install ${WORKDIR}/${APP_MODEL}/* ${D}/home/root/app_${APP_NAME}/exe/${APP_MODEL}
        install ${WORKDIR}/synset_words_imagenet.txt ${D}/home/root/app_${APP_NAME}/exe
}

do_configure[noexec] = "1"
