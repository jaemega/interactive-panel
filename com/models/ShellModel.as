package com.models {
	import flash.events.EventDispatcher;
	
	public class ShellModel extends EventDispatcher {
		private var _configs:XML;
		private var _shellElements:Object;
		private var _controller:EventDispatcher;

		public function ShellModel() {
			super();
		}
		
		//--
		
		public function get configs():XML {
			return _configs;
		}
		
		public function set configs($value:XML):void {
			_configs = $value;
		}
		
		public function get controller():EventDispatcher {
			return _controller;
		}
		
		public function set controller($value:EventDispatcher):void {
			_controller = $value;
		}
		
		public function get shellElements():Object {
			return _shellElements;
		}
		
		public function set shellElements($value:Object):void {
			_shellElements = $value;
		}

	}
	
}
