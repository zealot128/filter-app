# encoding: utf-8
#


Setting.read_yaml
load "db/seeds/#{Setting.key}.rb"
