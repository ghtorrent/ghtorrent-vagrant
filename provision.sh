#!/usr/bin/env bash

apt-get install --yes puppet || exit 1
puppet module install --version=3.6.2 --ignore-dependencies puppetlabs-mysql || exit 1
puppet module install puppetlabs-rabbitmq --ignore-dependencies || exit 1
puppet module install puppetlabs-mongodb || exit 1
