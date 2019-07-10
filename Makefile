.PHONY: clean docker release pipenv pypi setup dist test coverage

include .env

export PIPENV_VENV_IN_PROJECT
export CODECOV_TOKEN

SHELL := /usr/local/bin/bash
DIR   ?= .

# fetch platform spec
platform = $(shell python3 -c "import distutils.util; print(distutils.util.get_platform().replace('-', '_').replace('.', '_'))")
# get version string
version  = $(shell cat f2format.py | grep "^__version__" | sed "s/__version__ = '\(.*\)'/\1/")
# builtins.token
token    = $(shell python3 -c "print(__import__('token').__spec__.origin)")
# builtins.tokenize
tokenize = $(shell python3 -c "print(__import__('tokenize').__spec__.origin)")
# commit message
message  ?= ""
# pre-release flag
flag     = $(shell python3 -c "print(__import__('pkg_resources').parse_version('${version}').is_prerelease)")

clean: clean-pyc clean-misc clean-pypi
docker: setup-version docker-build
pipenv: update-pipenv
pypi: dist-pypi dist-upload
setup: setup-version setup-manpages
# setup: setup-version setup-stdlib setup-manpages
test: test-unittest test-interactive

test-unittest:
	pipenv run python share/test.py

test-interactive:
	pipenv run python test/test_driver.py

coverage:
	pipenv run coverage run share/test.py
	pipenv run coverage html
	open htmlcov/index.html
	read
	rm -rf htmlcov
	rm .coverage

# setup pipenv
setup-pipenv: clean-pipenv
	pipenv install --dev

# update version string
setup-version:
	[[ ${flag} -eq "False" ]] && python3 share/setup-version.py

# update Homebrew Formulae
setup-formula: pipenv
	pipenv run python3 share/setup-formula.py

# update Python stdlib files
# setup-stdlib:
# 	rm -f src/lib/token.py src/lib/tokenize.py
# 	mkdir -p src/lib
# 	cp -f $(token) $(tokenize) src/lib

# update manpages
setup-manpages:
	rm -f share/f2format.1
	pipenv run rst2man.py share/f2format.rst > share/f2format.1

# remove *.pyc
clean-pyc:
	find $(DIR) -iname __pycache__ | xargs rm -rf
	find $(DIR) -iname '*.pyc' | xargs rm -f

# remove devel files
clean-misc: clean-pyc
	find $(DIR) -iname .DS_Store | xargs rm -f

# remove pipenv
clean-pipenv:
	pipenv --rm

# prepare for PyPI distribution
.ONESHELL:
clean-pypi:
	set -ex
	cd $(DIR)
	mkdir -p dist sdist eggs wheels
	find dist -iname '*.egg' -exec mv {} eggs \;
	find dist -iname '*.whl' -exec mv {} wheels \;
	find dist -iname '*.tar.gz' -exec mv {} sdist \;
	rm -rf build dist *.egg-info

# update pipenv
update-pipenv:
	pipenv update
	pipenv install --dev
	pipenv clean

# update maintenance information
update-maintainer:
	go run github.com/gaocegege/maintainer changelog
	go run github.com/gaocegege/maintainer contributor
	go run github.com/gaocegege/maintainer contributing

docker-prep:
	rm -rf release
	mkdir -p release
	# cp -rf src release/f2format
	cp setup.py \
	   setup.cfg \
	   README.md \
	   MANIFEST.in \
	   docker/Dockerfile \
	   docker/.dockerignore \
	   f2format.py release
	DIR=release $(MAKE) clean-pyc

docker-build: docker-prep
	docker build --tag f2format:$(version) --tag f2format:latest release

# make PyPI distribution
#dist-pypi: clean-pypi dist-macos dist-linux
dist-pypi: clean-pypi dist-pypi-setup

.ONESHELL:
dist-pypi-setup:
	set -ex
	cd $(DIR)
	python3 setup.py sdist bdist_wheel

# .ONESHELL:
# dist-macos:
# 	set -ex
# 	cd $(DIR)
# 	python3.7 setup.py sdist bdist_egg bdist_wheel --plat-name="$(platform)" --python-tag='cp37'
# 	python3.6 setup.py bdist_egg bdist_wheel --plat-name="$(platform)" --python-tag='cp36'
# 	python3.5 setup.py bdist_egg bdist_wheel --plat-name="$(platform)" --python-tag='cp35'
# 	python3.4 setup.py bdist_egg bdist_wheel --plat-name="$(platform)" --python-tag='cp34'
# 	pypy3 setup.py bdist_wheel --plat-name="$(platform)" --python-tag='pp35'

# .ONESHELL:
# dist-linux:
# 	set -ex
# 	cd $(DIR)/docker
# 	sed -i "s/LABEL version.*/LABEL version $(shell date +%Y.%m.%d)/" Dockerfile
# 	docker-compose up --build

# upload PyPI distribution
.ONESHELL:
dist-upload:
	set -ex
	cd $(DIR)
	twine check dist/* || true
	twine upload dist/* -r pypi --skip-existing
	twine upload dist/* -r pypitest --skip-existing

# add tag
.ONESHELL:
git-tag:
	set -ex
	cd $(DIR)
	git tag "v$(version)"

# upload to GitHub
.ONESHELL:
git-upload:
	set -ex
	cd $(DIR)
	git pull
	git add .
	if [[ -z "$(message)" ]] ; then \
	    git commit -a -S ; \
	else \
	    git commit -a -S -m "$(message)" ; \
	fi
	git push

# update submodules
git-submodule:
	(cd vendor/cpython && git pull)
	(cd vendor/parso && git pull)
	(cd vendor/pypy && hg pull && hg update)
	(cd vendor/typed_ast && git pull)

# upload after distro
git-aftermath: git-submodule
	git pull
	git add .
	git commit -a -S -m "Regular update after distribution"
	git push

# file new release
release:
	go run github.com/aktau/github-release release \
	    --user JarryShaw \
	    --repo f2format \
	    --tag "v$(version)" \
	    --name "f2format v$(version)" \
	    --description "$(message)"

# run distribution process
dist: test-unittest
	$(MAKE) message="$(message)" \
	    setup clean pypi \
	    git-upload release setup-formula
	$(MAKE) message="f2format: $(version)" DIR=Tap \
	    git-upload
	$(MAKE) update-maintainer git-aftermath
