db-test-prepare:
  cmd.run:
    - user: vagrant
    - cwd: /vagrant
    - name: bundle exec rake db:test:prepare
    - unless: {{ salt['grains.get']('planner-db-test-prepared') == true }}
    - require:
      - cmd: db-migrate
  grains.present:
    - name: planner-db-test-prepared
    - value: true
    - require:
      - cmd: db-test-prepare
