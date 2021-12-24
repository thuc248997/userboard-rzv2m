FILESEXTRAPATHS_prepend := "${THISDIR}/files:"
LICENSE = "CLOSED"

SRC_URI = " \
	file://coastal.mp3 \
	file://coastal.wav \
"

S = "${WORKDIR}"

do_install () {
	mkdir -p ${D}/home/root/mp3
	cp -Rpfv ${WORKDIR}/coastal.mp3 ${D}/home/root/mp3
	cp -Rpfv ${WORKDIR}/coastal.wav ${D}/home/root/mp3
}

do_configure[noexec] = "1"
do_patch[noexec] = "1"
do_compile[noexec] = "1"

FILES_${PN} = " \
	/home/root \
"
