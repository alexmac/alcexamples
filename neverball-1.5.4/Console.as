package flascc
{
  import flash.display.Bitmap
  import flash.display.BitmapData
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.display.Stage3D;
  import flash.display.StageAlign;
  import flash.display.StageScaleMode;
  import flash.display3D.Context3D;
  import flash.display3D.Context3DRenderMode;
  import flash.events.AsyncErrorEvent;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.IOErrorEvent;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.ProgressEvent;
  import flash.events.SampleDataEvent;
  import flash.events.SecurityErrorEvent;
  import flash.geom.Rectangle
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.net.LocalConnection;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.net.URLRequest;
  import flash.text.TextField;
  import flash.ui.Keyboard;
  import flash.utils.ByteArray
  import flash.utils.getTimer;
  
  import GLS3D.GLAPI;
  import C_Run.ram;
  import flascc.CModule;
  import flascc.vfs.ISpecialFile;
  import flascc.vfs.InMemoryBackingStore;
  import flascc.vfs.zip.*

    class ZipBackingStore extends InMemoryBackingStore {
      public function ZipBackingStore()
      {
      }

      public function addZip(data:ByteArray) {
        var zip = new ZipFile(data)
        for (var i = 0; i < zip.entries.length; i++) {
          var e = zip.entries[i]
          if (e.isDirectory()) {
            addDirectory("/"+e.name)
          } else {
            addFile("/"+e.name, zip.getInput(e))
            trace(e.name)
          }
        }
      }
    }

    var zfs:ZipBackingStore = new ZipBackingStore();
  public function addVFSZip(x:*) {
    if(!zfs) {
      zfs = new ZipBackingStore();
    }
    zfs.addZip(x)
  }

  /**
  * A basic implementation of a console for flascc apps.
  * The PlayerPosix class delegates to this for things like read/write
  * so that console output can be displayed in a TextField on the Stage.
  */
  public class Console extends Sprite implements ISpecialFile
  {
    public static var current:Console;
    private static var _width:int = 1024;
    private static var _height:int = 768;
    private var bm:Bitmap
    private var bmd:BitmapData
    private var vbufferptr:int, vgl_mx:int, vgl_my:int, kp:int, vgl_buttons:int;
    private var mainloopTickPtr:int, soundUpdatePtr:int, audioBufferPtr:int;
    private var inputContainer
    private var keybytes:ByteArray = new ByteArray()
    private var mx:int = 0, my:int = 0, last_mx:int = 0, last_my:int = 0, button:int = 0;
    private var snd:Sound = null
    private var sndChan:SoundChannel = null
    public var sndDataBuffer:ByteArray = null
    private var _stage:Stage3D;
    private var _context:Context3D;
    private var rendered:Boolean = false;

    /**
    * To Support the preloader case you might want to have the Console
    * act as a child of some other DisplayObjectContainer.
    */
    public function Console(container:DisplayObjectContainer = null)
    {
      current = this;
      CModule.rootSprite = container ? container.root : this
      addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
    }

    private function onError(e:Event):void
    {
    }

    private function onProgress(e:Event):void
    {
    }

    public function onAddedToStage(e:Event):void
    {
      inputContainer = new Sprite()
      addChild(inputContainer)

      stage.align = StageAlign.TOP_LEFT;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      stage.addEventListener(KeyboardEvent.KEY_DOWN, bufferKeyDown);
      stage.addEventListener(KeyboardEvent.KEY_UP, bufferKeyUp);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, bufferMouseMove);
      stage.addEventListener(MouseEvent.MOUSE_DOWN, bufferMouseDown);
      stage.addEventListener(MouseEvent.MOUSE_UP, bufferMouseUp);
      stage.frameRate = 60;
      stage.scaleMode = StageScaleMode.NO_SCALE;
    
    _stage = stage.stage3Ds[0];
    _stage.addEventListener(Event.CONTEXT3D_CREATE, context_created);
    //_stage.requestContext3D(Context3DRenderMode.AUTO);
    _stage.requestContext3D("auto");
  }

  private function context_created(e:Event):void
  {
      _context = _stage.context3D;
      _context.configureBackBuffer(_width, _height, 4, true /*enableDepthAndStencil*/ );
      _context.enableErrorChecking = false;
      
      trace(_context.driverInfo);
      GLAPI.init(_context, null, stage);
          var gl:GLAPI = GLAPI.instance;
          gl.context.clear(0.0, 0.0, 0.0);
          gl.context.present();
          this.addEventListener(Event.ENTER_FRAME, runMain);
          stage.addEventListener(Event.RESIZE, stageResize);
    }
    
    private function stageResize(event:Event):void
    {
        // need to reconfigure back buffer
        _width = stage.stageWidth;
        _height = stage.stageHeight;
        _context.configureBackBuffer(_width, _height, 4, true /*enableDepthAndStencil*/ );
    }


    private function runMain(event:Event):void
    {
      CModule.vfs.console = this
      CModule.vfs.addBackingStore(zfs, null)

      this.removeEventListener(Event.ENTER_FRAME, runMain);

      var argv:Vector.<String> = new Vector.<String>();
      argv.push("/data/neverball.swf");
      CModule.startAsync(this, argv);
      trace("startAsync run");
      vbufferptr = CModule.read32(CModule.getPublicSymbol("__avm2_vgl_argb_buffer"))
      vgl_mx = CModule.getPublicSymbol("vgl_cur_mx");
      vgl_my = CModule.getPublicSymbol("vgl_cur_my");
      vgl_buttons = CModule.getPublicSymbol("vgl_cur_buttons");

      mainloopTickPtr = CModule.getPublicSymbol("mainLoopTick");
      soundUpdatePtr = CModule.getPublicSymbol("audio_step");
      audioBufferPtr = CModule.getPublicSymbol("audioBuffer");
      addEventListener(Event.ENTER_FRAME, framebufferBlit);
    }

/**
    * The PlayerPosix implementation will use this function to handle
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
      if(fd == 0 && nbyte == 1) {
        keybytes.position = kp++;
        if(keybytes.bytesAvailable) {
          CModule.write8(bufPtr, keybytes.readUnsignedByte());
        } else {
        keybytes.position = 0;
        keybytes.length = 0;
        kp = 0;
        }
      }
      return 0;
    }

    public function bufferMouseMove(me:MouseEvent) 
    {
      me.stopPropagation();
      mx = me.stageX;
      my = me.stageY;
    }
    
    public function bufferMouseDown(me:MouseEvent) 
    {
      me.stopPropagation();
      mx = me.stageX;
      my = me.stageY;
      button = 1;
    }
    
    public function bufferMouseUp(me:MouseEvent) 
    {
      me.stopPropagation();
      mx = me.stageX;
      my = me.stageY;
      button = 0;
    }


    public function bufferKeyDown(ke:KeyboardEvent) 
    {
      if(Keyboard.capsLock || ke.keyCode >= 127)
        return;

      keybytes.writeByte(int(ke.keyCode & 0x7F));
    }
    
    public function bufferKeyUp(ke:KeyboardEvent) 
    {
      if(Keyboard.capsLock || ke.keyCode > 128)
        return;

      keybytes.writeByte(int(ke.keyCode | 0x80));
    }

    public function consoleWrite(s:String):void
    {
      trace(s);
    }

    public function sndComplete(e:Event):void
    {
      sndChan.removeEventListener(Event.SOUND_COMPLETE, sndComplete);
      sndChan = snd.play();
      sndChan.addEventListener(Event.SOUND_COMPLETE, sndComplete);
    }

    public function sndData(e:SampleDataEvent):void
    {
      CModule.callI(soundUpdatePtr, new Vector.<int>)
      e.data.endian = "littleEndian"
      e.data.length = 0
      var ap:int = CModule.read32(audioBufferPtr)
      //e.data.writeBytes(ram, ap, 16384);
      
      for(var i:int=0; i<16384; i+=2) {
        ram.position = ap+i;
        var s:int = ram.readShort()
        var v:Number = (s / 32768.0)
        e.data.writeFloat(v)
      }
    }

    public function framebufferBlit(e:Event):void
    {
      CModule.serviceUIRequests()
      CModule.write32(vgl_mx, mx);
      CModule.write32(vgl_my, my);
      CModule.write32(vgl_buttons, button);

      var gl:GLAPI = GLAPI.instance;
      CModule.callI(mainloopTickPtr, new Vector.<int>());
      gl.context.present();

      if(!snd)
      {
        snd = new Sound();
        snd.addEventListener( SampleDataEvent.SAMPLE_DATA, sndData );
      }
      if (!sndChan)
      {
        sndChan = snd.play();
        sndChan.addEventListener(Event.SOUND_COMPLETE, sndComplete);
      }
    }
  }
}
