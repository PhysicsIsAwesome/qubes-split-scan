# qubes-split-scan
Split-scan setup for Qubes OS using Salt

This project provides a split-scan setup for Qubes OS, similar to the [other split setups](https://forum.qubes-os.org/t/split-everything-collection-of-how-to-guides-for-split-configurations/11480). 

Split-scan creates a client-server qube architecture for scanners.

Scanners get connected, installed and set up only in the server qube. It does not matter whether usb, network or other scanner type.

Multiple clients can then connect to this server qube via qrexec to use the scanner, even offline qubes. Since only the server qube needs direct access to the scanner, clients don’t need usb, network or other access to use the scanner and also don’t need hardware-specific software installed, like hplip.

Scanner access gets mediated by qubes policy rules, respectively looks for the tag `scan-client`, for which a rule in above repo is already implemented.

You can apply it using Salt. If you are not familiar with Salt, the files should still be relatively easy to understand, allowing you to apply the configuration manually.

This setup creates:
- server template `debian-13-scan-server`
- server VM `sys-scan-server` running the sane server
- configures `scan-test` as a client VM, adjust this to your own scan client VM name. The client VM is expected to already exist.

## dom0 configuration
Apply `dom0.sls` to do the following:
1. clone debian minimal template to create a specific scan server template
2. create a scan server appvm `sys-scan-server`
3. enable the necessary services for server template and appvm
4. tag a scan client appvm as an example. Adjust the appvm's name to your setup

## Server template
Apply `server-template.sls` to install necessary packages, configure and enable `saned` and install qubes-rpc services. You should add packages and plugins necessary for your scanner to work (e.g. `hplip` and `hp-plugin` for HP devices).

## Server VM
Set up the scanner in the server VM, `sys-scan-server`. Configure and test the scanner.
Once the scanner is working, use `scanimage -L` to identify and note down its `backend:device` string for use in the client VM.

## Client VM
Apply `client-vm.sls` to configure the necessary `socat` listeners. These listeners forward ports 6566 (SANE control) and 6567 (SANE data) to `sys-scan-server` through `qrexec-client-vm` calls.

To use the scanner from an AppVM, install a scanning application (for example, Skanpage) and its dependencies, apply `client-vm.sls`, and tag the AppVM with `scan-client`. Nothing else needs to be installed.

Make sure that `saned` is not running in the client VM, as it could interfere with the ports mentioned above.

If automatic device discovery fails, use the aforementioned `backend:device` string manually when launching scanner applications.

## Caveats
### Automatic device discovery in client VMs
Automatic device discovery may not work from within the client VM. If this happens, run `scanimage -L` in the server VM, note the `backend:device` string, and use it when launching the scanning application in the client VM. 

For example, an HP scanner using the `hpaio` backend might have a device string similar to `hpaio:/net/HP_LaserJet_111_colorMFP_M111m?ip=192.168.1.100`. Launch the scanning application with that device specified, for example: `skanpage -d hpaio:/net/HP_LaserJet_111_colorMFP_M111m?ip=192.168.1.100`
### Data port policy
The data port must always be allowed in the Qubes policy. It does not work with ask, because most scanning applications will simply hang if the data port is not immediately available.

## Security considerations
### Untrusted clients
`saned` is not designed to safely handle untrusted clients. Therefore, client VMs should be somewhat trusted.
### Data port abuse
The data port policy must always allow access for clients to work, while the control port policy can be set to ask. It is unclear whether the data port could be maliciously abused, including when access to the control port has not been granted.
### split-scan vs directly connecting clients to a scanner
I am not an expert in `saned` or scanner security, so I cannot determine for sure which setup is more secure. Split-scan seems to be the more Qubes-like way.

## Contributions
**If you have comments about the security implications of this setup or suggestions for improvements, please contact me, for example via opening an issue.**
