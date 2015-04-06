# Luma

**WARNING** : Still a toy, still pretty buggy and unfinished

Luma is a lisp that compiles to [Lua](http://www.lua.org) source code.
It derives inspiration from the Scheme and Clojure families, and uses a
combination of standard library and policy design to encourage a more
repl-friendly, functional style of coding.

Luma is written entirely in Lua, depends only on Lua modules except for
[LPEG](http://www.inf.puc-rio.br/~roberto/lpeg/lpeg.html), and can be used in
most places where Lua is already used.

Luma is known to work with Lua 5.1 and 5.2 as well as LuaJIT. Please
note that version specific features like for example ```setfenv()``` in 5.1 and
native integers in 5.3 do bubble up into Luma code, so it is important to keep
track of what language you target.

## TODO

* a reload-safe, require()-compatible module system
* line numbers in tracebacks
* Introspectable docstrings
* a better repl
* better macros, most likely hygienic
* more datastructures
* scheme compat mode?

## Examples

Luma syntax is roughly Schemelike, without adhering to any standard:
```scheme
;; My function foo
(define (foo a)
  (+ a 3))
(assert (= (foo 3) 6)
```

Luma has access to the full power of the Lua VM, including first class
closures, tail call elimination, and coroutines:
```scheme
(define (fib n)
  (define (loop a b n)
    (if (= n 0)
      a
      (loop b (+ a b) (- n 1)))))

(define (fib-iter)
  (define (loop a b)
    (coroutine.yield a)
    (loop b (+ a b)))
  (loop 1 1))
```

Normal Lua modules and tables behave as they do in Lua:
```scheme
(define t (table "foo" "bar" "bar" "baz"))
(assert (= t.bar (get t "bar")))
(define a (array 4 3 2 1))
(assert (= (get a 1) 4)) ; index by 1, sorry~
```

...Although Luma introduces new datatypes and functions in its standard
library, mostly built on the excellent
[luafun](http://github.com/rtsisyk/luafun):
```scheme
(define nums (map (partial + 1) (list 1 2 3 4)))
(assert (= (nth 2 nums) 3)) ; Still indexed by 1
(define scores (alist :player-1 -1 :player-2 1))
(define winning (filter (lambda (pair) (> (cdr pair) 0)) scores))
(define top-10
  (take 10 (sort scores (lambda (a b) (> (cdr a) (cdr b))))))
```

## Installing

Luma uses [Luarocks](http://luarocks.org) for dependency management and
installation.

Run
```bash
# luarocks install luma
```
or
```bash
$ luarocks make
```
to install a copy.

## Tests

Tests are written using the [Busted](http://olivinelabs.com/busted/) framework.
Get it from luarocks using:
```bash
# luarocks install busted
```
and run the tests using:
```bash
$ busted
```

## License

Copyright (c) 2015 Kyle McLamb, under the MIT License.

Permission is hereby granted, free of charge, to any person obtaining a copy of
this software and associated documentation files (the "Software"), to deal in
the Software without restriction, including without limitation the rights to
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
of the Software, and to permit persons to whom the Software is furnished to do
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
