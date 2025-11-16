#!/bin/bash
set -ex

# Default values for environment variables if not set
export SEED_HOSTNAME=${SEED_HOSTNAME}
export NODE_HOSTNAME=${NODE_HOSTNAME}
export EMAIL=${EMAIL}
export THREADS=${THREADS}
export ADDRESS=${ADDRESS:-"0.0.0.0"}
export PORT=${PORT:-"53"}
export NETWORK=${NETWORK:-"mainnet"}  # Default to "mainnet" unless otherwise set
export TOR_PROXY=${TOR_PROXY}  # Optional Tor SOCKS5 proxy (e.g., "127.0.0.1:9050" or "tor:9050")
export MAINNET_SEEDS=${MAINNET_SEEDS}  # Comma-separated list of mainnet seed hostnames
export TESTNET_SEEDS=${TESTNET_SEEDS}  # Comma-separated list of testnet seed hostnames
export MAINNET_ONION_SEEDS=${MAINNET_ONION_SEEDS}  # Comma-separated list of mainnet onion addresses (addr.onion:port)
export TESTNET_ONION_SEEDS=${TESTNET_ONION_SEEDS}  # Comma-separated list of testnet onion addresses (addr.onion:port)
export MAINNET_TXT_SEEDS=${MAINNET_TXT_SEEDS}      # Comma-separated list of mainnet domains to query for TXT records
export TESTNET_TXT_SEEDS=${TESTNET_TXT_SEEDS}      # Comma-separated list of testnet domains to query for TXT records

# Extra arguments for testnet
extra_args=""
if [[ "$NETWORK" == "testnet" ]]; then
  export extra_args="--testnet"
fi

# Add Tor proxy argument if set
if [[ -n "$TOR_PROXY" ]]; then
  export extra_args="$extra_args -o $TOR_PROXY"
fi

# Add mainnet seeds if set
if [[ -n "$MAINNET_SEEDS" ]]; then
  export extra_args="$extra_args -s \"$MAINNET_SEEDS\""
fi

# Add testnet seeds if set
if [[ -n "$TESTNET_SEEDS" ]]; then
  export extra_args="$extra_args -u \"$TESTNET_SEEDS\""
fi

# Add mainnet onion seeds if set
if [[ -n "$MAINNET_ONION_SEEDS" ]]; then
  export extra_args="$extra_args -r \"$MAINNET_ONION_SEEDS\""
fi

# Add testnet onion seeds if set
if [[ -n "$TESTNET_ONION_SEEDS" ]]; then
  export extra_args="$extra_args -y \"$TESTNET_ONION_SEEDS\""
fi

# Add mainnet TXT seed domains if set
if [[ -n "$MAINNET_TXT_SEEDS" ]]; then
  export extra_args="$extra_args -x \"$MAINNET_TXT_SEEDS\""
fi

# Add testnet TXT seed domains if set
if [[ -n "$TESTNET_TXT_SEEDS" ]]; then
  export extra_args="$extra_args -z \"$TESTNET_TXT_SEEDS\""
fi

# If the first argument starts with a hyphen (-), consider it an argument for the dnsseed binary
if [[ "${1:0:1}" == "-" ]]; then
  exec /usr/local/bin/dnsseed "$@"
fi

# Run the dnsseed binary with default arguments and extra_args, or run another command if provided
if [ "$1" == "/usr/local/bin/dnsseed" ]; then
  eval exec /usr/local/bin/dnsseed -h "$SEED_HOSTNAME" \
    -n "$NODE_HOSTNAME" \
    -a "$ADDRESS" \
    -p "$PORT" \
    -m "$EMAIL" \
    -t "$THREADS" $extra_args
else
  # If another command is passed, run that instead
  exec "$@"
fi
