(in-package #:cl-ipykernel)


(defvar *debug-cl-ipywidgets* nil)

(eval-when (:execute :load-toplevel)
  (setf *debugger-hook*
	#'(lambda (condition &rest args)
	    (cl-jupyter:logg 0 "~a~%" condition)
	    (cl-jupyter:logg 0 "~a~%" (with-output-to-string (sout) (trivial-backtrace:print-backtrace-to-stream sout))))))

(defmacro with-error-handling (msg &body body)
  (let ((wrn (gensym))
	(err (gensym)))
    `(handler-case
	 (handler-bind
	     ((simple-warning
	       #'(lambda (,wrn)
		   (format *error-output* "~&~a ~A: ~%" ,msg (class-name (class-of ,wrn)))
		   (apply (function format) *error-output*
			  (simple-condition-format-control   ,wrn)
			  (simple-condition-format-arguments ,wrn))
		   (format *error-output* "~&")
		   (muffle-warning)))
	      (warning
	       #'(lambda (,wrn)
		   (format *error-output* "~&~a ~A: ~%  ~A~%"
			   ,msg (class-name (class-of ,wrn)) ,wrn)
		   (muffle-warning)))
	      (serious-condition
	       #'(lambda (,err)
		   (format t "!!!!! A serious condition was encountered in with-error-handling - check log~%")
		   (finish-output)
		   (cl-jupyter:logg 0 "~a~%" ,msg)
		   (cl-jupyter:logg 0 "An error occurred of type ~a~%" (class-name (class-of ,err)))
;;		   (cl-jupyter:logg 0 "~a~%" ,err)
		   (cl-jupyter:logg 0 "~a~%" (with-output-to-string (sout) (trivial-backtrace:print-backtrace-to-stream sout))))))
	   (progn ,@body))
       (simple-condition (,err)
	 (format *error-output* "~&~A: ~%" (class-name (class-of ,err)))
	 (apply (function format) *error-output*
		(simple-condition-format-control   ,err)
		(simple-condition-format-arguments ,err))
	 (format *error-output* "~&"))
       (serious-condition (,err)
	 (format *error-output* "~&2An error occurred of type: ~A: ~%  ~S~%"
		 (class-name (class-of ,err)) ,err)))))

(defun json-clean (json)
  json)

(defparameter *python-indent* 0)
(defparameter *sort-encoded-json* nil)

(defun print-as-python (object stream &key indent)
  (let ((*sort-encoded-json* t))
    (myjson::encode-json stream object :indent indent)))

(defun as-python (msg)
  (with-output-to-string (sout)
    (print-as-python msg sout)))


(defun session.send (session
                     stream
                     msg-or-type
                     &key content parent ident (buffers #()) track header metadata)
  (check-type buffers array)
  (progn
    (cl-jupyter:logg 2 "---------------send-comm-message~%")
    (cl-jupyter:logg 2 "         session  -> ~s~%" session)
    (cl-jupyter:logg 2 "stream(or socket) -> ~s~%" stream)
    (cl-jupyter:logg 2 "      msg-or-type -> ~s~%" msg-or-type)
    (cl-jupyter:logg 2 "          content -> ~s~%" content)
    (cl-jupyter:logg 2 "           parent -> ~s~%" parent)
    (cl-jupyter:logg 2 "           (message-header parent) -> ~s~%" (cl-jupyter:message-header parent))
    (cl-jupyter:logg 2 "                  (header-msg-type (message-header parent)) -> ~s~%" (cl-jupyter::header-msg-type (cl-jupyter::message-header parent)))
    (cl-jupyter:logg 2 "            ident -> ~s~%" ident)
    (cl-jupyter:logg 2 " (length buffers) -> ~s~%" (length buffers))
    (cl-jupyter:logg 2 "            track -> ~s~%" track)
    (cl-jupyter:logg 2 "           header -> ~s~%" header)
    (cl-jupyter:logg 2 "         metadata -> ~s~%" metadata))
  (let ((track (streamp stream))
        msg msg-type)
    (if (typep msg-or-type '(or cl-jupyter::message list))
        (setf msg msg-or-type
              buffers (cond
		       (buffers buffers)
		       ((typep msg-or-type cl-jupyter:message)
			(cl-jupyter:message-buffers msg-or-type))
		       (t (error "How do I get buffers out of the object ~s" msg-or-type)))
              msg-type (cl-jupyter::header-msg-type (cl-jupyter:message-header parent)))
      (setf msg (cl-jupyter::make-message parent msg-or-type metadata content buffers)
	    msg-type msg-or-type)
      )
    (progn
      (cl-jupyter:logg 2 "          msg -> ~s~%" msg)
      (cl-jupyter:logg 2 "          msg-type -> ~s~%" msg-type))
;;; Check the PID  and compare to os.getpid - warn if sending message from fork and return
    ;; buffers = [] if buffers is None else buffers
    ;; ensure that buffers support memoryview buffer protocol
    (cl-jupyter:logg 2 "session.send ident -> ~s~%" ident)
    (prog1
        (let ((socket (cl-jupyter::iopub-socket stream)))
          (cl-jupyter:logg 2 "About to do message-send msg=|~s|~%" msg)
          (cl-jupyter::message-send socket msg :identities
				    (list (babel:string-to-octets ident)) :key (cl-jupyter::kernel-key cl-jupyter::*shell*)))
      (cl-jupyter:logg 2 "Done with message-send~%"))))


(defun extract-message-content (msg)
  (myjson:parse-json-from-string (cl-jupyter:message-content msg)))

