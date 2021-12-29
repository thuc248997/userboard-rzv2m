LIC_FILES_CHKSUM = "file://LICENSE.md;md5=2e4821bed385270bdfa81f3e13d0b68d"
LICENSE="BSD-3-Clause"
#PV = "1.04+git${SRCPV}"

PACKAGE_ARCH = "${MACHINE_ARCH}"

FLASH_WRITER_URL = "git://github.com/renesas-rz/rzg2_flash_writer.git"
BRANCH = "rz_v2m"

SRC_URI = "${FLASH_WRITER_URL};branch=${BRANCH}"
SRCREV = "27cc05b41b533b7296e35c77013c236483efd617"
SRC_URI_append = "\
        file://emmc_flash_writer_helper \
"

inherit deploy

S = "${WORKDIR}/git"

do_compile() {
        cd ${S}
        git checkout makefile.linaro
        sed 's|^INCLUDE_DIR = include$|INCLUDE_DIR = include -I../recipe-sysroot/usr/include|' -i makefile.linaro
	oe_runmake -f makefile.linaro CROSS_COMPILE=aarch64-poky-linux-
}

do_install[noexec] = "1"

do_deploy() {
	install -d ${DEPLOYDIR}
	install -m 755 ${S}/AArch64_output/*.mot ${DEPLOYDIR}
	install -m 755 ${S}/AArch64_output/B2_intSW.bin ${DEPLOYDIR}
        install -m 755 ${WORKDIR}/emmc_flash_writer_helper ${DEPLOYDIR}
}
PARALLEL_MAKE = "-j 1"
addtask deploy after do_compile
