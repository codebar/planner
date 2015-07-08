db-migrate:
  cmd.run:
    - user: vagrant
    - cwd: /vagrant
    - name: bundle exec rake db:migrate
    - unless: {{ salt['grains.get']('planner-db-migrated') == true }}
    - require:
      - pkg: postgresql
      - cmd: db-create
  grains.present:
    - name: planner-db-migrated
    - value: true
    - require:
      - cmd: db-migrate
