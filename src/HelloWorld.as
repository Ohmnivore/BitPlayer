package
{
	import flash.display3D.Context3D;
	import Main;

	import flash.display.Loader;
	import flash.display.Sprite;
	import flash.display.StageAlign;
	//import flash.display.Stage;
	import flash.display.StageScaleMode;
	import flash.events.Event;
	//import flash.filesystem.File;
	//import flash.filesystem.FileMode;
	//import flash.filesystem.FileStream;
	import flash.geom.Rectangle;
	import flash.system.Capabilities;
	import flash.utils.ByteArray;

	import starling.core.Starling;

	[SWF(width="620",height="620",frameRate="60",backgroundColor="#4a4137")]
	public class HelloWorld extends Sprite
	{
		public function HelloWorld()
		{
			this.loaderInfo.addEventListener(Event.COMPLETE, loaderInfo_completeHandler);
		}

		private var _starling:Starling;
		private var _launchImage:Loader;
		private var _savedAutoOrients:Boolean;

		public function loaderInfo_completeHandler(event:Event):void
		{
			this._starling = new Starling(Main, this.stage);
			this._starling.enableErrorChecking = false;
			this._starling.start();
		}
	}
}