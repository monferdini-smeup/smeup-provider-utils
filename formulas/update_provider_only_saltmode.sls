update_provider:
  cmd.run:
    - name: /home/smeup/bin/update-provider > /dev/null 2>&1
    - env:
      - HOME: '/home/smeup'
    - cwd: /home/smeup
    - runas: smeup
    - stateful: True
