
(defpackage #:cl-ipykernel
  (:use #:cl)
  (:shadow #:open #:close)
  (:export
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
