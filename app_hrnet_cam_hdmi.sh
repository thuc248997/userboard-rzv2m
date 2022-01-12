#!/bin/sh -e

#unset BBPATH BB_ENV_EXTRAWHITE

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colo

APP_FOLDER=app_hrnet_cam_hdmi
echo -e "${YELLOW}>> ${APP_FOLDER} ${NC}"

MODEL=$(echo ${APP_FOLDER} | awk -F '_' '{print $2}')
APP_NAME=$(echo ${APP_FOLDER} | sed 's/_/-/g')
WORK=`pwd`
DRPAI=${WORK}/drp-ai_translator_release

#############################
cd ${WORK}
[ ! -d drpai_samples/${MODEL}_cam -o ! -d drpai_samples/${MODEL}_jpg -o ! -d drpai_samples/${MODEL}_bmp ] && \
        tar zxvf r11an0530ej0500-rzv2m-drpai-sp/rzv2m_ai-implementation-guide/mmpose_${MODEL}/mmpose_${MODEL}_ver5.00.tar.gz

#############################
git clone -b v0.18.0 https://github.com/open-mmlab/mmpose.git || true
cd ${WORK}/mmpose
git checkout tools/deployment/pytorch2onnx.py && patch -p1 -l -f --fuzz 3 -i ../extra/mmpose_tools_deployment_pytorch2onnx_py.patch
if [ 0 -eq `pip3 list | grep opencv-python-headless | grep 4.5.4.60 | wc -l` ]; then
        pip3 install -r requirements.txt
        sudo python3 setup.py develop
        (pip3 uninstall opencv_python_headless -y || true) && pip3 install opencv-python-headless==4.5.4.60
        (pip3 uninstall mmcv -y || true) && pip3 install mmcv==1.3.16
fi

#############################
NN=configs/body/2d_kpt_sview_rgb_img/topdown_heatmap/coco/hrnet_w32_coco_256x192.py
OUTPUT=${MODEL}.onnx
WEIGHT=hrnet_w32_coco_256x192-c78dce93_20200708.pth
[ ! -f ${WEIGHT} ] && wget https://download.openmmlab.com/mmpose/top_down/${MODEL}/${WEIGHT} -O ${WEIGHT}
python3 tools/deployment/pytorch2onnx.py $NN ${WEIGHT} --opset-version 11 --shape 1 3 256 192 --output-file $OUTPUT
chmod +x ${MODEL}.onnx

cd ${WORK}
/bin/cp -rpf mmpose/${MODEL}.onnx $DRPAI/onnx/
ls -l $DRPAI/onnx/${MODEL}.onnx

#############################
cd ${DRPAI}
rm -rf output/${MODEL}_cam
./run_DRP-AI_translator_V2M.sh ${MODEL}_cam -onnx onnx/${MODEL}.onnx -addr ../drpai_samples/${MODEL}_cam/input/addrmap_in_${MODEL}.yaml -prepost ../drpai_samples/${MODEL}_cam/input/prepost_${MODEL}.yaml

#############################
echo -e "${YELLOW}>> meta-userboard-rzv2m/recipes-demo ${NC}"
cd ${WORK}
rm -rf meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_cam
mkdir -p meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
/bin/cp -Rpf ${DRPAI}/output/${MODEL}_cam meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
#/bin/cp -Rpf rzv2m_drpai-sample-application_ver5.00/app_${MODEL}_cam_hdmi/exe/${MODEL}_cam meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
echo -e "${YELLOW}>> ${MODEL}_cam ${NC}"
ls -ld --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_cam
ls -l --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_cam

echo -e "${YELLOW}>> app-${MODEL}-cam-hdmi/src ${NC}"
/bin/cp -Rpf rzv2m_drpai-sample-application_ver5.00/${APP_FOLDER}/src \
	meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
ls -ld --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/src
ls -l --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/src
exit 0
