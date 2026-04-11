#!/usr/bin/env puma

environment 'production'
rackup File.expand_path('../config.ru', __dir__)
