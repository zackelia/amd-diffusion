FROM rocm/dev-ubuntu-22.04:6.0.2 AS builder

ENV STABLE_DIFFUSION_RELEASE v1.7.0

RUN DEBIAN_FRONTEND=noninteractive apt-get update \
    && apt-get install -y \
    python3-venv git

# Get torch command here: https://pytorch.org/get-started/locally/
RUN python3 -m venv venv \
    && /venv/bin/python -m pip install --pre torch torchvision --index-url https://download.pytorch.org/whl/nightly/rocm6.0

RUN git clone --depth=1 --branch ${STABLE_DIFFUSION_RELEASE} https://github.com/AUTOMATIC1111/stable-diffusion-webui.git sd && \
    /venv/bin/python -m pip install -r /sd/requirements_versions.txt && \
    # For some reason `--exit` will do all the other git/pip dependencies/updates
    # Need `--skip-torch-cuda-test` because the driver devices aren't in the builder image
    /venv/bin/python /sd/launch.py --exit --skip-torch-cuda-test

# Multi-stage build shaves off ~2.5GB
FROM rocm/dev-ubuntu-22.04:6.0.2

COPY --from=builder /venv /venv
COPY --from=builder /sd /sd

RUN apt-get update && apt-get install git -y

WORKDIR /sd
EXPOSE 7860

ENTRYPOINT ["/venv/bin/python", "launch.py", "--listen", "--skip-prepare-environment"]
