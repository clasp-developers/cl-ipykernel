
(defpackage #:cl-ipykernel
  (:use #:cl)
  (:shadow #:open #:close)
  (:export
   #:comm
   #:open
   #:close
   #:send
   ))
