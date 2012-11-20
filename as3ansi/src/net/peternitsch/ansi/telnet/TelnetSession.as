/* Copyright (c) 2008-2009 Peter Nitsch

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE. */

package net.peternitsch.ansi.telnet
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.*;
	import flash.geom.Point;
	import flash.net.Socket;
	import flash.ui.Keyboard;
	import flash.utils.ByteArray;
	import flash.utils.Timer;
	
	import net.peternitsch.ansi.parser.CharacterCodes;
	import net.peternitsch.ansi.parser.DeviceEvent;
	import net.peternitsch.ansi.viewer.AnsiViewer;
	import net.peternitsch.ansi.viewer.Cursor;

	public class TelnetSession extends Socket
	{
		internal var viewer:AnsiViewer; 
		
		private var _serverURL:String;
		private var _portNumber:int;
		private var _commands:Commands;
		private var _stage:Stage;
		
		/**
		 * 
		 * @param ansiviewer
		 * @param host
		 * @param port
		 * 
		 */		
		public function TelnetSession(ansiviewer:AnsiViewer, host:String=null, port:Number=0, stage:Stage=null)
		{
			trace("AS3ANSI by Peter Nitsch : TelnetSession : constructor()");
			super(host, port);
			
			viewer = ansiviewer;
			viewer.parser.addEventListener(DeviceEvent.QUERY_CURSOR_POSITION, handleQueryCursorPosition, false, 0, true);
			viewer.parser.addEventListener(DeviceEvent.QUERY_STATUS, handleQueryStatus, false, 0, true);
			
			_commands = new Commands( this );
			
			_serverURL = host;
			_portNumber = port;
			_stage = stage;
			
			addEventListener(Event.CONNECT, handleConnect, false, 0, true);
		    addEventListener(Event.CLOSE, handleClose, false, 0, true);
		    addEventListener(ErrorEvent.ERROR, handleError, false, 0, true);
		    addEventListener(IOErrorEvent.IO_ERROR, handleIOError, false, 0, true);
		    addEventListener(ProgressEvent.SOCKET_DATA, handleSocketData, false, 0, true);
			
		    
		}
		
		/**
		 * 
		 * @param host
		 * @param port
		 * 
		 */		
		public function resetURL(host:String=null, port:Number=0):void {
			_serverURL = host;
			_portNumber = port;
		}
		
		/**
		 * 
		 * 
		 */		
		public function start():void {
			try {
		       	connect(_serverURL, _portNumber);
		    } catch (error:Error) {
		        trace(error.message);
		        close();
		    }
		}
		
		/**
		 * 
		 * @param code
		 * 
		 */		
		public function write( code:Number ):void
		{
			var byteObject:Object = new Object();
			byteObject.byteArray = new ByteArray();
		    
		    byteObject.byteArray.writeMultiByte(String.fromCharCode(code), "us-ascii");
		    writeBytes(byteObject.byteArray);
		    flush();
		    
		    delete byteObject.byteArray;
		}
		 
		public var cursor:Sprite;
		private var cursorTimer:Timer;
		private var cursorOffset:Point;
		public function drawCursor( offsetX:Number=0, offsetY:Number=0 ):Sprite {
			cursorOffset = new Point(offsetX, offsetY);
			
			//cursor = CharacterFactory.produce(CharacterCodes.LOW_LINE);
			cursor = new Sprite();
			cursor.graphics.beginFill(0xcccccc);
			cursor.graphics.drawRect(0, Cursor.lineHeight-1, Cursor.columnWidth, 1);
			cursor.x = cursorOffset.x;
			cursor.y = cursorOffset.y;
			cursorTimer = new Timer(500);
			cursorTimer.addEventListener(TimerEvent.TIMER, handleCursorTimer, false, 0, true);
			cursorTimer.start();
			
			return cursor;
		}
		
		public function removeCursor():void {
			cursorTimer.removeEventListener(TimerEvent.TIMER, handleCursorTimer);
		}
		
		//_______________________________ Socket handlers

		private function handleCursorTimer(e:TimerEvent):void {
			cursor.alpha = (cursor.alpha==1) ? 0 : 1;
		}
		
		private function handleUserInput(e:KeyboardEvent):void {
			var key:Number = e.keyCode;
			
			// TO DO
			switch (key) {
				case Keyboard.LEFT :
					writeByte(CharacterCodes.ESCAPE);
					writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
					writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_D);
					flush();
				break;
				
				case Keyboard.RIGHT :
					writeByte(CharacterCodes.ESCAPE);
					writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
					writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_C);
					flush();
				break;
				
				case Keyboard.UP :
					writeByte(CharacterCodes.ESCAPE);
					writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
					writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_A);
					flush();
				break;
				
				case Keyboard.DOWN :
					writeByte(CharacterCodes.ESCAPE);
					writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
					writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_B);
					flush();
				break;
				
				case Keyboard.PAGE_UP :
					writeByte(CharacterCodes.ESCAPE);
					writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
					writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_M);
					flush();
				break;
				
				case Keyboard.PAGE_DOWN :
					writeByte(CharacterCodes.ESCAPE);
					writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
					writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_H);
					writeByte(CharacterCodes.SEMICOLON);
					writeByte(CharacterCodes.ESCAPE);
					writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
					writeByte(CharacterCodes.DIGIT_TWO);
					writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_J);
					flush();
				break;
				
				case Keyboard.HOME :
					writeByte(CharacterCodes.ESCAPE);
					writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
					writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_H);
					flush();
				break;
				
				default:
					key = e.charCode;
					write( key );
				break;
			}
			
		}
		
		private function handleClose(e:Event):void {
	      	var canvas:Bitmap = viewer.getBitmap();
			canvas.stage.removeEventListener(KeyboardEvent.KEY_DOWN, handleUserInput);
			canvas.stage.removeEventListener(Event.ENTER_FRAME, handleEnterFrame);
			close();
	    }
	    
	    private function handleSocketData(e:ProgressEvent):void {    
	    	//
	    }
	    
	    public static var BAUD:Number = 33600;
	    
	    private function handleEnterFrame(e:Event):void {
	    	var byteObject:Object = new Object();
			byteObject.byteArray = new ByteArray();

	    	if(bytesAvailable > BAUD/_stage.frameRate ){ 
	    		readBytes(byteObject.byteArray, 0, BAUD/_stage.frameRate);
	    		viewer.readBytes(byteObject.byteArray);
	    	} else if(bytesAvailable < BAUD/_stage.frameRate && bytesAvailable > 0){
	    		
	    		if( bytesAvailable == 1 ){
	    			viewer.readByte(readByte());
	    		} else {
	    			readBytes(byteObject.byteArray, 0, bytesAvailable);
	    			viewer.readBytes(byteObject.byteArray);
	    		}
	    	} 
	    	
	    	byteObject.byteArray = null;
	    	delete byteObject.byteArray;
	    	
	    	if( cursor != null ){
		    	cursor.x = Cursor.position.x + cursorOffset.x;
				cursor.y = Cursor.position.y + cursorOffset.y;
				//cursor.foreground = Cursor.foregroundColor;
				//cursor.background = Cursor.backgroundColor;
	    	}
			
	    }
		
	    private function handleConnect(e:Event):void {    	
			var canvas:Bitmap = viewer.getBitmap();
			canvas.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleUserInput, false, 0, true);
			canvas.stage.addEventListener(Event.ENTER_FRAME, handleEnterFrame, false, 0, true);
			canvas.stage.focus = canvas.stage;
	    }
		
		private function handleError(e:ErrorEvent):void {
	    	trace("errorHandler: " + e);
	    }
	    
	    private function handleIOError(e:IOErrorEvent):void {
	        trace("ioErrorHandler: " + e);
	    }
	    
	    private function handleQueryCursorPosition(e:DeviceEvent):void {
			writeByte(CharacterCodes.ESCAPE);
			writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
			writeInt(viewer.cursor.y);
			writeByte(CharacterCodes.SEMICOLON);
			writeInt(viewer.cursor.x);
			writeByte(CharacterCodes.LATIN_CAPITAL_LETTER_R);
			flush();
		}
		
		private function handleQueryStatus(e:DeviceEvent):void {
			writeByte(CharacterCodes.ESCAPE);
			writeByte(CharacterCodes.LEFT_SQUARE_BRACKET);
			writeByte(CharacterCodes.DIGIT_ZERO);
			writeByte(CharacterCodes.LATIN_SMALL_LETTER_N);
			flush();
		}
	
	}
}