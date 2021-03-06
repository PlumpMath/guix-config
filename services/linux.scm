;;; linux.scm --- Linux services

;; Copyright © 2015, 2016 Alex Kost

;; Author: Alex Kost <alezost@gmail.com>
;; Created: 14 Feb 2015

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Various services related to Linux kernel.

;;; Code:

(define-module (al guix services linux)
  #:use-module (gnu services)
  #:use-module (gnu services shepherd)
  #:use-module (guix gexp)
  #:use-module (gnu packages linux)
  #:export (keycodes-service
            keycodes-from-file-service))

(define keycodes-service-type
  (shepherd-service-type
   'keycodes
   (lambda (args)
     (shepherd-service
      (documentation "Map some missing scancodes (setkeycodes).")
      (provision '(keycodes))
      (start #~(lambda _
                 (zero? (apply system*
                               (string-append #$kbd "/bin/setkeycodes")
                               #$args))))
      (respawn? #f)))))

(define (keycodes-service . args)
  "Map scancodes to keycodes using 'setkeycodes' command.
ARGS are passed to 'setkeycodes'."
  (service keycodes-service-type args))

(define keycodes-from-file-service-type
  (shepherd-service-type
   'keycodes-from-file
   (lambda (file)
     (shepherd-service
      (documentation "Map some missing scancodes (setkeycodes).")
      (provision '(keycodes))
      (start #~(lambda _
                 (let* ((port (open-input-file #$file))
                        (args (read port)))
                   (close-port port)
                   (zero? (apply system*
                                 (string-append #$kbd "/bin/setkeycodes")
                                 args)))))
      (respawn? #f)))))

(define (keycodes-from-file-service file)
  "Map scancodes to keycodes using 'setkeycodes' command.
Read a list of arguments that should be passed to 'setkeycodes' from a
scheme FILE."
  (service keycodes-from-file-service-type file))

;;; linux.scm ends here
