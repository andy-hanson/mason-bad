#! /usr/bin/env python3

import json, plistlib, yaml
from os import path
from subprocess import call

dir = path.dirname(path.realpath(__file__))

tml = path.join(dir, 'Mason.tmLanguage')

content = yaml.load(open(tml + '.yaml'))
plistlib.writePlist(content, tml)


home = path.expanduser('~')
call(['cp', tml, path.join(home, '.config/sublime-text-3/Packages/User')])
