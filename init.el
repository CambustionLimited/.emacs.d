;;; init.el --- ramblehead's emacs configuration  -*- lexical-binding: t; -*-
;;
;; Author: Victor Rybynok
;; Copyright (C) 2019-2023, Victor Rybynok, all rights reserved.

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file)
  (load custom-file))

(setq rh-emacs-version-string
      (replace-regexp-in-string
       "GNU Emacs \\([0-9]+.[0-9]+.[0-9]+\\).*"
       "\\1"
       (replace-regexp-in-string "\n" "" (emacs-version))))

(setq rh-emacs-version
      (mapcar 'string-to-number (split-string rh-emacs-version-string "\\.")))

(setq rh-site-start-file-paths ())

(cond
 ((equal system-type 'gnu/linux)
  (progn
    (setq rh-user-data (expand-file-name "~/.local/share/"))

    ;; Make the "~/.local/share/emacs" directories if does not already exist
    (if (not (file-exists-p (concat rh-user-data "emacs")))
        (make-directory (concat rh-user-data "emacs") t))
    (setq rh-recent-files-file-path (concat rh-user-data "emacs/recent-files"))
    (setq rh-saved-places-file-path (concat rh-user-data "emacs/saved-places"))
    (setq rh-bm-repository-file-path
          (concat rh-user-data "emacs/bm-repository"))
    (setq rh-ido-last-file-path (concat rh-user-data "emacs/ido-last"))

    ;; Paths for the site-start.el files, located in /usr/local/share/emacs/
    (let ((file-path "/usr/local/share/emacs/site-lisp/site-start.el")
          (ver-file-path
           (concat
            "/usr/local/share/emacs/"
            rh-emacs-version-string
            "/site-lisp/site-start.el")))
      (progn
        (when (file-exists-p file-path)
          (add-to-list 'rh-site-start-file-paths file-path))
        (when (file-exists-p ver-file-path)
          (add-to-list 'rh-site-start-file-paths ver-file-path)))))))

(setq rh-user-lisp-directory-path
      (concat (expand-file-name user-emacs-directory) "lisp/"))

(setq rh-user-site-start-file-path
      (concat rh-user-lisp-directory-path "site-start.el"))

(load "~/.config/emacs-private/secret.el" t)
(load (concat "~/.config/emacs-private/systems/" system-name ".el") t)

;;; /b/; Package initialisation and `use-package' bootstrap
;;; /b/{

;; see for straight.el
;; https://jeffkreeftmeijer.com/emacs-straight-use-package/

(require 'package)

(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
;; (add-to-list 'package-archives
;;              '("melpa" . "http://melpa.org/packages/"))
;; (add-to-list 'package-archives
;;              '("melpa-stable" . "https://stable.melpa.org/packages/"))
;; (add-to-list 'package-archives
;;              '("gnu" . "http://elpa.gnu.org/packages/"))

;; (setq package-check-signature nil)

(setq package-enable-at-startup nil)
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(use-package gnu-elpa-keyring-update
  :config (gnu-elpa-keyring-update)

  :demand t
  :ensure t)

(use-package use-package-ensure-system-package
  :ensure t)

;;; /b/}

;;; /b/; Basic system setup
;;; /b/{

(use-package color-theme-sanityinc-tomorrow
  :ensure t)

(use-package ace-window
  :config (setq aw-dispatch-when-more-than 1)

  :bind
  (("C-c a a" . ace-window)
   ("C-c a o" . ace-select-window)
   ("C-c a s" . ace-swap-window)
   ("C-c a d" . ace-delete-window))

  :ensure t
  :demand t)

(use-package emacs
  :config
  ;; No ceremony
  (setq inhibit-splash-screen t)
  (setq inhibit-startup-message t)

  ;; No mice
  (menu-bar-mode -1)
  (tool-bar-mode -1)
  (scroll-bar-mode -1)

  (setq default-input-method "russian-computer")

  (setq frame-title-format
	(concat "%b - emacs@" system-name))

  ;; Windows splitting
  (setq split-height-threshold nil)
  (setq split-width-threshold 170)

  (when (display-graphic-p)
    ;; Change cursor type according to mode
    ;; http://emacs-fu.blogspot.co.uk/2009/12/changing-cursor-color-and-shape.html
    (setq overwrite-cursor-type 'box)
    (setq read-only-cursor-type 'hbar)
    (setq normal-cursor-type 'bar)

    ;; (setq-default line-spacing nil)
    ;; (add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono"))
    ;; (add-to-list 'default-frame-alist
    ;;              '(font . "Hack-10.5"))

    ;; HiDPI
    (let ((width-pixels
           (elt (assoc 'geometry (car (display-monitor-attributes-list))) 3)))
      (cond
       ((= width-pixels 1920)
        ;; (fringe-mode '(16 . 16))
        ;; (setq read-only-cursor-type '(hbar . 4))
        ;; (setq normal-cursor-type '(bar . 4))
        ;; (add-to-list 'default-frame-alist '(font . "DejaVu Sans Mono"))
        (add-to-list 'default-frame-alist '(font . "Hack-10.5")))

       ((= width-pixels 2560)
        (add-to-list 'default-frame-alist '(font . "Hack-9")))))

    (set-face-attribute 'region nil
                        :box
                        '(:line-width
                          (-1 . -1)
                          ;; :color "gtk_selection_bg_color"
                          :color "#ea5e30"
                          :style nil)
                        :background "#ea5e30")

    ;; face-font-family-alternatives

    ;; (set-face-attribute 'default nil :font "Noto Mono" :height 90)
    ;; (set-face-attribute 'default nil
    ;;                     :family "Hack"
    ;;                     :height 90
    ;;                     :width 'semi-condensed
    ;;                     :weight 'normal)

    ;; see https://github.com/shosti/.emacs.d/blob/master/personal/p-display.el#L9
    (set-fontset-font t (decode-char 'ucs #x2d5b) "Noto Sans Tifinagh-9") ; ⵛ
    (set-fontset-font t (decode-char 'ucs #x2d59) "Noto Sans Tifinagh-9") ; ⵙ
    (set-fontset-font t (decode-char 'ucs #x2605) "Noto Sans Mono CJK SC-8") ; ★
    (set-fontset-font t (decode-char 'ucs #o20434) "Symbola-8.5") ; ℜ
    (set-fontset-font t (decode-char 'ucs #x2b6f) "Symbola-8.5") ; ⭯
    (set-fontset-font t (decode-char 'ucs #x2b73) "Symbola-8.5") ; ⭳
    (set-fontset-font t (decode-char 'ucs #x1f806) "Symbola-8.5") ; 🠆
    ;; (set-fontset-font t (decode-char 'ucs #x1f426) "Symbola-9.5") ; 🐦

    (defun rh-set-cursor-according-to-mode ()
      "Change cursor type according to some minor modes."
      (cond
       (buffer-read-only
        (setq cursor-type read-only-cursor-type))
       (overwrite-mode
        (setq cursor-type overwrite-cursor-type))
       (t
        (setq cursor-type normal-cursor-type))))

    (add-hook 'post-command-hook 'rh-set-cursor-according-to-mode))

  ;; TODO: Fix trailing-whitespace face in color-theme-sanityinc-tomorrow-blue
  (color-theme-sanityinc-tomorrow-blue)
  ;; (load-theme 'sanityinc-tomorrow-blue t)
  ;; (disable-theme 'sanityinc-tomorrow-blue)
  ;; (enable-theme 'sanityinc-tomorrow-blue)

  ;; (customize-set-variable 'find-file-visit-truename t)
  (customize-set-value 'find-file-visit-truename t)

  ;; Disable annoying key binding for (suspend-frame) function and quit
  (global-unset-key (kbd "C-x C-z"))
  (global-unset-key (kbd "C-x C-c"))

  ;; Prevent translation from <kp-bebin> to <begin>
  (global-set-key (kbd "<kp-begin>") (lambda () (interactive)))

  ;; see http://superuser.com/questions/498533/how-to-alias-keybindings-in-emacs
  ;; for keybindings aliases. Can also be used with (current-local-map)
  (define-key
   (current-global-map)
   (kbd "C-<kp-up>")
   (lookup-key (current-global-map) (kbd "C-<up>")))

  (define-key
   (current-global-map)
   (kbd "C-<kp-down>")
   (lookup-key (current-global-map) (kbd "C-<down>")))

  (define-key
   (current-global-map)
   (kbd "C-<kp-left>")
   (lookup-key (current-global-map) (kbd "C-<left>")))

  (define-key
   (current-global-map)
   (kbd "C-<kp-right>")
   (lookup-key (current-global-map) (kbd "C-<right>")))

  :bind
  (("C-x r q" . save-buffers-kill-terminal) ; Exit Emacs!
   ("C-z" . undo)
   ("C-x f" . find-file-at-point))

  :demand t)

;;; /b/}

;;; /b/; dired
;;; /b/{

(defun rh-dired-find-file ()
  (interactive)
  (let* ((filename (dired-get-file-for-visit))
         (filename-after
          (if (string= (file-name-nondirectory filename) "..")
              (dired-current-directory)
            (concat (file-name-as-directory filename) "..")))
         (find-file-respect-dired
          (lambda (fn)
            (if (= (length (get-buffer-window-list)) 1)
                (find-alternate-file fn)
              (bury-buffer)
              (find-file fn)))))
    (if (not (file-directory-p filename))
        (funcall find-file-respect-dired filename)
      (if (not (file-accessible-directory-p filename))
          (error (format "Directory '%s' is not accessible" filename))
        (funcall find-file-respect-dired filename))
      (dired-goto-file filename-after)
      (recenter))))

(defun rh-dired-change-to-file (filename)
  (interactive "FFind file: ")
  (find-alternate-file filename))

(defun rh-dired-ace-select-other-window ()
  (interactive)
  (let ((file-name (dired-get-file-for-visit)))
    (when (ace-select-window)
      (find-file file-name))))

(defun rh-get-buffer-mode-window-list (&optional buffer-or-name mode all-frames)
  (setq mode (or mode major-mode))
  (let ((window-list '()))
    (dolist (win (window-list-1 nil nil all-frames))
      (when (eq
             (with-selected-window win
               major-mode)
             mode)
        (push win window-list)))
    (nreverse window-list)))

(defun rh-dired-select-next-dired-window ()
  (interactive)
  (let ((window-list (rh-get-buffer-mode-window-list)))
    (if (> (length window-list) 1)
        (select-window (nth 1 window-list))
      (let ((directory (dired-current-directory))
            (pos (point)))
        (when (ace-select-window)
          (find-file directory)
          (goto-char pos))))))

(defun rh-dired-alt-ace-select-other-window ()
  (interactive)
  (with-selected-window (frame-selected-window)
    (let ((name (dired-get-file-for-visit)))
      (when (ace-select-window)
        (find-file name)))))

(defun rh-dired-change-to-parent-dir ()
  (interactive)
  (dired-goto-file (concat (dired-current-directory) ".."))
  (rh-dired-find-file))

(defun rh-dired-open-file ()
  "In dired, open the file named on this line."
  (interactive)
  (let ((file (dired-get-filename nil t)))
    (message "Opening %s..." file)
    (call-process "xdg-open" nil 0 nil file)))

;; (defun rh-dired-guess-dir ()
;;   "Starts dired in buffer-file-name directory or in '~', if buffer has no
;; filename associated with it."
;;   (interactive)
;;   (progn
;;     (dired (let ((fnm (buffer-file-name)))
;;              (if fnm
;;                  (file-name-directory fnm)
;;                "~")))))

(use-package dired
  :config
  ;; copy from one dired dir to the next dired dir shown in a split window
  (setq dired-dwim-target t)

  (require 'ace-window)

  (add-hook
   'dired-mode-hook
   (lambda ()
     (hl-line-mode 1)
     (setq-local coding-system-for-read vr-dired-coding-system)
     (setq-local find-file-visit-truename nil)
     ;; (add-hook
     ;;  'window-selection-change-functions
     ;;  (lambda (win)
     ;;    (when (eq (with-selected-window win major-mode) 'dired-mode)
     ;;      (if (eq win (frame-selected-window))
     ;;          (hl-line-mode 1)
     ;;        (with-selected-window win
     ;;          (when (= (length (get-buffer-window-list)) 1)
     ;;            (hl-line-mode -1))))))
     ;;  nil t)
     ))

  :bind
  (:map dired-mode-map
    ("RET" . rh-dired-find-file)
    ("<return>" . rh-dired-find-file)
    ("f" . rh-dired-find-file)
    ("<backspace>" . rh-dired-change-to-parent-dir)
    ("TAB" . rh-dired-select-next-dired-window)
    ("<kp-return>" . rh-dired-find-file)
    ("C-x C-f" . rh-dired-change-to-file)
    ("M-<return>" . rh-dired-alt-ace-select-other-window)
    ("M-<enter>" . rh-dired-alt-ace-select-other-window)
    ("C-M-<return>" . rh-dired-ace-select-other-window)
    ("C-M-<enter>" . rh-dired-ace-select-other-window)
    ("e" . rh-dired-open-file))

  :demand t)

(put 'dired-find-alternate-file 'disabled nil)

(if (equal system-type 'windows-nt)
    ;; In MS Windows systems
    (progn
      (setq dired-listing-switches "-alhgG")
      (setq vr-dired-coding-system 'cp1251))
  ;; In unix-like systems
  ;; Sort dirs and files in dired as in "C"
  (setenv "LC_COLLATE" "C")
  (setq dired-listing-switches
        ;; "--group-directories-first --time-style=long-iso -alhD"
        "--group-directories-first --time-style=long-iso -alh")
  (setq vr-dired-coding-system nil))

;; (global-set-key (kbd "C-x d") 'rh-dired-guess-dir)
(global-set-key (kbd "C-x d") #'dired-jump)

;; (use-package dired-subtree
;;   :config
;;   (setq dired-subtree-use-backgrounds nil)
;;   ;; :bind (:map which-key-mode-map
;;   ;;         ("<f1>" . which-key-show-top-level))

;;   :after dired
;;   :demand t
;;   :ensure t)

;; (use-package dired-open
;;   :after dired
;;   :demand t
;;   :ensure t)

;;; /b/}
