# Use Ubuntu as base image
FROM ubuntu:22.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive

# Install required packages
RUN apt-get update && apt-get install -y \
    git \
    cmake \
    gcc-arm-none-eabi \
    libnewlib-arm-none-eabi \
    build-essential \
    python3 \
    && rm -rf /var/lib/apt/lists/*

# Create workspace directory
WORKDIR /workspace

# Clone Pico SDK
RUN git clone https://github.com/raspberrypi/pico-sdk.git \
    && cd pico-sdk \
    && git submodule update --init

# Set Pico SDK path
ENV PICO_SDK_PATH=/workspace/pico-sdk

# Create and set build directory
WORKDIR /workspace/build

# Copy source files
COPY . .

# Build the project
RUN mkdir -p build && cd build \
    && cmake .. \
    && make -j$(nproc)

# Create output directory for artifacts
RUN mkdir -p /output \
    && cp build/keyboard.uf2 /output/

# Command to copy the built binary from container to host
CMD ["cp", "/output/keyboard.uf2", "/mounted/keyboard.uf2"]