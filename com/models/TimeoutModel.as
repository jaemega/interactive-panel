package com.models {
	import flash.events.EventDispatcher;
	
	public class TimeoutModel {
		private var _shellElements:Object;

		public function TimeoutModel() {
			super();
		}
		
		//--
		
		public function get shellElements():Object {
			return _shellElements;
		}
		
		public function set shellElements($value:Object):void {
			_shellElements = $value;
		}

	}
	
}
