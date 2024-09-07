{pkgs}:
/*
kbd
*/
''
  #|(defcfg
  	danger-enable-cmd yes
  )|#

  (defalias
  	esc-ctrl (tap-hold 100 100 esc lctrl)

  	;; held-meta-layer (layer-while-held meta-layer)

  	;; terminal (cmd ${pkgs.alacritty}/bin/alacritty)
  	;; browser (cmd ${pkgs.brave}/bin/brave)
  )

  (defsrc
  	caps

  	;; c
  	;; b

  	;; lmet
  )

  (deflayer default
  	@esc-ctrl

  	;; c
  	;; b

  	;; (multi @held-meta-layer lmet)
  )

  #|(deflayer meta-layer
  	_

  	@terminal
  	@browser

  	_
  )|#
''
