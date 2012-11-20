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
	import flash.geom.Point;

	/**
	 * CursorEvent
	 * 
	 * 
	 * @author Peter Nitsch
	 * 
	 */	
	public class CursorEvent extends Event
	{
		public static const DRAW_CHARACTER:String = "drawCharacter";
		public static const REPOSITION:String = "reposition";
		public static const SAVE_POSITION:String = "savePosition";
		public static const RESTORE_POSITION:String = "restorePosition";
		public static const MOVE_UP:String = "moveUp";
		public static const MOVE_DOWN:String = "moveDown";
		public static const MOVE_FORWARD:String = "moveForward";
		public static const MOVE_BACKWARD:String = "moveBackward";
		public static const CARRIAGE_RETURN:String = "carriageReturn";
		public static const FORM_FEED:String = "formFeed";
		public var character:*;
		public var value:Number;
		public var position:Point;
		public var erase:Boolean;
		
		/**
		 * 
		 * @param type
		 * @param character
		 * @param value
		 * @param x
		 * @param y
		 * @param bubbles
		 * @param cancelable
		 * 
		 */		
		public function CursorEvent(type:String, character:*=null, value:Number=0, x:Number=0, y:Number=0, erase:Boolean=false, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.character = character;
			this.value = value;
			this.erase = erase;
			position = new Point(x, y);
		}
		
		
		public override function clone():Event {
        	return new CursorEvent(type, character, value, position.x, position.y, bubbles, cancelable);
    	}

	}
}