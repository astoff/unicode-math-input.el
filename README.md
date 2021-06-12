unicode-math-input.el
=====================

[![MELPA](http://melpa.org/packages/unicode-math-input-badge.svg)](http://melpa.org/#/unicode-math-input)

This Emacs package provides two methods to insert mathematical
symbols:

- A completing-read based command, `unicode-math-input`, which reads
  the TeX name of a symbol and inserts the corresponding Unicode
  character.

- A proper input method for efficient typing.  Activate with `C-u C-\
  unicode-math RET`.  Then TeX commands (e.g., `\alpha`) are replaced
  automatically as you type with the corresponding Unicode character.

In either case, [all symbols] provided by the unicode-math LaTeX
package are available, with the same names.

The `unicode-math` input method is similar to Emacs's built-in `TeX`,
but it differs in a couple of ways.  First, it has a much larger
collection of characters, including various alphabets (Fraktur,
script, etc.) and combining accents (note you have to type, say,
`\pi\hat` to get π̂).  Second, it does not include any sequence not
starting with a backslash, so it interferes less with normal typing.

The input method is customizable; see `M-x customize-group RET
unicode-math-input RET` for details (but note that, by the nature of
input methods, any options must be set *before* loading the package).

[all symbols]: http://mirrors.ctan.org/macros/unicodetex/latex/unicode-math/unimath-symbols.pdf
