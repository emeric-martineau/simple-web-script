unit UnitHtml;
{*******************************************************************************
 * Copyright (C) 2007 MARTINEAU Emeric (php4php@free.fr)
 *
 * Simple Web Script
 *
 * This program is free software; you can redistribute it and/or modify it under
 * the terms of the GNU General Public License as published by the Free Software
 * Foundation; either version 2 of the License, or (at your option) any later
 * version.
 *
 * This program is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
 * FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License along with
 * this program; if not, write to the Free Software Foundation, Inc., 59 Temple
 * Place, Suite 330, Boston, MA 02111-1307 USA
 *
 *******************************************************************************
 * This unit containt string function :
 *   EXTRACTINTPART
 *   EXTRACTFLOATPART
 *   DECTOHEX/OCT/BIN
 *   Pi
 *   UNIQID
 ******************************************************************************}
interface

{$I config.inc}

uses Functions, UnitMessages, InternalFunction, classes ;

procedure HtmlFunctionsInit ;
procedure NlToBrCommande(arguments : TStringList) ;
procedure HtmlSpecialCharsEncodeCommande(arguments : TStringList) ;
procedure HtmlSpecialCharsDecodeCommande(arguments : TStringList) ;
procedure StripTagsCommande(arguments : TStringList) ;
//
procedure getChar(text : string; out Charactere : string; var i : integer; charset : string; out val : integer; IndexOfTableOfCharset : integer; out NewIndexOfTableOfCharset : Integer) ;
function htmlspecialcharencode(text : String; charset : String; quote : Integer; double_encode : boolean) : string ;
function ConvertNumberOfUtf8CharToStringUtf8(val : integer) : String ;
function htmlspecialchardecode(text : String; charset : String; quote : integer) : string ;
function StripTags(text : String; allowedTags : string) : String ;

implementation

uses Code, SysUtils ;

{*
 * HTML entity resources:
 *
 * http://msdn.microsoft.com/workshop/author/dhtml/reference/charsets/charset2.asp
 * http://msdn.microsoft.com/workshop/author/dhtml/reference/charsets/charset3.asp
 * http://www.unicode.org/Public/MAPPINGS/OBSOLETE/UNI2SGML.TXT
 *
 * http://www.w3.org/TR/2002/REC-xhtml1-20020801/dtds.html#h-A2
 *
 *}
type
  { Type : tableau contenant la translation de caractère }
  CharsetTable = array[0..255] of string ;
  PCharsetTable = ^CharsetTable;

  { Type : contient le nom du charset, la valeur du caractère de début et de fin,
           pointer sur le tableau de conversion }
  htmlEntityMap = record
      charset    : String ;
      startBase  : Integer ;
      endBase    : Integer ;
      tableCharset : PCharsetTable ;
  end ;

