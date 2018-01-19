package com.views {
	import flash.display.MovieClip;
	import flash.text.TextField;
	import com.utils.Utilities;
	
	public class TimeoutView extends MovieClip {
		public var yesBttn:MovieClip;
		public var noBttn:MovieClip;
		public var timeMessage:TextField;

		public function TimeoutView() {
			super();
			
			if(getChildByName('message')){
				timeMessage = this['message'];
			}
			
			_init();	//init
		}
		
		//-- INIT
		
		private function _init():void {
			//Place buttons
			yesBttn = Utilities.grabMovieClip('choiceBttn');
			noBttn = Utilities.grabMovieClip('choiceBttn');
			
			//button colors
			yesBttn.offStateColor = 0x58595b;
			yesBttn.offState.color = yesBttn.offStateColor;
			noBttn.offStateColor = 0x58595b;
			noBttn.offState.color = noBttn.offStateColor;
			
			yesBttn.label.text = 'YES';
			noBttn.label.text = 'NO';
			
			yesBttn.x = 273;
			yesBttn.y = 1025;
			
			noBttn.x = 557;
			noBttn.y = 1025;
			
			addChild(yesBttn);
			addChild(noBttn);
		}

	}
	
}
