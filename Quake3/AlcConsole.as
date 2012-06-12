package com.adobe.alchemy
{
  import flash.display.Sprite;
  import flash.text.TextField;
  import flash.display.StageScaleMode;
  import flash.display.DisplayObjectContainer;
  import flash.display.Bitmap
  import flash.display.BitmapData
  import flash.geom.Rectangle
  import flash.utils.ByteArray
  import flash.net.LocalConnection;
  import flash.net.URLRequest;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.media.SoundChannel;
  import flash.media.Sound;
  import flash.events.SampleDataEvent;
  import flash.utils.ByteArray;
  import flash.utils.Endian;
  import flash.events.Event;
  import flash.events.EventDispatcher;
  import flash.events.ProgressEvent;
  import flash.events.SecurityErrorEvent;
  import flash.events.IOErrorEvent;
  import flash.events.AsyncErrorEvent;
  import flash.display.Loader;
  import flash.net.URLRequest;
  import flash.net.URLLoader;
  import flash.net.URLLoaderDataFormat;
  import flash.ui.Mouse;
  import C_Run.ram;
  import C_Run.initLib;
  import com.adobe.alchemyvfs.HttpVFS;
  import Stage3DGL.GLAPI;
  import flash.display.Stage3D;
  import flash.display3D.Context3D;
  import flash.display3D.Context3DRenderMode;
  import flash.display.StageAlign;
  import flash.utils.getTimer;

  public class AlcConsole extends Sprite
  {
    public static var current:AlcConsole;
    private var enableConsole:Boolean = false;
    private static var _width:int = 1024;
    private static var _height:int = 768;
    private var bm:Bitmap
    private var bmd:BitmapData
    private var vbufferptr:int, vgl_mx:int, vgl_my:int, kp:int, vgl_buttons:int;
    //private var enginetickptr:int
    private var mainloopTickPtr:int, soundUpdatePtr:int, audioBufferPtr:int, resizePtr:int;
    private var _tf:TextField;
    private var inputContainer
    private var keybytes:ByteArray = new ByteArray()
    private var mx:int = 0, my:int = 0, last_mx:int = 0, last_my:int = 0, button:int = 0;
    private var snd:Sound = null
    private var sndChan:SoundChannel = null
    public var sndDataBuffer:ByteArray = null
    private var _stage:Stage3D;
    private var _context:Context3D;
    private var rendered:Boolean = false;
    private var vfs:HttpVFS;
    private var running:Boolean = false;

    public function AlcConsole(container:DisplayObjectContainer = null)
    {
      AlcConsole.current = this;
      stage.frameRate = 60;
      vfs = new HttpVFS();
      vfs.addEventListener(Event.COMPLETE, vfsloaded);
    }
    
    public function vfsloaded(e:*):void
    {
      CModule.getVFS().addBackingStore(vfs, null)
      initG(null);
    }

    private function initG(e:Event):void
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
      
      if(enableConsole) {
      _tf = new TextField;
      _tf.multiline = true;
      _tf.width = _width;
      _tf.height = _height;
      inputContainer.addChild(_tf);
      }

	  _stage = stage.stage3Ds[0];
	  _stage.addEventListener(Event.CONTEXT3D_CREATE, context_created);
	  //_stage.requestContext3D(Context3DRenderMode.AUTO);
	  _stage.requestContext3D("auto");
	}

	private function context_created(e:Event):void
	{
    _context = _stage.context3D;
    _context.configureBackBuffer(_width, _height, 4, true /*enableDepthAndStencil*/ );
    _context.enableErrorChecking = true;

    GLAPI.init(_context, null, stage);
    // Lame Q2 hack...
    GLAPI.instance.genOnBind = true;
    GLAPI.instance.disableCulling = true;
    GLAPI.instance.disableBlending = false;

    var gl:GLAPI = GLAPI.instance;
    gl.context.clear(0.0, 0.0, 0.0);
    gl.context.present();
    this.addEventListener(Event.ENTER_FRAME, runMain);
    stage.addEventListener(Event.RESIZE, stageResize);
  }
    
    private function stageResize(event:Event):void
    {
      if(false) {
        // need to reconfigure back buffer
        _width = stage.stageWidth;
        _height = stage.stageHeight;
        _context.configureBackBuffer(_width, _height, 4, true /*enableDepthAndStencil*/ );
        var args = new Vector.<int>();
        args.push(_width);
        args.push(_height);
        CModule.callFun(resizePtr, args);
      }
    }
    

    private function runMain(event:Event):void
    {
      this.removeEventListener(Event.ENTER_FRAME, runMain);

      initLib(this);
      vbufferptr = CModule.read32(CModule.getPublicSym("__avm2_vgl_argb_buffer"))
      vgl_mx = CModule.getPublicSym("vgl_cur_mx");
      vgl_my = CModule.getPublicSym("vgl_cur_my");
      vgl_buttons = CModule.getPublicSym("vgl_cur_buttons");
      mainloopTickPtr = CModule.getPublicSym("engineTick");
      //resizePtr = CModule.getPublicSym("engineResizeWindow");
       soundUpdatePtr = CModule.getPublicSym("engineTickSound");
      audioBufferPtr = CModule.getPublicSym("audioBuffer");
      addEventListener(Event.ENTER_FRAME, framebufferBlit);
    }

    public function write(fd:int, buf:int, nbyte:int, errno_ptr:int):int
    {
      var str:String = CModule.readString(buf, nbyte);
      i_write(str);
      return nbyte;
    }

    public function read(fd:int, buf:int, nbyte:int, errno_ptr:int):int
    {
      if(fd == 0 && nbyte == 1) {
        keybytes.position = kp++
        if(keybytes.bytesAvailable) {
          CModule.write8(buf, keybytes.readUnsignedByte())
        } else {
        keybytes.position = 0
        kp = 0
        }
      }
      return 0
    }

    public function bufferMouseMove(me:MouseEvent) {
      me.stopPropagation()
      mx = me.stageX
      my = me.stageY
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
      ke.stopPropagation();
      keybytes.writeByte(int(ke.keyCode & 0x7F));
    }
    
    public function bufferKeyUp(ke:KeyboardEvent) 
    {
      ke.stopPropagation();
      keybytes.writeByte(int(ke.keyCode | 0x80));
    }

    public function consoleWrite(s:String):void
    {
      if(enableConsole) {
        _tf.appendText(s);
        _tf.scrollV = _tf.maxScrollV
      }
      trace(s)
    }

    public function i_exit(code:int):void
    {
      consoleWrite("\nexit code: " + code + "\n");
    }

    public function i_error(e:String):void
    {
       consoleWrite("\nexception: " + e + "\n");
    }

    public function i_write(str:String):void
    {
      consoleWrite(str);
    }

    public function sndComplete(e:Event):void
    {
      sndChan.removeEventListener(Event.SOUND_COMPLETE, sndComplete);
      sndChan = snd.play();
      sndChan.addEventListener(Event.SOUND_COMPLETE, sndComplete);
    }

    public function sndData(e:SampleDataEvent):void
    {
      CModule.callFun(soundUpdatePtr, new Vector.<int>)
      e.data.endian = "littleEndian"
      e.data.length = 0
      var ap:int = CModule.read32(audioBufferPtr)
      //e.data.writeBytes(ram, ap, 16384);
      
      for(var i:int=0; i<8192; i+=2) {
        ram.position = ap+i;
        var s:int = ram.readShort()
        var v:Number = (s / 32768.0)
        e.data.writeFloat(v)
      }
    }

    public function framebufferBlit(e:Event):void
    {
      CModule.write32(vgl_mx, mx);
      CModule.write32(vgl_my, my);
      CModule.write32(vgl_buttons, button);

  	  var gl:GLAPI = GLAPI.instance;
      gl.context.clear(0.0, 0.0, 0.0);
  	  CModule.callFun(mainloopTickPtr, new Vector.<int>());
      running = true;
      //trace("------------ PRESENT ----------------")
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
