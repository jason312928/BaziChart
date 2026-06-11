.PHONY: build test app run clean

build:
	swift build -c release

test:
	./script/test.sh

app:
	./script/build_and_run.sh build

run:
	./script/build_and_run.sh

clean:
	swift package clean
	rm -rf dist
