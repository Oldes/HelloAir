name:  %HelloAir
appid: @com.amanitadesign.TestAmanitaAndroidANE

AIR_SDK:     %/C/Dev/SDKs/AIRSDK/
ANDROID_SDK: %/C/Users/oldes/AppData/Local/Android/Sdk
BUNDLETOOL:  %/C/Dev/bundletool-all-1.15.6.jar ;;-> https://github.com/google/bundletool/releases

;--- ADT configuration                                   
manifest: %application-v33.xml
root: %Data/
content: [
	%main.swf
	%icons/*
]
assetPacks: [
	%assetpack1
	%assetpack2
	%assetpack3
]

certificate: [
	keystore:  %certificate.keystore
	alias:     "1"
	storetype: 'jks
	storepass: "qwerty"
]
extdir:   %Extensions

;--- MXMLC configuration                                 
flex-config: [
	metadata: [
		title: "Hello Air Test Application"
		publisher: "Oldes"
		creator:   "Oldes' Rebol"
		language:  EN
	]
	;target-player: 23.0
	compiler: [
		configs: [
			debug:   false
			release: true
			air:     true
			mobile:  true
			desktop: false
			test_permissions: false
			test_hello:       true
			test_assets:      true
			test_system:      true
			test_google:      true
		]
		optimize: true
		omit-trace-statements: false
		verbose-stacktraces: true
		source-path: [%Source]
		external-library-path: [
			%Extensions/tech.oldes.hello.ane
			%Extensions/tech.oldes.permissions.ane
			%Extensions/tech.oldes.system.ane
			%Extensions/tech.oldes.GooglePlay.ane
			%Extensions/tech.oldes.GooglePlayAssets.ane
		]
	]
	file-specs: [%Source\Main.as]
	default-background-color: #FFFFFF
	default-frame-rate:       30
	default-size:             480x762
]