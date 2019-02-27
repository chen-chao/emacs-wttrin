;;; wttrin.el --- Emacs frontend for weather web service wttr.in
;; Copyright (C) 2016 Carl X. Su

;; Author: Carl X. Su <bcbcarl@gmail.com>
;;         ono hiroko (kuanyui) <azazabc123@gmail.com>
;; Version: 0.2.0
;; Package-Requires: ((emacs "24.4") (xterm-color "1.0"))
;; Keywords: comm, weather, wttrin
;; URL: https://github.com/bcbcarl/emacs-wttrin

;;; Commentary:

;; Provides the weather information from wttr.in based on your query condition.

;;; Code:

(require 'url)
(require 'xterm-color)
(require 'timer)

(defgroup wttrin nil
  "Emacs frontend for weather web service wttr.in."
  :prefix "wttrin-"
  :group 'comm)

(defcustom wttrin-default-cities '("Taipei" "Keelung" "Taichung" "Tainan")
  "Specify default cities list for quick completion."
  :group 'wttrin
  :type 'list)

(defcustom wttrin-default-accept-language '("Accept-Language" . "en-US,en;q=0.8,zh-CN;q=0.6,zh;q=0.4")
  "Specify default HTTP request Header for Accept-Language."
  :group 'wttrin
  :type '(list)
  )

(defcustom wttrin-mode-line-city nil
  "Specify default city for displaying weather in mode line.
nil for automatically chosen by wttr.in."
  :group 'wttrin
  :type 'string
  )

(defcustom wttrin-mode-line-format "format=\"%l:+%c %t %w\""
  "Specify default information format for querying wttr.in"
  :group 'wttrin
  :type 'string
  )

(defcustom wttrin-mode-line-time-interval 3600
  "Speify the updating interval of querying weather information in seconds."
  :group 'wttrin
  :type 'number
  )

(defvar wttrin-mode-line-timer nil)

(defvar wttrin-weather-string nil
  "String used in mode lines to display the weather
It should not be set directly, but is instead updated by the
`wttrin-display-weather-in-mode-line' function.")
;;;###autoload(put 'wttrin-weather-string 'risky-local-variable t)

(defun wttrin-fetch-raw-string (query)
  "Get the weather information based on your QUERY."
  (let ((url-request-extra-headers '(("User-Agent" . "curl"))))
    (add-to-list 'url-request-extra-headers wttrin-default-accept-language)
    (with-current-buffer
        (url-retrieve-synchronously
         (concat "http://wttr.in/" query)
         (lambda (status) (switch-to-buffer (current-buffer))))
      (decode-coding-string (buffer-string) 'utf-8))))

(defun wttrin-fetch-info (&optional city-name format)
  "Fetch the weather information by city name and query format."
  (let* ((city (or city-name ""))
	 (query-string (if format
			   (concat city "?" format)
			 city))
	 (raw-string (wttrin-fetch-raw-string query-string))
	 (pos (+ 2 (string-match "^$" raw-string)))  ; get rid of the quotation marks
	 (msg (substring raw-string pos -2))
	 )
    msg)
)

(defun wttrin-info-update ()
  (let ((city (or wttrin-mode-line-city ""))
	(format wttrin-mode-line-format))
    (condition-case ()
	(setq weather-info (wttrin-fetch-info city format))
      (error "")
      )
    (setq wttrin-weather-string weather-info)
    )
  (force-mode-line-update)
  )

(defun wttrin-display-weather-in-mode-line ()
  (and wttrin-mode-line-timer (cancel-timer wttrin-mode-line-timer))
  (setq wttrin-mode-line-timer nil)
  (setq wttrin-weather-string "")
  (or global-mode-string (setq global-mode-string '("")))
  (or (memq 'wttrin-weather-string global-mode-string)
      (setq global-mode-string
	    (append global-mode-string '(wttrin-weather-string))))
  (setq wttrin-mode-line-timer
	(run-with-timer 0 wttrin-mode-line-time-interval
			(lambda () (make-thread 'wttrin-info-update))))
  ;; (wttrin-info-update)
  )

(defun wttrin-cancel-display-in-mode-line ()
  (interactive)
  (and wttrin-mode-line-timer (cancel-timer wttrin-mode-line-timer))
  (setq wttrin-mode-line-timer nil)
  (setq wttrin-weather-string "")
  (delete 'wttrin-weather-string global-mode-string)
  (force-mode-line-update)
  )

(defun wttrin-exit ()
  (interactive)
  (quit-window t))

(defun wttrin-query (city-name)
  "Query weather of CITY-NAME via wttrin, and display the result in new buffer."
  (let ((raw-string (wttrin-fetch-raw-string city-name)))
    (if (string-match "ERROR" raw-string)
        (message "Cannot get weather data. Maybe you inputed a wrong city name?")
      (let ((buffer (get-buffer-create (format "*wttr.in - %s*" city-name))))
        (switch-to-buffer buffer)
        (setq buffer-read-only nil)
        (erase-buffer)
        (insert (xterm-color-filter raw-string))
        (goto-char (point-min))
        (re-search-forward "^$")
        (delete-region (point-min) (1+ (point)))
        (use-local-map (make-sparse-keymap))
        (local-set-key "q" 'wttrin-exit)
        (local-set-key "g" 'wttrin)
        (setq buffer-read-only t)))))

;;;###autoload
(defun wttrin (city)
  "Display weather information for CITY."
  (interactive
   (list
    (completing-read "City name: " wttrin-default-cities nil nil
                     (when (= (length wttrin-default-cities) 1)
                       (car wttrin-default-cities)))))
  (wttrin-query city))

(provide 'wttrin)

;;; wttrin.el ends here
