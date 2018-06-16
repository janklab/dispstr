VERSION=$(shell cat VERSION)

FILES=LICENSE Mcode Mcode-examples README.md doc

.PHONY: dist
dist:
	mkdir -p dist/dispstr-$(VERSION)
	cp -r $(FILES) dist/dispstr-$(VERSION)
	rm -f dist/dispstr-$(VERSION)/*.DS_Store
	cd dist && tar czf dispstr-$(VERSION).tgz dispstr-$(VERSION)
	cd dist && zip -r -q dispstr-$(VERSION).zip dispstr-$(VERSION)

.PHONY: clean
clean:
	rm -rf dist/*
