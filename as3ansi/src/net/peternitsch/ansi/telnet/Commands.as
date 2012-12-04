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
	import flash.utils.ByteArray;
	import flash.utils.Dictionary;
	
	/**
	 * Commands
	 * Telnet protocol implementation. Used telnetd (http://telnetd.sourceforge.net/) as reference.
	 *  
	 * @author pnitsch
	 * 
	 */	
	public class Commands
	{
		public static const IAC:uint = 255;
		public static const GA:uint = 249;
		public static const WILL:uint = 251;
		public static const WONT:uint = 252;
		public static const DO:uint = 253;
		public static const DONT:uint = 254;
		public static const SB:uint = 250;
		public static const SE:uint = 240;
		public static const NOP:uint = 241;
		public static const DM:uint = 242;
		public static const BRK:uint = 243;
		
		public static const IP:uint = 244;
		public static const AO:uint = 245;
		public static const AYT:uint = 246;
		public static const EC:uint = 247;
		public static const EL:uint = 248;
		
		public static const ECHO:uint = 1;
		public static const SUPGA:uint = 3;
		
		public static const NAWS:uint = 31;
		public static const TTYPE:uint = 24;
		public static const IS:uint = 0;
		public static const SEND:uint = 1;
		public static const LOGOUT:uint = 18;
		
		public static const LINEMODE:int = 34;
		public static const LM_MODE:int = 1;
		public static const LM_EDIT:int = 1;
		public static const LM_TRAPSIG:int = 2;
		public static const LM_MODEACK:int = 4;
		public static const LM_FORWARDMASK:int = 2;
		
		public static const LM_SLC:int = 3;
		public static const LM_SLC_NOSUPPORT:int = 0;
		public static const LM_SLC_DEFAULT:int = 3;
		public static const LM_SLC_VALUE:int = 2;
		public static const LM_SLC_CANTCHANGE:int = 1;
		public static const LM_SLC_LEVELBITS:int = 3;
		public static const LM_SLC_ACK:int = 128;
		public static const LM_SLC_FLUSHIN:int = 64;
		public static const LM_SLC_FLUSHOUT:int = 32;
		
		public static const LM_SLC_SYNCH:int = 1;
		public static const LM_SLC_BRK:int = 2;
		public static const LM_SLC_IP:int = 3;
		public static const LM_SLC_AO:int = 4;
		public static const LM_SLC_AYT:int = 5;
		public static const LM_SLC_EOR:int = 6;
		public static const LM_SLC_ABORT:int = 7;
		public static const LM_SLC_EOF:int = 8;
		public static const LM_SLC_SUSP:int = 9;
		
		public static const NEWENV:int = 39;
		public static const NE_INFO:int = 2;
		public static const NE_VAR:int = 0;
		public static const NE_VALUE:int = 1;
		public static const NE_ESC:int = 2;
		public static const NE_USERVAR:int = 3;
		
		public static const NE_VAR_OK:int = 2;
		public static const NE_VAR_DEFINED:int = 1;
		public static const NE_VAR_DEFINED_EMPTY:int = 0;
		public static const NE_VAR_UNDEFINED:int = -1;
		public static const NE_IN_ERROR:int = -2;
		public static const NE_IN_END:int = -3;
		public static const NE_VAR_NAME_MAXLENGTH:int = 50;
		public static const NE_VAR_VALUE_MAXLENGTH:int = 1000;
		
		// Unused
		public static const EXT_ASCII:int = 17;
		public static const SEND_LOC:int = 23;
		public static const AUTHENTICATION:int = 37;
		public static const ENCRYPT:int = 38;
		
		private var _session:TelnetSession;
		private var bytes:ByteArray;
		
		public function Commands( session:TelnetSession )
		{
			_session = session;
			init();
		}
		
		private var _actionCharacterLib:Dictionary = new Dictionary(true);
		
		private function init():void {
			_actionCharacterLib[ IAC ] = interpretCommand;
			_session.viewer.parser.writeException(IAC, interpretCommand);
		}
		
		
		private function interpretCommand( code:Number, bytes:ByteArray ):void {
			this.bytes = bytes;
			var command:uint = bytes.readUnsignedByte();
			handleC(command);
		}	


		private function read16int():int {
			var c:int = 0;
			try {
				c = bytes.readUnsignedByte();
				return c;
			} catch (e:Error) {
				trace(e);
			}
			
			return c;
		}
		
		private function IamHere():void {
			try {
				var ba:ByteArray = new ByteArray();
				ba.writeByte(IAC);
				ba.writeByte(DO);
				ba.writeByte(AYT);
				_session.writeBytes(ba);
				_session.flush();
				ba = null;
			} catch (error:Error) {
				trace("IamHere() Error", error);
			}
		}

		private function nvtBreak():void {
			// TO DO
		}
		
		private function setTerminalGeometry(width:int, height:int):void {
			// TO DO
		}
		
		public function setEcho(b:Boolean):void {
			// TO DO
		}
				
		private var buffer:Array = [0,0];
		
		private var DO_ECHO:Boolean = false;
		private var DO_SUPGA:Boolean = false;
		private var DO_NAWS:Boolean = false;
		private var DO_TTYPE:Boolean = false;
		private var DO_LINEMODE:Boolean = false;
		private var DO_NEWENV:Boolean = false;
		
		private var WAIT_DO_REPLY_SUPGA:Boolean = false;
		private var WAIT_DO_REPLY_ECHO:Boolean = false;
		private var WAIT_DO_REPLY_NAWS:Boolean = false;
		private var WAIT_DO_REPLY_TTYPE:Boolean = false;
		private var WAIT_DO_REPLY_LINEMODE:Boolean = false;
		private var WAIT_LM_MODE_ACK:Boolean = false;
		private var WAIT_LM_DO_REPLY_FORWARDMASK:Boolean = false;
		private var WAIT_DO_REPLY_NEWENV:Boolean = false;
		private var WAIT_NE_SEND_REPLY:Boolean = false;
		
		private var WAIT_WILL_REPLY_SUPGA:Boolean = false;
		private var WAIT_WILL_REPLY_ECHO:Boolean = false;
		private var WAIT_WILL_REPLY_NAWS:Boolean = false;
		private var WAIT_WILL_REPLY_TTYPE:Boolean = false;
		
		public function doCharacterModeInit():void {
			sendCommand(WILL, ECHO, true);
			sendCommand(DONT, ECHO, true);
			sendCommand(DO, NAWS, true);
			sendCommand(WILL, SUPGA, true);
			sendCommand(DO, SUPGA, true);
			sendCommand(DO, TTYPE, true);
			sendCommand(DO, NEWENV, true);
		}
		
		public function doLineModeInit():void {
			sendCommand(DO, NAWS, true);
			sendCommand(WILL, SUPGA, true);
			sendCommand(DO, SUPGA, true);
			sendCommand(DO, TTYPE, true);
			sendCommand(DO, LINEMODE, true);
			sendCommand(DO, NEWENV, true);
		}
		
		public function handleC(i:int):void {
			buffer[0] = i;
			  
			if (!parseTWO(buffer)) {
				try {
					buffer[1] = bytes.readUnsignedByte();
					parse(buffer);
				} catch(e:Error) {
					trace(e);
				}
			}
			
			buffer[0] = 0;
			buffer[1] = 0;
		}
		
		private function parseTWO(buf:Array):Boolean {
			switch (buf[0]) {
				case IAC:
				break;
				case AYT:
					IamHere();
				break;
				case AO:
				case IP:
				case EL:
				case EC:
				case NOP:
				break;
				case BRK:
					nvtBreak();
				break;
				default:
					return false;
			}
			return true;
		}
		
		private function parse(buf:Array):void {
			switch (buf[0]) {
				case WILL:
					if (supported(buf[1]) && isEnabled(buf[1])) {

					} else {
						if (waitDOreply(buf[1]) && supported(buf[1])) {
							enable(buf[1]);
							setWait(DO, buf[1], false);
						} else {
							if (supported(buf[1])) {                            
								sendCommand(DO, buf[1], false);
								enable(buf[1]);
							} else {
								sendCommand(DONT, buf[1], false);
							}
						}
					}
				break;
				case WONT:
					if (waitDOreply(buf[1]) && supported(buf[1])) {
						setWait(DO, buf[1], false);
					} else {
						if (supported(buf[1]) && isEnabled(buf[1])) {
							enable(buf[1]);
						}
					}
				break;
				case DO:
					if (supported(buf[1]) && isEnabled(buf[1])) {
					} else {
						if (waitWILLreply(buf[1]) && supported(buf[1])) {
							enable(buf[1]);
							setWait(WILL, buf[1], false);
						} else {
							if (supported(buf[1])) {
								sendCommand(WILL, buf[1], false);
								enable(buf[1]);
							} else {
								sendCommand(WONT, buf[1], false);
							}
						}
					}
				break;
				case DONT:
					if (waitWILLreply(buf[1]) && supported(buf[1])) {
						setWait(WILL, buf[1], false);
					} else {
						if (supported(buf[1]) && isEnabled(buf[1])) {
							enable(buf[1]);
						}
					}
				break;
				
				  
				case DM:	
				break;
				case SB: 
					if ((supported(buf[1])) && (isEnabled(buf[1]))) {
						switch (buf[1]) {
							case NAWS:
								handleNAWS();
							break;
							case TTYPE:
								handleTTYPE();
							break;
							case LINEMODE:
								handleLINEMODE();
							break;
							case NEWENV:
								handleNEWENV();
							break;
							default:
								;
						}
					} else {
				
					}
				break;
				default:
					;
			}
		}
		
		
		private function handleNAWS():void {
			var width:int = read16int();
			if (width == 255) {
				width = read16int(); 
			}
			var height:int = read16int();
			if (height == 255) {
				height = read16int(); 
			}
			skipToSE();
			setTerminalGeometry(width, height);
		}
		
		private function handleTTYPE():void {
			var tmpstr:String = "";
			var b:int = bytes.readUnsignedByte();
			 
			switch(b) {
				case SEND:
					var cont:Boolean = true;
					do {
						var i:int;
						i = bytes.readUnsignedByte();
						if (i == SE) {
							cont = false;
						}
			  
					} while (cont);
					
					_session.flush();
					  	
					var ba:ByteArray = new ByteArray();
					ba.writeByte(IAC);
					ba.writeByte(SB);
					ba.writeByte(TTYPE);
					ba.writeByte(IS);
					ba.writeUTF("ansi");
					ba.writeByte(IAC);
					ba.writeByte(SE);
					  
					_session.writeBytes(ba);
					_session.flush();
					ba = null;
				  
				break;
			  
				case IS:
					tmpstr = readIACSETerminatedString(40);
				break;
			}
		}
		
		public function handleLINEMODE():void {
			var c:int = bytes.readUnsignedByte();
			switch (c) {
				case LM_MODE:
					handleLMMode();
				break;
				case LM_SLC:
					handleLMSLC();
				break;
				case WONT:
				case WILL:
					handleLMForwardMask(c);
				break;
				default:
					skipToSE();
			}
		}
		
		public function handleLMMode():void {
			if (WAIT_LM_MODE_ACK) {
				var mask:int = bytes.readUnsignedByte();
				if (mask != (LM_EDIT | LM_TRAPSIG | LM_MODEACK)) {
				}
				WAIT_LM_MODE_ACK = false;
			}
			skipToSE();
		}
		
		public function handleLMSLC():void {
			var ba:ByteArray;
			var triple:Array = new Array(3);
			if (!readTriple(triple)) return;
			
			if ((triple[0] == 0) && (triple[1] == LM_SLC_DEFAULT) && (triple[2] == 0)) {
				skipToSE();
				ba = new ByteArray();
				ba.writeByte(IAC);
				ba.writeByte(SB);
				ba.writeByte(LINEMODE);
				ba.writeByte(LM_SLC);
			
				for (var i:int = 1; i < 12; i++) {
					ba.writeByte(i);
					ba.writeByte(LM_SLC_DEFAULT);
					ba.writeByte(0);
				}
			
				ba.writeByte(IAC);
				ba.writeByte(SE);
				_session.writeBytes(ba);
				_session.flush();
				ba = null;
			} else {
				ba = new ByteArray();
				ba.writeByte(IAC);
				ba.writeByte(SB);
				ba.writeByte(LINEMODE);
				ba.writeByte(LM_SLC);
				ba.writeByte(triple[0]);
				ba.writeByte(triple[1] | LM_SLC_ACK);
				ba.writeByte(triple[2]);
				while (readTriple(triple)) {
					ba.writeByte(triple[0]);
					ba.writeByte(triple[1] | LM_SLC_ACK);
					ba.writeByte(triple[2]);
				}
				ba.writeByte(IAC);
				ba.writeByte(SE);
				_session.writeBytes(ba);
				_session.flush();
				ba = null;
			}
		}
		
		public function handleLMForwardMask(WHAT:int):void {
			switch (WHAT) {
				case WONT:
					if (WAIT_LM_DO_REPLY_FORWARDMASK) {
						WAIT_LM_DO_REPLY_FORWARDMASK = false;
					}
				break;
			}
			skipToSE();
		}
		
		public function handleNEWENV():void {
			var c:int = bytes.readUnsignedByte();
			switch (c) {
				case IS:
					handleNEIs();
				break;
				case NE_INFO:
					handleNEInfo();
				break;
				default:
					skipToSE();
			}
		}
		
		private function readNEVariableName(sbuf:String):int {
			var i:int = -1;
			do {
				i = bytes.readUnsignedByte();
				if (i == -1) {
					return NE_IN_ERROR;
				} else if (i == IAC) {
					i = bytes.readUnsignedByte();
					if (i == IAC) {
						sbuf.concat(i);
					} else if (i == SE) {
						return NE_IN_END;
					} else {
						return NE_IN_ERROR;
					}
				} else if (i == NE_ESC) {
					i = bytes.readUnsignedByte();
					if (i == NE_ESC || i == NE_VAR || i == NE_USERVAR || i == NE_VALUE) {
						sbuf.concat(i);
					} else {
						return NE_IN_ERROR;
					}
				} else if (i == NE_VAR || i == NE_USERVAR) {
					return NE_VAR_UNDEFINED;
				} else if (i == NE_VALUE) {
					return NE_VAR_DEFINED;
				} else {
					if (sbuf.length >= NE_VAR_NAME_MAXLENGTH) {
						return NE_IN_ERROR;
					} else {
						sbuf.concat(i);
					}
				}
			} while (true);
			  
			return i;
		}
		
		private function readNEVariableValue(sbuf:String):int {
			var i:int = bytes.readUnsignedByte();
			if (i == -1) {
				return NE_IN_ERROR;
			} else if (i == IAC) {
				i = bytes.readUnsignedByte();
				if (i == IAC) {
					return NE_VAR_DEFINED_EMPTY;
				} else if (i == SE) {
					return NE_IN_END;
				} else {
					return NE_IN_ERROR;
				}
			} else if (i == NE_VAR || i == NE_USERVAR) {
				return NE_VAR_DEFINED_EMPTY;
			} else if (i == NE_ESC) {
				i = bytes.readUnsignedByte();
				if (i == NE_ESC || i == NE_VAR || i == NE_USERVAR || i == NE_VALUE) {
					sbuf.concat(i);
				} else {
					return NE_IN_ERROR;
				}
			} else {
				sbuf.concat(i);
			}
			  
			do {
				i = bytes.readUnsignedByte();
				if (i == -1) {
					return NE_IN_ERROR;
				} else if (i == IAC) {
					i = bytes.readUnsignedByte();
					if (i == IAC) {
						sbuf.concat(i);
					} else if (i == SE) {
						return NE_IN_END;
					} else {
						return NE_IN_ERROR;
					}
				} else if (i == NE_ESC) {
					i = bytes.readUnsignedByte();
					if (i == NE_ESC || i == NE_VAR || i == NE_USERVAR || i == NE_VALUE) {
						sbuf.concat(i);
					} else {
						return NE_IN_ERROR;
					}
				} else if (i == NE_VAR || i == NE_USERVAR) {
					return NE_VAR_OK;
				} else {
					if (sbuf.length > NE_VAR_VALUE_MAXLENGTH) {
						return NE_IN_ERROR;
					} else {
						sbuf.concat(i);
					}
				}
			} while (true);
			  
			return i;
		}
		
		
		public function readNEVariables():void {
			var sbuf:String = new String();
			var i:int = bytes.readUnsignedByte();
			if (i == IAC) {
				skipToSE();
				trace("readNEVariables()::INVALID VARIABLE");
				return;
			}
			var cont:Boolean = true;
			if (i == NE_VAR || i == NE_USERVAR) {
				do {
					switch (readNEVariableName(sbuf)) {
						case NE_IN_ERROR:
							trace("readNEVariables()::NE_IN_ERROR");
						return;
						case NE_IN_END:
							trace("readNEVariables()::NE_IN_END");
						return;
						case NE_VAR_DEFINED:
							trace("readNEVariables()::NE_VAR_DEFINED");
							var str:String = sbuf;
							sbuf = "";
							switch (readNEVariableValue(sbuf)) {
								case NE_IN_ERROR:
									trace("readNEVariables()::NE_IN_ERROR");
									return;
								case NE_IN_END:
									trace("readNEVariables()::NE_IN_END");
									return;
								case NE_VAR_DEFINED_EMPTY:
									trace("readNEVariables()::NE_VAR_DEFINED_EMPTY");
								break;
								case NE_VAR_OK:
									trace("readNEVariables()::NE_VAR_OK:VAR=" + str + " VAL=" + sbuf.toString());
									sbuf = "";
								break;
							}
						break;
						case NE_VAR_UNDEFINED:
							trace("readNEVariables()::NE_VAR_UNDEFINED");
						break;
					}
				} while (cont);
			}
		}
		
		public function handleNEIs():void {
			if (isEnabled(NEWENV)) {
				readNEVariables();
			}
		}
		
		public function handleNEInfo():void {
			if (isEnabled(NEWENV)) {
				readNEVariables();
			}
		}
		
		public function getTTYPE():void {
			if (isEnabled(TTYPE)) {
				var ba:ByteArray = new ByteArray();
				ba.writeByte(IAC);
				ba.writeByte(SB);
				ba.writeByte(TTYPE);
				ba.writeByte(SEND);
				ba.writeByte(IAC);
				ba.writeByte(SE);
				ba.writeBytes(ba);
				_session.flush();
				ba = null;
			}
		}
		
		public function negotiateLineMode():void {
			if (isEnabled(LINEMODE)) {
				var ba:ByteArray = new ByteArray();
				ba.writeByte(IAC);
				ba.writeByte(SB);
				ba.writeByte(LINEMODE);
				ba.writeByte(LM_MODE);
				ba.writeByte(LM_EDIT | LM_TRAPSIG);
				ba.writeByte(IAC);
				ba.writeByte(SE);
				WAIT_LM_MODE_ACK = true;
				
				ba.writeByte(IAC);
				ba.writeByte(SB);
				ba.writeByte(LINEMODE);
				ba.writeByte(DONT);
				ba.writeByte(LM_FORWARDMASK);
				ba.writeByte(IAC);
				ba.writeByte(SE);
				WAIT_LM_DO_REPLY_FORWARDMASK = true;
				_session.writeBytes(ba);
				_session.flush();
				ba = null;
			}
		}
		
		private function negotiateEnvironment():void {
			if (isEnabled(NEWENV)) {
				var ba:ByteArray = new ByteArray();
				ba.writeByte(IAC);
				ba.writeByte(SB);
				ba.writeByte(NEWENV);
				ba.writeByte(SEND);
				ba.writeByte(NE_VAR);
				ba.writeByte(NE_USERVAR);
				ba.writeByte(IAC);
				ba.writeByte(SE);
				WAIT_NE_SEND_REPLY = true;
				_session.writeBytes(ba);
				_session.flush();
				ba = null;
			}
		}
		
		private function skipToSE():void {
			while (bytes.readUnsignedByte() != SE) { }
		}
		
		private function readTriple(triple:Array):Boolean {
			triple[0] = bytes.readUnsignedByte();
			triple[1] = bytes.readUnsignedByte();
			if ((triple[0] == IAC) && (triple[1] == SE)) {
				return false;
			} else {
				triple[2] = bytes.readUnsignedByte();
				return true;
			}
			  
			return false;
		}
		
		
		private function readIACSETerminatedString(maxlength:int):String {
			var where:int = 0;
			var cbuf:Array = new Array(maxlength);
			var b:String = ' ';
			var cont:Boolean = true;
			
			do {
				var i:int;
				i = bytes.readUnsignedByte();
				switch (i) {
					case IAC:
						i = bytes.readUnsignedByte();
						if (i == SE) {
						cont = false;
						}
					break;
					case -1:
						return (new String("default"));
					default:
				}
				if (cont) {
					b = i.toString();
					if (b == '\n' || b == '\r' || where == maxlength) {
						cont = false;
					} else {
						cbuf[where++] = b;
					}
				}
			} while (cont);
			
			var str:String = "";
			for(var j:int=0; j<where; j++) {
				str.concat(cbuf[i]);
			}
			
			return (str);
		}
		
		private function supported(i:int):Boolean {
			switch (i) {
				case SUPGA:
				case ECHO:
				case NAWS:
				case TTYPE:
					return true;
				case LINEMODE:
					return false;
				default:
					return false;
			}
		}
		
		private function sendCommand(i:int, j:int, westarted:Boolean):void {
			var ba:ByteArray = new ByteArray();
			ba.writeByte(IAC);
			ba.writeByte(i);
			ba.writeByte(j);
			  
			if ((i == DO) && westarted) setWait(DO, j, true);
			if ((i == WILL) && westarted) setWait(WILL, j, true);
			  
			_session.writeBytes(ba);
			_session.flush();
			ba = null;
		}
		
		private function enable(i:int):void {
			switch (i) {
				case SUPGA:
					if (DO_SUPGA) {
						DO_SUPGA = false;
					} else {
						DO_SUPGA = true;
					}
				break;
				case ECHO:
					if (DO_ECHO) {
						DO_ECHO = false;
					} else {
						DO_ECHO = true;
					}
				break;
				case NAWS:
					if (DO_NAWS) {
						DO_NAWS = false;
					} else {
						DO_NAWS = true;
					}
				break;
				case TTYPE:
				if (DO_TTYPE) {
						DO_TTYPE = false;
					} else {
						DO_TTYPE = true;
						getTTYPE();
					}
				break;
				case LINEMODE:
					if (DO_LINEMODE) {
						DO_LINEMODE = false;
					} else {
						DO_LINEMODE = true;
						negotiateLineMode();
					}
				break;
				case NEWENV:
					if (DO_NEWENV) {
						DO_NEWENV = false;
					} else {
						DO_NEWENV = true;
						negotiateEnvironment();
					}
				break;
			}
		}
		
		private function isEnabled(i:int):Boolean {
			switch (i) {
				case SUPGA:
					return DO_SUPGA;
				case ECHO:
					return DO_ECHO;
				case NAWS:
					return DO_NAWS;
				case TTYPE:
					return DO_TTYPE;
				case LINEMODE:
					return DO_LINEMODE;
				case NEWENV:
					return DO_NEWENV;
				default:
					return false;
			}
			  
			return false;
		}
		
		private function waitWILLreply(i:int):Boolean {
			switch (i) {
				case SUPGA:
					return WAIT_WILL_REPLY_SUPGA;
				case ECHO:
					return WAIT_WILL_REPLY_ECHO;
				case NAWS:
					return WAIT_WILL_REPLY_NAWS;
				case TTYPE:
					return WAIT_WILL_REPLY_TTYPE;
				default:
					return false;
			}
		  
			return false;
		}
		
		private function waitDOreply(i:int):Boolean {
			switch (i) {
				case SUPGA:
					return WAIT_DO_REPLY_SUPGA;
				case ECHO:
					return WAIT_DO_REPLY_ECHO;
				case NAWS:
					return WAIT_DO_REPLY_NAWS;
				case TTYPE:
					return WAIT_DO_REPLY_TTYPE;
				case LINEMODE:
					return WAIT_DO_REPLY_LINEMODE;
				case NEWENV:
					return WAIT_DO_REPLY_NEWENV;
				default:
					return false;
			}
			  
			return false;
		}
		
		private function setWait(WHAT:int, OPTION:int, WAIT:Boolean):Boolean {
			switch (WHAT) {
				case DO:
				switch (OPTION) {
					case SUPGA:
						WAIT_DO_REPLY_SUPGA = WAIT;
					break;
					case ECHO:
						WAIT_DO_REPLY_ECHO = WAIT;
					break;
					case NAWS:
						WAIT_DO_REPLY_NAWS = WAIT;
					break;
					case TTYPE:
						WAIT_DO_REPLY_TTYPE = WAIT;
					break;
					case LINEMODE:
						WAIT_DO_REPLY_LINEMODE = WAIT;
					break;
					case NEWENV:
						WAIT_DO_REPLY_NEWENV = WAIT;
					break;
				}
				break;
				case WILL:
					switch (OPTION) {
					case SUPGA:
						WAIT_WILL_REPLY_SUPGA = WAIT;
					break;
					case ECHO:
						WAIT_WILL_REPLY_ECHO = WAIT;
					break;
					case NAWS:
						WAIT_WILL_REPLY_NAWS = WAIT;
					break;
					case TTYPE:
						WAIT_WILL_REPLY_TTYPE = WAIT;
					break;
				}
				break;
			}
			  
			return false;
		}



	}
}