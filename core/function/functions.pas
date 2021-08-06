unit Functions;
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
 * This unit containt all function are not functions or keyword of SimpleWebScript
 ******************************************************************************}
{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

interface

uses SysUtils, Variable, UnitMessages, Classes, Extension,
     InternalFunction, ListPointerOfTVariables, UnitOS,
     GetPostCookieFileData, Constantes
     {$IFNDEF COMMANDLINE}
     , DateUtils
     {$ENDIF}
      ;

procedure FinishProgram ;

procedure ExplodeStrings(asText : string; aoLigne : TStringList) ;
procedure ErrorMsg(asText : string) ;
procedure WarningMsg(asText : string) ;
procedure SetVar(asVariable : string; asValue : string) ;
function GetVar(asVariable : string) : String ;
function CheckVarName(aiStart : Integer; asVarName : string) : boolean ;
function IsVar(asText : string) : boolean ;
function GetValueOfStrings(var aoArguments : TStringList) : Integer ;
function IsNumeric(asNombre : string) : boolean ;
function Caree(aeValue : Extended; aiExposant : integer) : Extended;
procedure DelVar(asVariable : string) ;
function IsSetVar(asVariable : string) : boolean ;
function MyStrToInt(asNumber : string) : Integer;
function MyStrToInt64(asNumber : string) : Int64;
function GetPointeurOfVariable(asPointer : string) : string ;
function GetVarNameOfVariable(asPointer : string) : string ;
function GetReferenceFromVar(asVarNamePointed : string) : string;
procedure SetReferenceFromVar(asVarNamePointed : string; asValue : string) ;
procedure UnSetReference(asVarNamePointed : string) ;
function IsSetReference(asVarNamePointed : string) : Boolean ;
function IsFloat(asNumber : String) : Boolean ;
function MyStrToFloat(asNumber : string) : Extended ;
function MyFloatToStr(aeNumber : Extended) : string ;
function IsInteger(asNumber : string) : boolean ;
function FloatToInt(aeNumber : extended) : Int64 ;
function LoadCode(asFileName : String; aiStartLine : Integer) : boolean ;
procedure Explode(asText : string; aoLine : TStringList; asSeparator : string) ;
function ExecuteUserProcedure(asCommande : String; aoCurrentLine : TStringList) : integer ;
procedure DeleteVirguleAndParenthese(aoArgumentsWithParentheses : TStringList) ;
function GetString(asText : String) : String ;
function IsHexa(asNumber : string) : boolean ;
function ExtractCommande(asText : string) : string ;
procedure TStringListToPChar(aoArgTStringList : TStringList; var aArgPChar : PChar) ;
function CallExtension(asCommande : String; aoArguments : TStringList) : Boolean ;
function UrlDecode(asUrl : String) : String ;
function UrlEncode(asUrl : string): string;
function RealPath(asFileName : String) : string ;
function RepeterCaractere(asText : string; aiNumber : Int64) : String ;
function ExtractIntPart(asNumber : String) : String ;
function ExtractFloatPart(asNumber : String) : String ;
function AddSlashes(asText : String) : String ;
function DeleteSlashes(asText : String) : String ;
function DecToHex(aiNumber : Int64) : string ;
function DecToMyBase(aiNumber : Int64; aBase : Byte) : String ;
function DecToOct(aiNumber : Int64) : String ;
function DecToBin(aiNumber : Int64) : String ;
function UniqId : string ;
procedure AddHeader(asLine : String) ;
procedure SendHeader ;
function DateTimeToUnix(aoPascalDate : TDateTime): Longint;
function UnixToDateTime(aiUnixTime: Longint): TDateTime;
procedure OverTimeAndMemory ;
procedure OutputString(asText : String; abParse : boolean) ;
function ShowData(asData : string; asDecalage : String; aiIndex : Integer) : String ;
function ReplaceOneOccurence(asSubstr : string; var asStr : string; asReplaceStr : string; abCaseSensitive : Boolean) : Cardinal ;
function PosString(asSubStr : String; asStr : String; aiIndex : Integer; abCaseSensitive : boolean) : Cardinal ;
function PosrString(asSubStr : String; asStr : String; aiIndex : Integer; abCaseSensitive : boolean) : Cardinal ;
procedure ReplaceOneOccurenceOnce(asSubStr : string; var asStr : string; asReplaceStr : string; var asStrMod : String) ;
procedure setShortDayName ;
procedure setLongDayName ;
procedure setShortMonthName ;
procedure setLongMonthName ;
procedure InitDayName(var aaArray : array of string; aaValue : array of string) ;
procedure InitMonthName(var aaArray : array of string; aaValue : array of string) ;
function IsKeyWord(asKeyword : String) : boolean ;
function IsConst(asText : string) : boolean ;
function IsSetConst(asConstante : string) : boolean ;
function GetConst(asConstante : string) : string ;
function GetEndOfLine(asCommande : string) : string ;
function ExtractEndOperator(asText : string) : string ;
function IsEndOperatorBy(asEndOfLine : string) : boolean ;
function AnsiIndexStr(asText : string; const asValues : array of string) : integer;
function IndexOfTStringList(aiStart : Integer; aoList : TStringList; asSearch : String) : Integer ;
function GetReferenceFromPointer(asPointer : string; asTab : String) : string;
procedure SetReferenceFromPointer(asPointer : string; asTab : String; asValue : string) ;
function MyAbsPower(asBase : Integer; asExponent : Integer) : Integer ;

implementation

uses Code, UserFunction ;

const
  { Configure UnixStartDate vers TDateTime à 01/01/1970 }
  UnixStartDate: TDateTime = 25569.0;

{$INCLUDE finishprogram.inc}

{$INCLUDE explodestring.inc}

{$INCLUDE errormsg.inc}

{$INCLUDE warningmsg.inc}

{$INCLUDE setvar.inc}

{$INCLUDE getvar.inc}

{$INCLUDE checkvarname.inc}

{$INCLUDE isvar.inc}

{$INCLUDE getvalueofstrings.inc}

{$INCLUDE isnumeric.inc}

{$INCLUDE caree.inc}

{$INCLUDE delvar.inc}

{$INCLUDE issetvar.inc}

{$INCLUDE convnumber.inc}

{$INCLUDE convhexa.inc}

{$INCLUDE mystrtoint.inc}

{$INCLUDE mystrtoint64.inc}

{$INCLUDE getpointeurofvariable.inc}

{$INCLUDE getvarnameofvariable.inc}

{$INCLUDE getreferencefromvar.inc}

{$INCLUDE setreferencefromvar.inc}

{$INCLUDE unsetreference.inc}

{$INCLUDE issetreference.inc}

{$INCLUDE isfloat.inc}

{$INCLUDE mystrtofloat.inc}

{$INCLUDE myfloattostr.inc}

{$INCLUDE isinteger.inc}

{$INCLUDE floattoint.inc}

{$INCLUDE loadcode.inc}

{$INCLUDE explode.inc}

{$INCLUDE executeuserprocedure.inc}

{$INCLUDE deletevirguleandparenthese.inc}

{$INCLUDE getstring.inc}

{$INCLUDE ishexa.inc}

{$INCLUDE extractcommande.inc}

{$INCLUDE tstringlisttopchar.inc}

{$INCLUDE callextension.inc}

{$INCLUDE urldecode.inc}

{$INCLUDE urlencode.inc}

{$INCLUDE repetercaractere.inc}

{$INCLUDE extractintpart.inc}

{$INCLUDE extractfloatpart.inc}

{$INCLUDE addslashes.inc}

{$INCLUDE deleteslashes.inc}

{$INCLUDE dectohex.inc}

{$INCLUDE dectomybase.inc}

{$INCLUDE dectooct.inc}

{$INCLUDE dectobin.inc}

{$INCLUDE uniqid.inc}

{$INCLUDE addheader.inc}

{$INCLUDE sendheader.inc}

{$INCLUDE datetimetounix.inc}

{$INCLUDE unixtodatetime.inc}

{$INCLUDE overtimeandmemory.inc}

{$INCLUDE outputstring.inc}

{$INCLUDE realpath.inc}

{$INCLUDE showdata.inc}

{$INCLUDE replaceoneoccurence.inc}

{$INCLUDE posstring.inc}

{$INCLUDE posrstring.inc}

{$INCLUDE replaceoneoccurenceonce.inc}

{$INCLUDE setshortdayname.inc}

{$INCLUDE setlongdayname.inc}

{$INCLUDE setshortmonthname.inc}

{$INCLUDE setlongmonthname.inc}

{$INCLUDE initdayname.inc}

{$INCLUDE initmonthname.inc}

{$INCLUDE iskeyword.inc}

{$INCLUDE isconst.inc}

{$INCLUDE issetconst.inc}

{$INCLUDE getconst.inc}

{$INCLUDE getendofline.inc}

{$INCLUDE extractendoperator.inc}

{$INCLUDE isendoperatorby.inc}

{$INCLUDE ansiindexstr.inc}

{$INCLUDE indexoftstringlist.inc}

{$INCLUDE getreferencefrompointer.inc}

{$INCLUDE setreferencefrompointer.inc}

{$INCLUDE myabspower.inc}

end.

