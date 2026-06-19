# CNNs

> Convolutions, pooling, classical architectures (LeNet → AlexNet → VGG → ResNet → EfficientNet → ConvNeXt), and why CNNs are still everywhere despite the rise of vision transformers.

## The convolution operation

Slide a small **kernel** (e.g., 3×3) across the input; at each location compute the dot product of kernel with the local patch:

$$
y[i, j] = \sum_{u, v} x[i + u, j + v] \cdot K[u, v]
$$

The same kernel is applied everywhere → **weight sharing**. This is the key inductive bias: translation equivariance (a feature appearing at any location is detected the same way).

```python
import torch.nn as nn
conv = nn.Conv2d(in_channels=3, out_channels=64, kernel_size=3, padding=1)
# input: (B, 3, H, W); output: (B, 64, H, W)
```

## Why convolutions for images

Three properties make convolutions a perfect fit for visual data:

1. **Translation equivariance** — a cat is a cat wherever in the image it appears.
2. **Local connectivity** — pixels near each other are usually related; far pixels usually aren't (at low layers).
3. **Parameter sharing** — one set of filters for the whole image. Massive parameter reduction vs MLP.

A fully-connected layer from 224×224 RGB to 1000 classes needs ~150M parameters; a CNN like ResNet-50 uses ~25M for a much better classifier.

## Pooling

Downsample spatially:

- **Max pooling** — take the max in each window.
- **Average pooling** — take the mean.
- **Global average pooling** — average over the entire spatial extent.

```python
pool = nn.MaxPool2d(kernel_size=2, stride=2)
```

Effect: reduce spatial resolution, increase receptive field, add invariance to small translations. Modern architectures often use *strided convolutions* instead of explicit pooling.

## Channels and feature maps

