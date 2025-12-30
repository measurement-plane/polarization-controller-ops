#!/bin/bash

# Set environment variables
CONTAINER_NAME="polarization_controller"
IMAGE_NAME="ghcr.io/measurement-plane/polarization-controller:latest"
BROKER_URL="nats://172.17.0.1:4222"
ENDPOINT='polarization_controller'
HWP_ADDR="/dev/ttyUSB0"
QWP_ADDR="/dev/ttyUSB1"


# Stop and remove any running container with the same name
echo "Stopping and removing existing container (if any)..."
docker stop "$CONTAINER_NAME" >/dev/null 2>&1 || true
docker rm "$CONTAINER_NAME" >/dev/null 2>&1 || true

# Pull the latest pre-built image
echo "Pulling the latest image..."
if ! docker pull "$IMAGE_NAME"; then
    echo "Error: Failed to pull the image. Exiting."
    exit 1
fi

# Run the container
echo "Starting the container..."
docker run -it --name "$CONTAINER_NAME" \
    --device="$HWP_ADDR" \
    --device="$QWP_ADDR" \
    --group-add dialout \
    -e BROKER_URL="$BROKER_URL" \
    -e ENDPOINT="$ENDPOINT" \
    -e HWP_ADDR="$HWP_ADDR" \
    -e QWP_ADDR="$QWP_ADDR" \
    -e DRIVER_TYPE="$DRIVER_TYPE" \
    "$IMAGE_NAME" || {
        echo "ERROR: Failed to start container."
        exit 1
    }
