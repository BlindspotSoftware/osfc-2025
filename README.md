# OSFC 2025 Demo

This repository shows how to hook remote development boards into FirmwareCI for automated firmware testing. We've set up an ARM-based ODROID board - with full test suites that run boot tests, hardware checks, and performance validation.

**Learn More**: [FirmwareCI Platform](https://firmware-ci.com) | [Documentation](https://docs.firmware-ci.com)

## What's Here

FirmwareCI handles CI/CD for firmware on servers and embedded systems. Instead of manually flashing and testing firmware on physical hardware, you can run automated tests on remote boards over the network. This setup shows exactly how to configure two different architectures with the same test workflows.

### ODROID Board

- **Device Label**: `odroid`
- **Network Address**: `odroid.local`
- **Control Host**: `heracles.demo.vpn.firmware-ci.com`
- **Architecture**: ARM-based single-board computer

## Testing Capabilities

Both platforms are configured with identical test suites that validate:

1. **Boot Tests**: Verify successful firmware boot via serial console and network connectivity
2. **Hardware Enumeration**: Validate ACPI tables and PCI device discovery
3. **Performance Testing**: CPU load testing and network throughput validation using iperf3
4. **System Stability**: Warm reboot testing to ensure reliable power management
5. **Network Validation**: Comprehensive network connectivity and performance testing

> **Note:**  
> This repository provides example configurations and workflows for demonstration purposes only. For detailed guidance on setting up and customizing FirmwareCI for your own hardware platforms, refer to the [official documentation](https://docs.firmware-ci.com).

## Repository Structure

```
.firmwareci/
├── workflows/
│   ├── Odroid-Board/          # ODROID-specific workflow and tests
│       ├── workflow.yaml      # Main workflow definition  
│       └── tests/             # Test suite definitions
├── duts/                      # Device Under Test configurations
│   ├── odroid                # ODROID device configuration
└── storage/                   # Shared storage configurations
```

## Dut-agent Setup with PiKVM

### PiKVM

- Boot PiKVM with default config. ([Download PiKVM Image](https://pikvm.org/download/))

- Setup the pikvm as desired

```sh
ssh root@pikvm-ip

  # Set to read-write mode
  su root
  rw 
  
  # Set your desired hostname
  hostnamectl set-hostname XXX

  #Change default passwords
  passwd root
  kvmd-htpasswd set admin

  # Add demo KVM user
  kvmd-htpasswd add demo

  pikvm-update
```

###  Setup dutctl with Raspberry Pi 4.

- Copy `dutagent`, `dutagent.service` & `config.yaml` to dut. (arm32)
- Install `dutagent` to PATH of pikvm.
- Copy `config.yaml` to `etc/dutagent/config.yaml`.
- Modify and copy `dutagent.service` to platform at `/etc/systemd/system/.`.

```sh
  sudo systemctl daemon-reload
  sudo systemctl enable dutagent.service
  sudo systemctl start dutagent.service
```

- Install dependencies like `flashrom` and connect to hardware.

- Setup tailscale with firmwareci ([tailscale setup guide](https://docs.pikvm.org/tailscale/)).

- May need to open port for dutctl.
