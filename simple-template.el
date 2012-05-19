;; slack-off template
;;variable ${foo}

(defun st:rendering (env-map template-string)
  (with-temp-buffer
    (insert template-string)
    (goto-char (point-min))

    (while (re-search-forward "${" nil t 1)
      (let ((before (match-beginning 0)))
        (let ((target (st:bite-variable)))
          (goto-char before)
          (delete-char (length target))
          (insert (gethash target env-map "")))))

    (buffer-string)))

(lexical-let
    ((left (string-to-char "{"))
     (right (string-to-char "}")))
  (defun st:bite-variable ()
    (catch 'end-of-buffer
      (let ((braces 1))
        (progn
          (let ((before (match-beginning 0)))
            (while (< 0 braces)
              (forward-char 1)
              (let ((c (char-after)))
                (unless c
                  (throw 'end-of-buffer nil))
                (when (char-equal c left)
                  (incf braces))
                (when (char-equal c right)
                  (decf braces))))
            (buffer-substring-no-properties before (1+ (point)))))))))
  
(defun st:find-variables ()
  (let ((env-map (make-hash-table :test 'equal)))
    (save-excursion
      (goto-char (point-min))

      (while (re-search-forward "${" nil t 1)
        (let ((matched-val-name (st:bite-variable)))
          (unless (gethash matched-val-name env-map nil)
            (let ((val (st:hear-variable-value matched-val-name)))
              (puthash matched-val-name val env-map)))))
      env-map)))
  
(defun st:hear-variable-value (prompt) (interactive)
  (read-string (concat prompt ": ")))

(defun simple-template (fname) (interactive "f")
  (let ((buf (find-file-noselect fname))
        (marker (point-marker)))
    (let ((dwindow (display-buffer buf)))
      (let ((content (simple-template:rendering buf)))
        (delete-window dwindow)
        (when (equal (current-buffer)
                     (marker-buffer marker))
          (goto-char (marker-position marker))
          (insert content))))))
    ;; 
(defun simple-template:insert (fname) (interactive "f")
  (insert
   (simple-template:rendering fname)))

(defun* simple-template:rendering (buf &key env)
  (let ((buf (if (stringp buf) (find-file-noselect buf) buf)))
    (with-current-buffer buf
      (let ((env-map 
             (if env
                 (let ((ht (make-hash-table :test 'equal)))
                   (loop for (k . v) in env do (puthash k v ht))
                   ht)
             (st:find-variables)))
            (template-string (buffer-string)))
        (st:rendering env-map template-string)))))

