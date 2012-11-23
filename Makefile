REPORTER ?= dot

all: test build

build:
	@./node_modules/jake-tools/node_modules/.bin/coffee \
		-b -c \
		-o out/release/lib \
		./lib/event-pipe.coffee > /dev/null 2>&1
	@./node_modules/.bin/yaml2json -sp ./package.yaml > /dev/null 2>&1
	@echo "build done"

clean:
	@rm -fr out
	@rm -f package.json
	@echo "clean done"

clean1:
	@rm -fr out
	@rm -f package.json
	@echo "clean done"

test: clean _test clean1

test-cov: clean
	@./node_modules/.bin/jake

_test:
	@mkdir -p out/test
	@cp -r tests out/test/
	@cp -r lib out/test/

	@./node_modules/jake-tools/node_modules/.bin/coffee \
		-b -c \
		./out/test/lib/event-pipe.coffee > /dev/null 2>&1

	@./node_modules/jake-tools/node_modules/.bin/coffee \
		-b -c \
		./out/test/tests/test-event-pipe.coffee > /dev/null 2>&1

	@./node_modules/jake-tools/node_modules/.bin/mocha \
		--compilers coffee:coffee-script \
		--colors \
		-R tap \
		out/test/tests/test-event-pipe

.PHONY: all
