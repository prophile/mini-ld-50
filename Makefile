all: text.js world.js

text.js: text.coffee
	coffee --compile --map $^

world.js: world.yaml
	python compile-world.py

.PHONY: all

