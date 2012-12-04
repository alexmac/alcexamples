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
	import flash.geom.Point;
	
	import net.peternitsch.ansi.parser.SixteenColors;
	
	/**
	 * Cursor
	 * 
	 * 
	 * @author Peter Nitsch
	 * 
	 */	
	public class Cursor
	{	
		public var foregroundColor:uint = SixteenColors.WHITE_NORMAL;
		public var backgroundColor:uint = SixteenColors.BLACK_NORMAL;
		public var position:Point = new Point();
		
		public var maxColumnWidth:Number = 0;
		public var maxLineHeight:Number = 0;
		public var columnWidth:Number = 8;
		public var lineHeight:Number = 16;
		public var maxColumns:Number = 80;
		
		public var infiniteWidth:Boolean = false;
		public var infiniteHeight:Boolean = false;
		
		public function Cursor():void {
			
		}

		public function get x():int {
			return position.x;
		}

		public function get y():int {
			return position.y;
		}


		public function moveForward( columns:Number=1 ):void {
			if( position.x + (columns*columnWidth) <= maxColumns * columnWidth )
				position.x = position.x + (columns*columnWidth);
			else
				position.x = (maxColumns * columnWidth) - columnWidth;
		}
		
		public function moveBackward( columns:Number=1 ):void {
			if( position.x - (columns*columnWidth) >= 0 )
				position.x = position.x - (columns*columnWidth);
			else
				position.x = 0;
		}
		
		public function moveDown( lines:Number=1 ):Boolean {
			if( !infiniteHeight && maxLineHeight > 0 && (position.y + (lines*lineHeight)) >= (maxLineHeight*lineHeight) ){
				return true;
			}else{
				position.y = position.y + (lines*lineHeight);
			}
			return false;
		}
		
		public function moveUp( lines:Number=1 ):void {
			if( position.y - (lines*lineHeight) >= 0 ) 
				position.y = position.y - (lines*lineHeight);
			else
				position.y = 0;
		}
		
		public function carriageReturn():void {
			position.x = 0;
		}
	}
}