# NB: f2format is currently under reconstruction. It is highly recommended to directly install from the git repo or the pre-release distributions.

---

# f2format

[![PyPI - Downloads](https://pepy.tech/badge/f2format)](https://pepy.tech/count/f2format)
[![PyPI - Version](https://img.shields.io/pypi/v/f2format.svg)](https://pypi.org/project/f2format)
[![PyPI - Format](https://img.shields.io/pypi/format/f2format.svg)](https://pypi.org/project/f2format)
[![PyPI - Python Version](https://img.shields.io/pypi/pyversions/f2format.svg)](https://pypi.org/project/f2format)

[![Travis CI - Status](https://travis-ci.com/pybpc/f2format.svg)](https://travis-ci.org/pybpc/f2format)
[![Codecov - Coverage](https://codecov.io/gh/pybpc/f2format/branch/master/graph/badge.svg)](https://codecov.io/gh/pybpc/f2format)
[![License](https://img.shields.io/github/license/pybpc/f2format.svg)](https://www.apache.org/licenses/LICENSE-2.0.html)
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

## Documentation

&emsp; See [documentation](https://bpc-f2format.readthedocs.io/en/latest/) for usage and more details.

### Codec

> NB: this project is now stalled, because I just cannot figure out how to play w/ codecs :(

&emsp; [`f2format-codec`](https://github.com/pybpc/f2format-codec) registers a codec in Python
interpreter, which grants you the compatibility to write directly in Python 3.6 *f-string* syntax
even through running with a previous version of Python.

## Contribution

&emsp; Contributions are very welcome, especially fixing bugs and providing test cases.
Note that code must remain valid and reasonable.

## See Also

- [`pybpc`](https://github.com/pybpc/bpc) (formerly known as `python-babel`)
- [`poseur`](https://github.com/pybpc/poseur)
- [`walrus`](https://github.com/pybpc/walrus)
- [`vermin`](https://github.com/netromdk/vermin)
