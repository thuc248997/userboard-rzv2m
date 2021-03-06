#!/bin/sh -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Colo

APP_FOLDER=app_resnet50_img
echo -e "${YELLOW}>> ${APP_FOLDER} ${NC}"

MODEL=$(echo ${APP_FOLDER} | awk -F '_' '{print $2}') # resnet50
APP_NAME=$(echo ${APP_FOLDER} | sed 's/_/-/g')
WORK=`pwd`
DRPAI=${WORK}/drp-ai_translator_release

#############################
if [ 0 -eq `pip3 list | grep torch | wc -l` ]; then
        pip3 uninstall torch torchvision torchaudio -y || true
	if [ 0 -ne `lsmod | grep nvidia | wc -l` ]; then
		pip3 install torch==1.10.1+cu113 torchvision==0.11.2+cu113 torchaudio===0.10.1+cu113 -f https://download.pytorch.org/whl/cu113/torch_stable.html
	else
		pip3 install torch==1.10.1+cpu torchvision==0.11.2+cpu torchaudio==0.10.1+cpu -f https://download.pytorch.org/whl/cpu/torch_stable.html
	fi
fi
[ ! -d drpai_samples/${MODEL}_cam -o ! -d drpai_samples/${MODEL}_jpg -o ! -d drpai_samples/${MODEL}_bmp ] && \
	tar zxvf r11an0530ej0500-rzv2m-drpai-sp/rzv2m_ai-implementation-guide/pytorch_resnet/pytorch_resnet_ver5.00.tar.gz

#############################
cd ${WORK}/pytorch/${MODEL}
python3 ${WORK}/pytorch/${MODEL}/convert_to_onnx.py
/bin/cp -fv ${WORK}/pytorch/${MODEL}/${MODEL}.onnx $DRPAI/onnx/${MODEL}.onnx
chmod +x $DRPAI/onnx/${MODEL}.onnx
ls -l --color $DRPAI/onnx/${MODEL}.onnx

#############################
cd ${DRPAI}
ls -l --color ../drpai_samples/${MODEL}_bmp/input/*.yaml
rm -rf output/${MODEL}_bmp
echo -e "${YELLOW}>> DRP-AI translate => ${MODEL}_cam ${NC}"
./run_DRP-AI_translator_V2M.sh ${MODEL}_bmp \
	-onnx ./onnx/${MODEL}.onnx \
	-addr ../drpai_samples/${MODEL}_bmp/input/addrmap_in_${MODEL}.yaml \
	-prepost ../drpai_samples/${MODEL}_bmp/input/prepost_${MODEL}.yaml
chmod +x output/${MODEL}_bmp/*

#############################
echo -e "${YELLOW}>> meta-userboard-rzv2m/recipes-demo ${NC}"
cd ${WORK}
rm -rf meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_bmp
mkdir -p meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
/bin/cp -Rpf ${DRPAI}/output/${MODEL}_bmp \
	meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
echo -e "${YELLOW}>> ${MODEL}_bmp ${NC}"
ls -ld --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_bmp
ls -l --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/${MODEL}_bmp

echo -e "${YELLOW}>> app-${MODEL}-cam/src ${NC}"
/bin/cp -Rpf rzv2m_drpai-sample-application_ver5.00/${APP_FOLDER}/src \
	meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
ls -ld --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/src
ls -l --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files/src

/bin/cp -Rpf rzv2m_drpai-sample-application_ver5.00/${APP_FOLDER}/exe/synset_words_imagenet.txt meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
/bin/cp -Rpf rzv2m_drpai-sample-application_ver5.00/${APP_FOLDER}/exe/sample.bmp meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
ls -l --color meta-userboard-rzv2m/recipes-demo/${APP_NAME}/files
exit 0
