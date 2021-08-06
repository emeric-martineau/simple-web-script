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

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses Functions, UnitMessages, InternalFunction, classes ;

procedure HtmlFunctionsInit ;
procedure NlToBrCommande(aoArguments : TStringList) ;
procedure HtmlSpecialCharsEncodeCommande(aoArguments : TStringList) ;
procedure HtmlSpecialCharsDecodeCommande(aoArguments : TStringList) ;
procedure StripTagsCommande(aoArguments : TStringList) ;
//
procedure GetChar(asText : string; out asCharactere : string; var aiIndex : integer; asCharset : string; out aiVal : integer; aiIndexOfTableOfCharset : integer; out aiNewIndexOfTableOfCharset : Integer) ;
function htmlspecialcharencode(asText : String; asCharset : String; aiQuote : Integer; abDoubleEncode : boolean) : string ;
function ConvertNumberOfUtf8CharToStringUtf8(aiVal : integer) : String ;
function htmlspecialchardecode(asText : String; asCharset : String; aiQuote : integer) : string ;
function StripTags(asText : String; asAllowedTags : string) : String ;

Const
  ciNoQuoteConvertion : Integer = 0 ;
  ciDoubleQuoteConversion : Integer = 1 ;
  ciAllQuoteConversion : Integer = 2 ;

implementation

uses Code, SysUtils, Constantes ;

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

  EntryMap : array[0..33] of htmlEntityMap = (
                                            { 1252 }
                                            (charset : 'cp1252'; startBase : $80; endBase : $9F; tableCharset : @entryCp1252),
                                            (charset : 'windows-1252'; startBase : $80; endBase : $9F; tableCharset : @entryCp1252),

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
                                            (charset : 'euc-jp'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),
                                            (charset : 'eucjp'; startBase : $A0; endBase : $FF; tableCharset : @entryIso8859_1),

                                            { KOI8-R  koi8-ru, koi8r }
                                            (charset : 'koi8-r'; startBase : $A3; endBase : $FF; tableCharset : @entryKoi8r),
                                            (charset : 'koi8-ru'; startBase : $A3; endBase : $FF; tableCharset : @entryKoi8r),
                                            (charset : 'koi8r'; startBase : $A3; endBase : $FF; tableCharset : @entryKoi8r),

                                            { 1251 }
                                            (charset : 'cp1251'; startBase : $80; endBase : $FF; tableCharset : @entryCp1251),
                                            (charset : 'windows-1251'; startBase : $80; endBase : $FF; tableCharset : @entryCp1251),
                                            (charset : 'wind-1251'; startBase : $80; endBase : $FF; tableCharset : @entryCp1251),

                                            { ISO-8859-5 }
                                            (charset : 'iso8859-5'; startBase : $C0; endBase : $FF; tableCharset : @entryIso8859_5),
                                            (charset : 'iso-8859-5'; startBase : $C0; endBase : $FF; tableCharset : @entryIso8859_5),

                                            { 866 }
                                            (charset : 'cp886'; startBase : $C0; endBase : $FF; tableCharset : @entryCp866),
                                            (charset : 'ibm886'; startBase : $C0; endBase : $FF; tableCharset : @entryCp866),

                                            { end }
                                            (charset : ''; startBase : 0; endBase : 0; tableCharset : nil)
                                             ) ;
                                             
procedure NlToBrCommande(aoArguments : TStringList) ;
var
    { Compteur de caractère }
    liIndex : Integer ;
    { Taille de la chaine }
    liLength : Integer ;
begin
    if aoArguments.count = 1
    then begin
        gsResultFunction := '' ;

        liLength := Length(aoArguments[0]) ;
        liIndex := 1 ;

        { On n'utilise pas de fonction de recherche de caractère pour remplacment
          car on doit remplacer #10, #13, #13#10 donc on parcourerait 3 fois la
          chaine ce qui est plus long }
        while liIndex <= liLength do
        begin
            if aoArguments[0][liIndex] = #10
            then begin
                gsResultFunction := gsResultFunction + '<br />' ;
            end
            else if aoArguments[0][liIndex] = #13
            then begin
                if liIndex < liLength
                then begin
                    if aoArguments[0][liIndex + 1] = #10
                    then begin
                        Inc(liIndex) ;
                    end ;
                end ;

                gsResultFunction := gsResultFunction + '<br />' ;
            end
            else begin
                gsResultFunction := gsResultFunction + aoArguments[0][liIndex] ;
            end ;

            Inc(liIndex) ;

            OverTimeAndMemory ;

            if gbQuit
            then begin
                break ;
            end ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 1
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

