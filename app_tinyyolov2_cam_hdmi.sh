#!/bin/sh -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colo

APP_FOLDER=app_tinyyolov2_cam_hdmi
echo -e "${YELLOW}>> ${APP_FOLDER} ${NC}"

MODEL=$(echo ${APP_FOLDER} | awk -F '_' '{print $2}')
APP_NAME=$(echo ${APP_FOLDER} | sed 's/_/-/g')
WORK=`pwd`
DRPAI=${WORK}/drp-ai_translator_release
tar zxvf r11an0530ej0500-rzv2m-drpai-sp/rzv2m_ai-implementation-guide/darknet_${MODEL}/darknet_${MODEL}_ver5.00.tar.gz

#############################
echo -e "${YELLOW}>> Convert from Darknet to PyTorch ${NC}"
cd ${WORK}/pytorch/${MODEL}
#tail -2 ${WORK}/pytorch/tinyyolov2/convert_to_pytorch.py
python3 ${WORK}/pytorch/${MODEL}/convert_to_pytorch.py
chmod +x ${WORK}/pytorch/${MODEL}/yolov2-tiny-voc.pth
ls -l --color ${WORK}/pytorch/${MODEL}/yolov2-tiny-voc.pth

#############################
echo -e "${YELLOW}>> Convert from PyTorch to ONNX format ${NC}"
cd ${WORK}/pytorch/${MODEL}
python3 ${WORK}/pytorch/${MODEL}/convert_to_onnx.py
chmod +x ${WORK}/pytorch/${MODEL}/${MODEL}.onnx
ls -l --color ${WORK}/pytorch/${MODEL}/${MODEL}.onnx
#echo -e "${YELLOW}>> onnx/tinyyolov2.onnx ${NC}"
/bin/cp -fv ${WORK}/pytorch/${MODEL}/${MODEL}.onnx $DRPAI/onnx/${MODEL}.onnx
chmod +x $DRPAI/onnx/${MODEL}.onnx
ls -l --color $DRPAI/onnx/${MODEL}.onnx

#############################
cd ${DRPAI}
ls -l --color ../drpai_samples/${MODEL}_cam/input/*.yaml
rm -rfv output/${MODEL}_cam
echo -e "${YELLOW}>> DRP-AI translate => tinyyolov2_cam ${NC}"
./run_DRP-AI_translator_V2M.sh ${MODEL}_cam \
	-onnx ./onnx/${MODEL}.onnx \
	-addr ../drpai_samples/${MODEL}_cam/input/addrmap_in_${MODEL}.yaml \
	-prepost ../drpai_samples/${MODEL}_cam/input/prepost_${MODEL}.yaml
chmod +x output/${MODEL}_cam/*

#############################
echo -e "${YELLOW}>> meta-userboard-rzv2m/recipes-demo ${NC}"
cd ${WORK}
#rm -rf meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_cam
mkdir -p meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
/bin/cp -Rpf ${DRPAI}/output/${MODEL}_cam \
	meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
echo -e "${YELLOW}>> ${MODEL}_cam ${NC}"
ls -ld --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_cam
ls -l --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_cam

echo -e "${YELLOW}>> app-${MODEL}-cam-hdmi/src ${NC}"
/bin/cp -Rpf rzv2m_drpai-sample-application_ver5.00/${APP_FOLDER}/src \
	meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
ls -ld --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/src
ls -l --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/src
exit 0
