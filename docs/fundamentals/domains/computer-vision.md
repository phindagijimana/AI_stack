# Computer vision

> Classification, detection, segmentation, generation, video, 3D. The 70-year arc from hand-crafted features to vision transformers and multimodal foundation models.

## The eras

| Era | Dates | Defining methods |
| --- | --- | --- |
| Image processing | 1960s–1990s | Filters, edges, morphological ops |
| Classical CV | 1990s–2012 | SIFT, SURF, HOG + SVM; bag-of-visual-words |
| Deep learning (CNN) | 2012–2020 | AlexNet → ResNet → EfficientNet → ConvNeXt |
| Vision transformer | 2020–2023 | ViT, Swin, DeiT, BEiT |
| Multimodal foundation | 2023– | CLIP, SAM, DINOv2, GPT-4V, Gemini, Claude vision |

## Core tasks

### Image classification

Assign one (or several) labels to an image. Canonical benchmark: ImageNet (1000 classes).

Pre-CNN SOTA: ~25% top-5 error.
AlexNet (2012): 15.3%.
ResNet-152 (2015): 4.5%.
Vision transformers (2021+): ~1% top-5 — saturated.

### Object detection

Localise + classify objects with bounding boxes.

- **R-CNN family** ([Girshick 2014](https://arxiv.org/abs/1311.2524))[^rcnn]: region proposals + CNN classifier. Faster R-CNN, Mask R-CNN.
- **YOLO** family ([Redmon et al., 2016](https://arxiv.org/abs/1506.02640))[^yolo]: single-stage; very fast.
- **SSD**, **RetinaNet**: single-stage alternatives.
- **DETR** ([Carion et al., 2020](https://arxiv.org/abs/2005.12872))[^detr]: transformer-based; end-to-end.

Production today: YOLOv8 / YOLOv11 for real-time; Mask R-CNN for fidelity; DETR variants for SOTA.

### Semantic segmentation

Per-pixel class label. Output is a label map of the same size as the input.

- **FCN** ([Long et al., 2015](https://arxiv.org/abs/1411.4038))[^fcn]: fully-convolutional; the original.
- **U-Net** ([Ronneberger et al., 2015](https://arxiv.org/abs/1505.04597))[^unet]: encoder-decoder with skip connections; dominant in medical imaging.
- **DeepLab** ([Chen et al., 2016+](https://arxiv.org/abs/1606.00915))[^deeplab]: atrous convolutions for multi-scale context.
- **Segment Anything (SAM)** ([Kirillov et al., 2023](https://arxiv.org/abs/2304.02643))[^sam]: foundation model for promptable segmentation; one model handles thousands of segmentation tasks.

### Instance segmentation

Per-pixel labels with instance distinctions (object 1's pixels vs object 2's pixels, same class).

Standard: **Mask R-CNN** ([He et al., 2017](https://arxiv.org/abs/1703.06870))[^maskrcnn]. Modern: SAM-derived.

### Image generation

- **Pre-2014**: variational methods; image inpainting; texture synthesis.
- **2014–2021**: GANs (StyleGAN, BigGAN).
- **2021–**: diffusion models (DALL-E 2, Stable Diffusion, FLUX, SDXL, Imagen, Midjourney).

See [Generative models](../deep-learning/generative-models.md).

### Image-to-image translation

Convert images between domains: day → night, photo → painting, sketch → rendered.

- **pix2pix** ([Isola et al., 2017](https://arxiv.org/abs/1611.07004))[^pix2pix]: paired data.
- **CycleGAN** ([Zhu et al., 2017](https://arxiv.org/abs/1703.10593))[^cyclegan-cv]: unpaired.
- **ControlNet** ([Zhang et al., 2023](https://arxiv.org/abs/2302.05543))[^controlnet]: condition diffusion on edges / poses / depth.

### Video understanding

- **Action recognition** — what's happening in the video?
- **Temporal localisation** — when does the action occur?
- **Video object segmentation**.

Approaches: 3D CNNs (I3D, X3D), two-stream networks, video transformers (ViViT, TimeSformer, VideoMAE).

### Depth estimation, 3D reconstruction

- **Monocular depth** — predict per-pixel depth from a single image.
- **NeRF** ([Mildenhall et al., 2020](https://arxiv.org/abs/2003.08934))[^nerf] — neural radiance fields; 3D scene representation from images.
- **3D Gaussian Splatting** ([Kerbl et al., 2023](https://arxiv.org/abs/2308.04079))[^gaussian-splat] — explicit point-based scene representation; fast rendering.

These dominate the current 3D scene reconstruction / novel view synthesis frontier.

## Vision Transformers (ViT) [Dosovitskiy et al., 2020](https://arxiv.org/abs/2010.11929)[^vit-cv]

Split an image into 16×16 patches; treat each as a token; apply a standard transformer.

```
image (224x224) → 196 patches of 16x16 → linear projection → 196 tokens → transformer
```

Key finding: ViT matches / beats CNNs at scale (>100M images of pretraining). Below that scale, CNNs win.

Variants:

- **Swin Transformer** ([Liu et al., 2021](https://arxiv.org/abs/2103.14030))[^swin]: windowed attention; hierarchical; CNN-style inductive biases.
- **DeiT** ([Touvron et al., 2021](https://arxiv.org/abs/2012.12877))[^deit]: ViT that trains well on ImageNet alone (no JFT-300M pretraining).
- **DINOv2** ([Oquab et al., 2024](https://arxiv.org/abs/2304.07193))[^dinov2]: self-supervised ViT producing strong features.

## Foundation models in vision

- **CLIP** — image + text joint embedding. See [Embeddings](../deep-learning/embeddings.md#clip-and-multimodal-embeddings-radford-et-al-2021clip-emb).
- **SAM** — segment anything.
- **DINOv2** — strong general image features via self-supervision.
- **GPT-4V / Claude / Gemini** — multimodal LLMs with vision input. See [Senior → Multimodal](../../senior/multimodal.md).

These are increasingly *the* starting point — pretrained vision models you fine-tune or prompt rather than train from scratch.

## Classical CV that's still relevant

For some applications, deep learning is overkill:

- **OpenCV-style filters** for preprocessing.
- **SIFT / ORB feature matching** for image registration, panorama stitching.
- **Hough transform** for detecting lines / circles.
- **Camera calibration** with checkerboards (intrinsics, extrinsics).
- **Photogrammetry** for 3D reconstruction.

Often combined with deep models in a pipeline.

## Benchmarks

- **ImageNet** — classification (saturated).
- **COCO** — detection + segmentation.
- **Cityscapes** — semantic segmentation.
- **Kinetics** — action recognition.
- **OpenImages** — large-scale.
- **MMMU**, **MathVista** — multimodal reasoning. See [Benchmarks](../../evaluation/benchmarks.md).

## A pragmatic CV project checklist

For a new CV problem:

1. Is there a foundation model for this? Try it first.
   - **Classification**: CLIP zero-shot.
   - **Detection**: pretrained YOLO or Grounding DINO.
   - **Segmentation**: SAM.
2. If foundation-model performance isn't sufficient: fine-tune the closest pretrained model on your data.
3. If you have lots of in-domain data and unique requirements: train from scratch (rare today).

Almost no production CV project starts from random initialisation in 2026.

## References

[^rcnn]: Girshick R. Rich feature hierarchies for accurate object detection and semantic segmentation. *CVPR.* 2014.
[^yolo]: Redmon J, Divvala S, Girshick R, Farhadi A. You Only Look Once. *CVPR.* 2016.
[^detr]: Carion N, Massa F, Synnaeve G, et al. End-to-End Object Detection with Transformers. *ECCV.* 2020.
[^fcn]: Long J, Shelhamer E, Darrell T. Fully Convolutional Networks for Semantic Segmentation. *CVPR.* 2015.
[^unet]: Ronneberger O, Fischer P, Brox T. U-Net: Convolutional Networks for Biomedical Image Segmentation. *MICCAI.* 2015.
[^deeplab]: Chen L-C, Papandreou G, Kokkinos I, Murphy K, Yuille AL. DeepLab. *IEEE TPAMI.* 2017.
[^sam]: Kirillov A, Mintun E, Ravi N, et al. Segment Anything. *ICCV.* 2023.
[^maskrcnn]: He K, Gkioxari G, Dollár P, Girshick R. Mask R-CNN. *ICCV.* 2017.
[^pix2pix]: Isola P, Zhu J-Y, Zhou T, Efros AA. Image-to-Image Translation with Conditional Adversarial Networks. *CVPR.* 2017.
[^cyclegan-cv]: Zhu J-Y, et al. Unpaired Image-to-Image Translation using CycleGAN. *ICCV.* 2017.
[^controlnet]: Zhang L, Rao A, Agrawala M. Adding Conditional Control to Text-to-Image Diffusion Models (ControlNet). *ICCV.* 2023.
[^nerf]: Mildenhall B, Srinivasan PP, Tancik M, et al. NeRF: Representing Scenes as Neural Radiance Fields. *ECCV.* 2020.
[^gaussian-splat]: Kerbl B, Kopanas G, Leimkühler T, Drettakis G. 3D Gaussian Splatting for Real-Time Radiance Field Rendering. *SIGGRAPH.* 2023.
[^vit-cv]: Dosovitskiy A, Beyer L, Kolesnikov A, et al. An Image is Worth 16x16 Words (ViT). *ICLR.* 2021.
[^swin]: Liu Z, Lin Y, Cao Y, et al. Swin Transformer. *ICCV.* 2021.
[^deit]: Touvron H, Cord M, Douze M, et al. Training data-efficient image transformers (DeiT). *ICML.* 2021.
[^dinov2]: Oquab M, Darcet T, Moutakanni T, et al. DINOv2: Learning Robust Visual Features without Supervision. *TMLR.* 2024.
16. **Szeliski R.** *Computer Vision: Algorithms and Applications.* 2nd ed. 2022. (Free online.)
17. **Stanford CS231n: CNNs for Visual Recognition.** [cs231n.stanford.edu](http://cs231n.stanford.edu/)

## Where to next

[Speech & audio](speech-audio.md) — the parallel arc in audio signals.
