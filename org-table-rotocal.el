;;; org-rotocal.el --- rotate rows and columns in compact calendar table

;; Copyright (C) 2020 kleymik

;; Author: kleymik <kleymik@btinternet.com>
;; Keywords: org-mode table

;; This file is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 3, or (at your option)
;; any later version.

;; This file is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to
;; the Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Commentary:
;;
;; transferred the elegantly compact "one page calendar" from dave bakker
;; https://davebakker.io/onepagecalendar/ (found as link on Hacker News)
;; tweaked:
;;  - column with current month is manually placed of left hand side of dates-block
;;  - column with next month is manually placed of right hand side of dates-block
;; then added small "rotation" feature org-table-rotocal-move-date-topleft:
;;  - rotate selected date (where cursor is) block rows and columns so that the date
;;    is in top left corner
;;
;;       2020
;;        <---- dates-block ---->
;; |-----+---+----+----+----+----+-----+-----+-----+-----+-----+-----|
;; | Jul |   |    |    |    |    |     |     |     |     |     |     |
;; | Apr |   |    |    |    |    | Feb | Mar |     |     | Sep |     |
;; | JAN | a |  b |  c |  d |  e | Aug | Nov | May | Jun | Dec | Oct |
;; |-----+---+----+----+----+----+-----+-----+-----+-----+-----+-----|
;; | Thu | 2 |  9 | 16 | 23 | 30 | SUN | Mon | SAT | Tue | Wed | Fri |
;; | Fri | 3 | 10 | 17 | 24 | 31 | Mon | Tue | SUN | Wed | Thu | SAT |
;; | SAT | 4 | 11 | 18 | 25 |    | Tue | Wed | Mon | Thu | Fri | SUN |
;; | SUN | 5 | 12 | 19 | 26 |    | Wed | Thu | Tue | Fri | SAT | Mon |
;; | Mon | 6 | 13 | 20 | 27 |    | Thu | Fri | Wed | SAT | SUN | Tue |
;; | Tue | 7 | 14 | 21 |    | 28 | Fri | SAT | Thu | SUN | Mon | Wed |
;; | Wed | 1 |  8 | 15 | 22 | 29 | SAT | SUN | Fri | Mon | Tue | Thu |
;; |-----+---+----+----+----+----+-----+-----+-----+-----+-----+-----|
;;        <---- dates-block ---->

;;; Installation:
;;
;; 1) Copy org-rotocal.el to your load-path and add to your .emacs:
;; 2) (require 'org-rotocal)
;; 3) manually create a table such as above
;; 4) position cursor on a date in the dates-block

;;; History:
;;
;; 2020-01-01
;;      * initial version 0.1

;;; Code:

;; for debugging only replace dotimes with dotimes-slow, so that sit-for pausing
;; animates each step of the table manipulation
;; (macroexpand '(dotimes-slow (r row-delta) (previous-line)))

(defmacro dotimes-slow (exp1 exp2) (list 'dotimes exp1 (list 'progn exp2 '(sit-for 0.5))))

(defun org-table-rotocal-move-date-topleft (&optional row-shift col-shift)
    "in dates-block of the table:
      rotate dates-block rows until current date is in top column
      and    dates-block columns until current date is in leftmost column
     with args rotate dates-block rows and columns as specified by args"
    (interactive "P")
    (let* ((row-shift (if row-shift row-shift 4))
           (cur-row (org-table-current-dline))    ; row of cursor position
           (row-delta (- cur-row row-shift))      ; e.g. 6 6-4 => dotimes 2

           (col-shift (if col-shift col-shift 2))
           (cur-col (org-table-current-column))   ; column of cursor position
           (col-delta (- cur-col col-shift)))     ; e.g. 5 5-2 => dotimes 3

      (if (and (<= cur-row 10) (<= cur-col 6))
          (progn
            (message (concat "CUR ROW=" (number-to-string cur-row) ", RDELTA=" (number-to-string row-delta)))
            (message (concat "CUR COL=" (number-to-string cur-col) ", CDELTA=" (number-to-string col-delta)))

            ;; move cursor to top row of dates-block, lefmost column of dates-block
            (dotimes-slow (r row-delta) (previous-line))
            (dotimes-slow (c col-delta) (org-table-previous-field))

            ;; rotate selected row to top
            (dotimes (r row-delta)
              (dotimes-slow (x 6) (org-table-move-row))   ; move top column to bottom
              (dotimes-slow (x 6) (previous-line)))       ; put cursor back to home = top-left of block

            ;; rotate selected column to left
            (dotimes (c col-delta)
              (dotimes-slow (x 4) (org-table-move-column))
              (dotimes-slow (x 4) (org-table-previous-field)))
            )
        (message (concat "Outside dates-block CUR ROW=" (number-to-string cur-row) "CUR COL=" (number-to-string cur-col))))))


