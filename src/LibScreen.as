package  
{
	import com.stimuli.loading.BulkLoader;
	import com.stimuli.loading.BulkProgressEvent;
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.List;
	import feathers.controls.ProgressBar;
	import feathers.controls.Screen;
	import feathers.controls.ScrollContainer;
	import feathers.controls.TextInput;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import flash.events.ErrorEvent;
	import flash.filesystem.File;
	import flash.net.FileReference;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import neoart.flod.FileLoader;
	import starling.events.Event;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import starling.events.KeyboardEvent;
	
	import flash.net.URLLoaderDataFormat;
	import flash.events.FileListEvent;
	import flash.events.IOErrorEvent;
	/**
	 * ...
	 * @author Ohmnivore
	 */
	public class LibScreen extends Screen
	{
		public var main:Main;
		public var vcont:VerticalLayout;
		public var cont:HorizontalLayout;
		public var gcont:ScrollContainer;
		public var bcont:ScrollContainer;
		
		public var go:Button;
		public var play:Button;
		public var delbtn:Button;
		public var l:List;
		public var data:ListCollection;
		
		public var playingindex:int;
		
		public function LibScreen()
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
			
			cont = new HorizontalLayout;
			cont.paddingTop = 10;
			cont.paddingRight = 15;
			cont.paddingBottom = 10;
			cont.paddingLeft = 15;
			cont.gap = 5;
			cont.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_LEFT;
			cont.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			
			gcont = new ScrollContainer;
			gcont.layout = vcont;
			
			bcont = new ScrollContainer;
			bcont.layout = cont;
			
			addChild(gcont);
			
			gcont.addChild(bcont);
			
			go = new Button();
			go.label = "Browse for files";
			
			play = new Button();
			play.label = "Play";
			
			delbtn = new Button();
			delbtn.label = "Delete file";
			
			data = new ListCollection();
			l = new List;
			l.dataProvider = data;
			l.itemRendererProperties.labelField = "text";
			//l.width = 0;
			//l.height = 0;
			l.maxHeight = 200;
			
			//bcont.addChild(go);
			//go.validate();
			
			bcont.addChild(play);
			play.validate();
			
			bcont.addChild(delbtn);
			delbtn.validate();
			
			gcont.addChild(l);
			l.validate();
			
			go.addEventListener(Event.TRIGGERED, onGo);
			play.addEventListener(Event.TRIGGERED, onPlay);
			delbtn.addEventListener(Event.TRIGGERED, onDel);
			
			//Init list
			var f:File = new File(Registry.save.data["lib"]);
			recursiveDirectoryListing(f);
		}
		
		public function playNext():void
		{
			if (l.dataProvider.length > 1)
			{
				if (playingindex != -1)
				{
					playingindex++;
					if (playingindex < l.dataProvider.length)
					{
						var item:Object = l.dataProvider.getItemAt(playingindex);
						
						if (item != null)
						{
							var f:File = item["ref"];
							f.load();
							f.addEventListener(flash.events.Event.COMPLETE, onLoad);
							f.addEventListener(IOErrorEvent.IO_ERROR, onError);
						}
					}
				}
			}
		}
		
		protected function recursiveDirectoryListing(directory:File):void
		{
			if (directory.isDirectory) 
			{
				var files:Array = directory.getDirectoryListing();
				for (var i:int = 0; i < files.length; i++)
				{
					if (files[i].isDirectory && files[i].type != "json")
					{
						recursiveDirectoryListing(files[i]);
					}
					else
					{
						//trace("file found: " + files[i].nativePath );
						
						var item:Object = new Object;
				
						item["text"] = files[i].name;
						item["ref"] = files[i];
						
						l.dataProvider.addItem(item);
					}
				}
			}
		} 
		
		protected function onGo(event:Event):void
		{
			var f:File = new File;
			f.browseForOpenMultiple("Choose tracks to play");
			f.addEventListener(FileListEvent.SELECT_MULTIPLE, onSelect);
		}
		
		protected function onPlay(event:Event):void
		{
			var item:Object = l.selectedItem;
			playingindex = l.selectedIndex;
			
			if (item != null)
			{
				var f:File = item["ref"];
				f.load();
				f.addEventListener(flash.events.Event.COMPLETE, onLoad);
				f.addEventListener(IOErrorEvent.IO_ERROR, onError);
			}
		}
		
		protected function onDel(event:Event):void
		{
			l.dataProvider.removeItem(l.selectedItem);
		}
		
		protected function onError(e:IOErrorEvent):void
		{
			var pop:Alert = Alert.show(e.text, 
					"Can't open file", new ListCollection(
				[
					{ label: "OK" }
				]));
		}
		
		protected function onLoad(e:flash.events.Event):void
		{
			var bytes:ByteArray = e.target.data;
			//main.player.
			main.play(bytes, this);
		}
		
		protected function onSelect(e:FileListEvent):void
		{
			for each (var f:File in e.files)
			{
				var item:Object = new Object;
				
				item["text"] = f.name;
				item["ref"] = f;
				
				l.dataProvider.addItem(item);
			}
			
			if (e.files.length > 0)
			{
				//play first file
			}
		}
		
		protected function onTrackLoaded(e):void
		{
			//try
			//{
				//var track = dloader.getContent("gettrack");
				//
				//try { main.player.stop(); }
				//catch (e) { }
				//
				//main.loader = new FileLoader;
				//main.player = main.loader.load(track);
				//dloader.removeAll();
				//
				//main.player.play();
				//main.playing = true;
			//}
			//
			//catch (e:Error)
			//{
				//var pop:Alert = Alert.show("Unsupported file type", 
					//"Error on play", new ListCollection(
				//[
					//{ label: "OK" }
				//]));
				//dloader.removeAll();
				//
				//try { main.player.stop(); }
				//catch (e) {}
				//main.playing = false;
			//}
			//
			//bar.visible = false;
		}
	}
}