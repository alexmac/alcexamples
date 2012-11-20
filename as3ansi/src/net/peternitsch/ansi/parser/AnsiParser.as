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

package net.peternitsch.ansi.parser
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * AnsiParser
	 * Parses extended ASCII (IBM code page 437)
	 * 
	 * @author Peter Nitsch
	 * 
	 */	
	public class AnsiParser extends EventDispatcher
	{

		private var _escapeCommands:EscapeSequencer;
		
		/**
		 *  
		 * 
		 */		
		public function AnsiParser()
		{
			//trace("AS3ANSI by Peter Nitsch : AnsiParser : constructor()");
			_escapeCommands = new EscapeSequencer();
			
			_escapeCommands.addEventListener(CursorEvent.MOVE_BACKWARD, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(CursorEvent.MOVE_DOWN, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(CursorEvent.MOVE_FORWARD, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(CursorEvent.MOVE_UP, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(CursorEvent.REPOSITION, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(CursorEvent.RESTORE_POSITION, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(CursorEvent.SAVE_POSITION, redispatchEvent, false, 0, true);
			
			_escapeCommands.addEventListener(GraphicsEvent.ERASE_UP, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(GraphicsEvent.ERASE_SCREEN, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(GraphicsEvent.ERASE_DOWN, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(GraphicsEvent.ERASE_END_OF_LINE, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(GraphicsEvent.ERASE_LINE, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(GraphicsEvent.ERASE_START_OF_LINE, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(GraphicsEvent.BACKGROUND_COLOR_CHANGED, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(GraphicsEvent.FOREGROUND_COLOR_CHANGED, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(GraphicsEvent.SCROLL_UP, redispatchEvent, false, 0, true);
			
			_escapeCommands.addEventListener(DeviceEvent.QUERY_CURSOR_POSITION, redispatchEvent, false, 0, true);
			_escapeCommands.addEventListener(DeviceEvent.QUERY_STATUS, redispatchEvent, false, 0, true);
		}
		
		private function redispatchEvent(e:Event):void {
			dispatchEvent(e);
		}
		
		private var _request:URLRequest;
		private var _loader:URLLoader;
		
		
		/**
		 * 
		 * @param url	String	ANS file URL
		 * 
		 */		
		public function load( url:String ):void {
			_request =  new URLRequest(url);
			
			if( _loader == null ) {
				_loader = new URLLoader();
				_loader.addEventListener(ProgressEvent.PROGRESS, handleProgress, false, 0, true);
				_loader.addEventListener(IOErrorEvent.IO_ERROR, handleError, false, 0, true );
				_loader.addEventListener(Event.COMPLETE, handleLoadComplete, false, 0, true );
				_loader.dataFormat = URLLoaderDataFormat.BINARY;
			}

			_loader.load( _request );
			
		}
		
		private function handleProgress( e:Event ):void {
			//
		}
		
		private function handleError( e:Event ):void {
			//
		}
		
		private function handleLoadComplete( e:Event ):void {
			var bytes:ByteArray = new ByteArray();
			bytes = e.currentTarget.data;
			parse( bytes );
		}
		
		public function write():ByteArray {
			// TO DO
			
			var result:ByteArray = new ByteArray();
			return result;
		}
		
		
		
		/**
		 * 
		 * @param bytes	ByteArray
		 * 
		 */		
		public function parse( bytes:ByteArray ):void {
			if( bytes != null ) _bytes = bytes;
			dispatchEvent( new Event(Event.INIT) );

			while( _bytes.bytesAvailable > 0 ){
				var result:uint = _bytes.readUnsignedByte();
				
				if( result == CharacterCodes.SUBSTITUTE) {
					dispatchEvent( new Event(Event.COMPLETE) );					
					break;
				} else {
					readByte( result );
				}
				
			}
			
			_bytes.position = 0;
			dispatchEvent( new Event(Event.COMPLETE) );
		}
		
		
		private var _exceptionsLib:Dictionary = new Dictionary(true);
		private var _exceptions:Array = [];
		public function writeException( code:Number, callback:Function ):void {
			if( !hasException(code) ){
				_exceptionsLib[code] = callback;
				_exceptions.push(code);
			}
		}
		
		public function hasException( code:Number ):Boolean {
			if( _exceptions.indexOf(code) != -1 )
				return true;
			return false;
		}
		
		
		private var _bytes:ByteArray;
		public function get data():ByteArray { return _bytes; }
		private var _escapeCommand:Array;
		private var _bufferEscapeCommand:Boolean = false;
		
		public function readByte( byte:uint ):void {
			
			if( byte == CharacterCodes.ESCAPE ){
				_escapeCommand = [];
				_escapeCommand.push(byte);
				_bufferEscapeCommand = true;
			}else {		
				if( _bufferEscapeCommand ) {
					_escapeCommand.push(byte);
					if( _escapeCommands.checkCommandAction(byte) ) {
						_escapeCommands.executeCommand(_escapeCommand);
						_bufferEscapeCommand = false;
					}
				} else if( hasException(byte) ) {
					_exceptionsLib[byte]( byte, _bytes );
				} else if( byte >= 32 ) {
					dispatchEvent(new CursorEvent(CursorEvent.DRAW_CHARACTER, byte));
				} else {		
					switch( byte ){
						case CharacterCodes.BACKSPACE:
							dispatchEvent(new CursorEvent(CursorEvent.MOVE_BACKWARD, null, 1, 0, 0, true));
						break;
						
						case CharacterCodes.LINE_FEED:
							dispatchEvent(new CursorEvent(CursorEvent.MOVE_DOWN, null, 1));
						break;
						
						case CharacterCodes.CARRIAGE_RETURN:
							dispatchEvent(new CursorEvent(CursorEvent.CARRIAGE_RETURN));
						break;
						
						case CharacterCodes.FORM_FEED:
							dispatchEvent( new GraphicsEvent(GraphicsEvent.ERASE_SCREEN) );
							dispatchEvent( new CursorEvent(CursorEvent.REPOSITION, null, 0, 0, 0) );
						break;
					}
				}

			}
		}

		
	}
}