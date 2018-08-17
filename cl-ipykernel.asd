(asdf:defsystem #:cl-ipykernel
  :description "Jupyter kernel for cl-jupyter"
  :version "1.0"
  :author "Kevin Esslinger, Alex Wood, and Christian Schafmeister"
  :license "BSD 2-Clause. See LICENSE."
  :depends-on (:cl-jupyter
               :closer-mop)
  :serial t
  :pathname "cl-ipykernel"
  :components (
               (:file "packages")
	       (:file "tools")
               (:module ikernel
                :pathname "comm"
                :serial t
                :components ((:file "manager")
                             (:file "comm")))))
