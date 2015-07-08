bundle-install:
  cmd.run:
    - user: vagrant
    - cwd: /vagrant
    - name: bundle install --path vendor/bundle
    - unless: {{ salt['grains.get']('planner-bundle-installed') == true }}
    - require:
      - gem: bundler
  grains.present:
    - name: planner-bundle-installed
    - value: true
    - require:
      - cmd: bundle-install
