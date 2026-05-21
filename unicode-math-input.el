;;; unicode-math-input.el --- Insert Unicode math symbols using TeX notation -*- lexical-binding: t; -*-

;; Copyright (C) 2018, 2021 Augusto Stoffel

;; Author: Augusto Stoffel
;; URL: https://github.com/astoff/unicode-math-input.el
;; Package-Version: 0.1
;; Package-Requires: ((emacs "28.1"))

;; This file is not part of GNU Emacs.

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; For a full copy of the GNU General Public License
;; see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; This package provides two methods to insert mathematical symbols:
;;
;; - A proper input method for efficient typing.  Activate with `C-u
;;   C-\ unicode-math RET'.  Then TeX commands (e.g., `\alpha') are
;;   replaced automatically as you type with the corresponding Unicode
;;   character.
;;
;; - An interactive command, `unicode-math-input', which reads the TeX
;;   name of a symbol with completion and inserts the corresponding
;;   Unicode character.
;;
;; In either case, all symbols provided by the unicode-math LaTeX
;; package are available, with the same names.
;;
;; The `unicode-math' input method is similar to Emacs's built-in
;; `TeX', but it differs in a couple of ways.  First, it has a much
;; larger collection of characters, including various alphabets
;; (Fraktur, script, etc.) and combining accents (note you have to
;; type, say, \pi\hat to get π̂).  Second, it does not include any
;; sequence not starting with a backslash, so it interferes less with
;; normal typing.
;;
;; The input method can be customized by the variables
;; `unicode-math-input-escape', `unicode-math-input-min-prefix' and
;; `unicode-math-input-deterministic' (but they must be set before
;; loading the package).

;;; Code:

(require 'quail)

(defgroup unicode-math-input nil
  "Insert Unicode math symbols using TeX notation"
  :link '(url-link "https://github.com/astoff/unicode-math-input.el")
  :group 'convenience
  :group 'quail)

(defcustom unicode-math-input-escape "\\"
  "The triggering character for the `unicode-math' input method.
Setting this variable has no effect after `unicode-math-input' is
loaded.  Restart Emacs if needed."
  :type 'string)

(defcustom unicode-math-input-min-prefix 2
  "Replace candidates at least this long by their match in the input method.
This should be a positive number, or nil to disable prefix
matching.

Setting this variable has no effect after `unicode-math-input' is
loaded.  Restart Emacs if needed."
  :type 'integer)

(defcustom unicode-math-input-deterministic nil
  "When nil, allows selecting candidate translations with numeric keys.
This sets the DETERMINISTIC option of the Quail input method.
See `quail-define-package' for more details.

Setting this variable has no effect after `unicode-math-input' is
loaded.  Restart Emacs if needed."
  :type 'boolean)

(defcustom unicode-math-input-annotation
  #(" %c" 1 3 (face font-lock-keyword-face))
  "Annotation displayed in the `unicode-math-input' query.
This is passed to `format' with the relevant character as an
additional argument."
  :type 'string)

(defcustom unicode-math-input-extra-symbols nil
  "Alist of user-defined symbols for `unicode-math-input'.
Entries should be of the form (NAME . CHARACTER).

You must set this variable before loading `unicode-math-input'
for it to affect the input method."
  :type '(alist :key-type string :value-type: character))

(defvar unicode-math-input-symbols
  (with-temp-buffer
    (insert-file-contents
     (expand-file-name "symbols.eld" (file-name-directory
                                      (or (macroexp-file-name)
                                          default-directory))))
    (read (current-buffer)))
  "Alist of Unicode math symbols.")

(quail-define-package
 "unicode-math" "UTF-8" "Ω" t
 "Input math symbols in TeX notation.

\\alpha ~> α, \\sum ~> ∑, \\pi\\hat ~> π̂, etc.

Use the `unicode-math-input' command to display a complete list
of symbols."
 nil nil unicode-math-input-deterministic)

(dolist (i (number-sequence 0 9))
  (quail-defrule (format "%s^%c" unicode-math-input-escape (+ ?0 i))
                 (pcase i (1 ?¹) (2 ?²) (3 ?³) (_ (+ ?⁰ i))))
  (quail-defrule (format "%s_%c" unicode-math-input-escape (+ ?0 i))
                 (+ ?₀ i)))

(let ((min-prefix (or unicode-math-input-min-prefix most-positive-fixnum)))
  (dolist (it (reverse (append unicode-math-input-extra-symbols
                               unicode-math-input-symbols)))
    (cl-loop with name = (car it)
             with len = (length name)
             for n from (min min-prefix len) to len
             do (quail-defrule (concat unicode-math-input-escape
                                       (substring name 0 n))
                               (cdr it)))))

;;;###autoload
(register-input-method
 "unicode-math"
 "UTF-8"
 'quail-use-package
 "Ω"
 "Input math symbols in TeX notation."
 "unicode-math-input")

(defun unicode-math-input--completion-table ()
  "Completion table for `unicode-math-input'."
  (let* ((cands (append unicode-math-input-extra-symbols
                        unicode-math-input-symbols))
         (metadata `((annotation-function . ,(lambda (name)
                                               (format unicode-math-input-annotation
                                                       (cdr (assoc name cands)))))
                     (category . unicode-math-symbol))))
    (lambda (string predicate action)
      (if (eq action 'metadata)
          `(metadata ,@metadata)
        (complete-with-action action cands string predicate)))))

;;;###autoload
(defun unicode-math-input (&optional name)
  "Insert the Unicode character with the given TeX NAME.
Can also be used as an item in `completion-at-point-functions'."
  (interactive (list (completing-read "Insert math symbol: "
                                      (unicode-math-input--completion-table)
                                      nil t)))
  (if name
      (insert (cdr (or (assoc name unicode-math-input-extra-symbols)
                       (assoc name unicode-math-input-symbols)
                       (user-error "No symbol named `%s'" name))))
    (when (thing-at-point-looking-at
           (rx (literal unicode-math-input-escape)
               (group (+ (any "A-Z" "a-z")))))
      `(,(match-beginning 1) ,(match-end 1)
        ,(unicode-math-input--completion-table)
        :exclusive no))))

(provide 'unicode-math-input)
;;; unicode-math-input.el ends here
