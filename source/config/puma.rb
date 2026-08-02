#!/usr/bin/env puma

environment 'production'
rackup "#{__dir__}/config.ru"
