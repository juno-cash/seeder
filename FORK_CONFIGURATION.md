# Zcash Seeder - Fork Configuration for Juno

This seeder has been customized for the Juno network with the following network parameters:

## Network Parameters

### Mainnet
- **Magic Bytes**: `0xb50c0702`
- **Default Port**: `8234`
- **Protocol Version**: `170140` (NU6.1)

### Testnet
- **Magic Bytes**: `0xa723e16c`
- **Default Port**: `18234`
- **Protocol Version**: `170140` (NU6.1)

### Regtest
- **Magic Bytes**: `0x811d21f6`
- **Default Port**: `18345`
- **Protocol Version**: `170140` (NU6.1)

## Changes Made

1. **protocol.cpp** (line 25)
   - Updated magic bytes to `0xb5, 0x0c, 0x07, 0x02` (mainnet for Juno)

2. **protocol.h** (line 21)
   - Updated port configuration: mainnet=8234, testnet=18234

3. **main.cpp** (lines 479-483)
   - Updated testnet magic bytes to `0xa7, 0x23, 0xe1, 0x6c`

4. **main.cpp** (lines 421-422)
   - Updated seed domains to `dnsseed.junomoneta.io` and `dnsseed.testnet.junomoneta.io`

5. **serialize.h** (line 63)
   - Updated protocol version from `170100` to `170140`

## Running the Seeder

### Mainnet
```bash
./dnsseed -h <hostname> -n <nameserver> -m <email@example.com>
```

### Testnet
```bash
./dnsseed -h <hostname> -n <nameserver> -m <email@example.com> --testnet
```

### Options
- `-h <host>`: Hostname of the DNS seed
- `-n <ns>`: Hostname of the nameserver
- `-m <mbox>`: Email address reported in SOA records
- `-t <threads>`: Number of crawlers to run in parallel (default 96)
- `-d <threads>`: Number of DNS server threads (default 4)
- `-p <port>`: UDP port to listen on (default 53)
- `--testnet`: Use testnet parameters

## Network Isolation

These parameters ensure complete isolation from the Zcash network:
- Different magic bytes prevent cross-network connections
- Different ports prevent conflicts with Zcash nodes
- Protocol version matches the Juno network's consensus rules

## Important Notes

1. The seeder will attempt to connect to nodes on the configured network
2. It maintains a database of known good nodes in `dnsseed.dat`
3. DNS queries return IP addresses of healthy nodes
4. The seeder requires a working DNS setup with proper NS records

## Seed Nodes

The seeder is configured to bootstrap from these seed nodes (defined in main.cpp:421-422):
- Mainnet: `dnsseed.junomoneta.io`
- Testnet: `dnsseed.testnet.junomoneta.io`

These domains should point to your DNS seed servers that will provide IP addresses of active nodes on the Juno network.

## Testing

To test the seeder without DNS server functionality:
```bash
./dnsseed -n dummy
```

This will crawl the network but not start the DNS server.

## Files

- `dnsseed.dat` - Database of known nodes (auto-created)
- `dnsseed.dump` - Human-readable dump of node database
- `dnsstats.log` - Statistics log

## Build

The seeder has been built with the customized parameters. To rebuild:
```bash
rm -f *.o dnsseed
make
```
