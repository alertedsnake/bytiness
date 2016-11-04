.PHONY: all
APPNAME = bytiness
TAG_PREFIX = ${APPNAME}/v

# variables
GOPATH := $(CURDIR)/_vendor
TARGET := $(CURDIR)/bin/${APPNAME}
DEPENDENCIES := $(shell go list -f '{{ join .Imports "\n" }}')

# VERSIONING: Z.Y.x[[-rc][+COMMIT_COUNT.COMMMIT]
GIT_DESCRIBE := $(shell git describe --match '${TAG_PREFIX}*' --tags --always --abbrev=0 --exact-match 2>/dev/null || \
	echo "${TAG_PREFIX}`git describe --match '${TAG_PREFIX}*' --tags --always --abbrev=7`")
GIT_TAG    := $(shell echo ${GIT_DESCRIBE} | sed 's;^${TAG_PREFIX};;')
GIT_REVS   := $(shell git rev-list ${GIT_DESCRIBE}..HEAD --count 2>/dev/null || echo 0)
GIT_COMMIT := $(shell git rev-parse --short HEAD)
VERSION    := $(shell echo "${GIT_TAG}+${GIT_REVS}.git-${GIT_COMMIT}" | sed -e 's|\+0\..*$|||' -e 's|^.*/||')

export GOPATH

LDFLAGS=-ldflags "-X main.Version=${VERSION}"

all: build

echo:
	@echo GIT_DESCRIBE=${GIT_DESCRIBE}
	@echo GIT_TAG=${GIT_TAG}
	@echo GIT_REVS=${GIT_REVS}
	@echo GIT_COMMIT=${GIT_COMMIT}
	@echo VERSION=${VERSION}

clean:
	@rm -rf bin build

clean-all: clean
	@rm -rf _vendor

build: install-deps
	@test -d bin || mkdir bin
	go build ${LDFLAGS} -o ${TARGET}

xcompile: install-gox install-deps
	@test -d build || mkdir build
	@cd build && \
	${GOPATH}/bin/gox ${LDFLAGS} --os="linux" -arch="amd64 arm64" .. && \
	${GOPATH}/bin/gox ${LDFLAGS} --os="darwin" -arch="amd64" ..

package: clean xcompile
	cd build && \
	for f in ${APPNAME}_*; do \
	  mv $$f $${f}.bin && mkdir $${f}-${VERSION} && \
	  mv $${f}.bin $${f}-${VERSION}/${APPNAME} && \
	  tar -czf $${f}-${VERSION}.tar.gz -C $${f}-${VERSION} . && \
	  rm -rf $${f}-${VERSION}; \
	done

install-gox:
	go get github.com/mitchellh/gox

# install dependencies by using 'go list'
install-deps:
	@echo -n "Installing dependencies"
	@for pkg in $(DEPENDENCIES) ; do \
		echo -n "." ;\
		go get $$pkg; \
	done
	@echo

