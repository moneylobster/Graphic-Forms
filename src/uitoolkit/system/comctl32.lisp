(in-package :graphic-forms.uitoolkit.system)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (use-package :cffi))

(load-foreign-library "comctl32.dll")

;;; See this thread:
;;;
;;;  http://common-lisp.net/pipermail/cffi-devel/2006-December/000971.html
;;;
;;; for a discussion of why the following is commented out.
;;;
#|
(defcfun
  ("DllGetVersion" comctl-dll-get-version)
  HRESULT
  (info :pointer))
|#

(defcfun
  ("InitCommonControlsEx" init-common-controls)
  BOOL
  (init LPTR))
