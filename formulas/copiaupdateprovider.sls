/home/smeup/bin/update-provider:
  file.managed:
    - order: 1
    - source: salt://scripts/update-provider
    - makedirs: True
    - user: smeup
    - group: smeup
    - file_mode: keep
    - mode: 755
