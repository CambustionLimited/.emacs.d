;;; rh-cc-company.el --- ramblehead's rtags header line

;; Copyright (C) 2019 Victor Rybynok

;; Author: Victor Rybynok
;; URL: non yet
;; Package-Version: 20190321
;; Version: 0.0.0
;; Keywords: convenience c++ rtags
;; Package-Requires: ((emacs "26"))

;; This file is NOT part of GNU Emacs.

;;; License:

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; This module configures company-rtags back-end
;;
;;; Code:

(require 'company-rtags)
(require 'company-clang)

;;;###autoload
(defun rh-cc-company-setup ()
  (interactive)

  (setq-local company-backends
              '((company-keywords company-dabbrev-code)
                company-capf company-files company-dabbrev company-ispell))

  (bind-key "C-x C-<tab>"
            (lambda ()
              (interactive)
              (let ((company-backends '((company-rtags company-clang))))
                (company-complete)))
            c-mode-base-map)

  (company-mode 1))

(provide 'rh-cc-company)
;;; rh-cc-company.el ends here
