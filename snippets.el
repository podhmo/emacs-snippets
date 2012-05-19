(eval-when-compile (require 'cl))

(defun snippets:current-directory ()
  (if load-file-name
      (file-name-directory load-file-name)
    default-directory))

(defun snippets:directory-files (directory &optional full nosort)
  (directory-files directory full "^[^\\.]\\{1,2\\}" nosort))

;; settinsg
(defvar snippets:current-major-mode nil)
(defvar snippets:snippet-directory 
  (concat (snippets:current-directory) "snippets"))
(defvar snippets:snippet-directory-function nil)

(defvar snippets:major-mode-directory-mapping-alist 
  '((emacs-lisp-mode . "elisp")
    (python-mode . "python")))

(defun snippets:snippet-directory ()
  (if snippets:snippet-directory-function
      (funcall snippets:snippet-directory-function)
      snippets:snippet-directory))

(defun snippets:get-snippet-dicrectory-by-mode-name ()
  (let* ((curdir snippets:snippet-directory)
         (curdir (if (string-equal "/" (substring curdir -2 -1)) curdir (concat curdir "/"))))
    (concat curdir
            (assoc-default snippets:current-major-mode
                           snippets:major-mode-directory-mapping-alist))))

(setq snippets:snippet-directory-function
      'snippets:get-snippet-dicrectory-by-mode-name)

(defun snippets:snippets-candidates ()
  (let1 dir (snippets:snippet-directory)
    (unless (file-exists-p dir)
      (make-directory dir t))
    (snippets:directory-files dir)))
;; 
(defun snippets:insert-snippet (candidate)
  (let1 fpath (concat (snippets:snippet-directory) "/" candidate)
    (save-restriction
      (narrow-to-region (point) (point))
      ;;(insert-file-contents fpath)
      (simple-template fpath)
      (goto-char (point-max)))))

(defvar snippets:anything-c-source
  '((name . "snippets")
    (candidates . snippets:snippets-candidates)
    (action
     ("insert" . snippets:insert-snippet))
    (persistent-action . snippets:insert-snippet)))

(defun anything-snippets () (interactive)
  (setq snippets:current-major-mode major-mode)
  (anything-other-buffer 'snippets:anything-c-source
                         "*python snippets*"))


(provide 'snippets)