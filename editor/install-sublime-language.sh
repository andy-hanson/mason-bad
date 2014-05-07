python3 -c """
import yaml, json, plistlib
content = yaml.load(open('Mason.tmLanguage.yaml'))
plistlib.writePlist(content, 'Mason.tmLanguage')
"""

cp Mason.tmLanguage ~/.config/sublime-text-3/Packages/User
