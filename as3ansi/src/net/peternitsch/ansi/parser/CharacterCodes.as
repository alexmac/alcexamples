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
	/**
	 * CharacterCodes
	 * 
	 * 
	 * @author Peter Nitsch
	 * 
	 */	
	public class CharacterCodes
	{
		public static const NULL:Number = 0
		public static const START_OF_HEADING:Number = 1;
		public static const START_OF_TEXT:Number = 2;
		public static const END_OF_TEXT:Number = 3;
		public static const END_OF_TRANSMISSION:Number = 4;
		public static const ENQUIRY:Number = 5;
		public static const ACKNOWLEDGE:Number = 6;
		public static const BELL:Number = 7;
		public static const BACKSPACE:Number = 8;
		public static const HORIZONTAL_TABULATION:Number = 9;
		public static const LINE_FEED:Number = 10;
		public static const VERTICAL_TABULATION:Number = 11;
		public static const FORM_FEED:Number = 12;
		public static const CARRIAGE_RETURN:Number = 13;
		public static const SHIFT_OUT:Number = 14;
		public static const SHIFT_IN:Number = 15;
		public static const DATA_LINK_ESCAPE:Number = 16;
		public static const DEVICE_CONTROL_ONE:Number = 17;
		public static const DEVICE_CONTROL_TWO:Number = 18;
		public static const DEVICE_CONTROL_THREE:Number = 19;
		public static const DEVICE_CONTROL_FOUR:Number = 20;
		public static const NEGATIVE_ACKNOWLEDGE:Number = 21;
		public static const SYNCHRONOUS_IDLE:Number = 22;
		public static const END_OF_TRANSMISSION_BLOCK:Number = 23;
		public static const CANCEL:Number = 24;
		public static const END_OF_MEDIUM:Number = 25;
		public static const SUBSTITUTE:Number = 26;
		public static const ESCAPE:Number = 27;
		public static const FILE_SEPARATOR:Number = 28;
		public static const GROUP_SEPARATOR:Number = 29;
		public static const RECORD_SEPARATOR:Number = 30;
		public static const UNIT_SEPARATOR:Number = 31;
		public static const SPACE:Number = 32;
		public static const EXCLAMATION_MARK:Number = 33;
		public static const QUOTATION_MARK:Number = 34;
		public static const NUMBER_SIGN:Number = 35;
		public static const DOLLAR_SIGN:Number = 36;
		public static const PERCENT_SIGN:Number = 37;
		public static const AMPERSAND:Number = 38;
		public static const APOSTROPHE:Number = 39;
		public static const LEFT_PARENTHESIS:Number = 40;
		public static const RIGHT_PARENTHESIS:Number = 41;
		public static const ASTERISK:Number = 42;
		public static const PLUS_SIGN:Number = 43;
		public static const COMMA:Number = 44;
		public static const HYPHEN_MINUS:Number = 45;
		public static const FULL_STOP:Number = 46;
		public static const SOLIDUS:Number = 47;
		public static const DIGIT_ZERO:Number = 48;
		public static const DIGIT_ONE:Number = 49;
		public static const DIGIT_TWO:Number = 50;
		public static const DIGIT_THREE:Number = 51;
		public static const DIGIT_FOUR:Number = 52;
		public static const DIGIT_FIVE:Number = 53;
		public static const DIGIT_SIX:Number = 54;
		public static const DIGIT_SEVEN:Number = 55;
		public static const DIGIT_EIGHT:Number = 56;
		public static const DIGIT_NINE:Number = 57;
		public static const COLON:Number = 58;
		public static const SEMICOLON:Number = 59;
		public static const LESS_THAN_SIGN:Number = 60;
		public static const EQUALS_SIGN:Number = 61;
		public static const GREATER_THAN_SIGN:Number = 62;
		public static const QUESTION_MARK:Number = 63;
		public static const COMMERCIAL_AT:Number = 64;
		public static const LATIN_CAPITAL_LETTER_A:Number = 65;
		public static const LATIN_CAPITAL_LETTER_B:Number = 66;
		public static const LATIN_CAPITAL_LETTER_C:Number = 67;
		public static const LATIN_CAPITAL_LETTER_D:Number = 68;
		public static const LATIN_CAPITAL_LETTER_E:Number = 69;
		public static const LATIN_CAPITAL_LETTER_F:Number = 70;
		public static const LATIN_CAPITAL_LETTER_G:Number = 71;
		public static const LATIN_CAPITAL_LETTER_H:Number = 72;
		public static const LATIN_CAPITAL_LETTER_I:Number = 73;
		public static const LATIN_CAPITAL_LETTER_J:Number = 74;
		public static const LATIN_CAPITAL_LETTER_K:Number = 75;
		public static const LATIN_CAPITAL_LETTER_L:Number = 76;
		public static const LATIN_CAPITAL_LETTER_M:Number = 77;
		public static const LATIN_CAPITAL_LETTER_N:Number = 78;
		public static const LATIN_CAPITAL_LETTER_O:Number = 79;
		public static const LATIN_CAPITAL_LETTER_P:Number = 80;
		public static const LATIN_CAPITAL_LETTER_Q:Number = 81;
		public static const LATIN_CAPITAL_LETTER_R:Number = 82;
		public static const LATIN_CAPITAL_LETTER_S:Number = 83;
		public static const LATIN_CAPITAL_LETTER_T:Number = 84;
		public static const LATIN_CAPITAL_LETTER_U:Number = 85;
		public static const LATIN_CAPITAL_LETTER_V:Number = 86;
		public static const LATIN_CAPITAL_LETTER_W:Number = 87;
		public static const LATIN_CAPITAL_LETTER_X:Number = 88;
		public static const LATIN_CAPITAL_LETTER_Y:Number = 89;
		public static const LATIN_CAPITAL_LETTER_Z:Number = 90;
		public static const LEFT_SQUARE_BRACKET:Number = 91;
		public static const REVERSE_SOLIDUS:Number = 92;
		public static const RIGHT_SQUARE_BRACKET:Number = 93;
		public static const CIRCUMFLEX_ACCENT:Number = 94;
		public static const LOW_LINE:Number = 95;
		public static const GRAVE_ACCENT:Number = 96;
		public static const LATIN_SMALL_LETTER_A:Number = 97;
		public static const LATIN_SMALL_LETTER_B:Number = 98;
		public static const LATIN_SMALL_LETTER_C:Number = 99;
		public static const LATIN_SMALL_LETTER_D:Number = 100;
		public static const LATIN_SMALL_LETTER_E:Number = 101;
		public static const LATIN_SMALL_LETTER_F:Number = 102;
		public static const LATIN_SMALL_LETTER_G:Number = 103;
		public static const LATIN_SMALL_LETTER_H:Number = 104;
		public static const LATIN_SMALL_LETTER_I:Number = 105;
		public static const LATIN_SMALL_LETTER_J:Number = 106;
		public static const LATIN_SMALL_LETTER_K:Number = 107;
		public static const LATIN_SMALL_LETTER_L:Number = 108;
		public static const LATIN_SMALL_LETTER_M:Number = 109;
		public static const LATIN_SMALL_LETTER_N:Number = 110;
		public static const LATIN_SMALL_LETTER_O:Number = 111;
		public static const LATIN_SMALL_LETTER_P:Number = 112;
		public static const LATIN_SMALL_LETTER_Q:Number = 113;
		public static const LATIN_SMALL_LETTER_R:Number = 114;
		public static const LATIN_SMALL_LETTER_S:Number = 115;
		public static const LATIN_SMALL_LETTER_T:Number = 116;
		public static const LATIN_SMALL_LETTER_U:Number = 117;
		public static const LATIN_SMALL_LETTER_V:Number = 118;
		public static const LATIN_SMALL_LETTER_W:Number = 119;
		public static const LATIN_SMALL_LETTER_X:Number = 120;
		public static const LATIN_SMALL_LETTER_Y:Number = 121;
		public static const LATIN_SMALL_LETTER_Z:Number = 122;
		public static const LEFT_CURLY_BRACKET:Number = 123;
		public static const VERTICAL_LINE:Number = 124;
		public static const RIGHT_CURLY_BRACKET:Number = 125;
		public static const TILDE:Number = 126;
		public static const DELETE:Number = 127;
		public static const LATIN_CAPITAL_LETTER_C_WITH_CEDILLA:Number = 128;
		public static const LATIN_SMALL_LETTER_U_WITH_DIAERESIS:Number = 129;
		public static const LATIN_SMALL_LETTER_E_WITH_ACUTE:Number = 130;
		public static const LATIN_SMALL_LETTER_A_WITH_CIRCUMFLEX:Number = 131;
		public static const LATIN_SMALL_LETTER_A_WITH_DIAERESIS:Number = 132;
		public static const LATIN_SMALL_LETTER_A_WITH_GRAVE:Number = 133;
		public static const LATIN_SMALL_LETTER_A_WITH_RING_ABOVE:Number = 134;
		public static const LATIN_SMALL_LETTER_C_WITH_CEDILLA:Number = 135;
		public static const LATIN_SMALL_LETTER_E_WITH_CIRCUMFLEX:Number = 136;
		public static const LATIN_SMALL_LETTER_E_WITH_DIAERESIS:Number = 137;
		public static const LATIN_SMALL_LETTER_E_WITH_GRAVE:Number = 138;
		public static const LATIN_SMALL_LETTER_I_WITH_DIAERESIS:Number = 139;
		public static const LATIN_SMALL_LETTER_I_WITH_CIRCUMFLEX:Number = 140;
		public static const LATIN_SMALL_LETTER_I_WITH_GRAVE:Number = 141;
		public static const LATIN_CAPITAL_LETTER_A_WITH_DIAERESIS:Number = 142;
		public static const LATIN_CAPITAL_LETTER_A_WITH_RING_ABOVE:Number = 143;
		public static const LATIN_CAPITAL_LETTER_E_WITH_ACUTE:Number = 144;
		public static const LATIN_SMALL_LETTER_AE:Number = 145;
		public static const LATIN_CAPITAL_LETTER_AE:Number = 146;
		public static const LATIN_SMALL_LETTER_O_WITH_CIRCUMFLEX:Number = 147;
		public static const LATIN_SMALL_LETTER_O_WITH_DIAERESIS:Number = 148;
		public static const LATIN_SMALL_LETTER_O_WITH_GRAVE:Number = 149;
		public static const LATIN_SMALL_LETTER_U_WITH_CIRCUMFLEX:Number = 150;
		public static const LATIN_SMALL_LETTER_U_WITH_GRAVE:Number = 151;
		public static const LATIN_SMALL_LETTER_Y_WITH_DIAERESIS:Number = 152;
		public static const LATIN_CAPITAL_LETTER_O_WITH_DIAERESIS:Number = 153;
		public static const LATIN_CAPITAL_LETTER_U_WITH_DIAERESIS:Number = 154;
		public static const CENT_SIGN:Number = 155;
		public static const POUND_SIGN:Number = 156;
		public static const YEN_SIGN:Number = 157;
		public static const PESETA_SIGN:Number = 158;
		public static const LATIN_SMALL_LETTER_F_WITH_HOOK:Number = 159;
		public static const LATIN_SMALL_LETTER_A_WITH_ACUTE:Number = 160;
		public static const LATIN_SMALL_LETTER_I_WITH_ACUTE:Number = 161;
		public static const LATIN_SMALL_LETTER_O_WITH_ACUTE:Number = 162;
		public static const LATIN_SMALL_LETTER_U_WITH_ACUTE:Number = 163;
		public static const LATIN_SMALL_LETTER_N_WITH_TILDE:Number = 164;
		public static const LATIN_CAPITAL_LETTER_N_WITH_TILDE:Number = 165;
		public static const FEMININE_ORDINAL_INDICATOR:Number = 166;
		public static const MASCULINE_ORDINAL_INDICATOR:Number = 167;
		public static const INVERTED_QUESTION_MARK:Number = 168;
		public static const REVERSED_NOT_SIGN:Number = 169;
		public static const NOT_SIGN:Number = 170;
		public static const VULGAR_FRACTION_ONE_HALF:Number = 171;
		public static const VULGAR_FRACTION_ONE_QUARTER:Number = 172;
		public static const INVERTED_EXCLAMATION_MARK:Number = 173;
		public static const LEFT_POINTING_DOUBLE_ANGLE_QUOTATION_MARK:Number = 174;
		public static const RIGHT_POINTING_DOUBLE_ANGLE_QUOTATION_MARK:Number = 175;
		public static const LIGHT_SHADE:Number = 176;
		public static const MEDIUM_SHADE:Number = 177;
		public static const DARK_SHADE:Number = 178;
		public static const BOX_DRAWINGS_LIGHT_VERTICAL:Number = 179;
		public static const BOX_DRAWINGS_LIGHT_VERTICAL_AND_LEFT:Number = 180;
		public static const BOX_DRAWINGS_VERTICAL_SINGLE_AND_LEFT_DOUBLE:Number = 181;
		public static const BOX_DRAWINGS_VERTICAL_DOUBLE_AND_LEFT_SINGLE:Number = 182;
		public static const BOX_DRAWINGS_DOWN_DOUBLE_AND_LEFT_SINGLE:Number = 183;
		public static const BOX_DRAWINGS_DOWN_SINGLE_AND_LEFT_DOUBLE:Number = 184;
		public static const BOX_DRAWINGS_DOUBLE_VERTICAL_AND_LEFT:Number = 185;
		public static const BOX_DRAWINGS_DOUBLE_VERTICAL:Number = 186;
		public static const BOX_DRAWINGS_DOUBLE_DOWN_AND_LEFT:Number = 187;
		public static const BOX_DRAWINGS_DOUBLE_UP_AND_LEFT:Number = 188;
		public static const BOX_DRAWINGS_UP_DOUBLE_AND_LEFT_SINGLE:Number = 189;
		public static const BOX_DRAWINGS_UP_SINGLE_AND_LEFT_DOUBLE:Number = 190;
		public static const BOX_DRAWINGS_LIGHT_DOWN_AND_LEFT:Number = 191;
		public static const BOX_DRAWINGS_LIGHT_UP_AND_RIGHT:Number = 192;
		public static const BOX_DRAWINGS_LIGHT_UP_AND_HORIZONTAL:Number = 193;
		public static const BOX_DRAWINGS_LIGHT_DOWN_AND_HORIZONTAL:Number = 194;
		public static const BOX_DRAWINGS_LIGHT_VERTICAL_AND_RIGHT:Number = 195;
		public static const BOX_DRAWINGS_LIGHT_HORIZONTAL:Number = 196;
		public static const BOX_DRAWINGS_LIGHT_VERTICAL_AND_HORIZONTAL:Number = 197;
		public static const BOX_DRAWINGS_VERTICAL_SINGLE_AND_RIGHT_DOUBLE:Number = 198;
		public static const BOX_DRAWINGS_VERTICAL_DOUBLE_AND_RIGHT_SINGLE:Number = 199;
		public static const BOX_DRAWINGS_DOUBLE_UP_AND_RIGHT:Number = 200;
		public static const BOX_DRAWINGS_DOUBLE_DOWN_AND_RIGHT:Number = 201;
		public static const BOX_DRAWINGS_DOUBLE_UP_AND_HORIZONTAL:Number = 202;
		public static const BOX_DRAWINGS_DOUBLE_DOWN_AND_HORIZONTAL:Number = 203;
		public static const BOX_DRAWINGS_DOUBLE_VERTICAL_AND_RIGHT:Number = 204;
		public static const BOX_DRAWINGS_DOUBLE_HORIZONTAL:Number = 205;
		public static const BOX_DRAWINGS_DOUBLE_VERTICAL_AND_HORIZONTAL:Number = 206;
		public static const BOX_DRAWINGS_UP_SINGLE_AND_HORIZONTAL_DOUBLE:Number = 207;
		public static const BOX_DRAWINGS_UP_DOUBLE_AND_HORIZONTAL_SINGLE:Number = 208;
		public static const BOX_DRAWINGS_DOWN_SINGLE_AND_HORIZONTAL_DOUBLE:Number = 209;
		public static const BOX_DRAWINGS_DOWN_DOUBLE_AND_HORIZONTAL_SINGLE:Number = 210;
		public static const BOX_DRAWINGS_UP_DOUBLE_AND_RIGHT_SINGLE:Number = 211;
		public static const BOX_DRAWINGS_UP_SINGLE_AND_RIGHT_DOUBLE:Number = 212;
		public static const BOX_DRAWINGS_DOWN_SINGLE_AND_RIGHT_DOUBLE:Number = 213;
		public static const BOX_DRAWINGS_DOWN_DOUBLE_AND_RIGHT_SINGLE:Number = 214;
		public static const BOX_DRAWINGS_VERTICAL_DOUBLE_AND_HORIZONTAL_SINGLE:Number = 215;
		public static const BOX_DRAWINGS_VERTICAL_SINGLE_AND_HORIZONTAL_DOUBLE:Number = 216;
		public static const BOX_DRAWINGS_LIGHT_UP_AND_LEFT:Number = 217;
		public static const BOX_DRAWINGS_LIGHT_DOWN_AND_RIGHT:Number = 218;
		public static const FULL_BLOCK:Number = 219;
		public static const LOWER_HALF_BLOCK:Number = 220;
		public static const LEFT_HALF_BLOCK:Number = 221;
		public static const RIGHT_HALF_BLOCK:Number = 222;
		public static const UPPER_HALF_BLOCK:Number = 223;
		public static const GREEK_SMALL_LETTER_ALPHA:Number = 224;
		public static const LATIN_SMALL_LETTER_SHARP_S:Number = 225;
		public static const GREEK_CAPITAL_LETTER_GAMMA:Number = 226;
		public static const GREEK_SMALL_LETTER_PI:Number = 227;
		public static const GREEK_CAPITAL_LETTER_SIGMA:Number = 228;
		public static const GREEK_SMALL_LETTER_SIGMA:Number = 229;
		public static const MICRO_SIGN:Number = 230;
		public static const GREEK_SMALL_LETTER_TAU:Number = 231;
		public static const GREEK_CAPITAL_LETTER_PHI:Number = 232;
		public static const GREEK_CAPITAL_LETTER_THETA:Number = 233;
		public static const GREEK_CAPITAL_LETTER_OMEGA:Number = 234;
		public static const GREEK_SMALL_LETTER_DELTA:Number = 235;
		public static const INFINITY:Number = 236;
		public static const GREEK_SMALL_LETTER_PHI:Number = 237;
		public static const GREEK_SMALL_LETTER_EPSILON:Number = 238;
		public static const INTERSECTION:Number = 239;
		public static const IDENTICAL_TO:Number = 240;
		public static const PLUS_MINUS_SIGN:Number = 241;
		public static const GREATER_THAN_OR_EQUAL_TO:Number = 242;
		public static const LESS_THAN_OR_EQUAL_TO:Number = 243;
		public static const TOP_HALF_INTEGRAL:Number = 244;
		public static const BOTTOM_HALF_INTEGRAL:Number = 245;
		public static const DIVISION_SIGN:Number = 246;
		public static const ALMOST_EQUAL_TO:Number = 247;
		public static const DEGREE_SIGN:Number = 248;
		public static const BULLET_OPERATOR:Number = 249;
		public static const MIDDLE_DOT:Number = 250;
		public static const SQUARE_ROOT:Number = 251;
		public static const SUPERSCRIPT_LATIN_SMALL_LETTER_N:Number = 252;
		public static const SUPERSCRIPT_TWO:Number = 253;
		public static const BLACK_SQUARE:Number = 254;
		public static const NO_BREAK_SPACE:Number = 255;
	}
}