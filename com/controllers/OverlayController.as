package com.controllers {
	import flash.events.EventDispatcher;
	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	import flash.events.Event;
	import flash.text.TextField;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	import flash.events.TimerEvent;
	import flash.utils.*;
	import flash.display.Loader;
	import flash.system.LoaderContext;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.utils.getQualifiedClassName;
	import flash.display.Bitmap;
	import com.gui.ShellContent;
	import com.models.OverlayModel;
	
	public class OverlayController extends EventDispatcher {
		private var _view:MovieClip;
		private var _tab:MovieClip;
		private var _model:OverlayModel;
		private var _originY:Number;
		private var _newY:Number;
		private var _label:TextField;
		private var _closer:MovieClip;
		private var _leftArrow:MovieClip;
		private var _rightArrow:MovieClip;
		
		public var isOpen:Boolean;
		private var ticker:Timer;
		private var urlStack:Array;
		private var pageStack:Array;
		private var activePageNum:Number;

		public function OverlayController($view:MovieClip, $model:OverlayModel) {
			isOpen = false;
			
			_view = $view;	
			_model = $model;
			_model.controller = this;
			
			_tab = _view['tab'];
			_label = _tab['label'];
			
			if(_view.getChildByName('closer')){
				_closer = _view['closer'];
				_model.hasCloser = true;
			}
			
			if(_view.getChildByName('lArrow') && _view.getChildByName('rArrow')){
				_leftArrow = _view['lArrow'];
				_rightArrow = _view['rArrow'];
			}
			
			pageStack = new Array();
			urlStack = new Array();
			
			_originY = _view.y;
			_newY = Math.ceil(-(_view.height - _tab.height));
			
			_tab.mouseChildren = false;
			_tab.buttonMode = true;
			_tab.addEventListener(MouseEvent.CLICK, onClick);			
			
			_model.addEventListener(OverlayModel.LABEL_ADDED, onLabelAdded);
			_model.addEventListener(OverlayModel.PATH_ADDED, onPathAdded);
			_model.addEventListener(OverlayModel.MULTI_PAGE_ADDED, onMultiPageAdded);
			
			TweenPlugin.activate([AutoAlphaPlugin]);	//Activate tween plugins
			
			_init();	//init
		}
		
		//-- INIT
		private function _init():void {
			if(_model.hasCloser){
				_closer.addEventListener(MouseEvent.CLICK, onClick);
			}
		}
		
		//--
		
		public function onClick(e:MouseEvent):void {
			if(isOpen){
				close();
			}
			else {					
				deactivateAll();				
				open();
			}
			
			trace(_model.id + ' : isOpen = ' + isOpen);
		}
		
		private function onPathAdded(e:Event):void {
			
			if(_model.contentPath){
				var src:MovieClip = new ShellContent();
				var pLoader:Loader = new Loader(); 
				var pContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
				
				pLoader.load(new URLRequest(_model.contentPath), pContext);
				pLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event){
					
					if(pLoader.contentLoaderInfo.contentType.match('image')){	//image loaded
						var img:Bitmap = pLoader.content as Bitmap;
						img.smoothing = true;
						
						src.addChild(img);
					}
					else{
						src.content = pLoader.content as MovieClip;
						
						src.addChild(pLoader.content);
					}
				});
				
				src.x = 44;
				src.y = 124;
				_view.addChild(src);
			}
		}
		
		private function onLabelAdded(e:Event):void {
			_label.htmlText = _model.tabLabel;
			
			if(_label.numLines > 1){
				_label.height = _label.textHeight + 4;	//added numeral for forced padding beyond textHieght
				_label.y = ((_tab.height / 2) - (_label.height / 2)) - 3;
			}
		}
		
		private function onMultiPageAdded(e:Event):void {
			var url:String;
			
			if(_model.multiPath){				
				var multiContainer:MovieClip = new ShellContent();
				
				_leftArrow.alpha = 0.5;
				
				//Ensure numOfPages is set
				if(isNaN(_model.numOfPages)){
					throw new Error('numOfPages : provided value is not a number.');
				}
				
				//grab urls
				for(var i = 0; i < _model.numOfPages; i++){
					if(i < 9){
						url = _model.multiPath + '/' +_model.multiPrefix + '_0' + (i + 1) + '.png';
					}
					else{
						url = _model.multiPath + '/' + _model.multiPrefix + '_' + (i + 1) + '.png';
					}
					
					urlStack.push(url);
				}
				
				multiContainer.x = 0;
				multiContainer.y = 124;
				_view.addChild(multiContainer);
				
				//load pages
				urlStack.forEach(function (url:String, idx:uint, arr:Array){
					var cnt:MovieClip = new ShellContent();
					var pLoader:Loader = new Loader();
					var pContext:LoaderContext = new LoaderContext(false, ApplicationDomain.currentDomain);
					
					pLoader.load(new URLRequest(url), pContext);
					pLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function (e:Event){
						var holder:MovieClip = new MovieClip;
						
						var img:Bitmap = pLoader.content as Bitmap;
						img.smoothing = true;
						
						holder.addChild(img);
						
						holder.x = (_view.width / 2) - (img.width / 2);		//center;
						
						cnt.content = holder;
						cnt.addChild(holder);
					});
					
					pageStack.push(cnt);
					multiContainer.addChild(cnt);
				});
				
				//prep pages
				pageStack.forEach(function (page:MovieClip, idx:uint, arr:Array){
					if(idx == 0){
						activePageNum = idx;
					}
					else{
						page.visible = false;
						page.alpha = 0;
					}
				});
				
				_leftArrow.addEventListener(MouseEvent.CLICK, onLeftClick);
				_rightArrow.addEventListener(MouseEvent.CLICK, onRightClick);
			}
		}
		
		//--
		
		private function onLeftClick(e:MouseEvent):void {
			if(activePageNum > 0){
				changePage(activePageNum - 1);
			}
		}
		
		private function onRightClick(e:MouseEvent):void {
			if(activePageNum < (_model.numOfPages - 1)){
				changePage(activePageNum + 1);
			}
		}
		
		private function changePage($pid):void {
			var currPage:MovieClip = pageStack[activePageNum];
			var newPage:MovieClip = pageStack[$pid];
			
			TweenMax.killTweensOf(currPage);
			TweenMax.to(currPage, 0.8, { autoAlpha: 0, ease: Power2.easeInOut });
			TweenMax.to(newPage, 0.8, { autoAlpha: 1, ease: Power2.easeInOut });
			activePageNum = $pid;
			
			if($pid == (_model.numOfPages - 1)){
				_rightArrow.alpha = 0.5;
			}
			else if($pid == 0){
				_leftArrow.alpha = 0.5;
			}
			else {
				_leftArrow.alpha = 1;
				_rightArrow.alpha = 1;
			}
		}
		
		//--
		
		public function open():void {
			_model.shellElements.overlays.container.setChildIndex(_view, 0);
			slide(_view, _newY);
			isOpen = true;
			
			startTicker();
		}
		
		public function close():void {
			slide(_view, _originY);
			isOpen = false;
			
			removeTicker();
			
			if(_model.isMultiPage){
				pageStack[activePageNum].visible = false;
				pageStack[activePageNum].alpha = 0;
				
				pageStack[0].visible = true;
				pageStack[0].alpha = 1;
				_leftArrow.alpha = 0.5;
				_rightArrow.alpha = 1;
				activePageNum = 0;
			}
		}
		
		public function deactivateAll():void {
			_model.shellElements.overlays.tabs.forEach(function (overlay:OverlayController, idx:uint, arr:Array){
				overlay.close();
			});
		}
		
		private function slide($trgt, $pos):void {
			TweenMax.killTweensOf($trgt);
			TweenMax.to($trgt, 0.5, { y: $pos, ease: Power3.easeOut });
		}
		
		private function startTicker():void {
			var delay:uint = 60000;	//1 minute in milliseconds
			ticker = new Timer(delay, 1);
			
			ticker.start();
			
			_view.addEventListener(MouseEvent.CLICK, restartTicker);
			ticker.addEventListener(TimerEvent.TIMER_COMPLETE, removeTicker);			
		}
		
		private function restartTicker(e:MouseEvent):void {
			if(ticker && ticker.running){
				ticker.reset();
				ticker.start();
			}
		}
		
		private function removeTicker(e:TimerEvent = null):void {
			if(_view.hasEventListener(MouseEvent.CLICK)){
				_view.removeEventListener(MouseEvent.CLICK, restartTicker);
			}
			
			if(ticker && ticker.running){
				ticker.stop();
			}
			
			if(isOpen){
				close();
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
