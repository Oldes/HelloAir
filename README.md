# HelloAir
Simple AIR app for testing native extensions

This project uses [Rebol](https://github.com/Oldes/Rebol3/) to [make the build](https://github.com/Oldes/HelloAir/blob/main/build.r3), but even without Rebol it may be built in 2 steps using these commands (on Windows):
### Building a SWF file
```
java -Dsun.io.useCanonCaches=false -Xms32m -Xmx512m ^
  -Dflexlib=C:\Dev\SDKs\AIRSDK\frameworks ^
  -jar C:\Dev\SDKs\AIRSDK\lib\mxmlc-cli.jar ^
  -load-config=C:\Dev\SDKs\AIRSDK\frameworks\air-config.xml ^
  -load-config+=swf-config.xml +configname=air ^
  -advanced-telemetry=false ^
  -o Data\main.swf
```
### Building an AAB file
```
java -jar C:\Dev\SDKs\AIRSDK\lib\adt.jar ^
  -package -target aab ^
  -storetype jks -keystore certificate.keystore -alias 1 -storepass qwerty ^
  Build\HelloAir.aab ^
  application-v33.xml ^
  Data\main.swf Data\icons\* ^
  assetpack1 assetpack2 assetpack3 ^
  -extdir Extensions ^
  -platformsdk C:\Users\oldes\AppData\Local\Android\Sdk
```

In case anybody wants to test it, IDs and credentials must be changed!
