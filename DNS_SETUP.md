# DNS Seeder Setup for Juno

## Overview

The DNS seeder has been configured to use the Juno domains for network bootstrapping. The Docker Compose setup includes Unbound DNS server to handle both mainnet and testnet queries on a single server.

## Quick Start (Docker - Recommended)

The easiest deployment method uses Docker Compose with Unbound DNS:

```bash
cp docker-compose.yml-orig docker-compose.yml
# Edit hostnames and configuration
docker-compose up -d
```

**What gets deployed:**
- Unbound DNS server (port 53) - Routes queries to appropriate seeder
- Mainnet seeder - Crawls mainnet nodes (dnsseed.junomoneta.io)
- Testnet seeder - Crawls testnet nodes (dnsseed.testnet.junomoneta.io)
- Tor proxy - Enables onion node discovery

See QUICKSTART.md for detailed instructions.

## Seed Domains

The seeder uses seed domains to bootstrap the crawling process by finding initial peers.

### Default Seeds

#### Mainnet
- **Domain**: `dnsseed.junomoneta.io`
- **Purpose**: Bootstrap mainnet nodes
- **Network**: Mainnet (magic: `0xb50c0702`, port: `8234`)

#### Testnet
- **Domain**: `dnsseed.testnet.junomoneta.io`
- **Purpose**: Bootstrap testnet nodes
- **Network**: Testnet (magic: `0xa723e16c`, port: `18234`)

### Customizing Seed Domains

You can override the default seed domains using:

**Command-line:**
```bash
./dnsseed -h seed.example.com -n ns.example.com -s seed1.example.com,seed2.example.com
./dnsseed -h seed.example.com -n ns.example.com -u testseed1.example.com --testnet
```

**Docker environment variables:**
```yaml
environment:
  - MAINNET_SEEDS=seed1.example.com,seed2.example.com,seed3.example.com
  - TESTNET_SEEDS=testseed1.example.com,testseed2.example.com
```

### Bootstrapping Onion Nodes

For Tor onion nodes, you can directly specify `.onion` addresses to bootstrap discovery:

**Command-line:**
```bash
./dnsseed -h seed.example.com -n ns.example.com \
  -o 127.0.0.1:9050 \
  -r abc123def456.onion:8234,xyz789uvw012.onion:8234
```

**Docker environment variables:**
```yaml
environment:
  - TOR_PROXY=tor:9050
  - MAINNET_ONION_SEEDS=abc123def456.onion:8234,xyz789uvw012.onion:8234
  - TESTNET_ONION_SEEDS=test123abc456.onion:18234
```

The seeder will:
1. Connect to these onion addresses immediately on startup
2. Request peer lists, which may include more onion addresses
3. Continue discovering onion nodes through peer exchange
4. Serve discovered onion addresses via DNS TXT records

## How It Works

### With Docker Compose (Unbound + Seeders)

```
Internet Client
     ↓
Port 53 → Unbound DNS
     ↓
     ├─→ dnsseed.junomoneta.io query → Mainnet Seeder Container
     └─→ dnsseed.testnet.junomoneta.io query → Testnet Seeder Container
```

1. **Query Routing**: Unbound receives DNS queries on port 53
2. **Zone Forwarding**: Based on hostname, forwards to the correct seeder
3. **Node Discovery**: Each seeder crawls its network and maintains a database
4. **Response**: Seeders return IP addresses of healthy nodes

### Traditional Flow (Manual Setup)

1. **Bootstrap Phase**: When the seeder starts, it queries the seed domains to find initial peers
2. **Crawling Phase**: The seeder connects to discovered peers and asks for more peer addresses
3. **DNS Service**: The seeder responds to DNS queries with IP addresses of healthy nodes
4. **Continuous Operation**: The seeder continuously monitors node health and updates its database

## DNS Records Required

In your DNS provider (Cloudflare, Route53, etc.), configure NS records:

### For Docker Setup (Both Networks on One Server)

```
dnsseed.junomoneta.io.         IN  NS  ns.yourserver.com.
dnsseed.testnet.junomoneta.io. IN  NS  ns.yourserver.com.
ns.yourserver.com.             IN  A   <your-server-ip>
```

Both domains point to the same server. Unbound handles routing internally.

### Bootstrap Seeds (A Records)

For the seeders to find initial peers, add A records:

```
seeds.junomoneta.io.           IN  A   <node-ip-1>
seeds.junomoneta.io.           IN  A   <node-ip-2>
seeds.testnet.junomoneta.io.   IN  A   <testnet-node-ip>
```

The seeders will query these domains and connect to the returned IPs.

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

If needed, you can manually add initial nodes by editing the code in `main.cpp` around line 503:

```cpp
extern "C" void* ThreadSeeder(void*) {
  // Add manual nodes here (before the loop)
  db.Add(CService("1.2.3.4", 8234), true);  // Mainnet node

  do {
    // Existing code...
```

Then rebuild: `make`

Note: Using the `-s` or `-u` command-line options (or Docker environment variables) is
preferred over hardcoding IPs, as it provides more flexibility without requiring rebuilds.
