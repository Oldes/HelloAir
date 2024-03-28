//   ____  __   __        ______        __
//  / __ \/ /__/ /__ ___ /_  __/__ ____/ /
// / /_/ / / _  / -_|_-<_ / / / -_) __/ _ \
// \____/_/\_,_/\__/___(@)_/  \__/\__/_// /
//  ~~~ oldes.huhuman at gmail.com ~~~ /_/
//
// SPDX-License-Identifier: Apache-2.0
package
{
	import flash.desktop.NativeApplication;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.ErrorEvent;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	import flash.display.StageScaleMode;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	import flash.ui.Multitouch;
	import flash.ui.MultitouchInputMode;
	import flash.utils.ByteArray;
	import flash.utils.setTimeout;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	import tech.oldes.system.SystemExtension;
	import tech.oldes.system.events.AlertDialogEvent;
	import tech.oldes.system.events.StateChangedEvent;

	CONFIG::test_hello {
		import tech.oldes.hello.*
	}
	CONFIG::test_permissions {
		import tech.oldes.permissions.*
		import tech.oldes.permissions.events.*
	}
	CONFIG::test_google {
		import tech.oldes.google.GooglePlayExtension;
		import tech.oldes.google.GooglePlayEvent;
	}
	CONFIG::test_assets {
		import tech.oldes.google.PlayAssetsExtension;
		import tech.oldes.google.PlayAssetsStatus;
		import tech.oldes.google.events.PlayAssetsEvent;
		import tech.oldes.google.events.PlayAssetsException;
		import tech.oldes.google.events.PlayAssetsExecutionException;
	}

	public class Main extends Sprite 
	{
		public  var tf:TextField;
		private var nextBtnX:Number = 20;
		private static const MainOBBVersion:int = 1006;
		private var dialogId:int;

		private static const QUESTION_NOT_HAPPY      :int = 1;
		private static const QUESTION_RETRY_DOWNLOAD :int = 2;

		CONFIG::test_hello {
			private static const hello:HelloExtension = HelloExtension.instance;
		}
		CONFIG::test_permissions {
			private static const extPerm:PermissionsExtension = PermissionsExtension.instance;
		}
		CONFIG::test_google {
			private static const PlayGames:GooglePlayExtension = GooglePlayExtension.instance;
		}

		CONFIG::test_assets {
			public var assetsState:int = 0;
			public var assets:PlayAssetsExtension;
		}

		private function addButton(label:String, action:Function):void {
			var btn:TextField = new TextField();
			btn.defaultTextFormat = new TextFormat(null, 30, 0xFFFFFF, true);
			btn.background = true;
			btn.backgroundColor = 0xFF0000;
			btn.autoSize = TextFieldAutoSize.CENTER;
			btn.selectable = false;
			btn.text = label;
			
			btn.x = nextBtnX;
			btn.y = stage.stageHeight - btn.height - 60;
			nextBtnX = btn.x + btn.width + 10;
			btn.addEventListener(MouseEvent.CLICK, action);
			stage.addChild(btn);
		}
		
		public function Main() 
		{
			stage.scaleMode = StageScaleMode.NO_SCALE;
			stage.align = StageAlign.TOP_LEFT;
			stage.addEventListener(Event.DEACTIVATE, onDeactivate);
			stage.addEventListener(Event.ACTIVATE, onActivate);
			
			// touch or gesture?
			Multitouch.inputMode = MultitouchInputMode.TOUCH_POINT;
			
			tf = new TextField();
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight;
			tf.wordWrap = true;
			tf.defaultTextFormat = new TextFormat(null, 24);
			addChild(tf);

			//Handle resize
			stage.addEventListener(Event.RESIZE, onResize);
			log("Testing Amanita Android ANE......");
			setTimeout(startTests, 200);
		}
		private function startTests():void {
			CONFIG::test_hello {
				log("\nTesting Hello ANE!");
				log("Hello is: " + HelloExtension.instance );
				if (hello) {
					log("Hello version: " + hello.version + " native: " + hello.nativeVersion);
				}
			}

			CONFIG::test_google {
				log("\nTesting GooglePlay ANE!");
				addButton("SIG?", doGPisSigned);
				addButton("S-IN", doGPsignIn);
				addButton("S-IN2", doGPsilentSignIn);
				addButton("S-OUT", doGPsignOut);
				addButton("ACHs", doGPShowAchievements);
				addButton("LOAD", doGPLoadSnapshot);
				addButton("SAVE", doGPSaveSnapshot);
				addButton("DEL", doGPDeleteSnapshot);

				log("PlayGames is: " + GooglePlayExtension.instance );
				if (PlayGames) {
					log("PlayGames version: " + PlayGames.version + " native: " + PlayGames.nativeVersion);
				}
				PlayGames.addEventListener(GooglePlayEvent.ON_SIGN_IN_SUCCESS, GPSonSignInSuccess);
				PlayGames.addEventListener(GooglePlayEvent.ON_SIGN_OUT_SUCCESS, GPSonSignOutSuccess);
				PlayGames.addEventListener(GooglePlayEvent.ON_SIGN_IN_FAIL, GPSonSignInFail);
				PlayGames.addEventListener(GooglePlayEvent.ON_OPEN_SNAPSHOT_READY, GPSonSnapshotOpen);
				PlayGames.addEventListener(GooglePlayEvent.ON_OPEN_SNAPSHOT_FAILED, GPSonSnapshotOpen);
				PlayGames.signIn();
			}
			
			CONFIG::test_permissions {
				log("\nTesting Permissions ANE!");
				if (extPerm) {
					log("Permissions version: " + extPerm.version + " native: " + extPerm.nativeVersion);
					extPerm.addEventListener(RequestPermissionsResultEvent.ON_REQUEST_PERMISSIONS_RESULT, onRequestPermissionsResult);
					log("PERMISION WRITE: " + extPerm.checkPermission("android.permission.READ_EXTERNAL_STORAGE"));
					requestForPermissions();
				}
			}

			// register shared dialog response listener (use dialogId variable to recognize the question)
			SystemExtension.instance.addEventListener(AlertDialogEvent.ON_ALERT_DIALOG, onAlertDialogResult);

			CONFIG::test_system {
				SystemExtension.instance.addEventListener(StateChangedEvent.ON_STATE_CHANGED, onStateChangedEvent);
				SystemExtension.instance.showToast("Hello Toast!");
				dialogId = QUESTION_NOT_HAPPY;
				SystemExtension.instance.showAlertDialog("Are you happy?");
			}

			CONFIG::test_assets {
				log("\nTesting PlayAssets!");
				try {
					assets = PlayAssetsExtension.instance;
					log("PlayAssetsExtension is: " + PlayAssetsExtension.instance );
					if (assets) {
						log("version: " + assets.version + " native: " + assets.nativeVersion);
					}
					log("Assets: "+assets);
					if (assets.initAssetDelivery()) {
						log("PlayAssetDelivery initialised.");
					 	assets.addEventListener( PlayAssetsExtension.ON_UPDATE, onPlayAssetsUpdate );
					 	assets.addEventListener( PlayAssetsExtension.ON_EXCEPTION, onPlayAssetsException );
					 	assets.addEventListener( PlayAssetsExtension.ON_EXECUTION_EXCEPTION, onPlayAssetsExecutionException );
					 	log("Listening to "+ PlayAssetsEvent.PLAY_ASSET_UPDATE +" events...");
						log("\nfast-follow assets ===================================");
						log("asset_pack2 location: "+ assets.getAssetPackLocation("asset_pack2"));
						assets.fetchAssetsPack("asset_pack2");
						// Don't try to get asset's status or other values..
						// Wait for the PLAY_ASSET_UPDATE event first
					} else {
						log("PlayAssetDelivery unavailable!");
					}
				} catch (e:Error) {
					log("ERROR: "+e);
				}
			}
		}
		
		private function log(value:String):void{
			SystemExtension.instance.systemLog(value);
			tf.appendText(value+"\n");
			tf.scrollV = tf.maxScrollV;
		}
		
		private function onDeactivate(e:Event):void 
		{
			// make sure the app behaves well (or exits) when in background
			//NativeApplication.nativeApplication.exit();
		}
		private function onActivate(e:Event):void 
		{
			CONFIG::test_google {
				//log("== onActivate == silentSignIn");
				//gei.silentSignIn();
			}
		}
		private function onResize(e:Event):void {
			log("onResize: "+stage.stageWidth+"x"+stage.stageHeight);
			tf.width = stage.stageWidth;
			tf.height = stage.stageHeight;

		}
		private function onAlertDialogResult(event:AlertDialogEvent):void {
			//SystemExtension.instance.removeEventListener(AlertDialogEvent.ON_ALERT_DIALOG, onAlertDialogSignOut);
			log("onAlertDialogResult: "+ event);
			if (dialogId == QUESTION_NOT_HAPPY) {
				if (event.value == "no")
					SystemExtension.instance.showToast("Oh no.. so you are sad!");
				else
					SystemExtension.instance.showToast("I'm happy too!");
			}
			else if (dialogId == QUESTION_RETRY_DOWNLOAD) {
				CONFIG::test_assets {
					if (event.value == "yes") downloadOnDemandAsset();
				}
			}
		}
		private function onStateChangedEvent(event:StateChangedEvent):void {
			log("onStateChangedEvent: "+ event);
		}

		CONFIG::test_assets {
			private var exceptionTest:int = 2;
			public function downloadOnDemandAsset(e:MouseEvent=null):void {
				log("\non-demand assets =====================================");
				log("asset_pack3 location: "+ assets.getAssetPackLocation("asset_pack3"));
				if (exceptionTest == 2) {
					log ("Trying to fetch invalid asset pack...");
					assets.fetchAssetsPack("not_exists");
				} else if (exceptionTest == 1) {
					assets.testException(PlayAssetsException.NETWORK_ERROR);
				} else if (assets.getAssetAbsolutePath("asset_pack3", "Univerzal.lvl") != null) {
					log ("asset_pack3 is already downloaded!");
					displayAssetPackContent("asset_pack3", "Univerzal.lvl");
				} else {
					assets.fetchAssetsPack("asset_pack3");
					assetsState = 1;
				}
			}
			public function displayAssetPackContent(pack:String, path:String):void {
				var file:File;
				var fs:FileStream;

				log("Pack: "+ pack +" => "+ path);
				var absolutePath:String = assets.getAssetAbsolutePath(pack, path);
				log("File: "+ absolutePath);

				if (absolutePath == null) {
					log ("File content not found or asset pack does not exists!");
					return;
				}
				file = new File(absolutePath);
				if (file.exists) {
					fs = new FileStream();
					fs.open(file, FileMode.READ);
					if (fs.bytesAvailable > 50) {
						log("bytes: "+ fs.bytesAvailable);
					}
					else {
						log(fs.readUTFBytes( fs.bytesAvailable ));
					}
					fs.close();
				} else {
					log("File not found!");
				}
			}
			public function onPlayAssetsException(event:PlayAssetsException):void {
				log(event.toString());
				var reason:String;
				exceptionTest--;
				switch (event.status) {
					case PlayAssetsException.NETWORK_ERROR:
						reason = "Network error. Unable to obtain the asset pack details.";
						break;
					case PlayAssetsException.INSUFFICIENT_STORAGE:
						reason = "Asset pack download failed due to insufficient storage.";
						break;
					case PlayAssetsException.PLAY_STORE_NOT_FOUND:
						reason = "The Play Store app is either not installed or not the official version.";
						break;
					case PlayAssetsException.NETWORK_UNRESTRICTED:
						return; // this is ok!
					default:
						reason = "Failed to download the asset pack with reason: "+event.statusName;
				}
				SystemExtension.instance.showToast(reason);
				dialogId = QUESTION_RETRY_DOWNLOAD;
				SystemExtension.instance.showAlertDialog("Unable to download game assets.\nTry again?");
				log("statusName: "+event.statusName);
				// handle the response in the onAlertDialogResult function!
			}
			public function onPlayAssetsExecutionException(event:PlayAssetsExecutionException):void {
				exceptionTest--;
				log(event.toString());
			}
			public function onPlayAssetsUpdate( event:PlayAssetsEvent ):void {
				log(event.toString());

				switch (event.status) {
					case PlayAssetsStatus.DOWNLOADING:
						log(event.assetPackName +" bytes: "+ assets.getBytesDownloaded(event.assetPackName) +" / "+assets.getTotalBytesToDownLoad(event.assetPackName));	
						break;
					case PlayAssetsStatus.TRANSFERRING:
						log("percent: "+ assets.getTransferProgressPercentage(event.assetPackName));
						break;
					case PlayAssetsStatus.COMPLETED:
					{
						// An asset pack fetch was completed
						if(event.assetPackName == "asset_pack2" && assetsState == 0) {
							//log("status asset_pack2: "+ assets.getAssetPackStatus("asset_pack2"));
							//log("location: "+ assets.getAssetPackLocation("asset_pack2"));
							displayAssetPackContent("asset_pack2", "Start.lvl");
							displayAssetPackContent("asset_pack2", "Vesmir_A.lvl");
							addButton("ASSET", downloadOnDemandAsset);
						} else if (event.assetPackName == "asset_pack3") {
							displayAssetPackContent("asset_pack3", "Univerzal.lvl");
							assetsState = 2;
							CONFIG::test_google {
								PlayGames.reportAchievement("CgkIzaac840IEAIQAg");
							}
						}
						//assets.removeEventListener( PlayAssetsEvent.PLAY_ASSET_UPDATE, onPlayAssetsUpdate );
						break;
					}
					case PlayAssetsStatus.WAITING_FOR_WIFI:
					case PlayAssetsStatus.REQUIRES_USER_CONFIRMATION:
					{
						assets.showConfirmationDialog();
						break;
					}
				}
			}
		}

		CONFIG::test_google {
			public function doGPsignIn(e:MouseEvent=null):void {
				log("GoogleExtension.instance.signIn()");
				PlayGames.signIn();
			}
			public function doGPsilentSignIn(e:MouseEvent=null):void {
				log("GoogleExtension.instance.silentSignIn()");
				PlayGames.silentSignIn();
			}

			public function doGPsignOut(e:MouseEvent=null):void {
				log("GoogleExtension.instance.signOut()");
				PlayGames.signOut();
			}
			public function doGPisSigned(e:MouseEvent=null):void {
				log("isSignedIn reports: "+PlayGames.isSignedIn());
			}

			public function doGPShowAchievements(e:MouseEvent=null):void {
				log("GoogleExtension.instance.showStandardAchievements()");
				PlayGames.showStandardAchievements();
			}

			private var counter:int = 0;
			public function doGPLoadSnapshot(e:MouseEvent=null):void {
				log("GoogleExtension.instance.openSnapshot(\"test.txt\")");
				PlayGames.openSnapshot("test.txt");
			}
			public function doGPSaveSnapshot(e:MouseEvent=null):void {
				log("GoogleExtension.instance.writeSnapshot(\"test.txt\", ...)");
				var binary:ByteArray = new ByteArray();
				counter++;
				binary.writeInt(counter);
				binary.writeUTFBytes("hello boy");
				PlayGames.writeSnapshot("test.txt", binary, 0);
			}
			public function doGPDeleteSnapshot(e:MouseEvent=null):void {
				log("GoogleExtension.instance.deleteSnapshot(\"test.txt\")");
				counter = 0;
				PlayGames.deleteSnapshot("test.txt");
			}

			private function GPSonSignInSuccess(event:GooglePlayEvent):void {
				log("GPSonSignInSuccess: " + event.value);
				//log("\nOpen snapshot...");
				//PlayGames.openSnapshot("test.txt");
				log("\nTrying to report achievement...");
				PlayGames.reportAchievement("CgkIzaac840IEAIQAQ");
				//log("\nBilling init...");
				//PlayGames.addEventListener(AirBillingEvent.ON_BILLING, OnBilling);
				//PlayGames.billingInit();
			}
			private function GPSonSignOutSuccess(event:GooglePlayEvent):void {
				log("GPSonSignOutSuccess: " + event);
			}
			private function GPSonSignInFail(event:GooglePlayEvent):void {
				log("GPSonSignInFail: " + event.value);
			}

			private function GPSonSnapshotOpen(event:GooglePlayEvent):void {
				var name:String = event.value;
				var msg:String;
				log("GPSonSnapshotOpen: " + name);
				var baCloud:ByteArray = PlayGames.readSnapshot(name);
				if (baCloud) {
					counter = baCloud.readInt();
					msg = baCloud.readUTFBytes(baCloud.length-4);
					log("Snapshot "+counter+" bytes: " + baCloud.length +" "+msg);
				} else {
					log("No data");
				}
			}
			public function GPErrorHandler(e:ErrorEvent):void{
				log("GPErrorHandler: " + e.toString());
			}
		} //CONFIG::test_google


		CONFIG::test_permissions {
		//================================================================================================//
		//== Permissions =================================================================================//
		//================================================================================================//
			private function requestForPermissions():void {
				/** NOTE: you must have the rights in the request specified in application manifest as it was required for SDK < 23, else it would not work! **/
				log("Requesting for permissions: "
					+ extPerm.requestPermissions(
						["android.permission.READ_EXTERNAL_STORAGE", "android.permission.RECEIVE_SMS"]
						//["android.permission.READ_EXTERNAL_STORAGE"]
					)
				);
			}
			
			private function onAppDetailsActivityStarted( event:AppDetailsActivityStartedEvent):void {
				log("onAppDetailsActivityStarted");
				//NativeApplication.nativeApplication.exit();
			}
			
			private function onRequestPermissionsResult( event:RequestPermissionsResultEvent ):void {
				log("Request Permissions Result:");
				var results:Array = event.results;
				var canWrite:Boolean, shouldShowRationale:Boolean;
				if(results) {
					for (var key:String in results) {
						log("\t" + key + " " + results[key]);
					}
					log("PERMISION READ (using result): " + results["android.permission.READ_EXTERNAL_STORAGE"]);
				}
				canWrite = extPerm.checkPermission("android.permission.READ_EXTERNAL_STORAGE");
				log("PERMISION READ (using check) : " + canWrite);
				if (!canWrite) {
					shouldShowRationale = extPerm.shouldShowRequestPermissionRationale("android.permission.READ_EXTERNAL_STORAGE");
					log("shouldShowRequestPermissionRationale for STORAGE: " + shouldShowRationale);
					if (shouldShowRationale) {
						requestForPermissions();
					} else {
						extPerm.addEventListener(AppDetailsActivityStartedEvent.ON_APP_DETAILS_ACTIVITY_STARTED, onAppDetailsActivityStarted);
						log("startInstalledAppDetails: " + extPerm.startInstalledAppDetails("Please grant \"Storage\" permission to run this application."));
					}
				}
			}
		} //CONFIG::test_permissions
	}
}