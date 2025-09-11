# OSFC 2025 Demo

This repository shows how to hook remote development boards into FirmwareCI for automated firmware testing. We've set up two different boards - an ARM-based ODROID and an x86 UP² board - with full test suites that run boot tests, hardware checks, and performance validation.

**Learn More**: [FirmwareCI Platform](https://firmware-ci.com) | [Documentation](https://docs.firmware-ci.com)

## What's Here

FirmwareCI handles CI/CD for firmware on servers and embedded systems. Instead of manually flashing and testing firmware on physical hardware, you can run automated tests on remote boards over the network. This setup shows exactly how to configure two different architectures with the same test workflows.

## Included Hardware Platforms

### ODROID Board

- **Device Label**: `odroid`
- **Network Address**: `odroid.lan`
- **Control Host**: `heracles.demo.vpn.firmware-ci.com`
- **Architecture**: ARM-based single-board computer

### UP² Board

The UP² (UP Squared) is an x86-based single-board computer designed for IoT and embedded applications:

- **Device Label**: `up2` 
- **Network Address**: `up2.lan`
- **Control Host**: `demeter.demo.vpn.firmware-ci.com`
- **Architecture**: Intel x86_64 Apollo Lake platform

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
│   │   ├── workflow.yaml      # Main workflow definition
│   │   └── tests/             # Test suite definitions
│   └── Up2-Board/             # UP² board-specific workflow and tests
│       ├── workflow.yaml      # Main workflow definition  
│       └── tests/             # Test suite definitions
├── duts/                      # Device Under Test configurations
│   ├── odroid/                # ODROID device configuration
│   └── up2/                   # UP² device configuration
└── storage/                   # Shared storage configurations
```
