package  {
	import flash.events.EventDispatcher;
	import flash.display.Sprite;
	import flash.display.MovieClip;
	import com.controllers.ShellController;
	import com.views.ShellView;
	import com.models.ShellModel;
	
	public class InteractivePanel extends Sprite {
		private var _controller:ShellController;
		private var _view:ShellView;
		private var _shell:Sprite;
		private var _model:ShellModel;

		public function UcerisInteractivePanel() {
			super();
			
			_shell = this;
			_view = new ShellView();
			_model = new ShellModel();
			_controller = new ShellController(_view, _model, _shell);
			
			addChild(_view);
		}

	}
	
}
