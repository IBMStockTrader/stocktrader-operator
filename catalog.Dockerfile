# The base image is expected to contain
# /bin/opm (with a serve subcommand) and /bin/grpc_health_probe

# FROM quay.io/operator-framework/opm:latest
# Commented out above line to hardcode an Intel (amd64) image
# I develop on an M1 Mac (arm64), but want my image to run on Kube with Intel worker nodes
FROM quay.io/operator-framework/opm:v1.26.4-amd64

# Configure the entrypoint and command
ENTRYPOINT ["/bin/opm"]
CMD ["serve", "/configs"]

# Copy declarative config root into image at /configs
ADD catalog /configs

# Set DC-specific label for the location of the DC root directory
# in the image
LABEL operators.operatorframework.io.index.configs.v1=/configs
