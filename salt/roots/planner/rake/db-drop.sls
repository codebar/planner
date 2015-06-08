# NOT part of the automated execution. Execute manually with
# `sudo salt-call state.sls planner.rake.db-drop` on the guest machine

db-drop:
  cmd.run:
    - user: vagrant
    - cwd: /vagrant
    - name: bundle exec rake db:drop
    - require:
      - pkg: postgresql
      - cmd: bundle-install
  grains.absent:
    - names:
      - planner-db-created
      - planner-db-migrated
      - planner-db-test-prepared
      - planner-db-seeded
    - require:
      - cmd: db-drop

include:
  - postgresql
  - planner.bundle-install
