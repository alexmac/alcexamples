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
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.Dictionary;
	
	import net.peternitsch.ansi.parser.CursorEvent;
	import net.peternitsch.ansi.parser.SixteenColors;

	/**
	 * MultiFontViewer
	 * 
	 * 
	 * @author Peter Nitsch
	 * @version 0.1
	 * 
	 */	
	public class MultiFontViewer extends AnsiViewer
	{
		/**
		 * 
		 * @param defaultFont
		 * @param columnWidth
		 * @param lineHeight
		 * @param scroll
		 * 
		 */		
		public function MultiFontViewer(font:String="80x25", columnWidth:Number=80, lineHeight:Number=24, scroll:Boolean=true)
		{
			createLUT();
			super(columnWidth, lineHeight, scroll);
			
			if(fontArray.indexOf(font)!=-1)
				MultiFontViewer.defaultFont = font;
			else
				MultiFontViewer.defaultFont = FONT_PC8025;
			
			chooseFont(defaultFont, false);
		}
		
		public static var fontArray:Array = [FONT_PC8025, FONT_PC8050, FONT_POTNODDLE, FONT_TOPAZ];
		
		public static const FONT_PC8025:String = "80x25";
		[Embed(source="ansilove_font_pc_80x25.png")]
		private var Definition8025:Class;
		
		public static const FONT_PC8050:String = "80x50";
		[Embed(source="ansilove_font_pc_80x50.png")]
		private var Definition8050:Class;
		
		public static const FONT_POTNODDLE:String = "Pot Noodle";
		[Embed(source="ansilove_font_pot-noodle.png")]
		private var DefinitionPOTNODDLE:Class;
		
		public static const FONT_TOPAZ:String = "Topaz";
		[Embed(source="ansilove_font_topaz.png")]
		private var DefinitionTOPAZ:Class;
		
		public var fontmap:BitmapData;
		public var currentFont:Object;
		public static var defaultFont:String;
		
		public function chooseFont( fontType:String, flush:Boolean=true ):void {
			var font:Object = fontTable[fontType];
			var bm:Bitmap = new font.definition();
			fontmap = bm.bitmapData;
			cursor.columnWidth = font.width;
			cursor.lineHeight = font.height;
			//cursor.maxLineHeight = font.lineHeight;
			currentFont = font;
			if(flush) this.flush();
		}
		
		override public function handleDrawCharacter(e:CursorEvent):void {
			if( !cursor.infiniteWidth && cursor.position.x + cursor.columnWidth >= cursor.maxColumnWidth * cursor.columnWidth ){
				handleMoveDown( new CursorEvent(CursorEvent.MOVE_DOWN, null, 1) );
				cursor.carriageReturn();
			} else {
				cursor.moveForward();
			}
			
			draw( e.character );
		}
		
		private function draw( charCode:Number ):void {
			_bitmap.bitmapData.threshold(
				fontmap, 
				new Rectangle(charCode*(currentFont.width+1), colorTable[cursor.foregroundColor]*currentFont.height, currentFont.width, currentFont.height), 
				new Point(cursor.position.x-currentFont.width, cursor.position.y), 
				"==", 
				0xff4080c0, 
				0xff000000 + cursor.backgroundColor, 
				0xffffffff, 
				true
				);	
		}
		
		private var colorTable:Dictionary = new Dictionary();
		private var fontTable:Dictionary = new Dictionary();
		
		private function createLUT():void {
			colorTable[SixteenColors.BLACK_NORMAL] = 0;
			colorTable[SixteenColors.BLUE_NORMAL] = 1;
			colorTable[SixteenColors.GREEN_NORMAL] = 2;
			colorTable[SixteenColors.CYAN_NORMAL] = 3;
			colorTable[SixteenColors.RED_NORMAL] = 4;
			colorTable[SixteenColors.MAGENTA_NORMAL] = 5;
			colorTable[SixteenColors.YELLOW_NORMAL] = 6;
			colorTable[SixteenColors.WHITE_NORMAL] = 7;
			colorTable[SixteenColors.BLACK_BOLD] = 8;
			colorTable[SixteenColors.BLUE_BOLD] = 9;
			colorTable[SixteenColors.GREEN_BOLD] = 10;
			colorTable[SixteenColors.CYAN_BOLD] = 11;
			colorTable[SixteenColors.RED_BOLD] = 12;
			colorTable[SixteenColors.MAGENTA_BOLD] = 13;
			colorTable[SixteenColors.YELLOW_BOLD] = 14;
			colorTable[SixteenColors.WHITE_BOLD] = 15;
			
			fontTable[FONT_PC8025] = {definition:Definition8025, width:8, height:16, lineHeight:24};
			fontTable[FONT_PC8050] = {definition:Definition8050, width:8, height:8, lineHeight:50};
			fontTable[FONT_POTNODDLE] = {definition:DefinitionPOTNODDLE, width:7, height:11, lineHeight:36};
			fontTable[FONT_TOPAZ] = {definition:DefinitionTOPAZ, width:7, height:11, lineHeight:36};
		}
		
	}
}