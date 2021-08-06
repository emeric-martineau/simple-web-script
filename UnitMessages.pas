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

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

interface

Const
csMissingLabelOrArguments : string = 'Missing label or too arguments on goto instruction' ;
csNotAVariable : string = '"%s" is not a variable name' ;
csMissingOperator : string = 'Missing operator' ;
csVariableDoesntExist : string = 'Variable "%s" doesn''t exist' ;
csMissingargument : string = 'Missing argument' ;
csNoEndProc : string = 'Open procedure without endfunc command' ;
csProcedureAlreadyExist : string = 'Procedure %s already define' ;
csMissingOperatorOrValue : string = 'Missing operator or value' ;
csIncValNotValidNum : string = 'Increment value is not valid number' ;
csMissingStep : string = 'Must be have "step" keyword' ;
csEndValNotValidNum : string = 'End value is not valid number' ;
csMissingTo : string = 'Must be have "to" keyword' ;
csStartValNotValidNum : string = 'Start value is not valid number' ;
csMissingOrTooArguments : string = 'Missing or too arguments' ;
csMissingEqual : string = 'After variable name must have = charactere' ;
csInvalidFor : string = 'Invalid for command' ;
csCantInsertDataInArray : string = 'Can''t insert data into array' ;
csVarDoesExist : string = 'Variable %s doesn''t exist' ;
csCanExchangeData : string = 'Can''t exchange data' ;
csSndIndexOutBound : string = 'Second index out bound' ;
csFirstIndexOutBound : string = 'Firts index out bound' ;
csSndMustInt : string = 'Second index must be a integer' ;
csFirstMustInt : string = 'First index must be a integer' ;
csCantChunk : string = 'Can''t chunk data' ;
csSizeMustBeInt : string = 'Size must be a integer' ;
csNoEndString : string = 'Non terminate string' ;
csInvalidIndex : string = 'Invalid index. Index must be integer value and >= 0' ;
csInvalidPointer : string = 'Invalide pointer of variable' ;
csInvalidVarName : string = 'Invalide variable name' ;
csVarDoestExist : string = 'Variable "%s" doesn''t exist' ;
csMissingPar : string = 'Missing ")"' ;
csMissingCrochet : string = 'Missing "]" for "in" operator' ;
csMissingCrochet2 : string = 'Missing "[" for "in" operator' ;
//csDieseOnString : string = 'We cannot use "#" on string' ;
csNoValueAfter : string = 'No value or variable after "%s"' ;
csArabaseOnToLongString : string = 'Operator "@" on to string superior with one char' ;
csNoValueAfterArobase : string ='No value or variable after "@"' ;
csNoOnString : string = 'We cannot use "%s" on string' ;
csMissingAfterOperator : string = 'No value or variable after "%s"' ;
csExposantNotInteger : string = 'Eposant must be an integer' ;
csDivideByZero : string = 'Divide by zero' ;
csNoOnStringOrFloat : string = 'We cannot use "%" on string or float value' ;
csNoHexa : string = '"%s" is not valid hexa number' ;
csNoNumber : string = '"%s" is not valid number' ;
csNotValidPointer : string = 'Not valid pointer' ;
csTooArguments : string = 'Too many arguments' ;
csNoTildeOnFloat : string = 'No "~" on float' ;
csMainFileNotFound : string = '** ERROR ** Main file "%s" not found.' ;
csFileNotFound : string = 'File "%s" not found' ;
csCantReadFile : string = 'Can''t read file "%s"' ;
csUnknowCommande : string = 'Unknow "%s" command' ;
csAffectWithOutEqual : string = 'Affect without "="' ;
csOutOfMemory : String = 'Out of memory' ;
csReservedWord : String = '"%s" is reserved word' ;
csMustBeAnArray : String = 'Must be an array' ;
csGlobalInMain : string = 'Can''t call global command in main' ;
csParamFunctionIncorrect : String = 'Invalid parameter in declaration function' ;
csMustOptionalParameterAfter : String = 'After one optional parameter, must be have only optional parameters' ;
csEqualMustBefor3Dot : String = 'Equal ("=") must before "..."' ;
csNotEqualAnd3Dot : String = 'You cannot have in function optional parameters and "..."' ;
csCantFindFunctionToDelete : String = 'Can''t find function "%s" to deleted' ;
csMissingCompInCase : String = 'Missing comparator on case' ;
csMissingBreakInCase : String = 'Missing case in switch command' ;
csLabelOutOfPrecedure : String = 'Label out of function. Use "goto" commande' ;
//csCantAffectPredifinedVar : String = 'Can''t affect value to $true, $false, $_version, $_scriptname' ;
//csCantDelredifinedVar : String = 'Can''t delete variable $true, $false, $_version, $_scriptname' ;
//sNotCommentAfterSemiColumn : String = 'Error after ;. Only comment are authorized' ;
csString : String = 'String' ;
csInteger : String = 'Integer' ;
csFloat : String = 'Float' ;
csHexa : String = 'Hexadecimal' ;
csArray : String = 'Array' ;
//sFormatIndexNotInteger : String = 'In function, arguments %d is not integer' ;
csNotAFloatValue : String = 'Not a float value' ;
csNumberToBig : String = 'Number "%s" is to big' ;
csGeneralError : string = 'General Error : ' ;
csNoFileInput : String = 'No input file specified' ;
csErrorIn : String = 'ERROR in ' ;
csWarningIn : String = 'WARNING in ' ;
csTimeIsEnd : String = 'Maximum execution time' ;
csMemoryLimit : String = 'Maximum memory limit' ;
csFunctionDisabled : String = 'Function was disabled' ;
csPostDataTooBig : String = 'Post data too big check configuration of Simple Web Script' ;
csCantDoThisInSafeMode : String = 'In safe mode, you cannot do thats. You can only include/read/save file in doc_root' ;
csCanInitialiseDataToCallExtension : String = 'Can''t initialize data to call extension' ;
csMustBeFloat : String = 'Value must be float' ;
csNotAcceptNegativeValue : String = 'Not accept negative value' ;
csMustBeAByte : String = 'Must be a byte (max 255)' ;
csDecalgeMustBeInteger : String = 'Decalage must be a integer' ;
csMustBeNumber : String = 'Argument must be a integer or float' ;
csMustBeOneOrZero : String = 'String must be compose only by 0 or 1' ;
csMustBeInteger : String = 'Argument must be a integer' ;
// v0.1.1
csCanNotModifyHeader : String = 'Cannot modify header information - headers already sent by (output started at %s:%s)' ;
csLabelAlreadyExist : String = 'Label %s already exist' ;
csNotAConstante : string = '"%s" is not a constante name' ;
csDebugToMany : string = 'Missing arguments or too arguments' ;
csConstanteAlreadyDefine : string = 'Constantes "%s" is already define' ;
csCantFindEndOfComment : string = 'Can''t find end of comment on line' ;
csMissingEndOfLine : string = 'Missing "%s" at end' ;
csLineToLine : string = '%line1 to %line2' ;
csConstanteDoesntExist : string = 'Constante "%s" doesn''t exist' ;
implementation

end.
