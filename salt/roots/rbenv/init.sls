rbenv:
  rbenv.install_rbenv:
    - user: vagrant
    - require:
      - pkg: rbenv
  file.append:
    - name: /home/vagrant/.profile
    - text:
      - export PATH="$HOME/.rbenv/bin:$PATH"
      - eval "$(rbenv init -)"
    - require:
      - rbenv: rbenv
  pkg.installed:
    - names:
      - bash
      - git
      - openssl
      - libssl-dev
      - make
      - curl
      - autoconf
      - bison
      - build-essential
      - libffi-dev
      - libyaml-dev
      - libreadline6-dev
      - zlib1g-dev
      - libncurses5-dev