const
  entryCp1252 : array[0..31] of string = (
                                   'euro', '', 'sbquo', 'fnof', 'bdquo', 'hellip', 'dagger',
                                   'Dagger', 'circ', 'permil', 'Scaron', 'lsaquo', 'OElig',
                                   '', '', '', '', 'lsquo', 'rsquo', 'ldquo', 'rdquo',
                                   'bull', 'ndash', 'mdash', 'tilde', 'trade', 'scaron', 'rsaquo',
                                   'oelig', '', '', 'Yuml');

  entryIso8859_1 : array[0..95] of string = (
                                   'nbsp', 'iexcl', 'cent', 'pound', 'curren', 'yen', 'brvbar',
                                   'sect', 'uml', 'copy', 'ordf', 'laquo', 'not', 'shy', 'reg',
                                   'macr', 'deg', 'plusmn', 'sup2', 'sup3', 'acute', 'micro',
                                   'para', 'middot', 'cedil', 'sup1', 'ordm', 'raquo', 'frac14',
                                   'frac12', 'frac34', 'iquest', 'Agrave', 'Aacute', 'Acirc',
                                   'Atilde', 'Auml', 'Aring', 'AElig', 'Ccedil', 'Egrave',
                                   'Eacute', 'Ecirc', 'Euml', 'Igrave', 'Iacute', 'Icirc',
                                   'Iuml', 'ETH', 'Ntilde', 'Ograve', 'Oacute', 'Ocirc', 'Otilde',
                                   'Ouml', 'times', 'Oslash', 'Ugrave', 'Uacute', 'Ucirc', 'Uuml',
                                   'Yacute', 'THORN', 'szlig', 'agrave', 'aacute', 'acirc',
                                   'atilde', 'auml', 'aring', 'aelig', 'ccedil', 'egrave',
                                   'eacute', 'ecirc', 'euml', 'igrave', 'iacute', 'icirc',
                                   'iuml', 'eth', 'ntilde', 'ograve', 'oacute', 'ocirc', 'otilde',
                                   'ouml', 'divide', 'oslash', 'ugrave', 'uacute', 'ucirc',
                                   'uuml', 'yacute', 'thorn', 'yuml');

  entryIso8859_15 : array[0..95] of string = (
                                   'nbsp', 'iexcl', 'cent', 'pound', 'euro', 'yen', 'Scaron',
                                   'sect', 'scaron', 'copy', 'ordf', 'laquo', 'not', 'shy', 'reg',
                                   'macr', 'deg', 'plusmn', 'sup2', 'sup3', '',
                                   'micro', 'para', 'middot', '', 'sup1', 'ordm',
                                   'raquo', 'OElig', 'oelig', 'Yuml', 'iquest', 'Agrave', 'Aacute',
                                   'Acirc', 'Atilde', 'Auml', 'Aring', 'AElig', 'Ccedil', 'Egrave',
                                   'Eacute', 'Ecirc', 'Euml', 'Igrave', 'Iacute', 'Icirc',
                                   'Iuml', 'ETH', 'Ntilde', 'Ograve', 'Oacute', 'Ocirc', 'Otilde',
                                   'Ouml', 'times', 'Oslash', 'Ugrave', 'Uacute', 'Ucirc', 'Uuml',
                                   'Yacute', 'THORN', 'szlig', 'agrave', 'aacute', 'acirc',
                                   'atilde', 'auml', 'aring', 'aelig', 'ccedil', 'egrave',
                                   'eacute', 'ecirc', 'euml', 'igrave', 'iacute', 'icirc',
                                   'iuml', 'eth', 'ntilde', 'ograve', 'oacute', 'ocirc', 'otilde',
                                   'ouml', 'divide', 'oslash', 'ugrave', 'uacute', 'ucirc',
                                   'uuml', 'yacute', 'thorn', 'yuml') ;

  entryUni338_402 : array[0..64] of string = (
                                   { 338 }
                                   'OElig', 'oelig', '', '', '', '', '', '', '', '',
                                   '', '', '', '',
                                   { 352 }
                                   'Scaron', 'scaron',
                                   { 354  }
                                   '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 376 }
                                   'Yuml',
                                   { 377  }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   '',
                                   { 402 }
                                   'fnof') ;

  entryUniSpacing : array[0..22] of string = (
                                   { 710 }
                                   'circ',
                                   { 711 - 730 }
                                   '', '', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   { 731 - 732 }
                                   '', 'tilde');

  entryUniGreek : array[0..69] of string = (
                                   { 913 }
                                   'Alpha', 'Beta', 'Gamma', 'Delta', 'Epsilon', 'Zeta', 'Eta', 'Theta',
                                   'Iota', 'Kappa', 'Lambda', 'Mu', 'Nu', 'Xi', 'Omicron', 'Pi', 'Rho',
                                   '', 'Sigma', 'Tau', 'Upsilon', 'Phi', 'Chi', 'Psi', 'Omega',
                                   { 938 - 944 are not mapped }
                                   '', '', '', '', '', '', '',
                                   'alpha', 'beta', 'gamma', 'delta', 'epsilon', 'zeta', 'eta', 'theta',
                                   'iota', 'kappa', 'lambda', 'mu', 'nu', 'xi', 'omicron', 'pi', 'rho',
                                   'sigmaf', 'sigma', 'tau', 'upsilon', 'phi', 'chi', 'psi', 'omega',
                                   { 970 - 976 are not mapped }
                                   '', '', '', '', '', '', '',
                                   'thetasym', 'upsih',
                                   '', '', '', 'piv');
                                   
  entryUniPunct : array[0..66] of string = (
                                   { 8194 }
                                   'ensp', 'emsp', '', '', '', '', '',
                                   'thinsp', '', '', 'zwnj', 'zwj', 'lrm', 'rlm',
                                   '', '', '', 'ndash', 'mdash', '', '', '',
                                   'lsquo', 'rsquo', 'sbquo', '', 'ldquo', 'rdquo', 'bdquo', '',
                                   'dagger', 'Dagger', 'bull', '', '', '', 'hellip',
                                   '', '', '', '', '', '', '', '', '', 'permil', '',
                                   'prime', 'Prime', '', '', '', '', '', 'lsaquo', 'rsaquo',
                                   '', '', '', 'oline', '', '', '', '', '',
                                   'frasl');

  entryUniEuro : array[0..0] of string = ('euro');

  entryUni8465_8501 : array[0..36] of string = (
                                   { 8465 }
                                   'image', '', '', '', '', '', '',
                                   { 8472 }
                                   'weierp', '', '', '',
                                   { 8476 }
                                   'real', '', '', '', '', '',
                                   { 8482 }
                                   'trade', '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '', '', '',
                                   { 8501 }
                                   'alefsym');

  entryUni8592_9002 : array[0..410] of string = (
                                   { 8592 (0x2190) }
                                   'larr', 'uarr', 'rarr', 'darr', 'harr', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8608 (0x21a0) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8624 (0x21b0) }
                                   '', '', '', '', '', 'crarr', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8640 (0x21c0) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8656 (0x21d0) }
                                   'lArr', 'uArr', 'rArr', 'dArr', 'hArr', 'vArr', '', '',
                                   '', '', 'lAarr', 'rAarr', '', 'rarrw', '', '',
                                   { 8672 (0x21e0) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8704 (0x2200) }
                                   'forall', 'comp', 'part', 'exist', 'nexist', 'empty', '', 'nabla',
                                   'isin', 'notin', 'epsis', 'ni', 'notni', 'bepsi', '', 'prod',
                                   { 8720 (0x2210) }
                                   'coprod', 'sum', 'minus', 'mnplus', 'plusdo', '', 'setmn', 'lowast',
                                   'compfn', '', 'radic', '', '', 'prop', 'infin', 'ang90',
                                   { 8736 (0x2220) }
                                   'ang', 'angmsd', 'angsph', 'mid', 'nmid', 'par', 'npar', 'and',
                                   'or', 'cap', 'cup', 'int', '', '', 'conint', '',
                                   { 8752 (0x2230) }
                                   '', '', '', '', 'there4', 'becaus', '', '',
                                   '', '', '', '', 'sim', 'bsim', '', '',
                                   { 8768 (0x2240) }
                                   'wreath', 'nsim', '', 'sime', 'nsime', 'cong', '', 'ncong',
                                   'asymp', 'nap', 'ape', '', 'bcong', 'asymp', 'bump', 'bumpe',
                                   { 8784 (0x2250) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8800 (0x2260) }
                                   'ne', 'equiv', '', '', 'le', 'ge', 'lE', 'gE',
                                   'lnE', 'gnE', 'Lt', 'Gt', 'twixt', '', 'nlt', 'ngt',
                                   { 8816 (0x2270) }
                                   'nles', 'nges', 'lsim', 'gsim', '', '', 'lg', 'gl',
                                   '', '', 'pr', 'sc', 'cupre', 'sscue', 'prsim', 'scsim',
                                   { 8832 (0x2280) }
                                   'npr', 'nsc', 'sub', 'sup', 'nsub', 'nsup', 'sube', 'supe',
                                   '', '', '', '', '', '', '', '',
                                   { 8848 (0x2290) }
                                   '', '', '', '', '', 'oplus', '', 'otimes',
                                   '', '', '', '', '', '', '', '',
                                   { 8864 (0x22a0) }
                                   '', '', '', '', '', 'perp', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8880 (0x22b0) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8896 (0x22c0) }
                                   '', '', '', '', '', 'sdot', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8912 (0x22d0) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8928 (0x22e0) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8944 (0x22f0) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8960 (0x2300) }
                                   '', '', '', '', '', '', '', '',
                                   'lceil', 'rceil', 'lfloor', 'rfloor', '', '', '', '',
                                   { 8976 (0x2310) }
                                   '', '', '', '', '', '', '', '',
                                   '', '', '', '', '', '', '', '',
                                   { 8992 (0x2320) }
                                   '', '', '', '', '', '', '', '',
                                   '', 'lang', 'rang');

  entryUni9674 : array[0..0] of string = ('loz');

  entryUni9824_9830 : array[0..6] of string = (
                                   'spades', '', '', 'clubs', '', 'hearts', 'diams');

  entryKoi8r : array[0..92] of string = (
                                   '#1105', { 'jo ' }
                                   '', '', '', '', '', '', '', '', '', '', 
                                   '', '', '', '', '', '#1025', { 'JO' }
                                   '', '', '', '', '', '', '', '', '', '', '', '', 
                                   '#1102', '#1072', '#1073', '#1094', '#1076', '#1077', '#1092', 
                                   '#1075', '#1093', '#1080', '#1081', '#1082', '#1083', '#1084', 
                                   '#1085', '#1086', '#1087', '#1103', '#1088', '#1089', '#1090', 
                                   '#1091', '#1078', '#1074', '#1100', '#1099', '#1079', '#1096', 
                                   '#1101', '#1097', '#1095', '#1098', '#1070', '#1040', '#1041', 
                                   '#1062', '#1044', '#1045', '#1060', '#1043', '#1061', '#1048', 
                                   '#1049', '#1050', '#1051', '#1052', '#1053', '#1054', '#1055', 
                                   '#1071', '#1056', '#1057', '#1058', '#1059', '#1046', '#1042',
                                   '#1068', '#1067', '#1047', '#1064', '#1069', '#1065', '#1063', 
                                   '#1066');

  entryCp1251 : array[0..127] of string = (
                                   '#1026', '#1027', '#8218', '#1107', '#8222', 'hellip', 'dagger',
                                   'Dagger', 'euro', 'permil', '#1033', '#8249', '#1034', '#1036',
                                   '#1035', '#1039', '#1106', '#8216', '#8217', '#8219', '#8220',
                                   'bull', 'ndash', 'mdash', '', 'trade', '#1113', '#8250',
                                   '#1114', '#1116', '#1115', '#1119', 'nbsp', '#1038', '#1118',
                                   '#1032', 'curren', '#1168', 'brvbar', 'sect', '#1025', 'copy',
                                   '#1028', 'laquo', 'not', 'shy', 'reg', '#1031', 'deg', 'plusmn',
                                   '#1030', '#1110', '#1169', 'micro', 'para', 'middot', '#1105',
                                   '#8470', '#1108', 'raquo', '#1112', '#1029', '#1109', '#1111',
                                   '#1040', '#1041', '#1042', '#1043', '#1044', '#1045', '#1046',
                                   '#1047', '#1048', '#1049', '#1050', '#1051', '#1052', '#1053',
                                   '#1054', '#1055', '#1056', '#1057', '#1058', '#1059', '#1060',
                                   '#1061', '#1062', '#1063', '#1064', '#1065', '#1066', '#1067',
                                   '#1068', '#1069', '#1070', '#1071', '#1072', '#1073', '#1074',
                                   '#1075', '#1076', '#1077', '#1078', '#1079', '#1080', '#1081',
                                   '#1082', '#1083', '#1084', '#1085', '#1086', '#1087', '#1088',
                                   '#1089', '#1090', '#1091', '#1092', '#1093', '#1094', '#1095',
                                   '#1096', '#1097', '#1098', '#1099', '#1100', '#1101', '#1102',
                                   '#1103');

  entryIso8859_5 : array[0..63] of string = (
                                   '#1056', '#1057', '#1058', '#1059', '#1060', '#1061', '#1062',
                                   '#1063', '#1064', '#1065', '#1066', '#1067', '#1068', '#1069',
                                   '#1070', '#1071', '#1072', '#1073', '#1074', '#1075', '#1076',
                                   '#1077', '#1078', '#1079', '#1080', '#1081', '#1082', '#1083',
                                   '#1084', '#1085', '#1086', '#1087', '#1088', '#1089', '#1090',
                                   '#1091', '#1092', '#1093', '#1094', '#1095', '#1096', '#1097',
                                   '#1098', '#1099', '#1100', '#1101', '#1102', '#1103', '#1104',
                                   '#1105', '#1106', '#1107', '#1108', '#1109', '#1110', '#1111',
                                   '#1112', '#1113', '#1114', '#1115', '#1116', '#1117', '#1118',
                                   '#1119');

  entryCp866 : array[0..63] of string = (
                                   '#9492', '#9524', '#9516', '#9500', '#9472', '#9532', '#9566', 
                                   '#9567', '#9562', '#9556', '#9577', '#9574', '#9568', '#9552', 
                                   '#9580', '#9575', '#9576', '#9572', '#9573', '#9561', '#9560', 
                                   '#9554', '#9555', '#9579', '#9578', '#9496', '#9484', '#9608', 
                                   '#9604', '#9612', '#9616', '#9600', '#1088', '#1089', '#1090', 
                                   '#1091', '#1092', '#1093', '#1094', '#1095', '#1096', '#1097', 
                                   '#1098', '#1099', '#1100', '#1101', '#1102', '#1103', '#1025', 
                                   '#1105', '#1028', '#1108', '#1031', '#1111', '#1038', '#1118', 
                                   '#176', '#8729', '#183', '#8730', '#8470', '#164',  '#9632', 
                                   '#160');

  EntryMap : array[0..37] of htmlEntityMap = (
                                            { 1252 }
	                                        (charset : 'cp1252'; startBase : $80; endBase : $9F; tableCharset : @entryCp1252),
                                            (charset : 'windows-1252'; startBase : $80; endBase : $9F; tableCharset : @entryCp1252),
                                            (charset : '1252'; startBase : $80; endBase : $9F; tableCharset : @entryCp1252),

                                            { ISO-8859-1 }
                                            (charset : 'iso-8859-1'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'iso8859-1'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),

                                            { ISO-8859-15 }
                                            (charset : 'iso-8859-15'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_15),
                                            (charset : 'iso8859-15'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_15),

                                            { UTF-8 IMPORTANT for optimize raison, must be in startbase order }
                                            (charset : 'utf-8'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'utf-8'; startBase : 338; endBase : 402; tableCharset : @entryUni338_402),
                                            (charset : 'utf-8'; startBase : 710; endBase : 732; tableCharset : @entryUniSpacing),
                                            (charset : 'utf-8'; startBase : 913; endBase : 982; tableCharset : @entryUniGreek),
                                            (charset : 'utf-8'; startBase : 8194; endBase : 8260; tableCharset : @entryUniPunct),
                                            (charset : 'utf-8'; startBase : 8364; endBase : 8364; tableCharset : @entryUniEuro),
                                            (charset : 'utf-8'; startBase : 8465; endBase : 8501; tableCharset : @entryUni8465_8501),
                                            (charset : 'utf-8'; startBase : 8592; endBase : 9002; tableCharset : @entryUni8592_9002),
                                            (charset : 'utf-8'; startBase : 9674; endBase : 9674; tableCharset : @entryUni9674),
                                            (charset : 'utf-8'; startBase : 9824; endBase : 9830; tableCharset : @entryUni9824_9830),

                                            { BIG5, gb2312 ... - idem of ISO-8859-1 }
                                            (charset : 'big5'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'gb2312'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'big5-hkscs'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'shift_sjis'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'sjis'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : '932'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'euc-jp'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'eucjp'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),

                                            { KOI8-R  	koi8-ru, koi8r }
                                            (charset : 'koi8-r'; startBase : $A3; endBase : $FF; tableCharset : @entryKoi8r),
                                            (charset : 'koi8-ru'; startBase : $A3; endBase : $FF; tableCharset : @entryKoi8r),
                                            (charset : 'koi8r'; startBase : $A3; endBase : $FF; tableCharset : @entryKoi8r),

                                            { 1251 }
                                            (charset : 'cp1251'; startBase : $80; endBase : $FF; tableCharset : @entryCp1251),
                                            (charset : 'windows-1251'; startBase : $80; endBase : $FF; tableCharset : @entryCp1251),
                                            (charset : 'wind-1251'; startBase : $80; endBase : $FF; tableCharset : @entryCp1251),
                                            (charset : '1251'; startBase : $80; endBase : $FF; tableCharset : @entryCp1251),

                                            { ISO-8859-5 }
                                            (charset : 'iso8859-5'; startBase : $C0; endBase : $FF; tableCharset : @entryIso8859_5),
                                            (charset : 'iso-8859-5'; startBase : $C0; endBase : $FF; tableCharset : @entryIso8859_5),

                                            { 866 }
                                            (charset : '886'; startBase : $C0; endBase : $FF; tableCharset : @entryCp866),
                                            (charset : 'cp886'; startBase : $C0; endBase : $FF; tableCharset : @entryCp866),
                                            (charset : 'ibm886'; startBase : $C0; endBase : $FF; tableCharset : @entryCp866),

                                            { end }
                                            (charset : ''; startBase : 0; endBase : 0; tableCharset : nil)
                                             ) ;
                                             
