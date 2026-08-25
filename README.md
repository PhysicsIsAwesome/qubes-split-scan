# qubes-split-scan
Split-scan setup for Qubes OS via Salt

Split-scan setup for Qubes OS, similar to [other split setups](https://forum.qubes-os.org/t/split-everything-collection-of-how-to-guides-for-split-configurations/11480). You can apply it via Salt. If you are not familiar with Salt, it should be relatively easy to understand what they do, so you can apply it manually.

It creates a template `debian-13-scan-server`, a server VM `sys-scan-server`. It also configures `scan-test` as a client VM, adjust this to your own scan client VM's name. The client VM is expected to already exist.

## dom0 configuration
Apply `dom0.sls` to do the following:
1. clone debian minimal template to create a specific scan server template
2. create a scan server appvm `sys-scan-server`
3. enable the necessary services for server template and appvm
4. tag a scan client appvm as an example. Adjust the appvm's name to your setup

## Server template
Apply `server-template.sls` to install necessary packages, configure and enable `saned` and set up qubes-rpc. Add all the additional packages specifically needed for your scanner to work.

## Server VM
You need to setup the scanner in the server VM `sys-scan-server`. Install packages and plugins necessary for your scanner to work (e.g. `hplip` and `hp-plugin` for HP devices). Setup and test the scanner. Once it works, use `scanimage -L` to look up the backend and device. This might be necessary because sometimes auto-discovery from within the client VMs is broken, so you need to manually specify the device in the client VM's scan software.

## Client VM
Apply `client-vm.sls` to set up the necessary socat listeners, which forward ports 6566 (sane control) and 6567 (sane data) to `sys-scan-server` via `qrexec-client-vm` calls.

For the appvms to be able to use the scanner as clients of the scan server, simply install a scan application (e.g. skanpage) and its dependencies, apply `client-vm.sls` and tag the appvm with `scan-client`. No need to install anything else. Make sure `saned` is not active on the client vm, so that it does not interfere with the above mentioned ports.

## Caveats
### Auto-discovery
Auto-discovery might not work from within the client VM. If this happens, discover devices via `scanimage -L` from within the server VM, note down the `backend:device` string and use it when starting your scan application in the scan client VM. For example with a HP scanner with `hpaio` backend, it looks something like `hpaio:/net/HP_LaserJet_111_colorMFP_M111m?ip=192.168.1.100`. Start your scan application accordingly, e.g. `skanpage -d hpaio:/net/HP_LaserJet_111_colorMFP_M111m?ip=192.168.1.100`
### Data port policy
Data port needs to always be allowed in the qubes policy and does not work with `ask`, because most applications simply will hang, if the data port is not directly available.

## Security considerations
### Untrusted clients
`saned` is not designed to safely handle untrusted clients, so your client VMs should be somewhat trusted.
### Data port abuse
Since the data port policy always needs to be set to allow for clients to work, but the control port is set to ask, it is unclear to me whether the data port could be maliciously abused, even at times where access to the control port is not being granted.
### split-scan vs directly connecting to a scanner
I am neither into `saned` security nor scanner security in general, so I can't tell which setup is more secure. split-scan seems to be the most Qubes-like way of doing it, so I will stick with that.

## Contributions
**If you have any remarks regarding the security implications or improvements of this setup, please open an issue/discussion.**
