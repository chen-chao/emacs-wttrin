[![MELPA][melpa-badge]][melpa-package]
[![MELPA Stable][melpa-stable-badge]][melpa-stable-package]
[![Gitter][gitter-badge]][gitter-chatroom]
[![Build Status][travis-ci-badge]][travis-ci-status]

# wttrin.el

Emacs frontend for weather web service [wttr.in].

## Usage

### show in a buffer

Set a default cities list for completion:

```elisp
(setq wttrin-default-cities '("Taipei" "Tainan"))
```

You can also specify default HTTP request Header for Accept-Language:

```elisp
(setq wttrin-default-accept-language '("Accept-Language" . "zh-TW"))
```

Then run `M-x wttrin` to get the information.

When the weather is displayed you can press `q` to quit the buffer or `g` to query for another city.

![screenshot]


### show in the mode line

You can also choose to show the weather information in the mode
line(only works in Emacs 26.1+ for thread support):

```elisp
(setq wttrin-mode-line-city "Taipei") ;; nil for automatically chosen by wttr.in
(setq wttrin-mode-line-time-interval 3600) ;; updating interval in seconds 
(wttrin-display-weather-in-mode-line)
```

The query will run in a thread silently. You should have fonts that
supported unicode emojis installed to show the unicode weather
characters correctly. Consider [Symbola] if you don't have one.

Specify `wttrin-mode-line-format` to change the one-line output format of
wttr.in, see [wttr.in#one-line-output].


## LICENSE

MIT

[wttr.in]: http://wttr.in/
[wttr.in#one-line-output]: https://github.com/chubin/wttr.in#one-line-output
[Symbola]: http://users.teilar.gr/~g1951d/
[screenshot]: wttrin.png
[melpa-badge]: http://melpa.org/packages/wttrin-badge.svg
[melpa-package]: http://melpa.org/#/wttrin
[melpa-stable-badge]: http://stable.melpa.org/packages/wttrin-badge.svg
[melpa-stable-package]: http://stable.melpa.org/#/wttrin
[gitter-badge]: https://badges.gitter.im/bcbcarl/emacs-wttrin.svg
[gitter-chatroom]: https://gitter.im/bcbcarl/emacs-wttrin?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge
[travis-ci-badge]: https://travis-ci.org/bcbcarl/emacs-wttrin.svg?branch=master
[travis-ci-status]: https://travis-ci.org/bcbcarl/emacs-wttrin
