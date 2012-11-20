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

	/**
	 * GraphicsEvent
	 * 
	 * 
	 * @author Peter Nitsch
	 * 
	 */	
	public class GraphicsEvent extends Event
	{
		public static const FOREGROUND_COLOR_CHANGED:String = "foregroundColorChanged";
		public static const BACKGROUND_COLOR_CHANGED:String = "backgroundColorChanged";
		
		public static const ERASE_END_OF_LINE:String = "eraseEndOfLine"; 
		public static const ERASE_START_OF_LINE:String = "eraseStartOfLine"; 
		public static const ERASE_LINE:String = "eraseLine"; 
		
		//public static const CLEAR:String = "clear";
		public static const ERASE_DOWN:String = "eraseDown"; 
		public static const ERASE_UP:String = "eraseUp"; 
		public static const ERASE_SCREEN:String = "eraseScreen"; 
		
		public static const SCROLL_UP:String = "scrollUp"; 

		public var color:uint;
		
		/**
		 * 
		 * @param type
		 * @param color
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function GraphicsEvent(type:String, color:uint=0, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.color = color;
		}
		
		public override function clone():Event {
        	return new GraphicsEvent(type, color, bubbles, cancelable);
    	}
		
	}
}