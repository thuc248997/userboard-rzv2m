inherit autotools texinfo multilib_header

###PACKAGECONFIG[host] = "--host=${HOST_SYS},--host=${TARGET_SYS},host"
#
#EXTRA_OECONF += " --disable-assembly"

do_install_append() {
	oe_multilib_header gmp.h
}
