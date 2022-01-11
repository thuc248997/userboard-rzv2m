USE_DEPMOD ?= "1"

IMAGE_INSTALL_append = " \
	app-resnet50-cam \
	app-tinyyolov2-img \
	app-tinyyolov2-cam-hdmi \
	app-hrnet-cam-hdmi \
	tzdata \
	nfs-utils \
	devmem2 i2c-tools libgpiod sysbench \
	libdrm-tests libdrm-kms libdrm libpng tslib \
	dosfstools \
	lrzsz \
	demo-videos \
	demo-mp3 \
	drm2png \
	alsa-state \
"

IMAGE_INSTALL_append = " e2fsprogs e2fsprogs-resize2fs udev curl bc rpm usbutils"
IMAGE_INSTALL_append = " mmc-utils squashfs-tools iputils sqlite3 libevent"
IMAGE_INSTALL_append = " tmux yavta"
IMAGE_INSTALL_append = " live555 live555-openrtsp live555-playsip live555-mediaserver"

IMAGE_INSTALL_append = " libjpeg-turbo pv fbida"
IMAGE_INSTALL_append = " wget"
IMAGE_INSTALL_append = " mpg123"
IMAGE_INSTALL_append = " libexif giflib"

#IMAGE_INSTALL_append = " libqmi libmbim modemmanager minicom"
IMAGE_INSTALL_append = " minicom"
IMAGE_INSTALL_append = " ppp bluez5 iw wireless-tools hostapd"
