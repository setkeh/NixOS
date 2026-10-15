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

;; Window switching: SPC w <arrow> (and C-w <arrow>) come from evil's own
;; evil-window-map, which Doom binds to SPC w. Rebinding the "w" prefix under
;; :leader here would replace that whole map, so don't.

;; Bookmark clipping
(after! org
  (add-to-list 'org-capture-templates
        '("b" "Bookmark (Clipboard)" entry (file+headline "~/storage/org/personal/bookmarks.org" "Bookmarks")
           "** %(org-cliplink-capture)\n:PROPERTIES:\n:TIMESTAMP: %t\n:END:%?\n" :empty-lines 1 :prepend t))
)

(setq projectile-project-search-path '(
                                       "~/.config/home-manager"
                                       "~/SecondMind"
                                       ("~/Development" . 1)
                                       ))

;; Projectile + Auto TreeMacs
;; Doom's :ui workspaces takes over projectile's switch action and then calls
;; +workspaces-switch-project-function with the new project's root, so that is
;; where to hook in. Show that project (only that one) in Treemacs without
;; moving focus, then prompt for a file as Doom does by default.
(after! treemacs
  (setq treemacs-show-hidden-files nil))

(setq +workspaces-switch-project-function
      (lambda (dir)
        (let ((default-directory dir))
          (save-selected-window
            (treemacs-add-and-display-current-project-exclusively)))
        (doom-project-find-file dir)))

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

;;(load "~/.ercpass")

;;(add-hook 'erc-after-connect
;;    	  '(lambda (SERVER NICK)
;;    	     (cond
;;    	      ((string-match "libera\\.chat" SERVER)
;;    	       (erc-message "PRIVMSG" (format "NickServ identify setkeh %s" libera-pass)))

;;    	      ((string-match "oftc\\.net" SERVER)
;;    	       (erc-message "PRIVMSG" (format "NickServ identify %s setkeh" oftc-pass))))))

;;(setq erc-nickserv-passwords
;;          `((irc.libera.chat     (("nick-one" . ,libera-pass)))
;;            (irc.oftc.net       (("nickname" . ,oftc-pass)))))

;;(require 'erc-join)
;;(erc-autojoin-mode 1)
;;(setq erc-autojoin-channels-alist
;;          '(("libera.chat" "#emacs" "#systemcrafters" "#emacs" "#nixos")
;;            ("oftc.net" "#home-manager")))

;;(erc-tls :server "irc.libera.chat" :port 6697 :nick "setkeh")
;;(erc-tls :server "irc.oftc.net" :port 6697 :nick "setkeh")


;; Evil in ghostel terminals. claude-code-ide sets ESC in its buffers to switch
;; to normal state (claude-code-ide-ghostel-evil-escape), so ESC then SPC w
;; changes pane; C-c C-r toggles sending ESC to Claude instead.
(use-package! evil-ghostel
  :after (ghostel evil)
  :hook (ghostel-mode . evil-ghostel-mode))

;; Open ghostel terminals in a split along the bottom instead of over the
;; editor, like Doom's vterm (SPC o t). Unlike vterm's rule (:ttl 0), closing the
;; split keeps the shell; running ghostel again brings the same one back.
;; Claude's buffers are named *claude-code[...]*, so this doesn't touch them.
(set-popup-rule! "^\\*ghostel" :size 0.3 :vslot -4 :select t :quit nil :ttl nil)

;; Terminals run fish, like alacritty, not the bash login shell from $SHELL:
;; same prompt (which shows nix shell / develop) and the same history.
;; Claude's ghostel buffers run claude directly, so they aren't affected.
(setq ghostel-shell "/etc/profiles/per-user/setkeh/bin/fish"
      vterm-shell "/etc/profiles/per-user/setkeh/bin/fish")

;; SPC o t toggles the ghostel split, replacing Doom's vterm toggle there.
(defun +ghostel/toggle (&optional arg)
  "Show or hide the ghostel terminal split; the shell keeps running when hidden.
With a prefix ARG, hand it to `ghostel' instead: \\[universal-argument] opens
another terminal."
  (interactive "P")
  (if-let* ((win (and (not arg)
                      (seq-find (lambda (w)
                                  (string-prefix-p "*ghostel" (buffer-name (window-buffer w))))
                                (window-list)))))
      (delete-window win)
    (ghostel arg)))

(map! :leader :desc "Toggle ghostel" "o t" #'+ghostel/toggle)

;; Claude Code
(use-package! claude-code-ide
  :bind ("C-c C-'" . claude-code-ide-menu) ; Set your favorite keybinding
  :config
  ;; ghostel instead of vterm: vterm garbles Claude's screen when the window is
  ;; resized or refocused. ghostel comes from nixpkgs (see default.nix).
  (setq claude-code-ide-terminal-backend 'ghostel)
  (claude-code-ide-emacs-tools-setup)) ; Optionally enable Emacs MCP tools