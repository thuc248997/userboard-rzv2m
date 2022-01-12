## prepost_hrnet.yaml

### Install DRP-AI_Translator

```bash
cd ${WORK}
rm -rfv drp-ai_translator_release && (echo y | proprietary/DRP-AI_Translator-v1.60-Linux-x86_64-Install)
```



```patch
diff -Naur a/prepost_hrnet.yaml b/prepost_hrnet.yaml
--- a/prepost_hrnet.yaml
+++ b/prepost_hrnet.yaml
@@ -3,7 +3,7 @@
 #######################################
 input_to_pre:
   -
-    name: "camera_data"
+    name: "yuv_data"
     format: "YUY2"
     order: "HWC"
     shape: [480, 640, 2]
@@ -11,10 +11,10 @@
 
 input_to_body:
   -
-    name: "image2"        # must match ONNX's input name
+    name: "input1"          # must match ONNX's input name
     format: "RGB"
     order: "HWC"          # Inference part can handle only HWC order
-    shape: [416, 416, 3]  # must match ONNX's input shape
+    shape: [256, 192, 3]  # must match ONNX's input shape
     type: "fp16"          # Inference part can handle only FP16 data
 
 #######################################
@@ -22,15 +22,15 @@
 #######################################
 output_from_body:
   -
-    name: "grid"
-    shape: [13, 13, 125]
+    name: "output1"
+    shape: [64, 48, 17]
     order: "HWC"
     type: "fp16"
 
 output_from_post:
   -
     name: "post_out"
-    shape: [125, 13, 13]
+    shape: [17, 64, 48]
     order: "CHW"
     type: "fp32"
 
@@ -39,9 +39,9 @@
 #######################################
 preprocess:
   -
-    src      : ["camera_data"]
+    src      : ["yuv_data"]
 
-    dest     : ["image2"]
+    dest     : ["input1"]
 
     operations:
     -
@@ -50,11 +50,24 @@
         DOUT_RGB_FORMAT: 0 # "RGB"
 
     -
+      op: crop
+      shape_in : [[480, 640, 3]]
+      dtype_in : ["uint8"]
+      dorder_in: ["HWC"]
+      shape_out: [[480, 270, 3]]
+      dtype_out: ["uint8"]
+      dorder_out: ["HWC"]
+      param:
+        CROP_POS_X : 185
+        CROP_POS_Y : 0
+        DATA_TYPE : 0 # 0 : 1Byte, 1 : 2Byte
+
+    -
       op: resize_hwc
       param:
         RESIZE_ALG: 1 # "Bilinear"
         DATA_TYPE: 0  # "uint8"
-        shape_out: [416, 416]
+        shape_out: [256, 192]
 
     -
       op: cast_any_to_fp16
@@ -64,23 +77,23 @@
     -
       op: normalize
       param:
-        DOUT_RGB_ORDER: 0 # Output RGB order = Input RGB order
-        cof_add: [0.0, 0.0, 0.0]
-        cof_mul: [0.00392157, 0.00392157, 0.00392157]
+        DOUT_RGB_ORDER: 0
+        cof_add: [-123.675, -116.28, -103.53]
+        cof_mul: [0.01712475, 0.017507, 0.01742919]
 
 #######################################
 # Postprocess
 #######################################
 postprocess:
   -
-    src: ["grid"]
+    src: ["output1"]
 
     dest: ["post_out"]
 
     operations:
       -
         op : transpose
-        param: 
+        param:
           WORD_SIZE: 1    # 2Byte
           IS_CHW2HWC: 0   # HWC to CHW
 

```
```
patch -p1 -l -f --fuzz 3 -i prepost_tinyyolov2_to_hrnet_yaml.diff
```
