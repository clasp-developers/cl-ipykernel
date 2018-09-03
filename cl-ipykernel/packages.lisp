
(defpackage #:cl-ipykernel
  (:use #:cl)
  (:shadow #:open #:close)
  (:import-from :fredokun-utilities #:[] #:[]-contains)
  (:export
   #:session.send
   #:extract-message-content
   #:with-error-handling
   #:json-clean
   #:print-as-python
   #:as-python
   #:comm
   #:open
   #:close
   #:on-msg
   #:send
   #:make-comm-manager
   #:*kernel-comm-managers*
   #:comm-id
   #:register-target
   #:unregister-target
   #:register-comm
   #:unregister-comm
   #:comm.__init__
   #:get-comm
   #:comm-open
   #:comm-msg
   #:comm-close
   ))
