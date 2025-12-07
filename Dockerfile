FROM debian:trixie

# Avoid interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y \
    build-essential \
    g++ \
    make \
    pkg-config \
    libssl-dev \
    libevent-dev \
    libboost-all-dev \
    libc6-dev \
    git \
    ca-certificates && \
    apt clean

WORKDIR /src

# Copy your source code into the container
COPY . .

# Build it
RUN make clean || true && make

# Install the binary
RUN install -m 755 dnsseed /usr/local/bin/dnsseed

# Make entrypoint executable
RUN chmod +x /src/entrypoint.sh

# Set working directory to /data for persistence
WORKDIR /data

# Set entrypoint
ENTRYPOINT ["/src/entrypoint.sh"]

# Default command (runs dnsseed via entrypoint)
CMD ["/usr/local/bin/dnsseed"]