{*****************************************************************************
 * GetChar
 * MARTINEAU Emeric
 *
 * Retourne le caractère d'une chaine y compris UTF-8.
 *
 * Paramètres d'entrée :
 *   - asText : texte à lire,
 *   - aiIndex : index de la chaine à chercher,
 *   - asCharset : charset de la chaine,
 *   - aiIndexOfTableOfCharset : index de base dans la table de charset,
 *
 * Paramètres de sortie :
 *   - asCharactere : caractère correspondant,
 *   - aiIndex : incrémenté du nombre de caractère,
 *   - aiVal : valeur du caractère,
 *   - aiNewIndexOfTableOfCharset : nouvel index de base dans la table de charset
 *
 * Retour : nombre de bidule
 *****************************************************************************}
procedure GetChar(asText : string; out asCharactere : string; var aiIndex : integer; asCharset : string; out aiVal : integer; aiIndexOfTableOfCharset : integer; out aiNewIndexOfTableOfCharset : Integer);
var
    { Longueur de la chaine }
    liLength : integer ;
    { Octet courant }
    lbCurrentByte : byte ;
    { Compteur de boucle }
    liCount : Integer ;
begin
    liLength := Length(asText) ;

    if asCharset = 'utf-8'
    then begin
        asCharactere := asText[aiIndex] ;
        aiVal := Ord(asText[aiIndex]) ;
        aiNewIndexOfTableOfCharset := aiIndexOfTableOfCharset ;

        { de 0 à 127 on ne fait rien }
        if aiVal > 127
        then begin
            if (liLength - aiIndex) > 0
            then begin
                Inc(aiIndex) ;
                asCharactere := asCharactere + asText[aiIndex] ;
                lbCurrentByte := Ord(asText[aiIndex]) ;

                { si < $C0 codé sur 2 octets }
                if (aiVal and $E0) < $E0
                then begin
                    { 110yyyxx 10xxxxxx }
                    aiVal := (aiVal and $1F) shl 6 ; // idem  ((val and $1F) shr 2) shl 8
                    { force à 0 les deux bits de poids fort 00111111=3F }
                    aiVal := aiVal or (lbCurrentByte and $3F) ;
                    { On a donc un entier du type 00000yyy xxxxxxxx}
                end
                else begin
                    { CurrentByte pointe déjà sur le deuxième octet }

                    if (liLength - aiIndex) > 0
                    then begin
                        { pointe sur le troisième octet }
                        Inc(aiIndex) ;
                        asCharactere := asCharactere + asText[aiIndex] ;

                        { si < $F0 codé sur 3 octets }
                        if (aiVal and $F0) < $F0
                        then begin
                            { 1110yyyy 10yyyyxx 10xxxxxx }
                            { yyyy0000 }
                            aiVal := (aiVal and $0F) shl 12 ;
                            { 0000yyyy xx}
                            aiVal := aiVal or ((lbCurrentByte and $3F) shl 6) ;

                            { 3ème octet }
                            lbCurrentByte := Ord(asText[aiIndex]) ;

                            aiVal := aiVal or (lbCurrentByte and $3F) ;
                        end
                        else begin
                            { Codé sur 4 octets }
                            { 1 pas 2 car on a un inc(i) avant }
                            if (liLength - aiIndex) > 0
                            then begin
                                { 11110zzz 10zzyyyy 10yyyyxx 10xxxxxx }
                                { zzz00 }
                                aiVal := (aiVal and 7) shl 18 ;
                                { 000zz }
                                aiVal := aiVal or ((lbCurrentByte and $30) shl 12) ; // idem shr 4 shl 16
                                { yyyy0000 }
                                aiVal := aiVal or ((lbCurrentByte and $0F) shl 12) ;

                                { 3ème octet }
                                lbCurrentByte := Ord(asText[aiIndex]) ;

                                { 0000yyyy }
                                aiVal := aiVal or ((lbCurrentByte and $3C) shl 6) ;

                                { xx000000 }
                                aiVal := aiVal or ((lbCurrentByte and 3) shl 6) ;

                                Inc(aiIndex) ;
                                
                                asCharactere := asCharactere + asText[aiIndex] ;

                                { 4ème octet }
                                lbCurrentByte := Ord(asText[aiIndex]) ;

                                aiVal := aiVal or (lbCurrentByte and $3F) ;
                            end ;
                        end ;
                    end ;
                end ;
            end ;
        end ;

        Inc(aiIndex) ;

        { chercher la bonne table utf-8 }

        liCount := aiIndexOfTableOfCharset ;

        while EntryMap[liCount].charset <> '' do
        begin
            if (aiVal >= EntryMap[liCount].startBase) and (aiVal <= EntryMap[liCount].endBase)
            then begin
                aiNewIndexOfTableOfCharset := liCount ;
                break ;
            end
            else if aiVal < EntryMap[liCount].startBase
            then begin
                break ;
            end ;

            Inc(liCount) ;
        end ;
    end
    else begin
        aiVal := Ord(asText[aiIndex]) ;
        asCharactere := asText[aiIndex] ;
        Inc(aiIndex) ;
        aiNewIndexOfTableOfCharset := aiIndexOfTableOfCharset ;
    end ;
