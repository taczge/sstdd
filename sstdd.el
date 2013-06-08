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

;;
;; jump
;;
(defun sstdd-cmd-toggle-test-pair ()
  (interactive)
  (sstdd-toggle-test-pair (buffer-file-name)))

(defun sstdd-toggle-test-pair (filename)
  (cond ((sstdd-implemented-code-file-p filename)
         (sstdd-jump-test-code-file))
        ((sstdd-test-code-file-p filename)
         (sstdd-jump-implemented-code-file))))

(defun sstdd-implemented-code-file-p (filename)
  (not (sstdd-test-code-file-p filename)))

(defun sstdd-test-code-file-p (filename)
  (not (eq nil (string-match "[^/]+?UnitSpec.scala$" filename))))

(defun sstdd-jump-test-code-file ()
  (find-file
   (sstdd-to-test-code-file-name
    (sstdd-to-test-code-file-path (buffer-file-name)))))

(defun sstdd-jump-implemented-code-file ()
  (find-file
   (sstdd-to-implemented-code-file-name
    (sstdd-to-implemeted-code-file-path (buffer-file-name)))))

(defun sstdd-to-test-code-file-path (filename)
  (replace-regexp-in-string "/src/main/scala" "/src/test/scala" filename))

(defun sstdd-to-implemeted-code-file-path (filename)
  (replace-regexp-in-string "/src/test/scala" "/src/main/scala" filename))

(defun sstdd-to-test-code-file-name (filename)
  (replace-regexp-in-string
   "\\([^/]+?\\).scala$" "\\1UnitSpec\.scala" filename))

(defun sstdd-to-implemented-code-file-name (filename)
  (replace-regexp-in-string
   "\\([^/]+?\\)UnitSpec.scala$" "\\1\.scala" filename))

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
