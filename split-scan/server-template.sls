install packages required for sane:
 pkg.installed:
  - pkgs:
    - sane-utils

enable saned.socket:
 service.enabled:
  - name: saned.socket

/etc/qubes-rpc/qubes.Scan:
 file.managed:
  - user: root
  - group: root
  - mode: 755
  - makedirs: True
  - contents: |
     #!/bin/sh
     exec socat STDIO TCP:localhost:6566

/etc/qubes-rpc/qubes.ScanData:
 file.managed:
  - user: root
  - group: root
  - mode: 755
  - makedirs: True
  - contents: |
     #!/bin/sh
     exec socat STDIO TCP:localhost:6567

/etc/sane.d/saned.conf:
 file.line:
  - mode: ensure
  - content: data_portrange = 6567 - 6567
  - after: "^# data_portrange = 10000 - 10100"
