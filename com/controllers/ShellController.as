package  com.controllers {
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.utils.Utilities;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import com.moody.loaders.XMLLoader;
	import com.controllers.OverlayController;
	import com.gui.ShellContent;
	import flash.system.LoaderContext;
	import flash.system.ApplicationDomain;
	import flash.display.StageDisplayState;
	import flash.ui.Mouse;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	import com.controllers.TimeoutController;
	import flash.events.TimerEvent;
	import flash.utils.*;
	import com.models.ShellModel;
	import com.models.OverlayModel;
	import com.models.TimeoutModel;
	
	public class ShellController extends EventDispatcher {
		private var _shell:Sprite;
		private var _shellView:MovieClip;		
		private var _model:ShellModel;
		private var _controller:EventDispatcher;
		
		private var navBar:MovieClip;
		private var footer:MovieClip;
		private var timeout:MovieClip;
		private var overlayStack:Array;
		private var contentStack:Array;
		private var buttonStack:Array;
		private var subNavStack:Array;
		private var timeoutTicker:Timer;
		private var timeController:TimeoutController;
		
		public var activePage:MovieClip;

		public function ShellController($view:MovieClip, $model:ShellModel, $shell:Sprite) {
			_shellView = $view;
			_shell = $shell;	//stored reference to containing shell
			_controller = this;
			_model = $model;
			
			buttonStack = new Array();
			overlayStack = new Array();
			contentStack = new Array();
			subNavStack = new Array();
			
			//Prep public elements list
			_model.shellElements = {
				shell: _controller,
				content: { contianer: _shellView.content, pages: new Array() },
				navigation: { container: _shellView.navigation, buttons: new Array() },
				overlays: { container: _shellView.overlay, tabs: new Array() },
				timeout: { container: _shellView.timeout }
			};
			
			TweenPlugin.activate([AutoAlphaPlugin]);	//Activate tween plugins
			
			//Load configs
			var xmlLoad:XMLLoader = new XMLLoader('xml/config.xml');
			xmlLoad.load();
			xmlLoad.addEventListener(Event.COMPLETE, function (e:Event){
				_model.controller = _controller;
				_model.configs = xmlLoad.xml;
				
				_init();	//Init
			});
		}
		
		//--INIT
		private function _init():void {			
			var numOfBttns:uint;
			var numOfOvlys:uint;
			var numOfCnt:uint;
			var numOfSubBttns:uint;
			var bttnContainer:MovieClip;
			
			var tModel:TimeoutModel = new TimeoutModel();
			
			//Core settings
			if(_model.configs.settings.@fullscreen == 'true')
				_shell.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
				
			if(_model.configs.settings.@hideMouse == 'true')
				Mouse.hide();
			
			//Add footer
			footer = Utilities.grabMovieClip('footer');
			footer.y = 1639;
			_shellView.accents.addChild(footer);
			
			//Add timeout
			timeout = Utilities.grabMovieClip('timeoutOverlay');
			_shellView.timeout.addChild(timeout);
			timeController = new TimeoutController(timeout, tModel);
			
			startTicker();
			
			//Add content
			numOfCnt = _model.configs.content.page.length();
			for(var e = 0; e < numOfCnt; e++){
				contentStack.push(_model.configs.content.page[e].@path);
			}
			
			contentStack.forEach(function (url:String, idx:int, arr:Array){
				var page:MovieClip = new ShellContent();
				var pLoader:Loader = new Loader();
				var pContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				
				pLoader.load(new URLRequest(url), pContext);
				pLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event){
					page.content = pLoader.content as MovieClip;
					page.addChild(pLoader.content);
					
					if(page.content.hasOwnProperty('shellElements')){
						//_model.shellElements has finished populating by the time this loads; now feed to page
						page.content.shellElements = _model.shellElements;
					}
					
					if(page.content.hasOwnProperty('subNavSettings')){
						//also add subNavSettings
						page.content.subNavSettings = subNavStack;
						page.content.dispatchEvent(new Event(page.content.SUB_NAV_SETTINGS_ADDED));
					}
					
					//Play first page
					if(page.content.hasOwnProperty('isAnimated') && page.content.isAnimated){
						page.content.playPage();
					}
				});
				_shellView.content.addChild(page);
				_model.shellElements.content.pages.push(page);
				
				if(idx != 0){
					page.visible = false;
					page.alpha = 0;
				}
			});
			
			//Add navigation bar
			navBar = Utilities.grabMovieClip(_model.configs.navigation.@linkage);	
			_shellView.navigation.addChild(navBar);
			_shellView.navigation.x = parseInt(_model.configs.navigation.@x);	
			_shellView.navigation.y = parseInt(_model.configs.navigation.@y);	
			
			//Add navigation buttons
			numOfBttns = _model.configs.navigation.button.length();
			for(var i = 0; i < numOfBttns; i++){
				var bttnArr:Array = new Array();
				bttnArr['linkage'] = _model.configs.navigation.button[i].@linkage;
				bttnArr['label'] = _model.configs.navigation.button[i].@label;
				
				buttonStack.push(bttnArr);
			}
			
			bttnContainer = new MovieClip();
			navBar.addChild(bttnContainer);
			
			buttonStack.forEach(function (button:Array, idx:int, arr:Array){
				var bttn:MovieClip = Utilities.grabMovieClip(button.linkage);
				bttn.isMenuButton = true;
				bttn.y = 33;
				
				if(idx == 0){
					bttn.x = 0;
					bttn.isActive = true;
					bttn.active();
					activePage = _model.shellElements.content.pages[0];
				}
				else{
					bttn.x = bttnContainer.width + parseInt(_model.configs.navigation.@spacing);
				}
				
				if(bttn.hasLabel == true){
					bttn.label.text = button.label;
				}
				
				bttnContainer.addChild(bttn);
				
				_model.shellElements.navigation.buttons.push(bttn);
				
				bttn.addEventListener(MouseEvent.CLICK, function (e:MouseEvent){
					var currPage = _model.shellElements.content.pages[idx];
					var pageID = parseInt(_model.configs.navigation.button[idx].@id);
					
					if(activePage != currPage)
						pageChange(pageID);  
				});
			});
			
			bttnContainer.x = (navBar.width / 2) - (bttnContainer.width / 2);	//center
			
			//Grab subnav buttons
			subNavStack['x'] = parseInt(_model.configs.subnav.@x);
			subNavStack['y'] = parseInt(_model.configs.subnav.@y);
			subNavStack['buttons'] = new Array();
			
			numOfSubBttns = _model.configs.subnav.button.length();
			for(var s = 0; s < numOfSubBttns; s++){
				var sbBttn:Object = {
					linkage: _model.configs.subnav.button[s].@linkage,
					label: _model.configs.subnav.button[s],
					id: parseInt(_model.configs.subnav.button[s].@id)
				};
				
				subNavStack.buttons.push(sbBttn);
			}
			
			//Add overlays
			numOfOvlys = _model.configs.overlays.tab.length();
			for(var t = 0; t < numOfOvlys; t++){
				overlayStack.push(_model.configs.overlays.tab[t].@linkage);
			}
			
			overlayStack.forEach(function (linkage:String, idx:int, arr:Array){
				var tabs:MovieClip = Utilities.grabMovieClip(linkage);
				_shellView.overlay.addChild(tabs);
				
				var oModel:OverlayModel = new OverlayModel();
				var oController:OverlayController = new OverlayController(tabs, oModel);
				oModel.id = _model.configs.overlays.tab[idx].@id;
				oModel.tabLabel = _model.configs.overlays.tab[idx];
				
				if(_model.configs.overlays.tab[idx].@isMulti == 'true'){
					oModel.isMultiPage = true;
					oModel.multiPrefix = _model.configs.overlays.tab[idx].@prefix;
					oModel.numOfPages = parseInt(_model.configs.overlays.tab[idx].@pages);
					oModel.multiPath = _model.configs.overlays.tab[idx].@path;
				}
				else{
					oModel.contentPath = _model.configs.overlays.tab[idx].@src;
				}
				
				_model.shellElements.overlays.tabs.push(oController);
			});
			
			_shellView.overlay.y = parseInt(_model.configs.overlays.@y);	
			
			//--
			
			//Feed completed _model.shellElements to where it's needed
			for(var n = 0; n < numOfBttns; n++){
				_model.shellElements.navigation.buttons[n].shellElements = _model.shellElements;
				_model.shellElements.navigation.buttons[n].siblings = _model.shellElements.navigation.buttons;
			}
			
			for(var r = 0; r < numOfOvlys; r++){
				_model.shellElements.overlays.tabs[r].shellElements = _model.shellElements;
			}
			
			timeController.shellElements = _model.shellElements;
		}
		
		//--
		
		public function pageChange($id:Number):void {
			var newPage:MovieClip = _model.shellElements.content.pages[$id];
			
			TweenMax.killTweensOf(activePage);
			TweenMax.to(newPage, 0.5, { autoAlpha: 1, ease: Power2.easeInOut });
			
			activePage.visible = false;
			activePage.alpha = 0;
			
			if(newPage.content.hasOwnProperty('isAnimated') && newPage.content.isAnimated){
				newPage.content.playPage();
			}
			
			if(activePage.content.hasOwnProperty('isAnimated') && activePage.content.isAnimated){
				activePage.content.resetPage();
			}
			
			activePage = newPage;
		}
		
		public function startTicker():void {
			var delay:uint = parseInt(_model.configs.settings.@timeout) * 1000;	//in milliseconds 
			timeoutTicker = new Timer(delay, 1);
			
			timeoutTicker.addEventListener(TimerEvent.TIMER_COMPLETE, onTickerComplete);
			_shellView.addEventListener(MouseEvent.CLICK, resetTicker);
			
			timeoutTicker.start();
		}
		
		private function resetTicker(e:MouseEvent = null):void {
			timeoutTicker.reset();
			timeoutTicker.start();
		}
		
		private function onTickerComplete(e:TimerEvent):void {
			if(activePage != _model.shellElements.content.pages[0]){
				timeController.show();
			
				_shellView.removeEventListener(MouseEvent.CLICK, resetTicker);
			}
		}
		
		//--
		
		public function get shellElements():Object {
			return _model.shellElements;
		}
		
		public function set shellElements($elements:Object):void {
			_model.shellElements = $elements;
		}

	}
	
}
