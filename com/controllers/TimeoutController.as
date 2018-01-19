package com.controllers {
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.utils.Utilities;
	import flash.events.MouseEvent;
	import flash.events.TimerEvent;
	import flash.utils.*;
	import com.greensock.TweenMax;
	import com.greensock.plugins.*;
	import com.greensock.easing.*;
	import com.models.TimeoutModel;
	
	public class TimeoutController extends EventDispatcher {
		private var _view:MovieClip;
		private var _counter:Number;
		private var _model:TimeoutModel;
		
		private var ticker:Timer;

		public function TimeoutController($view:MovieClip, $model:TimeoutModel) {
			_view = $view;
			_model = $model;
			
			_view.visible = false;
			_view.alpha = 0;
			
			TweenPlugin.activate([AutoAlphaPlugin]);	//Activate tween plugins
			
			_view.yesBttn.addEventListener(MouseEvent.CLICK, onYesClick);
			_view.noBttn.addEventListener(MouseEvent.CLICK, onNoClick);
			
			_init();	//init
		}
		
		//-- INIT
		
		private function _init():void {
			reset();
		}
		
		//--
		
		private function onYesClick(e:MouseEvent):void {
			restart();
			
			if(ticker.running)
				ticker.stop();
		}
		
		private function onNoClick(e:MouseEvent):void {			
			closer();
			
			if(ticker.running)
				ticker.stop();
		}
		
		//--
		
		public function show():void {
			TweenMax.to(_view, 0.5, { autoAlpha: 1, ease: Power2.easeInOut, onComplete: startTicker });
		}
		
		public function hide():void {
			TweenMax.to(_view, 0.5, { autoAlpha: 0, ease: Power2.easeInOut, onComplete: reset });
		}
		
		private function startTicker():void {			
			ticker = new Timer(1000, 10);
			
			ticker.addEventListener(TimerEvent.TIMER, updateMessage);
			ticker.addEventListener(TimerEvent.TIMER_COMPLETE, restart);
			
			ticker.start();
		}
		
		public function updateMessage(e:TimerEvent = null):void {
			_view.timeMessage.text = "If no option is selected, this activity will\n automatically restart in ";
			
			if(ticker && ticker.running)
				_counter--;
			
			if(_counter > 1 || _counter == 0){
				_view.timeMessage.text += _counter + " seconds";
			}
			else{
				_view.timeMessage.text += _counter + " second";
			}
		}
		
		private function closer(e:TimerEvent = null):void {
			hide();
			_model.shellElements.shell.startTicker();
		}
		
		private function reset():void {
			_counter = 10;
			updateMessage();
		}
		
		private function restart(e:TimerEvent = null):void {
			closer();
			
			_model.shellElements.shell.pageChange(0);
			_model.shellElements.navigation.buttons[0].deactivateAll();
			_model.shellElements.navigation.buttons[0].isActive = true;
			_model.shellElements.navigation.buttons[0].active();			
			
			_model.shellElements.overlays.tabs[0].deactivateAll();
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
