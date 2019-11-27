# f2format

[![PyPI - Downloads](https://pepy.tech/badge/f2format)](https://pepy.tech/count/f2format)
[![PyPI - Version](https://img.shields.io/pypi/v/f2format.svg)](https://pypi.org/project/f2format)
[![PyPI - Format](https://img.shields.io/pypi/format/f2format.svg)](https://pypi.org/project/f2format)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/f2format.svg)](https://pypi.org/project/f2format)

[![Travis CI - Status](https://travis-ci.com/JarryShaw/f2format.svg)](https://travis-ci.org/JarryShaw/f2format)
[![Codecov - Coverage](https://codecov.io/gh/JarryShaw/f2format/branch/master/graph/badge.svg)](https://codecov.io/gh/JarryShaw/f2format)
[![License](https://img.shields.io/github/license/jarryshaw/f2format.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![LICENSE](https://img.shields.io/badge/license-Anti%20996-blue.svg)](https://github.com/996icu/996.ICU/blob/master/LICENSE)

> Write *f-string* in Python 3.6 flavour, and let `f2format` worry about back-port issues :beer:

&emsp; Since [PEP 498](https://www.python.org/dev/peps/pep-0498/), Python introduced
*[f-string](https://docs.python.org/3/reference/lexical_analysis.html#formatted-string-literals)*
literals in version __3.6__. Though released ever since
[December 23, 2016](https://docs.python.org/3.6/whatsnew/changelog.html#python-3-6-0-final), Python
3.6 is still not widely used as expected. For those who are now used to *f-string*s, `f2format`
provides an intelligent, yet imperfect, solution of a **backport compiler** by converting
*f-string*s to `str.format` expressions, which guarantees you to always write *f-string*s in Python
3.6 flavour then compile for compatibility later.

&emsp; `f2format` is inspired and assisted by my good mate [@gousaiyang](https://github.com/gousaiyang).
It functions by tokenising and parsing Python code into multiple abstract syntax trees (AST),
through which it shall synthesise and extract expressions from *f-string* literals, and then
reassemble the original string using `str.format` method. Besides
**[conversion](https://docs.python.org/3/library/string.html#format-string-syntax)** and
**[format specification](https://docs.python.org/3/library/string.html#formatspec)**, `f2format`
also considered and resolved
**[string concatenation](https://docs.python.org/3/reference/lexical_analysis.html#string-literal-concatenation)**.
Also, it always tries to maintain the original layout of source code, and accuracy of syntax.

## Installation

> Note that `f2format` only supports Python versions __since 3.3__ 🐍

&emsp; For macOS users, `f2format` is now available through [Homebrew](https://brew.sh):

```sh
brew tap jarryshaw/tap
brew install f2format
# or simply, a one-liner
brew install jarryshaw/tap/f2format
```

&emsp; Simply run the following to install the current version from PyPI:

```sh
pip install f2format
```

&emsp; Or install the latest version from the git repository:

```sh
git clone https://github.com/JarryShaw/f2format.git
cd f2format
pip install -e .
# and to update at any time
git pull
```

## Basic Usage

### CLI

&emsp; It is fairly straightforward to use `f2format`:

> context in `${...}` changes dynamically according to runtime environment

```man
usage: f2format [options] <python source files and folders...>

Convert f-string to str.format for Python 3 compatibility.

positional arguments:
  SOURCE                python source files and folders to be converted (${CWD})

optional arguments:
  -h, --help            show this help message and exit
  -V, --version         show program's version number and exit
  -q, --quiet           run in quiet mode

archive options:
  duplicate original files in case there's any issue

  -na, --no-archive     do not archive original files
  -p PATH, --archive-path PATH
                        path to archive original files (${CWD}/archive)

convert options:
  compatibility configuration for none-unicode files

  -c CODING, --encoding CODING
                        encoding to open source files (${LOCALE_ENCODING})
  -v VERSION, --python VERSION
                        convert against Python version (${LATEST_VERSION})
```

&emsp; `f2format` will read then convert all *f-string* literals in every Python file under this
path. In case there might be some problems with the conversion, `f2format` will duplicate all
original files it is to modify into `archive` directory ahead of the process, if `-n` not set.

&emsp; For instance, the code will be converted as follows.

```python
# the original code
var = f'foo{(1+2)*3:>5}bar{"a", "b"!r}boo'
# after `f2format`
var = 'foo{:>5}bar{!r}boo'.format((1+2)*3, ("a", "b"))
```

### Docker

> Well... it's not published to the Docker Hub yet ;)

&emsp; Considering `f2format` may be used in scenarios where Python is not reachable.
We provide also a Docker image for those poor little guys.

&emsp; See
[`Dockerfile`](https://github.com/JarryShaw/f2format/blob/master/docker/Dockerfile) for more
information.

### Bundled Executable

> Coming soooooooooooon...

&emsp; For the worst case, we also provide bundled executables of `f2format`. In such case,
you may simply download it then, voilà, it's ready for you.

&emsp; Special thanks to [PyInstaller](https://www.pyinstaller.org) ❤️

## Developer Reference

### Automator

&emsp; [`make-demo.sh`](https://github.com/JarryShaw/f2format/blob/master/script/make-demo.sh) provides a
demo script, which may help integrate `f2format` in your development and distribution circle.

> __NB__: `make-demo.sh` is not an integrated automation script. It should be revised by design.

&emsp; It assumes

- all source files in `/src` directory
- using GitHub for repository management
- having **release** branch under `/release` directory
- already installed `f2format` and [`twine`](https://github.com/pypa/twine#twine)
- permission to these files and folders granted

&emsp; And it will

- copy `setup.py` and `src` to `release` directory
- run `f2format` for Python files under `release`
- distribute to [PyPI](https://pypi.org) and [TestPyPI](https://test.pypi.org) using `twine`
- upload to release branch on GitHub
- upload original files to GitHub

### Environments

`f2format` currently supports three environment arguments:

- `F2FORMAT_QUIET` -- run in quiet mode (same as `--quiet` option in CLI)
- `F2FORMAT_VERSION` -- convert against Python version (same as `--python` option in CLI)
- `F2FORMAT_ENCODING` -- encoding to open source files (same as `--encoding` option in CLI)

### APIs

#### `f2format` -- wrapper works for conversion

```python
f2format(filename)
```

Args:

- `filename` -- `str`, file to be converted

Envs:

- `F2FORMAT_QUIET` -- run in quiet mode (same as `--quiet` option in CLI)
- `F2FORMAT_ENCODING` -- encoding to open source files (same as `--encoding` option in CLI)
- `F2FORMAT_VERSION` -- convert against Python version (same as `--python` option in CLI)

Raises:

- `ConvertError` -- when `parso.ParserSyntaxError` raised

#### `convert` -- the main conversion process

```python
convert(string, source='<unknown>')
```

Args:

- `string` -- `str`, context to be converted
- `source` -- `str`, source of the context

Envs:

- `F2FORMAT_VERSION` -- convert against Python version (same as `--python` option in CLI)

Returns:

- `str` -- converted string

Raises:

- `ConvertError` -- when `parso.ParserSyntaxError` raised

#### Internal exceptions

```python
class ConvertError(SyntaxError):
    """Parso syntax error."""
```

### Codec

> NB: this project is now stalled, because I just cannot figure out how to play w/ codecs :)

&emsp; [`f2format-codec`](https://github.com/JarryShaw/f2format-codec) registers a codec in Python
interpreter, which grants you the compatibility to write directly in Python 3.6 *f-string* syntax
even through running with a previous version of Python.

## Test

&emsp; The current test samples are under [`/test`](https://github.com/JarryShaw/f2format/blob/master/test)
folder. `test_driver.py` is the main entry point for tests.

&emsp; For unittests, see [`test.py`](https://github.com/JarryShaw/f2format/blob/master/share/test.py).

## Known bugs

&emsp; Since `f2format` is currently based on [`parso`](https://github.com/davidhalter/parso) project,
it had encountered several compatibility and parsing issues.

* ~~Parsing f-strings with nested format specifiers produces incorrect SyntaxError ([#74](https://github.com/davidhalter/parso/issues/74))~~
  This issue has been resolved since `parso` version __0.5.0__.

* Parsing f-strings with invalid quotes in expression part does not raise SyntaxError ([#86](https://github.com/davidhalter/parso/issues/86))

* Parsing f-strings with seeming assignment expressions produces incorrect SyntaxError ([#87](https://github.com/davidhalter/parso/issues/87))

## Contribution

&emsp; Contributions are very welcome, especially fixing bugs and providing test cases, which
[@gousaiyang](https://github.com/gousaiyang) is to help with, so to speak. Note that code must
remain valid and reasonable.

## See Also

- [`babel`](https://github.com/jarryshaw/babel)
- [`poseur`](https://github.com/jarryshaw/poseur)
- [`walrus`](https://github.com/jarryshaw/walrus)
- [`vermin`](https://github.com/netromdk/vermin)
