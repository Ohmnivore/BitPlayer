package  
{
	import com.stimuli.loading.BulkLoader;
	import com.stimuli.loading.BulkProgressEvent;
	import com.stimuli.loading.loadingtypes.LoadingItem;
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.ProgressBar;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.layout.VerticalLayout;
	import flash.events.ErrorEvent;
	import flash.system.LoaderContext;
	import neoart.flod.FileLoader;
	import starling.events.Event;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import starling.events.KeyboardEvent;
	
	import flash.net.URLLoaderDataFormat;
	import flash.filesystem.File;
	import flash.filesystem.FileStream;
	import flash.filesystem.FileMode;
	/**
	 * ...
	 * @author Ohmnivore
	 */
	public class DlScreen extends Screen
	{
		public var main:Main;
		public var vcont:VerticalLayout;
		public var gcont:ScrollContainer;
		
		public var url:TextInput;
		public var bar:ProgressBar;
		public var go:Button;
		public var save:Button;
		public var savename:TextInput;
		
		public var dloader:BulkLoader;
		public var context:LoaderContext;
		public var urlstr:String = "http";
		public var downloaded = null;
		
		public function DlScreen()
		{
			main = Registry.main;
			
			vcont = new VerticalLayout;
			vcont.paddingTop = 10;
			vcont.paddingRight = 15;
			vcont.paddingBottom = 10;
			vcont.paddingLeft = 15;
			vcont.gap = 5;
			vcont.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_LEFT;
			vcont.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			
			gcont = new ScrollContainer;
			gcont.layout = vcont;
			
			addChild(gcont);
			
			//BulkLoader
			dloader = Registry.dloader;
			context = new LoaderContext(false);
			
			go = new Button();
			go.label = "Download&Play";
			
			save = new Button();
			save.label = "Save";
			
			url = new TextInput;
			
			bar = new ProgressBar;
			
			gcont.addChild(go);
			go.validate();
			
			gcont.addChild(save);
			save.validate();
			
			gcont.addChild(url);
			url.text = "Download URL";
			url.isEditable = false;
			url.validate();
			
			var label:Label = new Label;
			label.text = "Ctrl-v to paste download url";
			gcont.addChild(label);
			//var call:Callout = Callout.show(label, url, Callout.DIRECTION_RIGHT);
			//call.closeOnTouchBeganOutside = false;
			//call.closeOnTouchEndedOutside = false;
			
			gcont.addChild(bar);
			bar.visible = false;
			bar.maximum = 1.0;
			bar.minimum = 0.0
			
			go.addEventListener(Event.TRIGGERED, dltrack);
			save.addEventListener(Event.TRIGGERED, saveTrack);
			url.addEventListener(Event.CHANGE, seturl);
			
			addEventListener(KeyboardEvent.KEY_DOWN, keyListener); 
		}
		
		public function playNext():void
		{
			main.title.text = "None";
		}
		
		private function keyListener(event:starling.events.KeyboardEvent):void
		{ 
			if (event.ctrlKey)
			{ 
				//event.preventDefault(); 
				
				switch(String.fromCharCode(event.charCode))
				{ 
					case "c": 
						event.preventDefault(); 
						//event.stopImmediatePropagation();
						//NativeApplication.nativeApplication.copy(); 
						break;
					case "v": 
						event.preventDefault(); 
						//event.stopImmediatePropagation();
						//NativeApplication.nativeApplication.paste();
						urlstr = Clipboard.generalClipboard.getData(ClipboardFormats.TEXT_FORMAT) as String;
						if (urlstr == null) urlstr = "Empty URL";
						url.text = urlstr;
						break; 
				}
			}
		}
		
		protected function saveTrack(event:Event):void
		{
			var pop:Alert = Alert.show("Choose file name. Don't forget a file extension.", 
			"Save to library", new ListCollection(
			[
				{label: "Save", triggered: saveNow },
			]));
			savename = new TextInput;
			pop.addChild(savename);
		}
		
		protected function saveNow(event:Event):void
		{
			var fs:FileStream = new FileStream;
			var f:File = new File(Registry.save.data["lib"]);
			fs.open(f.resolvePath(savename.text), FileMode.WRITE);
			if (downloaded != null) fs.writeBytes(downloaded);
			fs.close();
		}
		
		protected function dltrack(event:Event):void
		{
			dloader.add(urlstr, {context:context, id:"gettrack", type:"binary", dataFormat:URLLoaderDataFormat.BINARY});
			
			dloader.get("gettrack").addEventListener(Event.COMPLETE, onTrackLoaded);
			dloader.get("gettrack").addEventListener(BulkLoader.PROGRESS, onProgress);
			dloader.get("gettrack").addEventListener(BulkLoader.ERROR, dlError);
			
			dloader.start();
			
			bar.visible = true;
		}
		
		function dlError(evt:ErrorEvent):void
		{
			//trace (evt); // outputs more information
			var cont:Label = new Label;
			cont.text = evt.text;
			var pop:Alert = Alert.show(evt.text, "Error on download", new ListCollection(
			[
				{ label: "OK" }
			]));
			dloader.removeAll();
			bar.visible = false;
		}
		
		protected function onProgress(e:BulkProgressEvent):void
		{
			var p:Number = e.percentLoaded;
			bar.value = p;
		}
		
		protected function onTrackLoaded(e):void
		{
			var track = dloader.getContent("gettrack");
			downloaded = track;
			var name:LoadingItem = dloader.get("gettrack");
			main.play(dloader.getContent("gettrack"), this);
			dloader.removeAll();
			bar.visible = false;
		}
		
		protected function getFileName(fullPath:String):String
		{
			var fSlash: int = fullPath.lastIndexOf("/");
			var bSlash: int = fullPath.lastIndexOf("\\"); // reason for the double slash is just to escape the slash so it doesn't escape the quote!!!
			var slashIndex: int = fSlash > bSlash ? fSlash : bSlash;
			return fullPath.substr(slashIndex + 1);
		}
		
		protected function seturl(event:Event):void
		{
			urlstr = event.target["text"];
		}
	}

}