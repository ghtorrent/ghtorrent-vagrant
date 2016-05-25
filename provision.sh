#!/usr/bin/env bash

apt-get install --yes puppet || exit 1
puppet module install puppetlabs-mysql || exit 1
puppet module install puppetlabs-rabbitmq --ignore-dependencies || exit 1
puppet module install puppetlabs-mongodb || exit 1