procedure NlToBrCommande(arguments : TStringList) ;
var i, len : Integer ;
begin
    if arguments.count = 1
    then begin
        ResultFunction := '' ;

        len := Length(arguments[0]) ;
        i := 1 ;

        { On n'utilise pas de fonction de recherche de caractère pour remplacment
          car on doit remplacer #10, #13, #13#10 donc on parcourerait 3 fois la
          chaine ce qui est plus long }
        while i <= len do
        begin
            if arguments[0][i] = #10
            then begin
                ResultFunction := ResultFunction + '<br />' ;
            end
            else if arguments[0][i] = #13
            then begin
                if i < len
                then begin
                    if arguments[0][i+1] = #10
                    then begin
                        Inc(i) ;
                    end ;
                end ;

                ResultFunction := ResultFunction + '<br />' ;
            end
            else begin
                ResultFunction := ResultFunction + arguments[0][i] ;
            end ;

            Inc(i) ;

            OverTimeAndMemory ;

            if GlobalError
            then begin
                break ;
            end ;
        end ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 1
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

{*******************************************************************************
 * Retourne le caractère d'une chaine y compris UTF-8.
 *  Entrée
 *    text                  : chaine
 *    i                     : index de la chaine à chercher
 *    charset               : charset de la chaine
 *    IndexOfTableOfCharset : index de base dans la table de charset
 *
 *  Sortie
 *    Charactere               : caractère correspondant
 *    i                        : incrémenté du nombre de caractère
 *    val                      : valeur du caractère
 *    NewIndexOfTableOfCharset : nouvel index de base dans la table de charset
 ******************************************************************************}
