postgresql:
  pkg.installed:
    - names:
      - postgresql-9.3
      - postgresql-server-dev-9.3

  postgres_user.present:
    - name: vagrant
    - createdb: true
    - user: postgres
    - require:
      - pkg: postgresql

  service.running:
    - name: postgresql
    - user: postgres
    - watch:
      - file: /etc/postgresql/9.3/main/pg_hba.conf
    - require:
      - pkg: postgresql

  file.managed:
    - name: /etc/postgresql/9.3/main/pg_hba.conf
    - source: salt://postgresql/files/pg_hba.conf
    - user: postgres
    - group: postgres
    - mode: 644
    - require:
      - pkg: postgresql
