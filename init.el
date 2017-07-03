;; make it easy to go to pondo on eshell
(defun pondo () "/ssh:mbauer@ponderosa.biology.unr.edu:~")

;; set up package repos
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/"))
(package-initialize) 
;; "strip"
(blink-cursor-mode 0)
(setq initial-scratch-message "")
(setq inhibit-startup-message t)
(setq visible-bell t)
(setq inhibit-startup-echo-area-message "cyangekko")
(scroll-bar-mode 0)
(tool-bar-mode 0)
(menu-bar-mode 0)
(global-linum-mode 0) ;; turn ON line numbers!
(set-fringe-mode 100)
;;(setq-default header-line-format mode-line-format)
;;(setq-default mode-line-format nil)

;; set font size
(set-face-attribute 'default nil :height 200)

;; disable annoying backup files
(setq make-backup-files nil)

;; add load path stuff
(add-to-list 'load-path "~/.emacs.d/evil/")
(add-to-list 'load-path "~/.emacs.d/lisp/")
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

(setq c-default-style "linux"
      c-basic-offset 4)

;; include stuff
(require 'evil)
(require 'evil-leader)
(require 'flycheck)
(require 'rainbow-delimiters)
(require 'column-enforce-mode)

;; turn on stuff
(add-hook 'prog-mode-hook (lambda () (interactive)
			    (flycheck-mode)
			    (column-enforce-mode)
			    (rainbow-delimiters-mode)))
(add-hook 'c++-mode-hook (lambda () (setq flycheck-gcc-language-standard "c++11")))
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))

;; disable mouse
(dolist (k '([mouse-1] [down-mouse-1] [drag-mouse-1] [double-mouse-1] [triple-mouse-1]
	     [mouse-2] [down-mouse-2] [drag-mouse-2] [double-mouse-2] [triple-mouse-2]
	     [mouse-3] [down-mouse-3] [drag-mouse-3] [double-mouse-3] [triple-mouse-3]
	     [mouse-4] [down-mouse-4] [drag-mouse-4] [double-mouse-4] [triple-mouse-4]
	     [mouse-5] [down-mouse-5] [drag-mouse-5] [double-mouse-5] [triple-mouse-5]))
  (global-unset-key k))
(defun dsbl-key (map kbd-str)
  (define-key map (kbd kbd-str) (lambda () (interactive))))
(defun cat3 (one two three) (concatenate 'string one two three))
(defun dsbl-mouse-btn (map btn-num)
  (dsbl-key map (cat3 "<mouse-" btn-num ">"))
  (dsbl-key map (cat3 "<down-mouse-" btn-num ">"))
  (dsbl-key map (cat3 "<drag-mouse-" btn-num ">"))
  (dsbl-key map (cat3 "<double-mouse-" btn-num ">"))
  (dsbl-key map (cat3 "<triple-mouse-" btn-num ">")))
(defun dsbl-mouse (map)
  (dsbl-mouse-btn map "1")
  (dsbl-mouse-btn map "2")
  (dsbl-mouse-btn map "3")
  (dsbl-mouse-btn map "4")
  (dsbl-mouse-btn map "5"))
(dsbl-mouse evil-normal-state-map)
(dsbl-mouse evil-insert-state-map)
(dsbl-mouse evil-visual-state-map)

;; turn on evil
(require 'evil)
(evil-mode 1)

;; add evil bindings
(defun timeout-keyseq-hdl (key-initial swallow &rest finals) (interactive)
  (let ((event (read-event nil nil 0.5))
        (ondie (lambda () (if swallow nil (insert key-initial)))))
    (if event
      (loop for final in finals do
            (if (and (characterp event) (= event (car final)))
              (eval (cdr final))
              (funcall ondie)
              )
            )
      (funcall ondie))))

(define-key evil-insert-state-map "j"
            (lambda () (interactive) (timeout-keyseq-hdl ?j nil '(?k evil-normal-state))))
(define-key evil-insert-state-map "J" 
            (lambda () (interactive) (timeout-keyseq-hdl ?J nil '(?K evil-normal-state))))

;; window movement
(define-key evil-insert-state-map (kbd "C-h") 'windmove-left)
(define-key evil-insert-state-map (kbd "C-j") 'windmove-down)
(define-key evil-insert-state-map (kbd "C-k") 'windmove-up)
(define-key evil-insert-state-map (kbd "C-l") 'windmove-right)
(define-key evil-normal-state-map (kbd "C-h") 'windmove-left)
(define-key evil-normal-state-map (kbd "C-j") 'windmove-down)
(define-key evil-normal-state-map (kbd "C-k") 'windmove-up)
(define-key evil-normal-state-map (kbd "C-l") 'windmove-right)

;; movement within buffer
(define-key evil-normal-state-map (kbd "J") (lambda () (interactive) (next-line 5)))
(define-key evil-normal-state-map (kbd "K") (lambda () (interactive) (previous-line 5)))

;; adding more newline creation hotkeys
(define-key evil-normal-state-map ","
            (lambda () (interactive) (timeout-keyseq-hdl ?, t '(?l (lambda () (interactive) (timeout-keyseq-hdl ?l t '(?l (lambda () (interactive)
                                                                      (evil-open-above 1)
                                                                      (evil-normal-state)
                                                                      (evil-open-above 1)))))))))
;; configure org-mode
(require 'org)
(setq org-agenda-files '("~/org/"))
(define-key global-map "\C-cl" 'org-store-link)
(define-key global-map "\C-ca" 'org-agenda)
(setq org-log-done t)
(evil-define-key 'normal org-mode-map (kbd "<tab>") #'org-cycle)
(evil-define-key 'insert org-mode-map (kbd "<tab>") #'org-cycle)
(evil-define-key 'normal org-mode-map ","
  (lambda () (interactive) (timeout-keyseq-hdl ?, t
					       '(?d (lambda () (org-deadline 1)))
					       '(?a org-toggle-archive-tag)
					       '(?t org-todo)
					       '(?g org-agenda))))

;; semantic
(require 'cc-mode)
(require 'semantic)
(global-semanticdb-minor-mode 1)
(global-semantic-idle-scheduler-mode 1)
(semantic-mode 1)
(semantic-add-system-include "/usr/lib/gcc/x86_64-pc-linux-gnu/5.4.0/include/g++-v5/" 'c++-mode)

;; autocomplete
;;(ac-config-default)
;;(global-auto-complete-mode t)

;; company mode
(require 'company)
(add-hook 'after-init-hook 'global-company-mode)
(define-key c-mode-map [(tab)] 'company-complete)
(define-key c++-mode-map [(tab)] 'company-complete)
(add-to-list 'company-backends 'company-c-headers)
(require 'company-c-headers)
(add-to-list 'company-c-headers-path-system "/usr/lib/gcc/x86_64-pc-linux-gnu/5.4.0/include/g++-v5/")

;; company-jedi
(setq jedi:environment-virtualenv (list (expand-file-name "~/.emacs.d/.python-environments/")))

;; helm
;; taken from tuhdo.github.io/helm-intro.html
;; stripped to what is relevant to us
(require 'helm)
(require 'helm-config)
(global-set-key (kbd "C-c h") 'helm-command-prefix)
(global-unset-key (kbd "C-x c"))
(global-set-key (kbd "C-x C-f") 'helm-find-files)
(define-key helm-map (kbd "<tab>") 'helm-execute-persistent-action)
(define-key helm-map (kbd "C-z") 'helm-select-action)
(when (executable-find "curl")
  (setq helm-google-suggest-use-curl-p t))
(setq helm-split-window-in-side-p            t
      helm-move-to-line-cycle-in-source      t
      helm-ff-search-library-in-sexp         t
      helm-scroll-amount                     8
      helm-ff-file-name-history-use-recentf  t
      helm-echo-input-in-header-line         t)
(setq helm-autoresize-max-height 0)
(setq helm-autoresize-min-height 20)
(helm-autoresize-mode 1)
(helm-mode 1)

;; helm company
(global-unset-key (kbd "C-:"))
(eval-after-load 'company
  '(progn
     (define-key company-mode-map (kbd "C-:") 'helm-company)
     (define-key company-active-map (kbd "C-:") 'helm-company)))

;; helm gtags
;; from https://tuhdo.github.io/c-ide.html
;;(setq
 ;;helm-gtags-ignore-case t
 ;;helm-gtags-auto-update t
 ;;helm-gtags-use-input-at-cursor t
 ;;helm-gtags-pulse-at-cursor t
 ;;helm-gtags-prefix-key "\C-cg"
 ;;helm-gtags-suggested-key-mapping t)
;;(require 'helm-gtags)
;;(add-hook 'dired-mode-hook 'helm-gtags-mode)
;;(add-hook 'eshell-mode-hook 'helm-gtags-mode)
;;(add-hook 'c-mode-hook 'helm-gtags-mode)
;;(add-hook 'c++-mode-hook 'helm-gtags-mode)
;;(add-hook 'asm-mode-hook 'helm-gtags-mode)
;;(define-key helm-gtags-mode-map (kbd "C-c g a") 'helm-gtags-tags-in-this-function)
;;(define-key helm-gtags-mode-map (kbd "C-j") 'helm-gtags-select)
;;(global-unset-key (kbd "M-."))
;;(define-key helm-gtags-mode-map (kbd "M-.") 'helm-gtags-dwim)
;;(define-key helm-gtags-mode-map (kbd "M-,") 'helm-gtags-pop-stack)
;;(define-key helm-gtags-mode-map (kbd "C-c <") 'helm-gtags-previous-history)
;;(define-key helm-gtags-mode-map (kbd "C-c >") 'helm-gtags-next-history)

;; function-args
(require 'function-args)
(fa-config-default)
(add-to-list 'auto-mode-alist '("\\.h\\'" . c++-mode))
(set-default 'semantic-case-fold t)

;; theme
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(custom-enabled-themes (quote (orangish)))
 '(custom-safe-themes
   (quote
    ("e0c66085db350558f90f676e5a51c825cb1e0622020eeda6c573b07cb8d44be5" "dd4d9b3ed7d5d6b1f3e61efd22f4a79d4b010bf3efca9e97a24b52741dff2d5d" "5882a9761dad0d5c101d17321e03ec5ac95457abc43b4b69a9d0318c7242da6c" "2acc32e7a9e15d939943db7db758500007dd95d5ca5cbe7aa6c0fcc3f4f1dc88" "0d1e4e34c3a294ff0b7cf66a4559f589796bc4a2d4dc1fe0b0de2d8a3eef8173" "43f5944dfbf2f8b21f2e89830f68ba4e3a7bd9cb8d9cf995a12385ba62627705" "6e6aa96122cdfc1f2040ad1235306e066ee8a8dd09b799cab0fa21fdb23334b2" "19bbc2b1891c00d39e578f6a51da01871be5be147e5a8e343c62c3636a979073" "538631d9e17080e2726a6587790132d228880ff0e4efcc78838927f38824c61b" default)))
 '(org-blank-before-new-entry (quote ((heading . auto) (plain-list-item . auto))))
 '(org-hide-leading-stars t)
 '(package-selected-packages
   (quote
    (company-jedi helm-company company-c-headers company function-args helm-gtags helm auto-complete solarized-theme rainbow-delimiters monokai-theme molokai-theme magit flycheck darkokai-theme column-marker column-enforce-mode))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
