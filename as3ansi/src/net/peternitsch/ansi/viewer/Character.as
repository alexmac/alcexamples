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
	import flash.display.Sprite;
	import flash.text.TextField;
	import flash.text.TextFormat;

	/**
	 * Character
	 * 
	 * 
	 * @author Peter Nitsch
	 * 
	 */	
	public class Character extends Sprite
	{
		/**
		 * 
		 * 
		 */		
		public function Character( code:Number, bg:uint, w:Number, h:Number )
		{
			this.code = code;
			setBackground(bg, w, h);
		}
		
		public var code:Number;
		
		/**
		 * 
		 * @param value
		 * 
		 */		
		public function set foreground( value:uint ):void {
			var field:TextField = TextField(this.getChildAt(0));
			var format:TextFormat = new TextFormat("Font", 8, value, null, null, null, null, null, "left", 0, 0, 0, 0);
			field.setTextFormat(format, 0, 1);
		}
		
		/**
		 * 
		 * @param value
		 * 
		 */		
		public function setBackground( value:uint, w:Number, h:Number ):void {
			this.graphics.beginFill(value);
			this.graphics.drawRect(0, 0, w, h);
		}
		
	}
}