end ;

{*****************************************************************************
 * htmlspecialcharencode
 * MARTINEAU Emeric
 *
 * Convertit un texte en texte html.
 *
 * Paramètres d'entrée :
 *   asText : texte à convertir
 *   asCharset : charset à utiliser pour convertir
 *   aiQuote : 0 = pas de convertion de ' ou "
 *           1 = convertion de " mais pas '
 *           2 = convertion de ' et "
 *   abDoubleEncode : true indique qu'il s'agit d'un double encodage et donc ne
 *                   pas reconvertir les &xxxx;
 *
 * Retour : chaine encodée
 *****************************************************************************}
function htmlspecialcharencode(asText : String; asCharset : String; aiQuote : Integer; abDoubleEncode : boolean) : string ;
var
    { Compteur du text }
    liTextCount : integer ;
    { Compteur de caractère hexa }
    liHexaCount : integer ;
    { Longueur du texte }
    liTextLength : integer ;
    { Valeur du caractère }
    liVal : Integer ;
    { Index de table de charset }
    liIndexOfTableOfCharset : Integer ;
    { Nouvel index de table de charset }
    liNewIndexOfTableOfCharset : Integer ;
    { Pointeur de charset }
    lpTableOfCharset : PCharsetTable ;
    { Caractère }
    lsCharactere : String ;
    { Valeur hexa temporaire }
    lsTmpHexa : String ;
