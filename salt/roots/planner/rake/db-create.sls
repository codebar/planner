db-create:
  cmd.run:
    - user: vagrant
    - cwd: /vagrant
    - name: bundle exec rake db:create
    - unless: {{ salt['grains.get']('planner-db-created') == true }}
    - require:
      - pkg: postgresql
      - cmd: bundle-install
  grains.present:
    - name: planner-db-created
    - value: true
    - require:
      - cmd: db-create

include:
  - postgresql
  - planner.bundle-install