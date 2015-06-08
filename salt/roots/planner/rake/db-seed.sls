db-seed:
  cmd.run:
    - user: vagrant
    - cwd: /vagrant
    - name: bundle exec rake db:seed
    - unless: {{ salt['grains.get']('planner-db-seeded') == true }}
    - require:
      - cmd: db-migrate
      - cmd: db-test-prepare
  grains.present:
    - name: planner-db-seeded
    - value: true
    - require:
      - cmd: db-seed
