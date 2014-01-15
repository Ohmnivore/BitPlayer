package 
{
	import com.stimuli.loading.BulkProgressEvent;
	import feathers.controls.Alert;
	import feathers.controls.Button;
	import feathers.controls.Callout;
	import feathers.controls.Label;
	import feathers.controls.ProgressBar;
	import feathers.controls.ScreenNavigator;
	import feathers.controls.ScreenNavigatorItem;
	import feathers.controls.ScrollContainer;
	import feathers.controls.Slider;
	import feathers.controls.TabBar;
	import feathers.controls.TextArea;
	import feathers.controls.TextInput;
	import feathers.core.ITextRenderer;
	import feathers.data.ListCollection;
	import feathers.layout.HorizontalLayout;
	import feathers.layout.VerticalLayout;
	import feathers.layout.ViewPortBounds;
	import feathers.themes.MetalWorksMobileTheme;
	import feathers.controls.text.TextFieldTextRenderer;
	import flash.events.ErrorEvent;
	import flash.net.SharedObject;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	import neoart.flod.FileLoader;

	import starling.display.Sprite;
	import starling.events.Event;
	
	import neoart.flod.core.*;
	import com.stimuli.loading.BulkLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	import flash.system.Security;
	import flash.events.KeyboardEvent;
	import flash.desktop.NativeApplication;
	import flash.desktop.Clipboard;
	import flash.desktop.ClipboardFormats;
	import flash.filesystem.File;

	public class Main extends Sprite
	{
		public var tabs:TabBar;
		public var nav:ScreenNavigator;
		
		public var gctrllay:VerticalLayout;
		public var gcont:ScrollContainer;
		
		public var ctrllay:HorizontalLayout;
		public var cont:ScrollContainer;
		
		[Embed(source = "mod/Monday.mod", mimeType = "application/octet-stream")]
		public var TESTFILE:Class;
		
		//Buttons
		public var rewbtn:Button;
		public var playbtn:Button;
		public var ffbtn:Button;
		public var stopbtn:Button;
		public var about:Button;
		
		public var vol:Slider;
		public var title:Label;
		
		public var player:CorePlayer;
		public var loader:FileLoader;
		
		public var playing:Boolean = false;
		public var volume:Number = 100.0;
		public var nowplaying:*;
		
		public var save:SharedObject;
		
		public function Main()
		{
			Registry.main = this;
			
			save = SharedObject.getLocal("BitPlayer");
			if (!save.data.hasOwnProperty("lib"))
			{
				save.data["lib"] = File.applicationDirectory.resolvePath("lib").nativePath;
			}
			
			Registry.save = save;
			
			//Flod
			loader = new FileLoader;
			player = loader.load(new TESTFILE as ByteArray);
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
		}
		
		protected function addedToStageHandler(event:Event):void
		{
			this.removeEventListener(Event.ADDED_TO_STAGE, addedToStageHandler);
			
			new MetalWorksMobileTheme(null, false);
			
			nav = new ScreenNavigator;
			tabs = new TabBar;
			tabs.dataProvider = new ListCollection(
			[
				{ label: "Stream" },
				{ label: "Load files" },
				{ label: "Library" },
			]);
			
			gctrllay = new VerticalLayout;
			gctrllay.paddingTop = 10;
			gctrllay.paddingRight = 15;
			gctrllay.paddingBottom = 10;
			gctrllay.paddingLeft = 15;
			gctrllay.gap = 5;
			gctrllay.horizontalAlign = VerticalLayout.HORIZONTAL_ALIGN_CENTER;
			gctrllay.verticalAlign = VerticalLayout.VERTICAL_ALIGN_TOP;
			
			gcont = new ScrollContainer;
			gcont.layout = gctrllay;
			
			ctrllay = new HorizontalLayout;
			ctrllay.paddingTop = 10;
			ctrllay.paddingRight = 15;
			ctrllay.paddingBottom = 10;
			ctrllay.paddingLeft = 15;
			ctrllay.gap = 5;
			ctrllay.horizontalAlign = HorizontalLayout.HORIZONTAL_ALIGN_CENTER;
			ctrllay.verticalAlign = HorizontalLayout.VERTICAL_ALIGN_TOP;
			
			
			cont = new ScrollContainer;
			cont.layout = ctrllay;
			
			addChild(gcont);
			gcont.addChild(tabs);
			
			//Btns
			rewbtn = new Button();
			rewbtn.label = "Last";
			
			playbtn = new Button();
			playbtn.label = "Play/Pause";
			
			ffbtn = new Button();
			ffbtn.label = "Next";
			
			stopbtn = new Button();
			stopbtn.label = "Stop";
			
			about = new Button();
			about.label = "About";
			
			vol = new Slider;
			
			title = new Label;
			title.text = "None";
			title.maxWidth = 190;
			//title.isEditable = false;
			
			//Adding btns
			//cont.addChild(rewbtn);
			//rewbtn.validate();
			
			vol.minimum = 0;
			vol.maximum = 100;
			vol.value = 100;
			vol.step = 2;
			vol.page = 10;
			gcont.addChild(vol);
			
			gcont.addChild(cont);
			
			cont.addChild(playbtn);
			playbtn.validate();
			
			//cont.addChild(ffbtn);
			//ffbtn.validate();
			
			cont.addChild(stopbtn);
			stopbtn.validate();
			
			cont.addChild(title);
			title.validate();
			
			gcont.addChild(nav);
			nav.addScreen("dscreen", new ScreenNavigatorItem(DlScreen));
			nav.addScreen("fscreen", new ScreenNavigatorItem(FileScreen));
			nav.addScreen("lscreen", new ScreenNavigatorItem(LibScreen));
			nav.showScreen("dscreen");
			
			gcont.addChild(about);
			
			playbtn.addEventListener(Event.TRIGGERED, playpause);
			stopbtn.addEventListener(Event.TRIGGERED, stop);
			about.addEventListener(Event.TRIGGERED, help);
			vol.addEventListener(Event.CHANGE, setvol);
			tabs.addEventListener(Event.CHANGE, tabChange);
			//ffbtn.addEventListener(Event.TRIGGERED, fforward);
		}
		
		function tabChange( event:Event ):void
		{
			var t:TabBar = TabBar(event.currentTarget);
			if (t.selectedIndex == 0) 
			{
				nav.showScreen("dscreen");
			}
			if (t.selectedIndex == 1) 
			{
				nav.showScreen("fscreen");
			}
			if (t.selectedIndex == 2) 
			{
				nav.showScreen("lscreen");
			}
		}
		
		protected function playpause(event:Event):void
		{
			if (playing) 
			{
				playing = false;
				player.pause();
			}
			
			else 
			{
				playing = true;
				player.play();
			}
		}
		
		protected function stop(event:Event):void
		{
			player.stop();
		}
		
		protected function help(event:Event):void
		{
			navigateToURL(new URLRequest("https://github.com/Ohmnivore/BitPlayerWeb"), '_self');
		}
		
		protected function fforward(event:Event):void
		{
			//player.fast();
			//player.tempo = 200;
		}
		
		protected function setvol(event:Event):void
		{
			volume = event.target["value"];
			player.volume = volume / 100.0;
		}
		
		protected function onFinish(event:flash.events.Event):void
		{
			nowplaying.playNext();
		}
		
		public function play(Bytes:ByteArray, Nowplaying:*):void
		{
			nowplaying = Nowplaying;
			
			try
			{
				var track = Bytes;
				
				try { player.stop(); }
				catch (e) { }
				
				loader = new FileLoader;
				player = loader.load(track);
				
				player.play();
				playing = true;
				
				player.soundChan.addEventListener(flash.events.Event.SOUND_COMPLETE, onFinish);
				title.text = player.title;
			}
			
			catch (e:Error)
			{
				var pop:Alert = Alert.show("Unsupported file type", 
					"Error on play", new ListCollection(
				[
					{ label: "OK" }
				]));
				
				try { player.stop(); }
				catch (e) {}
				playing = false;
				
				title.text = "None";
			}
		}
	}
}
