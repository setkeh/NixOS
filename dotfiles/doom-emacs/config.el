;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; Add GOBIN to emacs Path
(setq exec-path (append exec-path '("~/go/bin")))

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "James <Setkeh> Griffis"
      user-mail-address "setkeh@gmail.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom. Here
;; are the three important ones:
;;
;; + `doom-font'
;; + `doom-variable-pitch-font'
;; + `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;;
;; They all accept either a font-spec, font string ("Input Mono-12"), or xlfd
;; font string. You generally only need these two:
;; (setq doom-font (font-spec :family "monospace" :size 12 :weight 'semi-light)
;;       doom-variable-pitch-font (font-spec :family "sans" :size 13))

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/storage/org/")

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type t)


;; Here are some additional functions/macros that could help you configure Doom:
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(after! evil
  (map! :map evil-window-map
        (:leader
         (:prefix ("w" . "Select Window")
          :n :desc "Left"  "<left>" 'evil-window-left
          :n :desc "Up"    "<up>" 'evil-window-up
          :n :desc "Down"  "<down>" 'evil-window-down
          :n :desc "Right" "<right>" 'evil-window-right
          ))
        ))

;; Bookmark clipping
(after! org
  (add-to-list 'org-capture-templates
        '("b" "Bookmark (Clipboard)" entry (file+headline "~/storage/org/personal/bookmarks.org" "Bookmarks")
           "** %(org-cliplink-capture)\n:PROPERTIES:\n:TIMESTAMP: %t\n:END:%?\n" :empty-lines 1 :prepend t))
)

(setq projectile-project-search-path '(
                                       "~/git"
                                       "~/go/src/github.com/setkeh/"
                                       "~/go/src/github.com/thesetkehproject/"
                                       "~/storage/org"
                                       "~/storage/WorkStuff"
                                       "~/storage/HackTheBox"
                                       "~/.doom.d"
                                       "~/.config"
                                       "~/.esp"
                                       ))

;; Go - lsp-mode
;; Set up before-save hooks to format buffer and add/delete imports.
(require 'lsp-mode)
(add-hook 'go-mode-hook #'lsp-deferred)

;; Set up before-save hooks to format buffer and add/delete imports.
;; Make sure you don't have other gofmt/goimports hooks enabled.
(defun lsp-go-install-save-hooks ()
  (add-hook 'before-save-hook #'lsp-format-buffer t t)
  (add-hook 'before-save-hook #'lsp-organize-imports t t))
(add-hook 'go-mode-hook #'lsp-go-install-save-hooks)

;; Python lsp-mode
;;(use-package lsp-jedi
;;  :ensure t
;;  :config
;;  (with-eval-after-load "lsp-mode"
;;    (add-to-list 'lsp-disabled-clients 'pyls)
;;    (add-to-list 'lsp-enabled-clients 'jedi 'gopls)))

;; ERC Setup
;;(setq erc-server "irc.libera.chat"
;;      erc-port "6697"
;;      erc-nick "setkeh"
;;      erc-user-full-name "James <SETKEH> Griffis"
;;      erc-autojoin-channels-alist '(("irc.libera.chat" "#systemcrafters" "#emacs" "#nixos"))
;;      erc-prompt-for-password true)

(load "~/.ercpass")

(add-hook 'erc-after-connect
    	  '(lambda (SERVER NICK)
    	     (cond
    	      ((string-match "libera\\.chat" SERVER)
    	       (erc-message "PRIVMSG" (format "NickServ identify setkeh %s" libera-pass)))

    	      ((string-match "oftc\\.net" SERVER)
    	       (erc-message "PRIVMSG" (format "NickServ identify %s setkeh" oftc-pass))))))

;;(setq erc-nickserv-passwords
;;          `((irc.libera.chat     (("nick-one" . ,libera-pass)))
;;            (irc.oftc.net       (("nickname" . ,oftc-pass)))))

(require 'erc-join)
(erc-autojoin-mode 1)
(setq erc-autojoin-channels-alist
          '(("libera.chat" "#emacs" "#systemcrafters" "#emacs" "#nixos")
            ("oftc.net" "#home-manager")))

(erc-tls :server "irc.libera.chat" :port 6697 :nick "setkeh")
(erc-tls :server "irc.oftc.net" :port 6697 :nick "setkeh")
