/*
** ADOBE SYSTEMS INCORPORATED
** Copyright 2012 Adobe Systems Incorporated. All Rights Reserved.
**
** NOTICE:  Adobe permits you to use, modify, and distribute this file in
** accordance with the terms of the Adobe license agreement accompanying it.
** If you have received this file from a source other than Adobe, then your use,
** modification, or distribution of it requires the prior written permission of Adobe.
*/

package com.adobe.flascc
{
  import flash.display.DisplayObjectContainer;
  import flash.display.Sprite;
  import flash.display.StageScaleMode;
  import flash.events.Event;
  import flash.events.KeyboardEvent;
  import flash.events.MouseEvent;
  import flash.events.SampleDataEvent;
  import flash.geom.Rectangle
  import flash.net.LocalConnection;
  import flash.net.URLRequest;
  import flash.text.TextField;
  import flash.utils.ByteArray;
  import flash.utils.getTimer;
  import flash.utils.setInterval;
  import flash.ui.Keyboard;
  import net.peternitsch.ansi.viewer.AnsiViewer;
  import net.peternitsch.ansi.parser.CharacterCodes;

  import nethack.vfs.InMemoryBackingStore;
  import nethack.vfs.ISpecialFile;
  import nethack.vfs.zip.*;
  import nethack.CModule;

  /**
  * A basic implementation of a console for FlasCC apps.
  * The PlayerKernel class delegates to this for things like read/write,
  * so that console output can be displayed in a TextField on the Stage.
  */
  public class Console extends Sprite implements ISpecialFile
  {
    private static const _height:int = 768 + 100;
    private static const _width:int = 1024;

    public var mx:int = 0, my:int = 0;
    private var enableConsole:Boolean = true;
    private var frameCount:int = 0;
    private var enginetickptr:int, engineticksoundptr:int, incrementInputAvailable:int;
    private var inputContainer:Sprite;
    private var keybytes:ByteArray = new ByteArray();
    private var last_mx:int = 0, last_my:int = 0;
    private var kp:int = 0;
    private var av:AnsiViewer;
    private const emptyArgs:Vector.<int> = new Vector.<int>;

    [Embed(source="../../../../nethackvfs.zip", mimeType="application/octet-stream")]
    private var nethackvfs:Class;

    public function addZip(bs:InMemoryBackingStore, data:ByteArray):void {
      var zip:Object = new ZipFile(data)
      for (var i:int = 0; i < zip.entries.length; i++) {
        var e:Object = zip.entries[i]
        if (e.isDirectory()) {
          bs.addDirectory("/"+e.name)
          trace("dir: " + e.name)
        } else {
          bs.addFile("/"+e.name, zip.getInput(e))
        }
      }
    }

    /**
    * To Support the preloader case you might want to have the Console
    * act as a child of some other DisplayObjectContainer.
    */
    public function Console(container:DisplayObjectContainer = null, webfs:ByteArray = null, ansiViewer:AnsiViewer = null)
    {
      CModule.rootSprite = container ? container.root : this;
         
      if(CModule.runningAsWorker()) {
        return;
      }

      av = new AnsiViewer(80, 25, false)
      addChild(av.getBitmap())

      var ba:ByteArray = new ByteArray();
      ba.writeMultiByte("Starting World...","utf-8");
      ba.position = 0;
      av.parser.parse( ba );

      if(container) {
        container.addChild(this)
        init(null)
      } else {
        addEventListener(Event.ADDED_TO_STAGE, init)
      }
    }

    /**
    * All of the real FlasCC init happens in this method,
    * which is either run on startup or once the SWF has
    * been added to the stage.
    */
    protected function init(e:Event):void
    {
      inputContainer = new Sprite()
      addChild(inputContainer)
      
      setInterval(serviceUIRequests, 5);

      stage.addEventListener(KeyboardEvent.KEY_DOWN, bufferKeyDown);
//      stage.addEventListener(KeyboardEvent.KEY_UP, bufferKeyUp);
      stage.addEventListener(MouseEvent.MOUSE_MOVE, bufferMouseMove);
      
      stage.frameRate = 60
      stage.scaleMode = StageScaleMode.NO_SCALE
      
      var zfs:InMemoryBackingStore = new InMemoryBackingStore();
      addZip(zfs, new nethackvfs() as ByteArray)

      try
      {
        CModule.vfs.console = this;
        CModule.vfs.addBackingStore(zfs, null)
        CModule.startBackground(this, new <String>[], new <String>["HOME=", "HACKDIR=/"]);
      }
      catch(e:*)
      {
        // If main gives any exceptions make sure we get a full stack trace
        // in our console
        consoleWrite(e.toString() + "\n" + e.getStackTrace().toString())
        throw e
      }


      incrementInputAvailable = CModule.getPublicSymbol("incrementInputAvailable");
    }

    /**
    * The callback to call when FlasCC code calls the <code>posix exit()</code> function. Leave null to exit silently.
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
      return exitHook != null ? exitHook(code) : false;
    }

    /**
    * The PlayerKernel implementation uses this function to handle
    * C IO write requests to the file "/dev/tty" (for example, output from
    * printf will pass through this function). See the ISpecialFile
    * documentation for more information about the arguments and return value.
    */
    public function write(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
    {
      consoleWrite( CModule.readString(bufPtr, nbyte) );

      if( fd != 1 )
        return 0;

      if( nbyte == 1 )
        av.readByte( CModule.read8( bufPtr ) );
      else
      {
         var ba:ByteArray = new ByteArray();   
         CModule.readBytes( bufPtr, nbyte, ba )
         ba.position = 0;
         av.readBytes( ba )
      }
      return nbyte
    }

    public function read(fd:int, bufPtr:int, nbyte:int, errnoPtr:int):int
    {
      if( fd == 0 ) 
      { 
         if ( nbyte == 1 ) 
         {
            keybytes.position = kp++;
            if(keybytes.bytesAvailable) 
            {
               CModule.write8(bufPtr, keybytes.readUnsignedByte());
               return 1;
            } 
            else 
            {
               if( keybytes.length > 0 )
                  keybytes = new ByteArray();
               kp = 0;
            }
         }
         else
         {
            var nread:int = 0;
            for( var i:int = 0; i < nbyte; i++ )
            {
               keybytes.position = kp++;
               if(keybytes.bytesAvailable)
               {
                  CModule.write8(bufPtr + nread, keybytes.readUnsignedByte());
                  nread++;
               }
               else
               {
                  if( keybytes.length > 0 )
                     keybytes = new ByteArray();
                  kp = 0;
               }
            }
            return nread;
         }        
      }
      return 0;
    }

    /**
    * The PlayerKernel implementation uses this function to handle
    * C fcntl requests to the file "/dev/tty." 
    * See the ISpecialFile documentation for more information about the
    * arguments and return value.
    */
    public function fcntl(fd:int, com:int, data:int, errnoPtr:int):int
    {
      return 0
    }

    /**
    * The PlayerKernel implementation uses this function to handle
    * C ioctl requests to the file "/dev/tty." 
    * See the ISpecialFile documentation for more information about the
    * arguments and return value.
    */
    public function ioctl(fd:int, com:int, data:int, errnoPtr:int):int
    {
      return 0
    }

    public function bufferMouseMove(me:MouseEvent):void {
      me.stopPropagation();
      mx = me.stageX;
      my = me.stageY;
    }

    public function bufferKeyDown(ke:KeyboardEvent):void {
      ke.stopPropagation();

      var oldLength:int = keybytes.length

      keybytes.position = keybytes.length;
      if( ke.charCode > 0 ) // TODO: if Alt+ use machine keymap(?)
         keybytes.writeByte(int(ke.charCode));
      else
      {
         var key:Number = ke.keyCode;

         switch (key) 
         {
            case Keyboard.LEFT :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_D);               
            break;
            
            case Keyboard.RIGHT :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_C);
            break;
            
            case Keyboard.UP :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_A);
            break;
            
            case Keyboard.DOWN :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_B);
            break;
            
            case Keyboard.PAGE_UP :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_M);
            break;
            
            case Keyboard.PAGE_DOWN :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_G);
               keybytes.writeByte(CharacterCodes.SEMICOLON);
            break;
            
            case Keyboard.HOME :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_H);
            break;

            case Keyboard.END :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_F);
            break;

            case Keyboard.INSERT:
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_L);
            break;              

            case Keyboard.F1 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_M);
            break;

            case Keyboard.F2 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_N);
            break;

            case Keyboard.F3 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_O);
            break;

            case Keyboard.F4 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_P);
            break;

            case Keyboard.F5 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_Q);
            break;

            case Keyboard.F6 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_R);
            break;

            case Keyboard.F7 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_S);
            break;

            case Keyboard.F8 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_T);
            break;

            case Keyboard.F9 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_U);
            break;

            case Keyboard.F10 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_V);
            break;

            case Keyboard.F11 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_W);
            break;

            case Keyboard.F12 :
               keybytes.writeByte(CharacterCodes.ESCAPE);
               keybytes.writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
               keybytes.writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_X);
            break;
           
            default:
//               key = ke.keyCode;
               keybytes.writeByte( key );
            break;
         }
      }

      /* Increment by however many bytes were added */
      var bytesAdded:int = keybytes.length - oldLength;
      while(bytesAdded--)
        CModule.callI(incrementInputAvailable, emptyArgs)
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

    /**
    * The enterFrame callback is run once every frame. UI thunk requests should be handled
    * here by calling <code>CModule.serviceUIRequests()</code> (see CModule ASdocs for more information on the UI thunking functionality).
    */
    protected function enterFrame(e:Event):void
    {
      CModule.serviceUIRequests()
    }
  }
}
