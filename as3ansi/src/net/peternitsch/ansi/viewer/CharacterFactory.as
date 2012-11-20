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
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * CharacterFactory
	 * 
	 * 
	 * @author Peter Nitsch
	 * 
	 */	
	public class CharacterFactory
	{
		/**
		 * 
		 * @param characterCode
		 * @return 
		 * 
		 */		
		public static function produce( characterCode:*, foreground:uint, background:uint, w:Number, h:Number ):Character {
			var character:Character = new Character( characterCode, background, w, h );
			character.addChild( generateSymbolFromFont(characterCode, foreground) );
			
			return character;
		}
		
		[Embed(source="Perfect DOS VGA 437.ttf", fontName="Font", mimeType="application/x-font-truetype")]
		private static var EMBEDDED_FONT:String;
		
		internal static function generateSymbolFromFont( stringCharCode:Number, color:uint ):TextField {	
			var format:TextFormat = new TextFormat("Font", 8, color, null, null, null, null, null, "left", 0, 0, 0, 0);
			var field:TextField = new TextField();
			field.x = -2;
			field.y = -2;
			field.width = 15;
			field.embedFonts = true;
			field.selectable = false;
			field.mouseEnabled = false;
			field.defaultTextFormat = format;
			field.multiline = false;
			field.wordWrap = false;
			field.text = String.fromCharCode(stringCharCode);
			return field;
		}

	}
}