procedure getChar(text : string; out Charactere : string; var i : integer; charset : string; out val : integer; IndexOfTableOfCharset : integer; out NewIndexOfTableOfCharset : Integer) ;
var len : integer ;
    CurrentByte : byte ;
    j : Integer ;
begin
    len := Length(text) ;

    if charset = 'utf-8'
    then begin
        Charactere := text[i] ;
        val := Ord(text[i]) ;
        NewIndexOfTableOfCharset := IndexOfTableOfCharset ;

        { de 0 à 127 on ne fait rien }
        if val > 127
        then begin
            if (len - i) > 0
            then begin
                Inc(i) ;
                Charactere := Charactere + Text[i] ;
                CurrentByte := Ord(Text[i]) ;

                { si < $C0 codé sur 2 octets }
                if (val and $E0) < $E0
                then begin
                    { 110yyyxx 10xxxxxx }
                    val := (val and $1F) shl 6 ; // idem  ((val and $1F) shr 2) shl 8
                    { force à 0 les deux bits de poids fort 00111111=3F }
                    val := val or (CurrentByte and $3F) ;
                    { On a donc un entier du type 00000yyy xxxxxxxx}
                end
                else begin
                    { CurrentByte pointe déjà sur le deuxième octet }

                    if (len - i) > 0
                    then begin
                        { pointe sur le troisième octet }
                        Inc(i) ;
                        Charactere := Charactere + Text[i] ;

                        { si < $F0 codé sur 3 octets }
                        if (val and $F0) < $F0
                        then begin
                            { 1110yyyy 10yyyyxx 10xxxxxx }
                            { yyyy0000 }
                            val := (val and $0F) shl 12 ;
                            { 0000yyyy xx}
                            val := val or ((CurrentByte and $3F) shl 6) ;

                            { 3ème octet }
                            CurrentByte := Ord(Text[i]) ;

                            val := val or (CurrentByte and $3F) ;
                        end
                        else begin
                            { Codé sur 4 octets }
                            { 1 pas 2 car on a un inc(i) avant }
                            if (len - i) > 0
                            then begin
                                { 11110zzz 10zzyyyy 10yyyyxx 10xxxxxx }
                                { zzz00 }
                                val := (val and 7) shl 18 ;
                                { 000zz }
                                val := val or ((CurrentByte and $30) shl 12) ; // idem shr 4 shl 16
                                { yyyy0000 }
                                val := val or ((CurrentByte and $0F) shl 12) ;

                                { 3ème octet }
                                CurrentByte := Ord(Text[i]) ;

                                { 0000yyyy }
                                val := val or ((CurrentByte and $3C) shl 6) ;

                                { xx000000 }
                                val := val or ((CurrentByte and 3) shl 6) ;

                                Inc(i) ;
                                
                                Charactere := Charactere + Text[i] ;

                                { 4ème octet }
                                CurrentByte := Ord(Text[i]) ;

                                val := val or (CurrentByte and $3F) ;
                            end ;
                        end ;
                    end ;
                end ;
            end ;
        end ;

        Inc(i) ;

        { chercher la bonne table utf-8 }

        j := IndexOfTableOfCharset ;

        while EntryMap[j].charset <> '' do
        begin
            if (val >= EntryMap[j].startBase) and (val <= EntryMap[j].endBase)
            then begin
                NewIndexOfTableOfCharset := j ;
                break ;
            end
            else if val < EntryMap[j].startBase
            then
                break ;

            Inc(j) ;
        end ;
    end
    else begin
        val := Ord(text[i]) ;
        Charactere := text[i] ;
        Inc(i) ;
        NewIndexOfTableOfCharset := IndexOfTableOfCharset ;
    end ;
