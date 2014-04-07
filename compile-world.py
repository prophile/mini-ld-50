import yaml
import json
import sys

with open('world.yaml') as f:
    content = yaml.load(f)

with open('world.js', 'w') as f:
    f.write('window.Level = ')
    json.dump(content, f)
    f.write(';')

