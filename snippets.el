(defun snippets:current-directory ()
  (if load-file-name
      (file-name-directory load-file-name)
    default-directory))
      
(defvar snippets:snippet-directory 
  (concat (snippets:current-directory) ".emacs.d/snippets"))

(defun snippets:snippets-candidates ()
  (unless (file-exists-p snipetts:snipetts-directory)
    (make-directory snipetts:snipetts-directory))
  (directory-files2 snippets:snippet-directory))

(defun snippets-util:insert-snippet (candidate)
  (let1 fpath (concat snippets:snippet-directory "/" candidate)
    (save-restriction
      (narrow-to-region (point) (point))
      (insert-file-contents fpath)
      (goto-char (point-max)))))

(defvar snippets:anything-c-source
  '((name . "python snippets")
    (candidates . snippets:snippets-candidates)
    (action
     ("insert" . snippets-util:insert-snippet))
    (persistent-action . snippets-util:insert-snippet)))

(defun anything-snippets () (interactive)
  (anything-other-buffer 'snippets:anything-c-source
                         "*python snippets*"))

(provide 'snippets)