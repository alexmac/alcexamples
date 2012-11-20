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
	import flash.events.EventDispatcher;
	import flash.utils.Dictionary;
	
	/**
	 * EscapeSequencer
	 * Executes escape code sequences

	 * @author Peter Nitsch
	 * 
	 */	
	public class EscapeSequencer extends EventDispatcher
	{
		/**
		 * 
		 * 
		 */		
		public function EscapeSequencer()
		{
			super(null);
			init();
		}
		
		private var _actionCharacterLib:Dictionary = new Dictionary(true);
		
		private function init():void {
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_H ] = cursorPosition;	
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_F ] = cursorPosition;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_A ] = cursorUp;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_B ] = cursorDown;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_C] = cursorForward;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_D ] = cursorBackward;	
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_S ] = saveCursorPosition;	
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_U ] = restoreCursorPosition;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_K ] = eraseLine;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_J ] = eraseDisplay;	
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_N ] = deviceRequest;
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_M ] = setGraphicsMode;
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_H ] = setMode;	
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_L ] = resetMode;	
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_P ] = setKeyboardStrings;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_M ] = scrollUp;
			
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_A ] = unused;	
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_D ] = unused;	
			_actionCharacterLib[ CharacterCodes.LATIN_SMALL_LETTER_E ] = unused;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_L ] = unused;
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_P ] = unused;
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_E ] = unused;	
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_F ] = unused;
			_actionCharacterLib[ CharacterCodes.LATIN_CAPITAL_LETTER_X ] = unused;
		}

		
		internal function executeCommand( command:Array ):void {
			try {
				_actionCharacterLib[ command[command.length-1] ]( command );
			} catch(error:Error) {
				trace(error);
				
			}
		}
		
		internal function checkCommandAction( character:* ):Boolean {
			var flag:Boolean = false;
			if( _actionCharacterLib[character] != undefined )
				flag = true;
				
			return flag;
		}
		
		
		//_______________________________ Cursor movement functions
		internal function unused( params:Array ):void {
			//trace("Unused Escape Sequence: "+params);
		}
		
		
		internal function deviceRequest( params:Array ):void {

			if( params[2]==CharacterCodes.DIGIT_FIVE ){
				dispatchEvent( new DeviceEvent(DeviceEvent.QUERY_STATUS) );
			} else if( params[2]==CharacterCodes.DIGIT_SIX ) {
				dispatchEvent( new DeviceEvent(DeviceEvent.QUERY_CURSOR_POSITION) );
			} else {
				// 0 - Report Device OK
				// 3 - Report Device Failure 
			}
			
		}
		
		internal function cursorPosition( params:Array ):void {
			var i:Number = 0;
			var lastCharacter:Number = params[params.length-1];
			
			var lineArray:Array = [];
			var lineStr:String = "";
			var line:Number = 0;
			
			var columnArray:Array = [];
			var columnStr:String = "";
			var column:Number = 0;
			
			if(params.indexOf(CharacterCodes.SEMICOLON) != -1){
				var semicolonIndex:Number = params.indexOf(CharacterCodes.SEMICOLON);
				
				if( params[semicolonIndex-1] != CharacterCodes.LEFT_SQUARE_BRACKET ) {
					lineArray = params.slice(2, semicolonIndex);
					for( i=0; i<lineArray.length; i++ ){
						lineStr += (lineArray[i] - 48).toString();
					}
					line = parseInt(lineStr);
				}
				
				columnArray = params.slice(semicolonIndex+1, params.length-1);
				for( i=0; i<columnArray.length; i++ ){
					columnStr += (columnArray[i] - 48).toString();
				}
				column = parseInt(columnStr);
				
			} else if(params.slice(2, params.indexOf(lastCharacter)).length > 0){
				lineArray = params.slice(2, params.length-1);
				for( i=0; i<lineArray.length; i++ ){
					lineStr += (lineArray[i] - 48).toString();
				}
				line = parseInt(lineStr);
			} 
			
			column = (column>0) ? column-1 : 0;
			line = (line>0) ? line-1 : 0;
			
			dispatchEvent( new CursorEvent(CursorEvent.REPOSITION, null, 0, column, line) );
		}
		
		internal function cursorUp( params:Array ):void {
				
			var valueArray:Array = params.slice(2, params.length-1);
			var valueStr:String = "";
			for( var i:Number=0; i<valueArray.length; i++ ){
				valueStr += (valueArray[i] - 48).toString();
			}
			var value:Number = (valueStr.length > 0) ? parseInt(valueStr) : 1;
			
			dispatchEvent( new CursorEvent(CursorEvent.MOVE_UP, null, value) );
		}
		
		internal function cursorDown( params:Array ):void {
;	
			var valueArray:Array = params.slice(2, params.length-1);
			var valueStr:String = "";
			for( var i:Number=0; i<valueArray.length; i++ ){
				valueStr += (valueArray[i] - 48).toString();
			}
			var value:Number = (valueStr.length > 0) ? parseInt(valueStr) : 1;
			
			dispatchEvent( new CursorEvent(CursorEvent.MOVE_DOWN, null, value) );
		}
		
		internal function cursorForward( params:Array ):void {		
			
			var valueArray:Array = params.slice(2, params.length-1);
			var valueStr:String = "";
			for( var i:Number=0; i<valueArray.length; i++ ){
				valueStr += (valueArray[i] - 48).toString();
			}
			var value:Number = (valueStr.length > 0) ? parseInt(valueStr) : 1;
				
			dispatchEvent( new CursorEvent(CursorEvent.MOVE_FORWARD, null, value) );
		}
		
		internal function cursorBackward( params:Array ):void {
			
			var valueArray:Array = params.slice(2, params.length-1);
			var valueStr:String = "";
			for( var i:Number=0; i<valueArray.length; i++ ){
				valueStr += (valueArray[i] - 48).toString();
			}
			var value:Number = (valueStr.length > 0) ? parseInt(valueStr) : 1;
			
			dispatchEvent( new CursorEvent(CursorEvent.MOVE_BACKWARD, null, value) );
		}
		
		internal function saveCursorPosition( params:Array ):void {
			dispatchEvent( new CursorEvent(CursorEvent.SAVE_POSITION) );
		}
		
		internal function restoreCursorPosition( params:Array ):void {
			dispatchEvent( new CursorEvent(CursorEvent.RESTORE_POSITION) );
		}
		
		
		//_______________________________ Set Graphic Mode functions
		
		private var _bold:Boolean = false;
		private var _reverse:Boolean = false;
		
		private var _boldColors:Array = [SixteenColors.BLACK_BOLD, SixteenColors.RED_BOLD, SixteenColors.GREEN_BOLD, SixteenColors.YELLOW_BOLD, SixteenColors.BLUE_BOLD, SixteenColors.MAGENTA_BOLD, SixteenColors.CYAN_BOLD, SixteenColors.WHITE_BOLD];
		private var _normalColors:Array = [SixteenColors.BLACK_NORMAL, SixteenColors.RED_NORMAL, SixteenColors.GREEN_NORMAL, SixteenColors.YELLOW_NORMAL, SixteenColors.BLUE_NORMAL, SixteenColors.MAGENTA_NORMAL, SixteenColors.CYAN_NORMAL, SixteenColors.WHITE_NORMAL];		
		
		private var _currentForegroundColor:uint = SixteenColors.WHITE_NORMAL;
		private var _currentBackgroundColor:uint = SixteenColors.BLACK_NORMAL;
		
		internal function setGraphicsMode( params:Array ):void {
			
			for( var i:Number=2; i<params.length; i++ ){
				switch( params[i] ){

					/*  Reset */
					case CharacterCodes.LATIN_SMALL_LETTER_M:
					case CharacterCodes.DIGIT_ZERO:
						if(params[i-1] == CharacterCodes.SEMICOLON || params[i-1] == CharacterCodes.LEFT_SQUARE_BRACKET){
							_bold = false;
							_reverse = false;
							
							_currentForegroundColor = SixteenColors.WHITE_NORMAL;
							_currentBackgroundColor = SixteenColors.BLACK_NORMAL;
							
							dispatchEvent( new GraphicsEvent(GraphicsEvent.FOREGROUND_COLOR_CHANGED, _currentForegroundColor) );
							dispatchEvent( new GraphicsEvent(GraphicsEvent.BACKGROUND_COLOR_CHANGED, _currentBackgroundColor) );
						}
					break;
					
					/*  Bold ON */
					case CharacterCodes.DIGIT_ONE:
						if(params[i-1] == CharacterCodes.SEMICOLON || params[i-1] == CharacterCodes.LEFT_SQUARE_BRACKET) {
							_bold = true;

							for( var j:Number=0; j<_normalColors.length; j++ ){
								if( _currentForegroundColor == _normalColors[j] )
									_currentForegroundColor = _boldColors[j];
							}
							
							dispatchEvent( new GraphicsEvent(GraphicsEvent.FOREGROUND_COLOR_CHANGED, _currentForegroundColor) );
						}
					break;
					
					/* Dim */
					case CharacterCodes.DIGIT_TWO:						
						if(params[i-1] == CharacterCodes.SEMICOLON || params[i-1] == CharacterCodes.LEFT_SQUARE_BRACKET) {
							_bold = false;

							for( var j:Number=0; j<_normalColors.length; j++ ){
								if( _currentForegroundColor == _boldColors[j] )
									_currentForegroundColor = _normalColors[j];
							}
							
							dispatchEvent( new GraphicsEvent(GraphicsEvent.FOREGROUND_COLOR_CHANGED, _currentForegroundColor) );
						}
					break;
					
					/* Set foreground color */
					case CharacterCodes.DIGIT_THREE:
						if(params[i-1] == CharacterCodes.SEMICOLON || params[i-1] == CharacterCodes.LEFT_SQUARE_BRACKET){
							if(params[i+1] != CharacterCodes.SEMICOLON && params[i+1] != CharacterCodes.LATIN_SMALL_LETTER_M){
								
								var position:Number = params[i+1] - 48;
								if(_reverse) {
									_currentBackgroundColor = _normalColors[position];
									dispatchEvent( new GraphicsEvent(GraphicsEvent.BACKGROUND_COLOR_CHANGED, _currentBackgroundColor) );
								}else {
									_currentForegroundColor = (_bold) ? _boldColors[position] : _normalColors[position];
									dispatchEvent( new GraphicsEvent(GraphicsEvent.FOREGROUND_COLOR_CHANGED, _currentForegroundColor) );
								}
								
							}
						}
					break;
					
					/* Set background color */
					case CharacterCodes.DIGIT_FOUR:
						if(params[i-1] == CharacterCodes.SEMICOLON || params[i-1] == CharacterCodes.LEFT_SQUARE_BRACKET){
							if(params[i+1] != CharacterCodes.SEMICOLON && params[i+1] != CharacterCodes.LATIN_SMALL_LETTER_M){
								
								position = params[i+1] - 48;
								if(_reverse) {
									_currentForegroundColor = (_bold) ? _boldColors[position] : _normalColors[position];
									dispatchEvent( new GraphicsEvent(GraphicsEvent.FOREGROUND_COLOR_CHANGED, _currentForegroundColor) );
								} else {
									_currentBackgroundColor = _normalColors[position];
									dispatchEvent( new GraphicsEvent(GraphicsEvent.BACKGROUND_COLOR_CHANGED, _currentBackgroundColor) );
								}
							
							/* Underline ON */		
							} else {
								// TO DO
							}
						}
					break;
					
					/* Blink ON */
					case CharacterCodes.DIGIT_FIVE:
						// TO DO
					break;
					
					/* Reverse ON */
					case CharacterCodes.DIGIT_SEVEN:
						if(params[i-1] == CharacterCodes.SEMICOLON || params[i-1] == CharacterCodes.LEFT_SQUARE_BRACKET)
							_reverse = true;
					break;
					
					/* Concealed ON */
					case CharacterCodes.DIGIT_EIGHT:
						// TO DO
					break;
					
					/* Reset to normal? */
					case CharacterCodes.DIGIT_NINE:
						// TO DO
					break;
				}
			}
		}
		
		internal function scrollUp( params:Array ):void {
			dispatchEvent( new GraphicsEvent(GraphicsEvent.SCROLL_UP) );
		}
		
		internal function eraseDisplay( params:Array ):void {
			if( params[2]==CharacterCodes.DIGIT_ONE ){
				dispatchEvent( new GraphicsEvent(GraphicsEvent.ERASE_UP) );
				dispatchEvent( new CursorEvent(CursorEvent.REPOSITION, null, 0, 0, 0) );
			} else if( params[2]==CharacterCodes.DIGIT_TWO ) {
				dispatchEvent( new GraphicsEvent(GraphicsEvent.ERASE_SCREEN) );
				dispatchEvent( new CursorEvent(CursorEvent.REPOSITION, null, 0, 0, 0) );
			} else {
				dispatchEvent( new GraphicsEvent(GraphicsEvent.ERASE_DOWN) );
			}
		}
		
		internal function eraseLine( params:Array ):void {
			if( params[2]==CharacterCodes.DIGIT_ONE ){
				dispatchEvent( new GraphicsEvent(GraphicsEvent.ERASE_START_OF_LINE) );
			} else if( params[2]==CharacterCodes.DIGIT_TWO ) {
				dispatchEvent( new GraphicsEvent(GraphicsEvent.ERASE_LINE) );
			} else {
				dispatchEvent( new GraphicsEvent(GraphicsEvent.ERASE_END_OF_LINE) );
			}
					
		}
		
		
		//_______________________________ Terminal functions
		internal function setMode( params:Array ):void {
			// TO DO
		}
		
		internal function resetMode( params:Array ):void {
			// TO DO
		}
		
		internal function setKeyboardStrings( params:Array ):void {
			// TO DO
		}

	}
}