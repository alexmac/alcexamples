package com.adobe.flascc
{
  import flash.display.Bitmap
  import flash.display.BitmapData
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.ActivityEvent;
  import flash.events.MouseEvent;
  import flash.events.SampleDataEvent;
  import flash.geom.Rectangle
  import flash.media.Camera;
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.media.Video;
  import flash.net.LocalConnection;
  import flash.net.URLRequest;
  import flash.profiler.Telemetry;
  import flash.text.TextField;
  import flash.utils.ByteArray;
  import flash.utils.getTimer;
  import flash.utils.setInterval;

  import com.adobe.flascc.vfs.InMemoryBackingStore;
  import com.adobe.flascc.vfs.ISpecialFile;
  import com.adobe.flascc.vfs.RootFSBackingStore;
  import com.adobe.flascc.vfs.zip.*;

  /**
  * A basic implementation of a console for flascc apps.
  * The PlayerKernel class delegates to this for things like read/write
  * so that console output can be displayed in a TextField on the Stage.
  */
  public class Console extends Sprite implements ISpecialFile
  {
    private static const _height:int = 768 + 100;
    private static const _width:int = 1024;

    private var video:Video;
    private var camera:Camera;
    private const emptyArgs:Vector.<int> = new Vector.<int>;

    /**
    * To Support the preloader case you might want to have the Console
    * act as a child of some other DisplayObjectContainer.
    */
    public function Console(container:DisplayObjectContainer = null, webfs:ByteArray = null)
    {
      CModule.rootSprite = container ? container.root : this
      
      if(CModule.runningAsWorker()) {
        return;
      }

      CModule.vfs.addBackingStore(new RootFSBackingStore(), null)

      if(container) {
        container.addChild(this)
        init(null)
      } else {
        addEventListener(Event.ADDED_TO_STAGE, init)
      }
    }

    /**
    * All of the real flascc init happens in this method
    * which is either run on startup or once the SWF has
    * been added to the stage.
    */
    protected function init(e:Event):void
    {
      camera = Camera.getCamera();
      if (camera != null) {
          camera.setQuality(0, 100);
          camera.setMotionLevel(0, 20);
          camera.setMode(stage.stageWidth, stage.stageHeight, 30);
          video = new Video(stage.stageWidth, stage.stageHeight);
          video.attachCamera(camera);
          addChild(video);
      } else {
          trace("Demo needs a camera to work...");
          return;
      }

      addEventListener(Event.ENTER_FRAME, enterFrame)
      setInterval(serviceUIRequests, 5);

      stage.frameRate = 60
      stage.scaleMode = StageScaleMode.NO_SCALE

      try
      {
        CModule.vfs.console = this
        CModule.startBackground(this,
              new <String>["opencvtest"],
              new <String>[])
      }
      catch(e:*)
      {
        // If main gives any exceptions make sure we get a full stack trace
        // in our console
        consoleWrite(e.toString() + "\n" + e.getStackTrace().toString())
        throw e
      }
    }

    private function enterFrame(e:*):void {
      var imgptr:int = CModule.read32(CModule.getPublicSymbol("imageData"))
      if(imgptr) {
        trace("Copy frame!");
        CModule.ram.position = imgptr
        camera.copyToByteArray(new Rectangle(0,0,stage.stageWidth,stage.stageHeight), CModule.ram)
      }
    }

    /**
    * The callback to call when flascc code calls the posix exit() function. Leave null to exit silently.
    * @private
    */
    public var exitHook:Function;

    /**
    * The PlayerKernel implementation will use this function to handle
    * C process exit requests
    */
    public function exit(code:int):Boolean
    {
      // default to unhandled
      return exitHook ? exitHook(code) : false;
    }

    /**
    * The PlayerKernel implementation will use this function to handle
    * C IO write requests to the file "/dev/tty" (e.g. output from
    * printf will pass through this function). See the ISpecialFile
    * documentation for more information about the arguments and return value.
    */
    public function write(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
    {
      var str:String = CModule.readString(bufPtr, nbyte)
      consoleWrite(str)
      return nbyte
    }

    public function read(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
    {
      return 0
    }

    /**
    * The PlayerKernel implementation will use this function to handle
    * C fcntl requests to the file "/dev/tty" 
    * See the ISpecialFile documentation for more information about the
    * arguments and return value.
    */
    public function fcntl(fd:int, com:int, data:int, errnoPtr:int):int
    {
      return 0
    }

    /**
    * The PlayerKernel implementation will use this function to handle
    * C ioctl requests to the file "/dev/tty" 
    * See the ISpecialFile documentation for more information about the
    * arguments and return value.
    */
    public function ioctl(fd:int, com:int, data:int, errnoPtr:int):int
    {
      return 0
    }

    /**
    * Helper function that traces to the flashlog text file and also
    * displays output in the on-screen textfield console.
    */
    protected function consoleWrite(s:String):void
    {
      trace(s)
    }

    protected function serviceUIRequests():void
    {
      CModule.serviceUIRequests()
    }
  }
}
