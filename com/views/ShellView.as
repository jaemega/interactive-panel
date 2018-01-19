package com.views {
	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.events.Event;
	import com.utils.Utilities;
	
	public class ShellView extends MovieClip{
		public var navigation:Sprite;
		public var timeout:Sprite;
		public var content:Sprite;
		public var overlay:Sprite;
		public var accents:Sprite;

		public function ShellView() {
			super();
			
			navigation = new Sprite();
			timeout = new Sprite();
			content = new Sprite();
			overlay = new Sprite();
			accents = new Sprite();
			
			addChild(content);
			addChild(navigation);
			addChild(accents);
			addChild(overlay);
			addChild(timeout);
		}

	}
	
}
