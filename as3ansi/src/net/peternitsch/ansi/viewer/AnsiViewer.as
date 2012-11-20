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

package net.peternitsch.ansi.viewer
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.PixelSnapping;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.ByteArray;
	
	import net.peternitsch.ansi.parser.AnsiParser;
	import net.peternitsch.ansi.parser.CharacterCodes;
	import net.peternitsch.ansi.parser.CursorEvent;
	import net.peternitsch.ansi.parser.GraphicsEvent;
	
	/**
	 * AnsiViewer
	 * Tool for Flex applications that generates Sprites and Bitmaps from ANS files. 
	 * Uses Perfect DOS VGA 437 font (by Zeh Fernando) for character creation.
	 * 
	 * @author Peter Nitsch
	 * @version 0.1
	 * 
	 */	
	public class AnsiViewer extends EventDispatcher
	{
		
		/**
		 * 
		 * @param columnWidth
		 * @param lineHeight
		 * @param scroll
		 * 
		 */				
		public function AnsiViewer( columnWidth:Number=80, lineHeight:Number=25, scroll:Boolean=true )
		{
			//trace("AS3ANSI by Peter Nitsch : AnsiViewer : constructor()");
			this.scroll = scroll;
			cursor = new Cursor();

			cursor.maxColumnWidth = columnWidth;
			cursor.maxColumns = columnWidth;
			if(lineHeight==0)
				cursor.infiniteHeight = true;
			cursor.maxLineHeight = (lineHeight==0) ? 24 : lineHeight;
			
			init();
			flush(cursor.columnWidth*cursor.maxColumnWidth, cursor.lineHeight*cursor.maxLineHeight);
		}
		
		/**
		 * 
		 */		
		public var cursor:Cursor; 
		 
		public var scroll:Boolean = false;
		
		public var parser:AnsiParser
		
		protected function init():void {
			parser = new AnsiParser();
			
			parser.addEventListener(Event.COMPLETE, handleComplete, false, 0, true);
			
			parser.addEventListener(CursorEvent.CARRIAGE_RETURN, handleCarriageReturn, false, 0, true);
			parser.addEventListener(CursorEvent.DRAW_CHARACTER, handleDrawCharacter, false, 0, true);
			parser.addEventListener(CursorEvent.FORM_FEED, handleFormFeed, false, 0, true);
			parser.addEventListener(CursorEvent.MOVE_BACKWARD, handleMoveBackward, false, 0, true);
			parser.addEventListener(CursorEvent.MOVE_DOWN, handleMoveDown, false, 0, true);
			parser.addEventListener(CursorEvent.MOVE_FORWARD, handleMoveForward, false, 0, true);
			parser.addEventListener(CursorEvent.MOVE_UP, handleMoveUp, false, 0, true);
			parser.addEventListener(CursorEvent.REPOSITION, handleReposition, false, 0, true);
			parser.addEventListener(CursorEvent.RESTORE_POSITION, handleRestorePosition, false, 0, true);
			parser.addEventListener(CursorEvent.SAVE_POSITION, handleSavePosition, false, 0, true);
			
			//parser.addEventListener(GraphicsEvent.CLEAR, handleDisplayCleared);
			parser.addEventListener(GraphicsEvent.ERASE_UP, handleEraseUp, false, 0, true);
			parser.addEventListener(GraphicsEvent.ERASE_SCREEN, handleEraseScreen, false, 0, true);
			parser.addEventListener(GraphicsEvent.ERASE_DOWN, handleEraseDown, false, 0, true);
			parser.addEventListener(GraphicsEvent.ERASE_END_OF_LINE, handleEraseEndOfLine, false, 0, true);
			parser.addEventListener(GraphicsEvent.ERASE_LINE, handleEraseLine, false, 0, true);
			parser.addEventListener(GraphicsEvent.ERASE_START_OF_LINE, handleEraseStartOfLine, false, 0, true);
			parser.addEventListener(GraphicsEvent.BACKGROUND_COLOR_CHANGED, handleBackgroundColorChanged, false, 0, true);
			parser.addEventListener(GraphicsEvent.FOREGROUND_COLOR_CHANGED, handleForegroundColorChanged, false, 0, true);
			parser.addEventListener(GraphicsEvent.SCROLL_UP, handleScrollUp, false, 0, true);
		}
		
		protected var _bitmap:Bitmap;
		
		/**
		 * 
		 * @return	Bitmap
		 * 
		 */		
		public function getBitmap():Bitmap {
			return _bitmap;
		}
		
		/**
		 * 
		 * @param filename
		 * 
		 */		
		public function load( filename:String ):void {
			flush();
			parser.load(filename);
		}
		
		public function readByte( byte:uint ):void {
			parser.readByte( byte );
		}
		
		public function readBytes( bytes:ByteArray ):void {
			parser.parse( bytes );
		}
		
		public function reset(columnWidth:Number=80, lineHeight:Number=25):void {
			this.scroll = scroll;

			cursor.maxColumnWidth = columnWidth;
			cursor.maxColumns = columnWidth;
			if(lineHeight==0)
				cursor.infiniteHeight = true;
			cursor.maxLineHeight = (lineHeight==0) ? 24 : lineHeight;

			flush(cursor.columnWidth*cursor.maxColumnWidth, cursor.lineHeight*cursor.maxLineHeight);
		}
		
		public function flush(w:Number=640, h:Number=400):void {
			cursor.position = new Point();
			_bitmap = new Bitmap(new BitmapData((w>8190)?8190:w, (h>8190)?8190:h, false, 0), PixelSnapping.NEVER, true);
			dispatchEvent(new ViewerEvent(ViewerEvent.FLUSH));
		}
		
		public function scrollUp():void {
			var rect:Rectangle = new Rectangle(0, cursor.lineHeight, cursor.maxColumnWidth * cursor.columnWidth, cursor.maxLineHeight * cursor.lineHeight);
			var scroll:BitmapData = _bitmap.bitmapData.clone();
			handleDisplayCleared(null);
			_bitmap.bitmapData.copyPixels(scroll, rect, new Point());
		}
		
		public function get position():Point {
			return cursor.position;
		}
		
		public function get foreground():uint {
			return cursor.foregroundColor;
		}
		
		public function get background():uint {
			return cursor.backgroundColor;
		}
		
		//_______________________________ Parser handlers
		
		public function handleComplete(e:Event):void {
			dispatchEvent(e);
		}
		
		public function handleCarriageReturn(e:CursorEvent):void {
			cursor.carriageReturn();
		}
		
		public function handleDrawCharacter(e:CursorEvent):void {

			var character:Character = CharacterFactory.produce(e.character, cursor.foregroundColor, cursor.backgroundColor, cursor.columnWidth, cursor.lineHeight);
			
			if( character != null ) {
				character.x = cursor.position.x;
				character.y = cursor.position.y;

				if( cursor.position.x + cursor.columnWidth >= cursor.maxColumnWidth * cursor.columnWidth ){
					handleMoveDown( new CursorEvent(CursorEvent.MOVE_DOWN, null, 1) );
					cursor.carriageReturn();
				} else {
					cursor.moveForward();
				}
				
				drawCharacter( character );
				character = null;
			}
						
		}
		
		public function drawCharacter( character:Character ):void {
			var matrix:Matrix = new Matrix(1, 0, 0, 1, character.x, character.y);
			_bitmap.bitmapData.draw(character, matrix);
			character = null;
		}
		
		public function handleFormFeed(e:CursorEvent):void {
			cursor.position.x = 0;
			cursor.position.y = 0;
		}
		
		public function handleMoveBackward(e:CursorEvent):void {
			var movements:Number = e.value;
			
			while( movements > 0 ) {
				if( e.erase ) {
					var char:Character = CharacterFactory.produce(CharacterCodes.SPACE, cursor.foregroundColor, cursor.backgroundColor, cursor.columnWidth, cursor.lineHeight);
					char.x = cursor.position.x - cursor.columnWidth;
					char.y = cursor.position.y;
					drawCharacter(char);
				}
				cursor.moveBackward( 1 );
				movements--;
			}

		}
		
		public function handleMoveDown(e:CursorEvent):void {
			if( cursor.moveDown(e.value) && scroll ){
				scrollUp();
			}
		}
		
		public function handleMoveForward(e:CursorEvent):void {
			cursor.moveForward( e.value );
		}
		
		public function handleMoveUp(e:CursorEvent):void {
			cursor.moveUp( e.value );
		}
		
		public function handleReposition(e:CursorEvent):void {
			cursor.position = new Point(e.position.x * cursor.columnWidth, e.position.y * cursor.lineHeight);
		}
		
		public var _savedPosition:Point = new Point();
		
		public function handleRestorePosition(e:CursorEvent):void {
			cursor.position = _savedPosition;
		}
		
		public function handleSavePosition(e:CursorEvent):void {
			_savedPosition = new Point(cursor.position.x, cursor.position.y);
		}
		
		public function handleDisplayCleared(e:GraphicsEvent):void {
			_bitmap.bitmapData.fillRect(new Rectangle(0, 0, cursor.maxColumnWidth * cursor.columnWidth, cursor.maxLineHeight * cursor.lineHeight), 0);
		}
		
		public function handleEraseUp(e:GraphicsEvent):void {
			_bitmap.bitmapData.fillRect(new Rectangle(0, 0, cursor.maxColumnWidth * cursor.columnWidth, cursor.position.y), 0);
		}
		
		public function handleEraseScreen(e:GraphicsEvent):void {
			_bitmap.bitmapData.fillRect(new Rectangle(0, 0, cursor.maxColumnWidth * cursor.columnWidth, cursor.maxLineHeight * cursor.lineHeight), cursor.backgroundColor);
		}
		
		public function handleEraseDown(e:GraphicsEvent):void {
			_bitmap.bitmapData.fillRect(new Rectangle(0, cursor.position.y, cursor.maxColumnWidth * cursor.columnWidth, (cursor.maxLineHeight * cursor.lineHeight) - cursor.position.y), 0);
		}	
		
		public function handleEraseEndOfLine(e:GraphicsEvent):void {
			var w:Number = (cursor.maxColumnWidth * cursor.columnWidth) - (cursor.position.x - cursor.columnWidth);
			_bitmap.bitmapData.fillRect(new Rectangle(cursor.position.x, cursor.position.y, w, cursor.lineHeight), 0);
		}
		
		public function handleEraseStartOfLine(e:GraphicsEvent):void {
			_bitmap.bitmapData.fillRect(new Rectangle(0, cursor.position.y, cursor.position.x, cursor.lineHeight), 0);
		}
		
		public function handleEraseLine(e:GraphicsEvent):void {
			_bitmap.bitmapData.fillRect(new Rectangle(0, cursor.position.y, cursor.maxColumnWidth * cursor.columnWidth, cursor.lineHeight), 0);
		}
		
		public function handleBackgroundColorChanged(e:GraphicsEvent):void {
			cursor.backgroundColor = e.color;
		}
			
		public function handleForegroundColorChanged(e:GraphicsEvent):void {
			cursor.foregroundColor = e.color;
		}
		
		public function handleScrollUp(e:GraphicsEvent):void {
			scrollUp();
		}

	}
}






