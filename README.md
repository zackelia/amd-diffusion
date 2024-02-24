# amd-diffusion

Docker image with AMD support for AUTOMATIC1111/stable-diffusion-webui

## Prerequisites

Install amdgpu driver with ROCm 6.0.2 support. Download at https://www.amd.com/en/support/linux-drivers

Instructions adapted from https://amdgpu-install.readthedocs.io/en/latest/install-installing.html

```
sudo apt install ./amdgpu-install_6.0.60002-1_all.deb
amdgpu-install -y --accept-eula --usecase=rocm
sudo usermod -a -G render $LOGNAME
sudo usermod -a -G video $LOGNAME
```

Reboot for changes to take effect.

## Usage

`pytorch` is currently built for gfx90a, gfx900, gfx906, gfx908, gfx1030, gfx1100. You can check what processor your GPU is by either visiting LLVM's documentation (https://llvm.org/docs/AMDGPUUsage.html#id16) or by running the following command:

```
rocminfo | grep gfx
```

If your processor is not built by `pytorch`, you will need to provide the `HSA_OVERRIDE_GFX_VERSION` environment variable with the closet version. For example, an RX 67XX XT has processor gfx1031 so it should be using gfx1030. To use gfx1030, set `HSA_OVERRIDE_GFX_VERSION=10.3.0` in docker-compose.yml.

For some cards, you will need to provide extra arguments in docker-compose.yml (some of which will boost performance) https://github.com/AUTOMATIC1111/stable-diffusion-webui/wiki/Install-and-Run-on-AMD-GPUs
> For many AMD GPUs, you must add --precision full --no-half or --upcast-sampling arguments to avoid NaN errors or crashing. If --upcast-sampling works as a fix with your card, you should have 2x speed (fp16) compared to running in full precision.

To run the server, run the following:

```
docker compose up -d
```

Download compatible stable diffusion models (*.safetensors) to the `models/Stable-diffusion` directory.
