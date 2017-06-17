(in-package :graphic-forms.uitoolkit.graphics.default)

(eval-when (:compile-toplevel :load-toplevel :execute)
  (use-package :com.gigamonkeys.binary-data))

;;;
;;; fundamental binary types used by image definitions
;;;

;; This utility was copied from Peter Seibel's id3v2 package,
;; renamed to signify that it is for big-endian values.
;;
(define-binary-type unsigned-integer-be (bytes bits-per-byte)
  (:reader (in)
    (loop with value = 0
       for low-bit downfrom (* bits-per-byte (1- bytes)) to 0 by bits-per-byte do
         (setf (ldb (byte bits-per-byte low-bit) value) (read-byte in))
       finally (return value)))
  (:writer (out value)
    (loop for low-bit downfrom (* bits-per-byte (1- bytes)) to 0 by bits-per-byte
       do (write-byte (ldb (byte bits-per-byte low-bit) value) out))))

;; This utility is based on the same unsigned-integer binary type,
;; but this one is for little-endian types.
;;
(define-binary-type unsigned-integer-le (bytes bits-per-byte)
  (:reader (in)
    (loop with value = 0
       for low-bit from 0 to (* bits-per-byte (1- bytes)) by bits-per-byte do
         (setf (ldb (byte bits-per-byte low-bit) value) (read-byte in))
       finally (return value)))
  (:writer (out value)
    (loop for low-bit from 0 to (* bits-per-byte (1- bytes)) by bits-per-byte
       do (write-byte (ldb (byte bits-per-byte low-bit) value) out))))

;;; aliases for single-byte and 32-bit types with names
;;; matching the GDI docs
;;;
(define-binary-type BYTE       () (unsigned-integer-le :bytes 1 :bits-per-byte 8))
(define-binary-type DWORD      () (unsigned-integer-le :bytes 4 :bits-per-byte 8))
(define-binary-type FXPT2DOT30 () (unsigned-integer-le :bytes 4 :bits-per-byte 8))
(define-binary-type LONG       () (unsigned-integer-le :bytes 4 :bits-per-byte 8))
(define-binary-type WORD       () (unsigned-integer-le :bytes 2 :bits-per-byte 8))

;;;
;;; Win32 GDI Bitmap Formats
;;;

(define-binary-class BITMAPFILEHEADER ()
  ((bfType      WORD)
   (bfSize      DWORD)
   (bfReserved1 WORD)
   (bfReserved2 WORD)
   (bfOffBits   DWORD)))

(define-binary-class CIEXYZ ()
  ((ciexyzX FXPT2DOT30)
   (ciexyzY FXPT2DOT30)
   (ciexyzZ FXPT2DOT30)))

(define-binary-class CIEXYZTRIPLE ()
  ((ciexyzRed   CIEXYZ)
   (ciexyzGreen CIEXYZ)
   (ciexyzBlue  CIEXYZ)))

(define-tagged-binary-class BASE-BITMAPINFOHEADER ()
  ((biSize          DWORD)
   (biWidth         LONG)
   (biHeight        LONG)
   (biPlanes        WORD)
   (biBitCount      WORD)
   (biCompression   DWORD)
   (biSizeImage     DWORD)
   (biXPelsPerMeter LONG)
   (biYPelsPerMeter LONG)
   (biClrUsed       DWORD)
   (biClrImportant  DWORD))
  (:dispatch
    (ecase biSize
      (40  'BITMAPINFOHEADER)
      (120 'BITMAPV4HEADER)
      (124 'BITMAPV5HEADER))))

(define-binary-class BITMAPINFOHEADER (BASE-BITMAPINFOHEADER) ())

(define-binary-class BITMAPV4HEADER (BASE-BITMAPINFOHEADER)
  ((bv4RedMask    DWORD)
   (bv4GreenMask  DWORD)
   (bv4BlueMask   DWORD)
   (bv4AlphaMask  DWORD)
   (bv4CSType     DWORD)
   (bv4Endpoints  CIEXYZTRIPLE)
   (bv4GammaRed   DWORD)
   (bv4GammaGreen DWORD)
   (bv4GammaBlue  DWORD)))

(define-binary-class BITMAPV5HEADER (BITMAPV4HEADER)
  ((bv5Intent      DWORD)
   (bv5ProfileData DWORD)
   (bv5ProfileSize DWORD)
   (bv5Reserved    DWORD)))

(define-binary-class RGBQUAD ()
  ((rgbBlue     BYTE)
   (rgbGreen    BYTE)
   (rgbRed      BYTE)
   (rgbReserved BYTE)))

;;;
;;; Win32 GDI Icon Formats
;;;

(define-binary-class ICONDIR ()
  ((idReserved WORD)
   (idType     WORD)
   (idCount    WORD))) ; ICONDIRENTRY array read separately

(define-binary-class ICONDIRENTRY ()
  ((ideWidth       BYTE)
   (ideHeight      BYTE)
   (ideColorCount  BYTE)
   (ideReserved    BYTE)
   (idePlanes      WORD)
   (ideBitCount    WORD)
   (ideBytesInRes  DWORD)
   (ideImageOffset DWORD)))
