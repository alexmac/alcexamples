package com.adobe.alchemy
{
  import flash.display.Bitmap
  import flash.display.BitmapData
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.SampleDataEvent;
  import flash.geom.Rectangle
  import flash.media.Sound;
  import flash.media.SoundChannel;
  import flash.net.LocalConnection;
  import flash.net.URLRequest;
  import flash.text.TextField;
  import flash.utils.ByteArray

  import C_Run.ram;
  import com.adobe.alchemyvfs.*;  
  

  /**
  * A basic implementation of a console for Alchemy apps.
  * The PlayerPosix class delegates to this for things like read/write
  * so that console output can be displayed in a TextField on the Stage.
  */
  public class AlcConsole extends Sprite
  {
    private static const _height:int = 768 + 100;
    private static const _width:int = 1024;

    public static var current:AlcConsole;
    public var mx:int = 0, my:int = 0;
    public var sndDataBuffer:ByteArray = null

    private var _tf:TextField;
    private var bm:Bitmap
    private var enableConsole:Boolean = true
    private var runningInWorker:Boolean = false;
    private var frameCount:int = 0;
    private var enginetickptr:int, engineticksoundptr:int
    private var inputContainer
    private var bmd:BitmapData
    private var bmr:Rectangle
    private var keybytes:ByteArray = new ByteArray()
    private var last_mx:int = 0, last_my:int = 0
    private var snd:Sound = null
    private var sndChan:SoundChannel = null
    private var vbuffer:int, vgl_mx:int, vgl_my:int, kp:int
    private const emptyArgs:Vector.<int> = new Vector.<int>;

    public function AlcConsole(container:DisplayObjectContainer = null)
    {
      AlcConsole.current = this;
      if(container) {
        container.addChild(this);
        initG(null);
      } else {
        addEventListener(Event.ADDED_TO_STAGE, initG);
      }
    }

    private function initG(e:Event):void
    {
      inputContainer = new Sprite()
      addChild(inputContainer)

      stage.addEventListener(KeyboardEvent.KEY_DOWN, bufferKeyDown);
      stage.addEventListener(KeyboardEvent.KEY_UP, bufferKeyUp);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, bufferMouseMove);
      stage.frameRate = 60;
      stage.scaleMode = StageScaleMode.NO_SCALE;
      graphics.lineStyle(1, 0xe0e0e0);
      graphics.drawRect(0, 0, _width, _height);
      bmd = new BitmapData(1024,768)
      bm = new Bitmap(bmd)
      bmr = new Rectangle(0,0,bmd.width, bmd.height)
      bmd.fillRect(bmd.rect, 0);
      inputContainer.addChild(bm)
      
      if(enableConsole) {
      _tf = new TextField;
      _tf.multiline = true;
      _tf.width = _width;
      _tf.height = _height;
      inputContainer.addChild(_tf);
      }

      addEventListener(Event.ENTER_FRAME, framebufferBlit);

      //CModule.getVFS().addBackingStore(new RootFSBackingStore(), null);
      try
      {
        CModule.getVFS().setConsole(this);

        // change to false to prevent running main in the background
        // when Workers are supported
        var ns:Namespace = new Namespace("C_Run")
        runningInWorker = ns::workerClass

        if(runningInWorker)
          CModule.bgStart(new <String>["-bgworker"], new <String>[], this)
        else
          ns::initLib(this)
      }
      catch(e:*)
      {
        i_error(e.toString() + "\n" + e.getStackTrace().toString());
        throw e;
      }
      vbuffer = CModule.getPublicSym("__avm2_vgl_argb_buffer")
      vgl_mx = CModule.getPublicSym("vgl_cur_mx")
      vgl_my = CModule.getPublicSym("vgl_cur_my")
      //enginetickptr = CModule.getPublicSym("engineTick")
        
      //initTesting();
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

    public function bufferKeyDown(ke:KeyboardEvent) {
      ke.stopPropagation()
      keybytes.writeByte(int(ke.keyCode & 0x7F))
    }
    
    public function bufferKeyUp(ke:KeyboardEvent) {
      ke.stopPropagation()
      keybytes.writeByte(int(ke.keyCode | 0x80))
    }

    public function consoleWrite(s:String):void
    {
      if(enableConsole) {
        _tf.appendText(s);
        _tf.scrollV = _tf.maxScrollV
      }
      trace(s);
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
      e.data.length = 0
      sndDataBuffer = e.data

      if(frameCount == 0)
        return;

      if(engineticksoundptr == 0)
        engineticksoundptr = CModule.getPublicSym("engineTickSound")

      if(engineticksoundptr)
        CModule.callFun(engineticksoundptr, emptyArgs)
    }

    public function framebufferBlit(e:Event):void
    {
      if(runningInWorker) {
        // Background worker handles blitting
        CModule.uiTick();
        if(vbuffer == 0)
          vbuffer = CModule.getPublicSym("__avm2_vgl_argb_buffer")
      } else {
        CModule.write32(vgl_mx, mx)
        CModule.write32(vgl_my, my)
        CModule.callFun(enginetickptr, emptyArgs)
      }

      ram.position = CModule.read32(vbuffer)
      if (ram.position != 0) {
        frameCount++;
        bmd.setPixels(bmr, ram);
      }

      /*if(!snd)
      {
        snd = new Sound();
        snd.addEventListener( SampleDataEvent.SAMPLE_DATA, sndData );
      }
      if (!sndChan)
      {
        sndChan = snd.play();
        sndChan.addEventListener(Event.SOUND_COMPLETE, sndComplete);
      }*/
    }
  }
}
