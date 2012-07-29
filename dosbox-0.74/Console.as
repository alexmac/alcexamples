package flascc
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
  import flascc.vfs.*;  
  

  /**
  * A basic implementation of a console for Alchemy apps.
  * The PlayerPosix class delegates to this for things like read/write
  * so that console output can be displayed in a TextField on the Stage.
  */
  public class Console extends Sprite implements ISpecialFile
  {
    private static const _height:int = 768 + 100;
    private static const _width:int = 1024;

    public var mx:int = 0, my:int = 0;
    public var sndDataBuffer:ByteArray = null

    private var _tf:TextField;
    private var bm:Bitmap
    private var enableConsole:Boolean = false
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

    public function Console(container:DisplayObjectContainer = null)
    {
      CModule.rootSprite = container ? container.root : this
 
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
    private function init(e:Event):void
    {
      inputContainer = new Sprite()
      addChild(inputContainer)

      addEventListener(Event.ENTER_FRAME, enterFrame)

      stage.addEventListener(KeyboardEvent.KEY_DOWN, bufferKeyDown);
      stage.addEventListener(KeyboardEvent.KEY_UP, bufferKeyUp);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, bufferMouseMove);
      stage.frameRate = 60
      stage.scaleMode = StageScaleMode.NO_SCALE
      bmd = new BitmapData(1024,768)
      bm = new Bitmap(bmd)
      bmr = new Rectangle(0,0,bmd.width, bmd.height)
      bmd.fillRect(bmd.rect, 0);
      inputContainer.addChild(bm)
      
      if(enableConsole) {
        _tf = new TextField
        _tf.multiline = true
        _tf.width = stage.stageWidth
        _tf.height = stage.stageHeight 
        inputContainer.addChild(_tf)
      }

      try
      {
        CModule.vfs.console = this;

        CModule.startBackground(
              this,
              new <String>["dosbox", "/duke3d_install/DUKE3D/DUKE3D.EXE"],
              new <String>[])
      }
      catch(e:*)
      {
        // If main gives any exceptions make sure we get a full stack trace
        // in our console
        consoleWrite(e.toString() + "\n" + e.getStackTrace().toString())
        throw e
      }
      vbuffer = CModule.getPublicSymbol("__avm2_vgl_argb_buffer")
      vgl_mx = CModule.getPublicSymbol("vgl_cur_mx")
      vgl_my = CModule.getPublicSymbol("vgl_cur_my")
    }

    public function write(fd:int, buf:int, nbyte:int, errno_ptr:int):int
    {
      var str:String = CModule.readString(buf, nbyte)
      consoleWrite(str)
      return nbyte
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

    /**
    * Helper function that traces to the flashlog text file and also
    * displays output in the on-screen textfield console.
    */
    private function consoleWrite(s:String):void
    {
      trace(s)
      if(enableConsole) {
        _tf.appendText(s)
        _tf.scrollV = _tf.maxScrollV
      }
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
        engineticksoundptr = CModule.getPublicSymbol("engineTickSound")

      if(engineticksoundptr)
        CModule.callI(engineticksoundptr, emptyArgs)
    }

    public function enterFrame(e:Event):void
    {
        // Background worker handles blitting
        CModule.serviceUIRequests();
        if(vbuffer == 0)
          vbuffer = CModule.getPublicSymbol("__avm2_vgl_argb_buffer")
     // } else {
     //   CModule.write32(vgl_mx, mx)
     //   CModule.write32(vgl_my, my)
     //   CModule.callFun(enginetickptr, emptyArgs)
     // }

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