A 2D convolutional layer has shape `(C_in, C_out, H_kernel, W_kernel)`. Each output channel is a learned filter; the model learns *what features to detect*. Early layers learn edges and textures; later layers learn parts and objects ([Olah et al., 2017](https://distill.pub/2017/feature-visualization/))[^olah-fv].

## A canonical CNN architecture

```
Input (224x224x3)
  ↓ Conv 64 + ReLU + MaxPool      → 112x112x64
  ↓ Conv 128 + ReLU + MaxPool     → 56x56x128
  ↓ Conv 256 + ReLU + MaxPool     → 28x28x256
  ↓ Conv 512 + ReLU + MaxPool     → 14x14x512
  ↓ Conv 512 + ReLU + MaxPool     → 7x7x512
  ↓ Flatten
  ↓ FC 4096 + ReLU + Dropout
  ↓ FC 1000 + Softmax
  → 1000 class probabilities
```

Roughly: VGG-16. Variations on this shape dominated 2012–2017.

## The famous architectures

### LeNet-5 [LeCun et al., 1998](http://yann.lecun.com/exdb/publis/pdf/lecun-98.pdf)[^lenet]

The original CNN. Trained on MNIST. ~60k parameters.

### AlexNet [Krizhevsky et al., 2012](https://proceedings.neurips.cc/paper/2012/hash/c399862d3b9d6b76c8436e924a68c45b-Abstract.html)[^alexnet-cnn]

Won ImageNet 2012 by a huge margin (~10% error reduction). Demonstrated:

- GPUs make deep CNNs trainable.
- ReLU > sigmoid.
- Dropout helps.
- Local response normalisation (later abandoned for batch norm).

The "ImageNet moment" that started the deep-learning revolution.

### VGG [Simonyan & Zisserman, 2015](https://arxiv.org/abs/1409.1556)[^vgg]

Simple architecture: stack 3×3 convolutions. Showed that *depth matters*. 16- and 19-layer variants. Heavy parameter count.

### Inception / GoogLeNet [Szegedy et al., 2015](https://arxiv.org/abs/1409.4842)[^inception]

Parallel convolutions at multiple scales within each "Inception module." More parameter-efficient than VGG.

### ResNet [He et al., 2016](https://arxiv.org/abs/1512.03385)[^resnet-cnn]

The breakthrough that enabled networks with hundreds of layers via **residual connections** (skip connections):

$$
h_{\ell+1} = h_\ell + F(h_\ell)
$$

The identity-shortcut lets gradients flow back unimpeded. Trained 152-layer networks; later thousand-layer variants. The architectural pattern adopted by basically every deep network since — including transformers.

### EfficientNet [Tan & Le, 2019](https://arxiv.org/abs/1905.11946)[^efficientnet]

Systematic study of compound scaling (depth × width × resolution). Strong accuracy at low parameter count.

### ConvNeXt [Liu et al., 2022](https://arxiv.org/abs/2201.03545)[^convnext]

Modernised CNN architecture inspired by ViT-era best practices (LayerNorm, fewer activations, depthwise-separable conv). Showed CNNs are *still competitive* with vision transformers when modernised.

## Variants worth knowing

- **Depthwise-separable convolution** (MobileNet): separates per-channel and pointwise convolutions; much cheaper.
- **Dilated / atrous convolution**: introduces gaps to increase receptive field without increasing parameters. Used in semantic segmentation.
- **Group convolution**: shards channels into groups; reduces compute.
- **Deformable convolution**: learned sampling offsets.

## CNNs vs vision transformers

Since [ViT (Dosovitskiy et al., 2020)](https://arxiv.org/abs/2010.11929)[^vit], transformers have dominated vision benchmarks at scale. But:

- **CNNs win at small data** — ViTs need lots of pretraining data; CNNs work with thousands of images.
- **CNNs are faster** on edge / mobile.
- **CNN feature hierarchies** are interpretable (early=edges, late=objects).
- **Hybrid models** (Swin Transformer, CoAtNet, ConvNeXt) combine convolutional priors with attention.

For multimodal LLMs, the vision encoder is still often a CNN or a hybrid. Pure ViTs are common in research; in production both architectures coexist.

## Applications

- **Image classification** — ImageNet, fine-grained recognition.
- **Object detection** — Faster R-CNN, YOLO, RetinaNet (CNN backbones).
- **Semantic segmentation** — U-Net, FCN, DeepLab.
- **Image generation** — older GANs (StyleGAN family); now displaced by diffusion + transformers.
- **Medical imaging** — CT / MRI / X-ray classification and segmentation.
- **Satellite imagery** — classification, change detection.
- **Edge AI** — MobileNet-style architectures on phones.

## A minimal PyTorch CNN

```python
import torch.nn as nn

class SimpleCNN(nn.Module):
    def __init__(self, n_classes=10):
        super().__init__()
        self.features = nn.Sequential(
            nn.Conv2d(3, 32, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(32, 64, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
            nn.Conv2d(64, 128, 3, padding=1), nn.ReLU(), nn.MaxPool2d(2),
        )
        self.classifier = nn.Sequential(
            nn.AdaptiveAvgPool2d(1), nn.Flatten(),
            nn.Linear(128, n_classes),
        )
    def forward(self, x):
        return self.classifier(self.features(x))
```

90 lines including imports. Trains on CIFAR-10 to >80% in an hour on a laptop.

## References

[^olah-fv]: Olah C, Mordvintsev A, Schubert L. Feature Visualization. *Distill.* 2017.
[^lenet]: LeCun Y, Bottou L, Bengio Y, Haffner P. Gradient-Based Learning Applied to Document Recognition. *Proceedings of the IEEE.* 1998.
[^alexnet-cnn]: Krizhevsky A, Sutskever I, Hinton GE. ImageNet Classification with Deep CNNs. *NeurIPS.* 2012.
[^vgg]: Simonyan K, Zisserman A. Very Deep Convolutional Networks for Large-Scale Image Recognition. *ICLR.* 2015. [arXiv:1409.1556](https://arxiv.org/abs/1409.1556)
[^inception]: Szegedy C, Liu W, Jia Y, et al. Going Deeper with Convolutions. *CVPR.* 2015. [arXiv:1409.4842](https://arxiv.org/abs/1409.4842)
[^resnet-cnn]: He K, Zhang X, Ren S, Sun J. Deep Residual Learning for Image Recognition. *CVPR.* 2016. [arXiv:1512.03385](https://arxiv.org/abs/1512.03385)
[^efficientnet]: Tan M, Le QV. EfficientNet: Rethinking Model Scaling for Convolutional Neural Networks. *ICML.* 2019. [arXiv:1905.11946](https://arxiv.org/abs/1905.11946)
[^convnext]: Liu Z, Mao H, Wu C-Y, Feichtenhofer C, Darrell T, Xie S. A ConvNet for the 2020s (ConvNeXt). *CVPR.* 2022. [arXiv:2201.03545](https://arxiv.org/abs/2201.03545)
[^vit]: Dosovitskiy A, Beyer L, Kolesnikov A, et al. An Image is Worth 16x16 Words: Transformers for Image Recognition at Scale. *ICLR.* 2021. [arXiv:2010.11929](https://arxiv.org/abs/2010.11929)
10. **Goodfellow I, Bengio Y, Courville A.** *Deep Learning.* Ch. 9 — Convolutional Networks.

## Where to next

[RNNs / LSTMs](rnns-lstms.md) — the pre-transformer sequence architectures.
