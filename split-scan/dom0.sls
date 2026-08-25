create scan server template:
 qvm.clone:
  - name: debian-13-scan-server
  - source: debian-13-minimal

create scan server VM:
 qvm.vm:
  - name: sys-scan-server
  - present:
    - template: debian-13-scan-server
    - class: AppVM
    - label: red
    - mem: 200
    - maxmem: 1000
    - vcpus: 1
  - prefs:
    - netvm: sys-firewall
    - autostart: True
  - features:
    - set:
      - menu-items: xfce4-terminal.desktop

enable services in template:
 qvm.features:
  - name: debian-13-scan-server
  - enable:
    - service.saned
    - service.avahi-daemon
    - service.ahavi

enable services in server vm:
 qvm.features:
  - name: sys-scan-server
  - enable:
    - service.saned
    - service.avahi-daemon
    - service.ahavi

tag scan test vm:
 qvm.tags:
  - name: scan-test
  - add:
    - scan-client

/etc/qubes/policy.d/31-scan.policy:
 file.managed:
  - user: root
  - group: root
  - mode: 755
  - makedirs: True
  - contents: |
     qubes.Scan * @tag:scan-client sys-scan-server ask target=sys-scan-server
     qubes.ScanData * @tag:scan-client sys-scan-server allow target=sys-scan-server
