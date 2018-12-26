all: build/index.html build/web.html build/favicon.ico

build:
	mkdir -p $@

build/index.html: build
	head -1 ../sub.sh > $@
	cat index.html | awk '{ print "# " $$0 }' >> $@
	tail -n+2 ../sub.sh >> $@

build/web.html: build
	cp web.html $@

build/favicon.ico: build
	cp favicon.ico $@
