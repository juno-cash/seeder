# DNS Seeder Setup for Juno

## Overview

The DNS seeder has been configured to use the Juno domains for network bootstrapping.

## Seed Domains

### Mainnet
- **Domain**: `dnsseed.junomoneta.io`
- **Purpose**: Bootstrap mainnet nodes
- **Network**: Mainnet (magic: `0xb50c0702`, port: `8234`)

### Testnet
- **Domain**: `dnsseed.testnet.junomoneta.io`
- **Purpose**: Bootstrap testnet nodes
- **Network**: Testnet (magic: `0xa723e16c`, port: `18234`)

## How It Works

1. **Bootstrap Phase**: When the seeder starts, it queries the seed domains to find initial peers
2. **Crawling Phase**: The seeder connects to discovered peers and asks for more peer addresses
3. **DNS Service**: The seeder responds to DNS queries with IP addresses of healthy nodes
4. **Continuous Operation**: The seeder continuously monitors node health and updates its database

## DNS Records Required

For the seeder to work as a DNS service, you need to set up:

### For Mainnet DNS Seed (e.g., `seed.junomoneta.io`)

```
seed.junomoneta.io.   IN  NS  ns1.yourserver.com.
ns1.yourserver.com.   IN  A   <your-server-ip>
```

### For Testnet DNS Seed (e.g., `dnsseed.testnet.junomoneta.io`)

```
dnsseed.testnet.junomoneta.io. IN  NS  ns1.yourserver.com.
ns1.yourserver.com.            IN  A   <your-server-ip>
```

## Running the Seeder

### Mainnet Seeder
```bash
cd ~/zcash-seeder
./dnsseed -h seed.junomoneta.io -n ns1.yourserver.com -m admin@junomoneta.io
```

### Testnet Seeder
```bash
cd ~/zcash-seeder
./dnsseed -h dnsseed.testnet.junomoneta.io -n ns1.yourserver.com -m admin@junomoneta.io --testnet
```

## Bootstrap Process

When the seeder starts:

1. It queries `dnsseed.junomoneta.io` (or `dnsseed.testnet.junomoneta.io` for testnet)
2. Resolves the domain to IP addresses
3. Connects to those nodes on the appropriate port (8234 for mainnet, 18234 for testnet)
4. Requests peer lists from those nodes
5. Builds a database of active nodes
6. Begins serving DNS queries for nodes wanting to join the network

## Initial Setup

For the first deployment, you'll need to:

1. **Set up the seed domains**: Configure `dnsseed.junomoneta.io` and `dnsseed.testnet.junomoneta.io` to point to your initial nodes
2. **Start initial nodes**: Have at least one mainnet and one testnet node running
3. **Start the seeder**: Launch the seeder so it can discover the initial nodes
4. **Configure DNS**: Set up NS records for your seed domains
5. **Add to node software**: Configure nodes to use your seed domain for peer discovery

## Network Isolation

The seeder uses the correct magic bytes for each network:
- **Mainnet**: `0xb50c0702` - Only connects to mainnet nodes
- **Testnet**: `0xa723e16c` - Only connects to testnet nodes

This ensures complete network isolation from Zcash and prevents cross-network connections.

## Monitoring

The seeder provides:
- **dnsseed.dump**: Human-readable list of all known nodes
- **dnsstats.log**: Statistics over time
- **Console output**: Real-time statistics of crawler activity and DNS requests

## Troubleshooting

If the seeder can't find initial nodes:
1. Check that `dnsseed.junomoneta.io` / `dnsseed.testnet.junomoneta.io` resolve to valid IPs
2. Verify nodes are running on the correct ports (8234/18234)
3. Check firewall rules allow connections
4. Verify the nodes are using the correct magic bytes
5. Check seeder logs for connection errors

## Manual Node Addition

If needed, you can manually add initial nodes by editing the code in `main.cpp` around line 426:

```cpp
extern "C" void* ThreadSeeder(void*) {
  // Add manual nodes here
  db.Add(CService("1.2.3.4", 8234), true);  // Mainnet node

  do {
    // Existing code...
```

Then rebuild: `make`