begin
    Result := '' ;
    liTextLength := Length(astext) + 1 ;
    liIndexOfTableOfCharset := 0 ;

    { Fait pointer IndexOfTableOfCharset sur le bon charset }
    for liTextCount := Low(EntryMap) to High(EntryMap) do
    begin
        if EntryMap[liTextCount].charset = asCharset
        then begin
            liIndexOfTableOfCharset := liTextCount ;
            break ;
        end ;
    end ;

    { Convertit la chaine }
    liTextCount := 1 ;
    
    while liTextCount < liTextLength do
    begin
        GetChar(asText, lsCharactere, liTextCount, asCharset, liVal, liIndexOfTableOfCharset, liNewIndexOfTableOfCharset) ;


        if (liVal >= EntryMap[liNewIndexOfTableOfCharset].startBase) and (liVal <= EntryMap[liNewIndexOfTableOfCharset].endBase)
        then begin
            { Pointe sur le bon tableau }
            lpTableOfCharset := EntryMap[liNewIndexOfTableOfCharset].tableCharset ;
            lsTmpHexa := lpTableOfCharset^[liVal - EntryMap[liNewIndexOfTableOfCharset].startBase] ;

            if lsTmpHexa <> ''
            then begin
                lsCharactere := '&' + lsTmpHexa + ';' ;
            end ;
        end ;

        if (lsCharactere = '"') and (aiQuote > ciNoQuoteConvertion)
        then begin
            lsCharactere := '&quot;' ;
        end
        else if (lsCharactere = '''') and (aiQuote > ciDoubleQuoteConversion)
        then begin
            lsCharactere := '&#039;' ;
        end
        else if (lsCharactere = '<')
        then begin
            lsCharactere := '&lt;' ;
        end
        else if (lsCharactere = '>')
        then begin
            lsCharactere := '&gt;' ;
        end
        else if (lsCharactere = '&')
        then begin
            if abDoubleEncode = False
            then begin
                lsCharactere := '&amp;' ;
            end
            else begin
                if (liTextLength - liTextCount) > 0
                then begin
                    { on fait pointer j sur i car on va incrémenter le pointeur
                      de chaine or s'il ne s'agit pas d'un caractère html, il
                      faut revenir en arrière }
                    liHexaCount := liTextCount ;

                    lsTmpHexa := lsCharactere ;

                    { On n'incrément pas j car i pointe déjà sur le caractère
                      suivant }

                    if asText[liHexaCount] = '#'
                    then begin
                        lsTmpHexa := lsTmpHexa + asText[liHexaCount] ;
                        Inc(liHexaCount) ;
                    end ;

                    while liHexaCount < liTextLength do
                    begin
                        if (asText[liHexaCount] in ['a'..'z']) or (asText[liHexaCount] in ['A'..'Z']) or
                           (asText[liHexaCount] in ['0'..'9'])
                        then begin
                            lsTmpHexa := lsTmpHexa + asText[liHexaCount] ;
                        end
                        else begin
                            if asText[liHexaCount] = ';'
                            then begin
                                { pointe sur le caractère d'après }
                                lsTmpHexa := lsTmpHexa + asText[liHexaCount] ;

                                { pointe sur le prochain caractère }
                                liTextCount := liHexaCount + 1 ;

                                lsCharactere := lsTmpHexa ;
                            end
                            else begin
                                lsCharactere := '&amp;' ;
                            end ;

                            break ;                            
                        end ;

                        Inc(liHexaCount) ;
                    end ;
                end
                else begin
                    lsCharactere := '&amp;' ;
                end ;
            end ;
        end ;

        Result := Result + lsCharactere ;
    end ;
end ;

{*****************************************************************************
 * ConvertNumberOfUtf8CharToStringUtf8
 * MARTINEAU Emeric
 *
 * Convertit un numéro de caractère UTF-8 en suite d'octet.
 *
 * Paramètres d'entrée :
 *   - aiVal : numéro du caractère
 *
 * Retour : octet représentant le caractère
 *****************************************************************************}
function ConvertNumberOfUtf8CharToStringUtf8(aiVal : integer) : String ;
var
    lbOctet : byte ;
begin
    if aiVal < 128
    then begin
        { 1 octet }
        { 0xxxxxxx }
        Result := Chr(aiVal) ;
    end
    else if (aiVal > 127) and (aiVal < 2048)
    then begin
        { 2 octets }
        { yyxxxxxx -> 110yyyxx 10xxxxxx }
        // yy
        lbOctet := ((aiVal and $C0) shr 6) or $C0 ;
        Result := Chr(lbOctet) ;
        // xxxxxx
        lbOctet := (aiVal and $3F) or $80 ;
        Result := Result + Chr(lbOctet) ;

    end
    else if (aiVal > 2047) and (aiVal < 65536)
    then begin
        { 3 octets }
        { yyyyyyyy xxxxxxxx -> 1110yyyy 10yyyyxx 10xxxxxx}
        lbOctet := ((aiVal and $F000) shr 12) or $E0 ;
        Result := Chr(lbOctet) ;

        { 10yyyyxx }
        lbOctet := ((aiVal and $F00) shr 6) or ((aiVal and $C0) shr 6) or $80 ;
        Result := Result + Chr(lbOctet) ;

        lbOctet := (aiVal and $3F) or $80 ;
        Result := Result + Chr(lbOctet) ;
    end
    else begin
        { 4 octets }
        { zzzzz yyyyyyyy xxxxxxxx -> 11110zzz 10zzyyyy 10yyyyxx 10xxxxxx }
        lbOctet := ((aiVal and $1C0000) shr 18) or $F0 ;
        Result := Chr(lbOctet) ;

        lbOctet := ((aiVal and $30000) shr 12) or ((aiVal and $F000) shr 12) or $80 ;
        Result := Result + Chr(lbOctet) ;

        lbOctet := ((aiVal and $F00) shr 6) or ((aiVal and $C0) shr 6) or $80 ;
        Result := Result + Chr(lbOctet) ;

        lbOctet := (aiVal and $3F) or $80 ;
        Result := Result + Chr(lbOctet) ;
    end ;
end ;

{*****************************************************************************
 * htmlspecialchardecode
 * MARTINEAU Emeric
 *
 * Convertit un texte html en text.
 *
 * Paramètres d'entrée :
 *   - aiTruc : texte,
 *   - asCharset : charset de la chaine,
 *   - aiQuote : indique si les quotes doivent être converties,
 *
 * Retour : chaine convertie
 *****************************************************************************}
function htmlspecialchardecode(asText : String; asCharset : String; aiQuote : integer) : string ;
var
    { Compteur de chaine }
    liTextCount : integer ;
    { Compteur de caractère à décoder entre & et ; }
    liCharCount : integer ;
    { Compteur d'hexa }
    liHexaCount : integer ;
    { Compteur de charset }
    liTableCharsetCount : Integer ;
    { Longueur de asText }
    liTextLength : integer ;
    { Index de la table de charset }
    liIndexOfTableOfCharset : Integer ;
    { Caractère décodé }
    lsCharactere : String ;
    { Valeur temporaire (entre & et ;) du caractère à décoder }
    lsTmpValOfChar : string ;
    { TAble de charset }
    lpTableOfCharset : PCharsetTable ;
    { Valeur du caractère si hexa }
    liHexaVal : integer ;
    { Indique si le caractère à décodé est de l'hexa }
    lbHexa : Boolean ;
    { Longueur du caractère (entre & et ;) à décoder }
    liLenOfDecodeChar : Integer ;
    { Indique si le caractère est trouvé dans une des tables de charset }
    lbFound : Boolean ;
    { Fin du charset }
    liFin : Integer ;
begin
    liTextLength := Length(asText) + 1 ;
    Result := '' ;
    liIndexOfTableOfCharset := 0 ;

    { Fait pointer IndexOfTableOfCharset sur le bon charset }
    for liTextCount := Low(EntryMap) to High(EntryMap) do
    begin
        if EntryMap[liTextCount].charset = asCharset
        then begin
            liIndexOfTableOfCharset := liTextCount ;
            break ;
        end ;
    end ;

    liTextCount := 1 ;

    while liTextCount < liTextLength do
    begin
        lsCharactere := asText[liTextCount] ;

        if asText[liTextCount] = '&'
        then begin
            if (liTextLength - liTextCount) > 0
            then begin
                liCharCount := liTextCount ;

                { pointe sur le prochain caractère }
                Inc(liCharCount) ;
                lsTmpValOfChar := '' ;

                if asText[liCharCount] = '#'
                then begin
                    Inc(liCharCount) ;
                end ;

                while liCharCount < liTextLength do
                begin
                    if (asText[liCharCount] in ['a'..'z']) or (asText[liCharCount] in ['A'..'Z']) or
                       (asText[liCharCount] in ['0'..'9'])
                    then begin
                        lsTmpValOfChar := lsTmpValOfChar + asText[liCharCount] ;
                        Inc(liCharCount) ;
                    end
                    else begin
                        if asText[liCharCount] = ';'
                        then begin
                            { vérifie qu'il ne s'agit pas d'un nombre hexa }
                            if (lsTmpValOfChar[1] = 'x') or (lsTmpValOfChar[1] = 'X')
                            then begin
                                lsTmpValOfChar[1] := '$' ;
                                { permet d'éviter le $ dans la boucle de
                                  vérification du nombre }
                                liHexaCount := 2 ;
                                lbHexa := True ;
                            end
                            else begin
                                liHexaCount := 1 ;
                                lbHexa := False ;
                            end ;

                            liHexaVal := -1 ;
                            liLenOfDecodeChar := Length(lsTmpValOfChar) ;

                            for liHexaCount := liHexaCount to liLenOfDecodeChar do
                            begin
                                if not (lsTmpValOfChar[liHexaCount] in ['0'..'9'])
                                then begin
                                    if not ((lbHexa) and ((lsTmpValOfChar[liHexaCount] in ['a'..'z']) or (lsTmpValOfChar[liHexaCount] in ['A'..'Z'])))
                                    then begin
                                        break ;
                                    end ;
                                end ;

                                if liHexaCount = liLenOfDecodeChar
                                then begin
                                    liHexaVal := StrToInt(lsTmpValOfChar) ;
                                end ;
                            end ;

                            if (lsTmpValOfChar = 'quot') and (aiQuote > ciNoQuoteConvertion)
                            then begin
                                lsCharactere := '"' ;
                            end
                            else if (liHexaVal = 39) and (aiQuote > ciDoubleQuoteConversion)
                            then begin
                                lsCharactere := '''' ;
                            end
                            else if (lsTmpValOfChar = 'lt')
                            then begin
                                lsCharactere := '<' ;
                            end
                            else if (lsCharactere = 'gt')
                            then begin
                                lsCharactere := '>'
                            end
                            else begin
                                lsCharactere := '&' + lsTmpValOfChar + ';' ;
                                lbFound := False ;

                                if liHexaVal = - 1
                                then begin
                                    repeat
                                        liTableCharsetCount := 0 ;
                                        liFin := EntryMap[liIndexOfTableOfCharset].endBase - EntryMap[liIndexOfTableOfCharset].startBase ;
                                        lpTableOfCharset := EntryMap[liIndexOfTableOfCharset].tableCharset ;

                                        while liTableCharsetCount <= liFin do
                                        begin
                                            if lpTableOfCharset^[liTableCharsetCount] = lsTmpValOfChar
                                            then begin
                                                if asCharset = 'utf-8'
                                                then begin
                                                    lsCharactere := ConvertNumberOfUtf8CharToStringUtf8(EntryMap[liIndexOfTableOfCharset].startBase + liTableCharsetCount)
                                                end
                                                else begin
                                                    lsCharactere := Chr(liTableCharsetCount + EntryMap[liIndexOfTableOfCharset].startBase) ;
                                                end ;

                                                lbFound := True ;

                                                break ;
                                            end ;

                                            Inc(liTableCharsetCount) ;
                                        end ;

                                        { Pointe sur le prochain jeu de caractères }
                                        Inc(liIndexOfTableOfCharset) ;

                                    until (EntryMap[liIndexOfTableOfCharset].charset <> 'utf-8') or (lbFound = True) ;
                                end
                                else begin
                                    if asCharset = 'utf-8'
                                    then begin
                                        lsCharactere := ConvertNumberOfUtf8CharToStringUtf8(liHexaVal)
                                    end
                                    else begin
                                        lsCharactere := Chr(liHexaVal) ;
                                    end ;
                                end ;
                            end ;

                            { Pointe le caractère suivant }
                            Inc(liCharCount) ;

                            liTextCount := liCharCount ;

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
            Inc(liTextCount) ;
        end ;
        
        Result := Result + lsCharactere ;
    end ;
end ;

procedure HtmlSpecialCharsEncodeCommande(aoArguments : TStringList) ;
var
    { Charset à utiliser }
    lsCharset : string ;
    { niveau de quote à utiliser }
    liQuote : Integer ;
    { Double encoding }
    lbDoubleEncode : boolean ;
begin
    if (aoArguments.count > 0) and (aoArguments.count < 5)
    then begin
        if (aoArguments.count > 1)
        then begin
            if aoArguments[1] = IntToStr(ciNoQuoteConvertion)
            then begin
                liQuote := ciNoQuoteConvertion ;
            end
            else if aoArguments[1] = IntToStr(ciDoubleQuoteConversion)
            then begin
                liQuote := ciDoubleQuoteConversion ;
            end
            else if aoArguments[1] = IntToStr(ciAllQuoteConversion)
            then begin
                liQuote := ciAllQuoteConversion ;
            end
            else begin
                liQuote := ciDoubleQuoteConversion ;
            end ;
        end
        else begin
            liQuote := 1 ;
        end ;

        if (aoArguments.count > 2)
        then begin
            lsCharset := aoArguments[2]
        end
        else begin
            lsCharset := gsDefaultCharset ;
        end ;

        if (aoArguments.count > 3)
        then begin
            lbDoubleEncode := (aoArguments[3] = csTrueValue)
        end
        else begin
            lbDoubleEncode := false ;
        end ;

        gsResultFunction := htmlspecialcharencode(aoArguments[0], lsCharset, liQuote, lbDoubleEncode) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 4
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure HtmlSpecialCharsDecodeCommande(aoArguments : TStringList) ;
var lsCharset : string ;
    liQuote : Integer ;
begin
    if (aoArguments.count > 0) and (aoArguments.count < 4)
    then begin
        if (aoArguments.count > 1)
        then begin
            if aoArguments[1] = IntToStr(ciNoQuoteConvertion)
            then begin
                liQuote := ciNoQuoteConvertion ;
            end
            else if aoArguments[1] = IntToStr(ciDoubleQuoteConversion)
            then begin
                liQuote := ciDoubleQuoteConversion ;
            end
            else if aoArguments[1] = IntToStr(ciAllQuoteConversion)
            then begin
                liQuote := ciAllQuoteConversion ;
            end
            else begin
                liQuote := ciDoubleQuoteConversion ;
            end ;
        end
        else begin
            liQuote := 1 ;
        end ;

        if (aoArguments.count > 2)
        then begin
            lsCharset := aoArguments[2]
        end
        else begin
            lsCharset := gsDefaultCharset ;
        end ;

        gsResultFunction := htmlspecialchardecode(aoArguments[0], lsCharset, liQuote) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

{*****************************************************************************
 * StripTags
 * MARTINEAU Emeric
 *
 * Supprime les balises SGML
 *
 * Paramètres d'entrée :
 *   - asText : texte à analyser,
 *   - asAllowedTags : tag autorisées,
 *
 * Retour : chaine avec les tags supprimées,
 *****************************************************************************}
function StripTags(asText : String; asAllowedTags : string) : String ;
var
    { Compteur de boucle }
    liTextCount : Integer ;
    { Valeur d'une quote si " ou ' }
    asQuote : String ;
    { Longueur de asText }
    liTextLength : Integer ;
    { Indique si on se trouve dans un argument }
    lbInArg : Boolean ;
    { Nom de la balise courante }
    lsBaliseName : String ;
    { Balise complète avec les aoArguments }
    lsFullBalise : String ;
    { Liste des tags autorisées }
    laAllowTags : array of string ;
    { Nombre de tags autoriseés }
    liCountAllowTags : Integer ;

    procedure SetAllowedTags ;
    var
        { Position de début du tag }
        liPosStart : integer ;
        { Position de fin du tag }
        liPosEnd : integer ;
        { Tag }
        lsTag : String ;
    begin
        liCountAllowTags := 0 ;

        while asAllowedTags <> '' do
        begin
            liPosStart := pos('<', asAllowedTags) ;
            liPosEnd := pos('>', asAllowedTags) ;

            { Si un des élement < ou > manque on ne peut pas tenir compte du
              reste des tags proposés }
            if (liPosStart = 0) or (liPosEnd = 0)
            then begin
                break ;
            end ;
            
            { Copie le tag }
            lsTag := Copy(asAllowedTags, liPosStart + 1, liPosEnd - liPosStart - 1) ;

            { Supprime le tag de la chaine }
            Delete(asAllowedTags, liPosStart, liPosEnd - liPosStart + 1) ;

            { on ajoute tags si seulement la chaine n'est pas vide }
            if lsTag <> ''
            then begin
                { Incrémente le compteur de nombre d'élément }
                Inc(liCountAllowTags) ;

                SetLength(laAllowTags, liCountAllowTags) ;

                laAllowTags[liCountAllowTags - 1] := LowerCase(lsTag) ;
            end ;
        end ;
    end ;

    function CheckIfAllowedTag(tag : string) : boolean ;
    var
        { Index du tableau de tag autorisée }
        liTabAllowTags : Integer ;
    begin
        Result := False ;

        for liTabAllowTags := 0 to liCountAllowTags - 1 do
        begin
            if (laAllowTags[liTabAllowTags] = tag) or (('/' + laAllowTags[liTabAllowTags]) = tag)
            then begin
                Result := True ;
                break ;
            end ;
        end ;
    end ;
begin
    liTextLength := Length(asText) + 1 ;
    Result := '' ;
    liTextCount := 1 ;

    { récupère les tags autorisés }
    setAllowedTags ;

    while liTextCount < liTextLength do
    begin
        if (asText[liTextCount] = '<')
        then begin
            lbInArg := False ;

            lsBaliseName := '' ;

            { on pointe actuellement sur '<' }
            lsFullBalise := asText[liTextCount] ;
            Inc(liTextCount);

            { Copie le nom de la balise }
            while liTextCount < liTextLength do
            begin
                { Copie le nom jusqu'à l'espace, tabulation ou caractère '>' }
                if (asText[liTextCount] <> ' ') and (asText[liTextCount] <> #9) and (asText[liTextCount] <> '>')
                then begin
                    lsBaliseName := lsBaliseName + asText[liTextCount] ;
                    lsFullBalise := lsFullBalise + asText[liTextCount] ;
                end
                else begin
                    break ;
                end ;

                Inc(liTextCount) ;
            end ;

            lsBaliseName := LowerCase(lsBaliseName) ;

            { va jusqu'à la fin de la balise}
            while liTextCount < liTextLength do
            begin
                lsFullBalise := lsFullBalise + asText[liTextCount] ;

                if ((asText[liTextCount] = '"') or (asText[liTextCount] = '''')) and (lbInArg = False)
                then begin
                    lbInArg := True ;
                    asQuote := asText[liTextCount] ;
                end
                else if (lbInArg = True) and (asQuote = asText[liTextCount])
                then begin
                    lbInArg := False ;
                end ;

                if (asText[liTextCount] = '>') and (lbInArg = False)
                then begin
                    break ;
                end ;

                Inc(liTextCount) ;
            end ;

            if CheckIfAllowedTag(lsBaliseName)
            then begin
                { On ajoute la balise }
                Result := Result + lsFullBalise ;
            end ;
        end
        else begin
            Result := Result + asText[liTextCount] ;
        end ;

        Inc(liTextCount) ;
    end ;
end ;

procedure StripTagsCommande(aoArguments : TStringList) ;
begin
    if (aoArguments.count = 1) or (aoArguments.count = 2)
    then begin
        if (aoArguments.count = 1)
        then begin
            aoArguments.add('') ;
        end ;
        
        gsResultFunction := StripTags(aoArguments[0], aoArguments[1]) ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end  ;

procedure HtmlFunctionsInit ;
begin
    goInternalFunction.Add('nlToBr', @NlToBrCommande, true) ;
    goInternalFunction.Add('htmlSpecialCharsEncode', @HtmlSpecialCharsEncodeCommande, true) ;
    goInternalFunction.Add('htmlSpecialCharsDecode', @HtmlSpecialCharsDecodeCommande, true) ;
    goInternalFunction.Add('stripTags', @StripTagsCommande, true) ;

    goConstantes.Add('#ENT_NOQUOTES', IntToStr(ciNoQuoteConvertion)) ;
    goConstantes.Add('#ENT_COMPAT', IntToStr(ciDoubleQuoteConversion)) ;
    goConstantes.Add('#ENT_QUOTES', IntToStr(ciAllQuoteConversion)) ;

    goConstantes.Add('#ISO_8859_1', 'iso-8859-1') ;
    goConstantes.Add('#ISO8859_1', 'iso8859-1') ;
    goConstantes.Add('#ISO_8859_15', 'iso-8859-15') ;
    goConstantes.Add('#ISO8859_15', 'iso8859-15') ;
    goConstantes.Add('#UTF_8', 'utf8') ;
    goConstantes.Add('#CP866', 'cp866') ;
    goConstantes.Add('#IBM866', 'ibm866') ;
    goConstantes.Add('#CP1251', 'cp1251') ;
    goConstantes.Add('#WINDOWS_1251', 'windows-1251') ;
    goConstantes.Add('#WIN_1251', 'win-1251') ;
    goConstantes.Add('#CP1252', 'cp1252') ;
    goConstantes.Add('#WINDOWS_1252', 'windows-1252') ;
    goConstantes.Add('#KOI8_R', 'koi8-r') ;
    goConstantes.Add('#KOI8_RU', 'koi8-ru') ;
    goConstantes.Add('#KOI8R', 'koi8r') ;
    goConstantes.Add('#BIG5', 'big5') ;
    goConstantes.Add('#GB2312', 'gb2312') ;
    goConstantes.Add('#BIG5_HKSCS', 'big5-hkscs') ;
    goConstantes.Add('#SHIFT_JIS', 'shift_jis') ;
    goConstantes.Add('#SJIS', 'sjis') ;
    goConstantes.Add('#EUC_JP', 'euc-jp') ;
    goConstantes.Add('#EUCJP', 'eucjp' ) ;
end ;

end.
