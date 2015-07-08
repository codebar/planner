planner:
  file.append:
    - name: /home/vagrant/.profile
    - text:
      - cd /vagrant

include:
  - planner.bundle-install
  - planner.rake.db-create
  - planner.rake.db-migrate
  - planner.rake.db-test-prepare
  - planner.rake.db-seed
