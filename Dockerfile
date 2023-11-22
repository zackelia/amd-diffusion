FROM rocm/dev-ubuntu-22.04:5.7

ENV STABLE_DIFFUSION_RELEASE v1.6.0

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y \
    python3-venv git

# Get torch command here: https://pytorch.org/get-started/locally/
# As of 11/03/23, only nightly supports ROCm 5.7
RUN python3 -m venv venv \
    && /venv/bin/python -m pip install --pre torch torchvision --index-url https://download.pytorch.org/whl/nightly/rocm5.7

RUN git clone --depth=1 --branch ${STABLE_DIFFUSION_RELEASE} https://github.com/AUTOMATIC1111/stable-diffusion-webui.git sd && \
    # https://github.com/AUTOMATIC1111/stable-diffusion-webui/pull/13839
    /venv/bin/python -m pip install "httpx<0.25" && \
    /venv/bin/python -m pip install -r /sd/requirements_versions.txt && \
    # https://github.com/AUTOMATIC1111/stable-diffusion-webui/issues/13985
    sed -i 's/from torchvision.transforms.functional_tensor import rgb_to_grayscale/from torchvision.transforms.functional import rgb_to_grayscale/' venv/lib/python3.10/site-packages/basicsr/data/degradations.py && \
    # For some reason `--exit` will do all the other git/pip dependencies/updates
    # Need `--skip-torch-cuda-test` because the driver devices aren't in the builder image
    /venv/bin/python /sd/launch.py --exit --skip-torch-cuda-test

WORKDIR /sd
EXPOSE 7860

ENTRYPOINT ["/venv/bin/python", "launch.py", "--listen", "--skip-prepare-environment"]
