unit UnitMessages;
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
 * Contain message
 ******************************************************************************}
{$I config.inc}

interface

Const
sMissingLabelOrArguments : string = 'Missing label or too arguments on goto instruction' ;
sNotAVariable : string = '"%s" is not a variable name' ;
sMissingOperator : string = 'Missing operator' ;
sVariableDoesntExist : string = 'Variable "%s" doesn''t exist' ;
sMissingargument : string = 'Missing argument' ;
sNoEndProc : string = 'Open procedure without endfunc command' ;
sProcedureAlreadyExist : string = 'Procedure %s already define' ;
sMissingOperatorOrValue : string = 'Missing operator or value' ;
sIncValNotValidNum : string = 'Increment value is not valid number' ;
sMissingStep : string = 'Must be have "step" keyword' ;
sEndValNotValidNum : string = 'End value is not valid number' ;
sMissingTo : string = 'Must be have "to" keyword' ;
sStartValNotValidNum : string = 'Start value is not valid number' ;
sMissingOrTooArguments : string = 'Missing or too arguments' ;
sMissingEqual : string = 'After variable name must have = charactere' ;
sInvalidFor : string = 'Invalid for command' ;
sCantInsertDataInArray : string = 'Can''t insert data into array' ;
sVarDoesExist : string = 'Variable %s doesn''t exist' ;
sCanExchangeData : string = 'Can''t exchange data' ;
sSndIndexOutBound : string = 'Second index out bound' ;
sFirstIndexOutBound : string = 'Firts index out bound' ;
sSndMustInt : string = 'Second index must be a integer' ;
sFirstMustInt : string = 'First index must be a integer' ;
sCantChunk : string = 'Can''t chunk data' ;
sSizeMustBeInt : string = 'Size must be a integer' ;
sNoEndString : string = 'Non terminate string' ;
sInvalidIndex : string = 'Invalid index. Index must be integer value and > 0' ;
sInvalidPointer : string = 'Invalide pointer of variable' ;
sInvalidVarName : string = 'Invalide variable name' ;
sVarDoestExist : string = 'Variable "%s" doesn''t exist' ;
sMissingPar : string = 'Missing ")"' ;
sMissingCrochet : string = 'Missing "]" for "in" operator' ;
sMissingCrochet2 : string = 'Missing "[" for "in" operator' ;
sDieseOnString : string = 'We cannot use "#" on string' ;
sNoValueAfter : string = 'No value or variable after "%s"' ;
sArabaseOnToLongString : string = 'Operator "@" on to string superior with one char' ;
sNoValueAfterArobase : string ='No value or variable after "@"' ;
sNoOnString : string = 'We cannot use "%s" on string' ;
sMissingAfterOperator : string = 'No value or variable after "%s"' ;
sExposantNotInteger : string = 'Eposant must be an integer' ;
sDivideByZero : string = 'Divide by zero' ;
sNoOnStringOrFloat : string = 'We cannot use "%" on string or float value' ;
sNoHexa : string = '"%s" is not valid hexa number' ;
sNoNumber : string = '"%s" is not valid number' ;
sNotValidPointer : string = 'Not valid pointer' ;
sTooArguments : string = 'Too many arguments' ;
sNoTildeOnFloat : string = 'No "~" on float' ;
sMainFileNotFound : string = '** ERROR ** Main file "%s" not found.' ;
sFileNotFound : string = 'File "%s" not found' ;
sCantReadFile : string = 'Can''t read file "%s"' ;
sUnknowCommande : string = 'Unknow "%s" command' ;
sAffectWithOutEqual : string = 'Affect without "="' ;
sOutOfMemory : String = 'Out of memory' ;
sReservedWord : String = '"%s" is reserved word' ;
sMustBeAnArray : String = 'Must be an array' ;
sGlobalInMain : string = 'Can''t call global command in main' ;
sParamFunctionIncorrect : String = 'Invalid parameter in declaration function' ;
sMustOptionalParameterAfter : String = 'After one optional parameter, must be have only optional parameters' ;
sEqualMustBefor3Dot : String = 'Equal ("=") must before "..."' ;
sNotEqualAnd3Dot : String = 'You cannot have in function optional parameters and "..."' ;
sCantFindFunctionToDelete : String = 'Can''t find function "%s" to deleted' ;
sMissingCompInCase : String = 'Missing comparator on case' ;
sMissingBreakInCase : String = 'Missing case in switch command' ;
sLabelOutOfPrecedure : String = 'Label out of function. Use "goto" commande' ;
sCantAffectPredifinedVar : String = 'Can''t affect value to $true, $false, $_version, $_scriptname' ;
sCantDelredifinedVar : String = 'Can''t delete variable $true, $false, $_version, $_scriptname' ;
//sNotCommentAfterSemiColumn : String = 'Error after ;. Only comment are authorized' ;
sString : String = 'String' ;
sInteger : String = 'Integer' ;
sFloat : String = 'Float' ;
sHexa : String = 'Hexadecimal' ;
sArray : String = 'Array' ;
//sFormatIndexNotInteger : String = 'In function, arguments %d is not integer' ;
sNotAFloatValue : String = 'Not a float value' ;
sNumberToBig : String = 'Number "%s" is to big' ;
sGeneralError : string = 'General Error : ' ;
sNoFileInput : String = 'No input file specified' ;
sErrorIn : String = 'ERROR in ' ;
sWarningIn : String = 'WARNING in ' ;
sTimeIsEnd : String = 'Maximum execution time' ;
sMemoryLimit : String = 'Maximum memory limit' ;
sFunctionDisabled : String = 'Function was disabled' ;
sPostDataTooBig : String = 'Post data too big check configuration of Simple Web Script' ;
sCantDoThisInSafeMode : String = 'In safe mode, you cannot do thats. You can only include/read/save file in doc_root' ;
sCanInitialiseDataToCallExtension : String = 'Can''t initialize data to call extension' ;
sMustBeFloat : String = 'Value must be float' ;
sNotAcceptNegativeValue : String = 'Not accept negative value' ;
sMustBeAByte : String = 'Must be a byte (max 255)' ;
sDecalgeMustBeInteger : String = 'Decalage must be a integer' ;
sMustBeNumber : String = 'Argument must be a integer or float' ;
sMustBeOneOrZero : String = 'String must be compose only by 0 or 1' ;
sMustBeInteger : String = 'Argument must be a integer' ;

implementation

end.
