;;; sstdd.el --- scala sbt tdd tool

;; Copyright (C) 2013  nge

;; Author: taczge <tn00gm@gmail.com>
;; Keywords: 

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; 

;;; Code:

(require 'ert-expectations)

;;
;; jump
;;
(defun sstdd-cmd-toggle-testing-pair ()
  (interactive)
  (sstdd-toggle-testing-pair (buffer-file-name)))

(defun sstdd-toggle-testing-pair (file-name)
  (cond ((sstdd-impl-code-file-p file-name)
         (sstdd-jump-into-test-code-file file-name))
        ((sstdd-test-code-file-p file-name)
         (sstdd-jump-into-impl-code-file file-name))))

(defun sstdd-impl-code-file-p (filename)
  (not (sstdd-test-code-file-p filename)))

(defun sstdd-test-code-file-p (filename)
  (not (eq nil (string-match "[^/]+?UnitSpec.scala$" filename))))

(dont-compile
  (when (fboundp 'expectations)
    (expectations
      (expect t
        (sstdd-impl-code-file-p
         "proj/src/main/scala/aaa/bbb/Ccc.scala"))
      (expect nil
        (sstdd-impl-code-file-p
         "proj/src/test/scala/aaa/bbb/CccUnitSpec.scala"))
      (expect nil
        (sstdd-test-code-file-p
         "proj/src/main/scala/aaa/bbb/Ccc.scala"))
      (expect t
        (sstdd-test-code-file-p
         "proj/src/main/scala/aaa/bbb/CccUnitSpec.scala")))))

(defun sstdd-convert-impl-code-path-to-test-code-path
  (impl-code-file-path)
  (replace-regexp-in-string
   "/src/main/scala/\\(.*\\)/\\([^/]+?\\)\.scala"
   "/src/test/scala/\\1/\\2UnitSpec.scala" impl-code-file-path))

(defun sstdd-convert-test-code-path-to-impl-code-path
  (test-code-file-path)
  (replace-regexp-in-string
   "/src/test/scala/\\(.*\\)/\\([^/]+?\\)UnitSpec\.scala"
   "/src/main/scala/\\1/\\2\.scala" test-code-file-path))

(dont-compile
  (when (fboundp 'expectations)
    (expectations
      (expect "proj/src/test/scala/aaa/bbb/MyUnitSpec.scala"
        (sstdd-convert-impl-code-path-to-test-code-path
         "proj/src/main/scala/aaa/bbb/My.scala"))
      (expect "proj/src/main/scala/aaa/bbb/Ccc.scala"
        (sstdd-convert-test-code-path-to-impl-code-path
         "proj/src/test/scala/aaa/bbb/CccUnitSpec.scala")))))

(defun sstdd-jump-into-test-code-file (file-name)
  (find-file (sstdd-convert-impl-code-path-to-test-code-path file-name)))

(defun sstdd-jump-into-impl-code-file (file-name)
  (find-file (sstdd-convert-test-code-path-to-impl-code-path file-name)))

;;
;; run
;;
(defun sstdd-extract-class-name (fullpath)
  (replace-regexp-in-string ".*/\\(.+\\).scala" "\\1" fullpath))

(defun sstdd-extract-package-name (fullpath)
  (sstdd-convert-dash-to-slash
   (replace-regexp-in-string
    ".*/\\(test/scala/.*\\)/[^/]+.scala$" "\\1" fullpath)))

(defun sstdd-convert-dash-to-slash (path)
  (replace-regexp-in-string "/" "." path))

(defun sstdd-to-sbt-test-only-command (fullpath)
  (format "test-only %s.%s"
   (sstdd-extract-package-name fullpath)
   (sstdd-extract-class-name   fullpath)))

(defun sstdd-insert-test-only-command-to-eshell ()
  (interactive)
  (let ((sbt-test-only-command (sstdd-to-sbt-test-only-command (buffer-file-name))))
    (switch-to-buffer "*eshell*")
    (goto-char (point-max))
    (insert sbt-test-only-command)))

(provide 'sstdd)

;;; sstdd.el ends here
