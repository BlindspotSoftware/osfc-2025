# OSFC 2025 Demo

This repository showcases how to hook remote development boards into FirmwareCI for automated firmware testing. We've set up two ODROID boards with full test suites that run boot tests, hardware checks, and performance validation. Both boards are not part of the FirmwareCI network but establish a connection to the server via our own VPN network. We harness [Headscale](https://headscale.net/stable/) for a scalable VPN solution.

**Learn More**: [FirmwareCI Platform](https://firmware-ci.com) | [Documentation](https://docs.firmware-ci.com)

## What's Here

FirmwareCI handles CI/CD for firmware on servers and embedded systems. Instead of manually flashing and testing firmware on physical hardware, you can run automated tests on several remote boards over the network. This repository serves as the Infrastructure-as-Configuration store. All the necessary configurations can be found inside the `.firmwareci` directory. Both boards are connected to a Raspberry Pi running [dutagent](https://github.com/BlindspotSoftware/dutctl), which takes care of power-cycling, flashing, and serial output of the device. Each device is also connected to a PiKVM so one can hook up a variety of OS images. Both of these can be easily orchestrated inside tests using FirmwareCI.

### ODROID Board 1

- **Network Address**: `odroid.local`
- **Control Host**: `heracles.demo.vpn.firmware-ci.com`
- **PiKVM**: `freya.demo.vpn.firmware-ci.com`

### ODROID Board 2

- **Network Address**: `odroid-2.local`
- **Control Host**: `erebus.demo.vpn.firmware-ci.com`
- **PiKVM**: `hestia.demo.vpn.firmware-ci.com`

## Testing Capabilities

Both platforms are able to verify the same test cases independently of each other:

1. **Boot Tests**: Verify successful firmware boot via serial console and network connectivity
2. **Hardware Enumeration**: Validate ACPI tables and PCI device discovery
3. **Performance Testing**: CPU load testing
4. **System Stability**: Warm reboot testing to ensure reliable power management

> **Note:**  
> This repository provides example configurations and workflows for demonstration purposes only. For detailed guidance on setting up and customizing FirmwareCI for your own hardware platforms, refer to the [official documentation](https://docs.firmware-ci.com).

## Repository Structure

```
.firmwareci/
├── workflows/
│   └── Odroid-Board/          # ODROID-specific workflow and tests
│       ├── workflow.yaml      # Main workflow definition
│       └── tests/             # Test suite definitions
├── duts/                      # Device Under Test configurations
│   ├── odroid-h4/              # ODROID Board 1 configuration
│   └── odroid-h4-2/              # ODROID Board 2 configuration
└── storage/                   # Shared storage configurations for images or other tooling
```

## Hardware Setup

### Prerequisites

- PiKVM device ([Download PiKVM Image](https://pikvm.org/download/))
- Raspberry Pi 4 (ARM32)
- Required files: `dutagent`, `dutagent.service`, `config.yaml`
- FirmwareCI VPN authentication key

### PiKVM Setup

1. Boot PiKVM with default configuration

2. Initial configuration:

```sh
ssh root@pikvm-ip

# Set to read-write mode
su root
rw

# Set your desired hostname
hostnamectl set-hostname <your-hostname>

# Change default passwords
passwd root
kvmd-htpasswd set admin

# Add demo KVM user
kvmd-htpasswd add demo

# Update PiKVM
pikvm-update
```

3. Connect to FirmwareCI VPN using Tailscale ([Tailscale setup guide](https://docs.pikvm.org/tailscale/)):

```sh
tailscale up --login-server=https://connect.firmware-ci.com --hostname=<your-hostname>.org --authkey=<your-auth-key>
```

### DUT Agent Setup (Raspberry Pi 4)

1. Copy required files to the Raspberry Pi:
   - `dutagent` binary (ARM32)
   - `dutagent.service` systemd unit file
   - `config.yaml` configuration file

2. Install dutagent:

```sh
# Install dutagent binary to system PATH
sudo install -m 755 dutagent /usr/local/bin/

# Copy configuration file
sudo mkdir -p /etc/dutagent
sudo cp config.yaml /etc/dutagent/config.yaml

# Install systemd service
sudo cp dutagent.service /etc/systemd/system/
```

3. Enable and start the service:

```sh
sudo systemctl daemon-reload
sudo systemctl enable dutagent.service
sudo systemctl start dutagent.service
```

4. Install dependencies and configure hardware:

```sh
# Install required tools
sudo apt-get update
sudo apt-get install -y flashrom

# Verify service status
sudo systemctl status dutagent.service
```

5. Connect to FirmwareCI VPN using Tailscale:

```sh
tailscale up --login-server=https://connect.firmware-ci.com --hostname=<your-hostname>.org --authkey=<your-auth-key>
```

6. Configure firewall rules to allow dutagent traffic (default port configuration in `/etc/dutagent/config.yaml`)
