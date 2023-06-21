;;; ramblehead's eldoc configuration

(defun rh-eldoc-minibuffer-message-with-ellipsis
    (oldfun format-string &rest args)
  "Wrapper function that combines original `eldoc-minibuffer-message` behavior
with ellipsis truncation."
  (let* ((message-string (apply #'format (or format-string "") args))
         (first-line (car (split-string message-string "\n")))
         (max-length (- (frame-width) 3)))
    (if (<= (length first-line) max-length)
        (apply oldfun first-line args)
      (funcall oldfun (format "%s..." (substring first-line 0 max-length))))))

(advice-add
 'eldoc-minibuffer-message
 :around #'rh-eldoc-minibuffer-message-with-ellipsis)

(provide 'config-eldoc)
