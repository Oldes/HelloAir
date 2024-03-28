;;   ____  __   __        ______        __
;;  / __ \/ /__/ /__ ___ /_  __/__ ____/ /
;; / /_/ / / _  / -_|_-<_ / / / -_) __/ _ \
;; \____/_/\_,_/\__/___(@)_/  \__/\__/_// /
;;  ~~~ oldes.huhuman at gmail.com ~~~ /_/
;;
;; SPDX-License-Identifier: Apache-2.0
Rebol [
	Title: "Build Hello AIR app"
	Purpose: "For testing native extensions"
]

import airsdk ;== https://github.com/Oldes/Rebol-AIRSDK

;air-task "Build icon res" [make-icon-res %Resources/ %test-icon.png]

write airsdk:config.reb [
	make-swf
	make-aab
;	local-test
;	extract-apk
;	make-android-project
]
