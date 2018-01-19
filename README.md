# Interactive Panel
Here are some examples from an interactive desktop application I'd built with Adobe AIR/Flex

### Premise:
* Application would load a configuration file that provides core settings and the location of additional resources essential to the app
* Outside of the inner content and reusable gui components, there are three global controllers:
  * Shell (app controller)
  * Timeout (tracks the users interaction with the app and whether the application should reset itself)
  * Overlay (shared controller between instances of global overlays throughout the app)
* All pieces are implemented for via the applications document class __InteractivePanel__