end ;

{*******************************************************************************
 * Convertit un texte en texte html.
 *
 *  Entrée
 *   Text : texte à convertir
 *   Charset : charset à utiliser pour convertir
 *   Quote : 0 = pas de convertion de ' ou "
 *           1 = convertion de " mais pas '
 *           2 = convertion de ' et "
 *   double_encode : true indique qu'il s'agit d'un double encodage et donc ne
 *                   pas reconvertir les &xxxx;
 *
 *  Retour : chaine encodée
 ******************************************************************************}
function htmlspecialcharencode(text : String; charset : String; quote : Integer; double_encode : boolean) : string ;
var i : integer ;
    j : integer ;
    len : integer ;
    val : Integer ;
    IndexOfTableOfCharset : Integer ;
    NewIndexOfTableOfCharset : Integer ;
    TableOfCharset : PCharsetTable ;
    Charactere : String ;
    tmp : String ;
begin
    Result := '' ;
    len := Length(text) + 1 ;
    IndexOfTableOfCharset := 0 ;
    charset := LowerCase(charset) ;

    { Fait pointer IndexOfTableOfCharset sur le bon charset }
    for i := Low(EntryMap) to High(EntryMap) do
    begin
        if EntryMap[i].charset = charset
        then begin
            IndexOfTableOfCharset := i ;
            break ;
        end ;
    end ;

    { Convertit la chaine }
    i := 1 ;
    
    while i < len do
    begin
        getChar(text, Charactere, i, charset, val, IndexOfTableOfCharset, NewIndexOfTableOfCharset) ;


        if (val >= EntryMap[NewIndexOfTableOfCharset].startBase) and (val <= EntryMap[NewIndexOfTableOfCharset].endBase)
        then begin
            { Pointe sur le bon tableau }
            TableOfCharset := EntryMap[NewIndexOfTableOfCharset].tableCharset ;
            tmp := TableOfCharset^[val - EntryMap[NewIndexOfTableOfCharset].startBase] ;

            if tmp <> ''
            then
                Charactere := '&' + tmp + ';' ;
        end ;

        if (Charactere = '"') and (quote > 0)
        then
            Charactere := '&quot;'
        else if (Charactere = '''') and (quote > 1)
        then
            Charactere := '&#039;'
        else if (Charactere = '<')
        then
            Charactere := '&lt;'
        else if (Charactere = '>')
        then
            Charactere := '&gt;'
        else if (Charactere = '&')
        then begin
            if double_encode = False
            then begin
                Charactere := '&amp;' ;
            end
            else begin
                if (len - i) > 0
                then begin
                    { on fait pointer j sur i car on va incrémenter le pointeur
                      de chaine or s'il ne s'agit pas d'un caractère html, il
                      faut revenir en arrière }
                    j := i ;

                    tmp := Charactere ;

                    { On n'incrément pas j car i pointe déjà sur le caractère
                      suivant }

                    if text[j] = '#'
                    then begin
                        tmp := tmp + text[j] ;
                        Inc(j) ;
                    end ;

                    while j < len do
                    begin
                        if (Text[j] in ['a'..'z']) or (Text[j] in ['A'..'Z']) or
                           (Text[j] in ['0'..'9'])
                        then begin
                            tmp := tmp + Text[j] ;
                        end
                        else begin
                            if Text[j] = ';'
                            then begin
                                { pointe sur le caractère d'après }
                                tmp := tmp + Text[j] ;

                                { pointe sur le prochain caractère }
                                i := j + 1 ;

                                Charactere := tmp ;
                            end
                            else begin
                                Charactere := '&amp;' ;
                            end ;

                            break ;                            
                        end ;

                        Inc(j) ;
                    end ;
                end
                else begin
                    Charactere := '&amp;' ;
                end ;
            end ;
        end ;


        Result := Result + Charactere ;
    end ;
end ;

{*******************************************************************************
 * Convertit un numéro de caractère UTF-8 en suite d'octet
 *
 *  Entrée
 *   val : numéro du caractère
 *
 *  Retour : octet représentant le caractère
 ******************************************************************************}
function ConvertNumberOfUtf8CharToStringUtf8(val : integer) : String ;
var octet : byte ;
begin
    if val < 128
    then begin
        { 1 octet }
        { 0xxxxxxx }
        Result := Chr(val) ;
    end
    else if (val > 127) and (val < 2048)
    then begin
        { 2 octets }
        { yyxxxxxx -> 110yyyxx 10xxxxxx }
        // yy
        octet := ((val and $C0) shr 6) or $C0 ;
        Result := Chr(octet) ;
        // xxxxxx
        octet := (val and $3F) or $80 ;
        Result := Result + Chr(octet) ;

    end
    else if (val > 2047) and (val < 65536)
    then begin
        { 3 octets }
        { yyyyyyyy xxxxxxxx -> 1110yyyy 10yyyyxx 10xxxxxx}
        octet := ((val and $F000) shr 12) or $E0 ;
        Result := Chr(octet) ;

        { 10yyyyxx }
        octet := ((val and $F00) shr 6) or ((val and $C0) shr 6) or $80 ;
        Result := Result + Chr(octet) ;

        octet := (val and $3F) or $80 ;
        Result := Result + Chr(octet) ;
    end
    else begin
        { 4 octets }
        { zzzzz yyyyyyyy xxxxxxxx -> 11110zzz 10zzyyyy 10yyyyxx 10xxxxxx }
        octet := ((val and $1C0000) shr 18) or $F0 ;
        Result := Chr(octet) ;

        octet := ((val and $30000) shr 12) or ((val and $F000) shr 12) or $80 ;
        Result := Result + Chr(octet) ;

        octet := ((val and $F00) shr 6) or ((val and $C0) shr 6) or $80 ;
        Result := Result + Chr(octet) ;

        octet := (val and $3F) or $80 ;
        Result := Result + Chr(octet) ;
        
    end ;
end ;

{*******************************************************************************
 * Convertit un texte html en text.
 *
 *  Entrée
 *   Text : texte à convertir
 *   Charset : charset à utiliser pour convertir
 *   Quote : 0 = pas de convertion de ' ou "
 *           1 = convertion de " mais pas '
 *           2 = convertion de ' et "
 *
 *  Retour : chaine décodée
 ******************************************************************************}
function htmlspecialchardecode(text : String; charset : String; quote : integer) : string ;
var i : integer ;
    j : integer ;
    k : integer ;
    len : integer ;
    IndexOfTableOfCharset : Integer ;
    Charactere : String ;
    tmp : string ;
    TableOfCharset : PCharsetTable ;
    val : integer ;
    len2 : Integer ;
    hexa : Boolean ;
    found : Boolean ;
    fin : Integer ;
begin
    len := Length(Text) + 1 ;
    Result := '' ;
    IndexOfTableOfCharset := 0 ;
    charset := LowerCase(charset) ;

    { Fait pointer IndexOfTableOfCharset sur le bon charset }
    for i := Low(EntryMap) to High(EntryMap) do
    begin
        if EntryMap[i].charset = charset
        then begin
            IndexOfTableOfCharset := i ;
            break ;
        end ;
    end ;

    i := 1 ;

    while i < len do
    begin
        Charactere := Text[i] ;

        if Text[i] = '&'
        then begin
            if (len - i) > 0
            then begin
                j := i ;

                { pointe sur le prochain caractère }
                Inc(j) ;
                tmp := '' ;

                if Text[j] = '#'
                then begin
                    Inc(j) ;
                end ;

                while j < len do
                begin
                    if (Text[j] in ['a'..'z']) or (Text[j] in ['A'..'Z']) or
                       (Text[j] in ['0'..'9'])
                    then begin
                        tmp := tmp + Text[j] ;
                        Inc(j) ;
                    end
                    else begin
                        if Text[j] = ';'
                        then begin
                            { vérifie qu'il ne s'agit pas d'un nombre hexa }
                            if (tmp[1] = 'x') or (tmp[1] = 'X')
                            then begin
                                tmp[1] := '$' ;
                                { permet d'éviter le $ dans la boucle de
                                  vérification du nombre }
                                k := 2 ;
                                hexa := True ;
                            end
                            else begin
                                k := 1 ;
                                hexa := False ;
                            end ;

                            val := -1 ;
                            len2 := Length(tmp) ;

                            for k := k to len2 do
                            begin
                                if not (tmp[k] in ['0'..'9'])
                                then begin
                                    if not ((hexa) and ((tmp[k] in ['a'..'z']) or (tmp[k] in ['A'..'Z'])))
                                    then
                                        break ;
                                end ;

                                if k = len2
                                then
                                    val := StrToInt(tmp) ;
                            end ;

                            if (tmp = 'quot') and (quote > 0)
                            then
                                Charactere := '"'
                            else if (val = 39) and (quote > 1)
                            then
                                Charactere := ''''
                            else if (tmp = 'lt')
                            then
                                Charactere := '<'
                            else if (Charactere = 'gt')
                            then
                                Charactere := '>'
                            else begin
                                Charactere := '&' + tmp + ';' ;
                                found := False ;

                                if val = - 1
                                then begin
                                    repeat
                                        k := 0 ;
                                        fin := EntryMap[IndexOfTableOfCharset].endBase - EntryMap[IndexOfTableOfCharset].startBase ;
                                        TableOfCharset := EntryMap[IndexOfTableOfCharset].tableCharset ;

                                        while k <= fin do
                                        begin
                                            if TableOfCharset^[k] = tmp
                                            then begin
                                                if charset = 'utf-8'
                                                then
                                                    Charactere := ConvertNumberOfUtf8CharToStringUtf8(EntryMap[IndexOfTableOfCharset].startBase + k)
                                                else
                                                    Charactere := Chr(k + EntryMap[IndexOfTableOfCharset].startBase) ;

                                                found := True ;

                                                break ;
                                            end ;

                                            Inc(k) ;
                                        end ;

                                        { Pointe sur le prochain jeu de caractères }
                                        Inc(IndexOfTableOfCharset) ;

                                    until (EntryMap[IndexOfTableOfCharset].charset <> 'utf-8') or (found = True) ;
                                end
                                else begin
                                    if charset = 'utf-8'
                                    then
                                        Charactere := ConvertNumberOfUtf8CharToStringUtf8(val)
                                    else
                                        Charactere := Chr(val) ;
                                end ;
                            end ;

                            { Pointe le caractère suivant }
                            Inc(j) ;

                            i := j ;

                            break ;
                        end
                        else begin
                            { ce n'est pas un caractère html valide donc on
                              quitte la boucle et donc sur retourne sur le
                              premier caractère }
                            break ;
                        end ;
                    end ;
                end ;
            end ;
        end
        else begin
            Inc(i) ;
        end ;
        
        Result := Result + Charactere ;
    end ;
end ;

procedure HtmlSpecialCharsEncodeCommande(arguments : TStringList) ;
var charset : string ;
    quote : Integer ;
    double_encode : boolean ;
begin
    if (arguments.count > 0) and (arguments.count < 5)
    then begin
        if (arguments.count > 1)
        then
            charset := LowerCase(arguments[1])
        else
            charset := DefaultCharset ;

        if (arguments.count > 2)
        then begin
            if UpperCase(arguments[2]) = 'ENT_NOQUOTES'
            then
                quote := 0
            else if UpperCase(arguments[2]) = 'ENT_COMPAT'
            then
                quote := 1
            else if UpperCase(arguments[2]) = 'ENT_QUOTES'
            then
                quote := 2
            else
                quote := 1 ;
        end
        else
            quote := 1 ;

        if (arguments.count > 3)
        then
            double_encode := (arguments[3] = trueValue)
        else
            double_encode := false ;

        ResultFunction := htmlspecialcharencode(Arguments[0], charset, quote, double_encode) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 4
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end  ;

procedure HtmlSpecialCharsDecodeCommande(arguments : TStringList) ;
var charset : string ;
    quote : Integer ;
begin
    if (arguments.count > 0) and (arguments.count < 4)
    then begin
        if (arguments.count > 1)
        then
            charset := LowerCase(arguments[1])
        else
            charset := DefaultCharset ;

        if (arguments.count > 2)
        then begin
            if UpperCase(arguments[2]) = 'ENT_NOQUOTES'
            then
                quote := 0
            else if UpperCase(arguments[2]) = 'ENT_COMPAT'
            then
                quote := 1
            else if UpperCase(arguments[2]) = 'ENT_QUOTES'
            then
                quote := 2
            else
                quote := 1 ;
        end
        else
            quote := 1 ;

        ResultFunction := htmlspecialchardecode(arguments[0], charset, quote) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end  ;

{*******************************************************************************
 * Supprime les balises SGML
 *
 *  Entrée
 *   text : texte à traiter
 *   allowedTags : tags autorisé sous forme d'une chaine : "<p><b>"
 *
 *  Retour : chaine traitée
 ******************************************************************************}
function StripTags(text : String; allowedTags : string) : String ;
var i : Integer ;
    quote : String ;
    len : Integer ;
    inArg : Boolean ;
    BaliseName : String ;
    tmp : String ;
    Tags : array of string ;
    countTags : Integer ;

    procedure setAllowedTags ;
    var posStart : integer ;
        posEnd : integer ;
        tag : String ;
    begin
        countTags := 0 ;

        while allowedTags <> '' do
        begin
            posStart := pos('<', allowedTags) ;
            posEnd := pos('>', allowedTags) ;

            { Si un des élement < ou > manque on ne peut pas tenir compte du
              reste des tags proposés }
            if (posStart = 0) or (posEnd = 0)
            then
                break ;

            { Copie le tag }
            tag := Copy(allowedTags, posStart + 1, posEnd - posStart - 1) ;

            { Supprime le tag de la chaine }
            Delete(allowedTags, posStart, posEnd - posStart + 1) ;

            { on ajoute tags si seulement la chaine n'est pas vide }
            if tag <> ''
            then begin
                { Incrémente le compteur de nombre d'élément }
                Inc(countTags) ;

                SetLength(Tags, countTags) ;

                Tags[countTags - 1] := LowerCase(tag) ;
            end ;
        end ;
    end ;

    function CheckIfAllowedTag(tag : string) : boolean ;
    var j : Integer ;
    begin
        Result := False ;

        for j := 0 to countTags - 1 do
        begin
            if (Tags[j] = tag) or (('/' + Tags[j]) = tag)
            then begin
                Result := True ;
                break ;
            end ;
        end ;
    end ;
begin
    len := Length(text) + 1 ;
    Result := '' ;
    i := 1 ;

    { récupère les tags autorisés }
    setAllowedTags ;

    while i < len do
    begin
        if (Text[i] = '<')
        then begin
            inArg := False ;

            BaliseName := '' ;

            { on pointe actuellement sur '<' }
            tmp := Text[i] ;
            Inc(i);

            { Copie le nom de la balise }
            while i < len do
            begin
                { Copie le nom jusqu'à l'espace, tabulation ou caractère '>' }
                if (Text[i] <> ' ') and (Text[i] <> #9) and (Text[i] <> '>')
                then begin
                    BaliseName := BaliseName + Text[i] ;
                    tmp := tmp + Text[i] ;
                end
                else
                    break ;

                Inc(i) ;
            end ;

            BaliseName := LowerCase(BaliseName) ;

            { va jusqu'à la fin de la balise}
            while i < len do
            begin
                tmp := tmp + Text[i] ;

                if ((Text[i] = '"') or (Text[i] = '''')) and (inArg = False)
                then begin
                    inArg := True ;
                    quote := Text[i] ;
                end
                else if (inArg = True) and (quote = Text[i])
                then begin
                    inArg := False ;
                end ;

                if (Text[i] = '>') and (inArg = False)
                then begin
                    break ;
                end ;

                Inc(i) ;
            end ;

            if CheckIfAllowedTag(BaliseName)
            then begin
                { On ajoute la balise }
                Result := Result + tmp ;
            end ;
        end
        else begin
            Result := Result + Text[i] ;
        end ;

        Inc(i) ;
    end ;
end ;

procedure StripTagsCommande(arguments : TStringList) ;
begin
    if (arguments.count = 1) or (arguments.count = 2)
    then begin
        if (arguments.count = 1)
        then
            arguments.add('') ;
            
        ResultFunction := StripTags(arguments[0], arguments[1]) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 2
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end  ;

procedure HtmlFunctionsInit ;
begin
    ListFunction.Add('nltobr', @NlToBrCommande, true) ;
    ListFunction.Add('htmlspecialcharsencode', @HtmlSpecialCharsEncodeCommande, true) ;
    ListFunction.Add('htmlspecialcharsdecode', @HtmlSpecialCharsDecodeCommande, true) ;
    ListFunction.Add('striptags', @StripTagsCommande, true) ;        
end ;

end.
