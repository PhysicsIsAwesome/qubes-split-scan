/rw/config/rc.local.d/scan-client-socat.rc:
 file.managed:
  - user: root
  - group: root
  - mode: 744
  - makedirs: True
  - contents: |
     #!/bin/sh
     socat TCP4-LISTEN:6566,reuseaddr,fork EXEC:"qrexec-client-vm sys-scan-server qubes.Scan" &

/rw/config/rc.local.d/scan-client-data-socat.rc:
 file.managed:
  - user: root
  - group: root
  - mode: 744
  - makedirs: True
  - contents: |
     #!/bin/sh
     socat TCP4-LISTEN:6567,reuseaddr,fork EXEC:"qrexec-client-vm sys-scan-server qubes.ScanData" &
