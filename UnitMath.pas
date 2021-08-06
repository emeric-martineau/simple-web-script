unit UnitMath;
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

uses Functions, UnitMessages, InternalFunction, classes, Math, Variable ;

procedure MathFunctionsInit ;
procedure ExtractIntPartCommande(arguments : TStringList) ;
procedure ExtractFloatPartCommande(arguments : TStringList) ;
procedure DecToHexCommande(arguments : TStringList) ;
procedure DecToOctCommande(arguments : TStringList) ;
procedure DecToBinCommande(arguments : TStringList) ;
procedure PiCommande(arguments : TStringList) ;
procedure uniqIdCommande(arguments : TStringList) ;
procedure MaxCommande(arguments : TStringList) ;
procedure MinCommande(arguments : TStringList) ;
procedure BinToDecCommande(arguments : TStringList) ;
procedure ExpCommande(arguments : TStringList) ;
procedure LnCommande(arguments : TStringList) ;
procedure oddCommande(arguments : TStringList) ;
procedure cosCommande(arguments : TStringList) ;
procedure acosCommande(arguments : TStringList) ;
procedure acoshCommande(arguments : TStringList) ;
procedure sinCommande(arguments : TStringList) ;
procedure asinCommande(arguments : TStringList) ;
procedure asinhCommande(arguments : TStringList) ;
procedure tanCommande(arguments : TStringList) ;
procedure atanCommande(arguments : TStringList) ;
procedure atanhCommande(arguments : TStringList) ;
procedure atan2Commande(arguments : TStringList) ;
procedure absCommande(arguments : TStringList) ;
procedure fracCommande(arguments : TStringList) ;
procedure cotCommande(arguments : TStringList) ;
procedure acotCommande(arguments : TStringList) ;
procedure intCommande(arguments : TStringList) ;
procedure roundCommande(arguments : TStringList) ;
procedure sqrtCommande(arguments : TStringList) ;
procedure sqrCommande(arguments : TStringList) ;
procedure truncCommande(arguments : TStringList) ;
procedure randCommande(arguments : TStringList) ;
procedure ceilCommande(arguments : TStringList) ;
procedure EnsureRangeCommande(arguments : TStringList) ;
procedure floorCommande(arguments : TStringList) ;
procedure FrexpCommande(arguments : TStringList) ;
procedure InRangeCommande(arguments : TStringList) ;
procedure LdExpCommande(arguments : TStringList) ;
procedure LnXP1Commande(arguments : TStringList) ;
procedure Log10Commande(arguments : TStringList) ;
procedure Log2Commande(arguments : TStringList) ;
procedure LogNCommande(arguments : TStringList) ;
procedure PolyCommande(arguments : TStringList) ;
procedure SameValueCommande(arguments : TStringList) ;
procedure RoundToCommande(arguments : TStringList) ;

implementation

uses Code, SysUtils ;


procedure ExtractIntPartCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then
            ResultFunction := ExtractIntPart(arguments[0])
        else
            WarningMsg(sNotAFloatValue) ;
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

procedure ExtractFloatPartCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then
            ResultFunction := '0.' + ExtractFloatPart(arguments[0])
        else
            WarningMsg(sNotAFloatValue) ;
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

procedure DecToHexCommande(arguments : TStringList) ;
var valeur : Integer ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            valeur := MyStrToInt(ExtractIntPart(arguments[0])) ;
            ResultFunction := DecToHex(valeur) ;
        end
        else
            WarningMsg(sNotAFloatValue) ;
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

procedure DecToOctCommande(arguments : TStringList) ;
var valeur : Integer ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            valeur := MyStrToInt(ExtractIntPart(arguments[0])) ;
            ResultFunction := DecToOct(valeur) ;
        end
        else
            WarningMsg(sNotAFloatValue) ;
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

procedure DecToBinCommande(arguments : TStringList) ;
var valeur : Integer ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            valeur := MyStrToInt(ExtractIntPart(arguments[0])) ;
            ResultFunction := DecToBin(valeur) ;
        end
        else
            WarningMsg(sNotAFloatValue) ;
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

procedure PiCommande(arguments : TStringList) ;
begin
    if arguments.count = 0
    then begin
        ResultFunction := MyFloatToStr(Pi) ;
    end
    else if arguments.count < 0
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 0
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure uniqIdCommande(arguments : TStringList) ;
begin
    if arguments.count = 0
    then begin
        ResultFunction := UniqId ;
    end
    else if arguments.count < 0
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 0
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure MaxCommande(arguments : TStringList) ;
var i : Integer ;
    MaxValue : Integer ;
    CurrentValue : Integer ;
begin
    if arguments.count > 0
    then begin
        if isFloat(arguments[0])
        then begin
            MaxValue := MyStrToInt(arguments[0]) ;
            ResultFunction := arguments[0] ;

            for i := 1 to arguments.Count - 1 do
            begin
                if isFloat(arguments[i])
                then begin
                    CurrentValue := MyStrToInt(arguments[i]) ;

                    if CurrentValue > MaxValue
                    then begin
                        MaxValue := CurrentValue ;
                        ResultFunction := arguments[i] ;
                    end ;
                end
                else begin
                    ErrorMsg(sMustBeNumber + ' ' + arguments[i]) ;
                    break ;
                end ;
            end ;
        end
        else begin
            ErrorMsg(sMustBeNumber) ;
        end ;
    end
    else if arguments.count < 0
    then begin
        ErrorMsg(sMissingargument) ;
    end ;
end ;

procedure MinCommande(arguments : TStringList) ;
var i : Integer ;
    MinValue : Integer ;
    CurrentValue : Integer ;
begin
    if arguments.count > 0
    then begin
        if isFloat(arguments[0])
        then begin
            MinValue := MyStrToInt(arguments[0]) ;
            ResultFunction := arguments[0] ;

            for i := 1 to arguments.Count - 1 do
            begin
                if isFloat(arguments[i])
                then begin
                    CurrentValue := MyStrToInt(arguments[i]) ;

                    if CurrentValue < MinValue
                    then begin
                        MinValue := CurrentValue ;
                        ResultFunction := arguments[i] ;
                    end ;
                end
                else begin
                    ErrorMsg(sMustBeNumber + ' ' + arguments[i]) ;
                    break ;
                end ;
            end ;
        end
        else begin
            ErrorMsg(sMustBeNumber) ;
        end ;
    end
    else if arguments.count < 0
    then begin
        ErrorMsg(sMissingargument) ;
    end ;
end ;

procedure BinToDecCommande(arguments : TStringList) ;
var i : Integer ;
    val : Integer ;
    index : Integer ;
begin
    if arguments.count = 1
    then begin
        val := 0 ;
        index := 0 ;
        for i := Length(arguments[0]) downto 1 do
        begin
            if (arguments[0][i] = '1') or (arguments[0][i] = '0')
            then begin
                val := val + StrToInt(arguments[0][i]) * Trunc(caree(2, index)) ;
                Inc(index) ;
            end
            else begin
                ErrorMsg(sMustBeOneOrZero) ;
                break ;
            end ;
        end ;

        ResultFunction := IntToStr(val) ;
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

procedure ExpCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(exp(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure LnCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(Ln(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure oddCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isInteger(arguments[0])
        then begin
            if Odd(MyStrToInt(arguments[0]))
            then
                ResultFunction := trueValue
            else
                ResultFunction := FalseValue ;
        end
        else begin
            ErrorMsg(sMustBeInteger) ;
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

procedure cosCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(cos(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure acosCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(ArcCos(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure acoshCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(ArcCosh(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure sinCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(sin(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure asinCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(Arcsin(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure asinhCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(Arcsinh(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure tanCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(tan(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure atanCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(Arctan(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure atanhCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(Arctanh(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure atan2Commande(arguments : TStringList) ;
begin
    if arguments.count = 2
    then begin
        if isFloat(arguments[0]) and isFloat(arguments[1])
        then begin
            ResultFunction := MyFloatToStr(Arctan2(MyStrToFloat(arguments[0]), MyStrToFloat(arguments[1]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 2
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 2
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure absCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(abs(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure fracCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(frac(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure cotCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(cot(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure acotCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(Tan(1 / MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure intCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(int(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure roundCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(round(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure sqrtCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(sqrt(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure sqrCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(sqr(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure truncCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(trunc(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure randCommande(arguments : TStringList) ;
var aMax, aMin : Integer ;
begin
    if (arguments.count = 1) or (arguments.count = 2)
    then begin
        if isInteger(arguments[0])
        then begin
            Randomize ;

            if (arguments.count = 1)
            then begin
                ResultFunction := MyFloatToStr(Random(MyStrToInt(arguments[0]))) ;
            end
            else begin
                if isInteger(arguments[1])
                then begin
                    aMin := MyStrToInt(arguments[0]) ;
                    aMax := MyStrToInt(arguments[1]) ;
                    ResultFunction := MyFloatToStr(Random(aMax-aMin) + aMin) ;
                end
                else
                    ErrorMsg(sMustBeInteger) ;
            end ;
        end
        else
            ErrorMsg(sMustBeInteger) ;
    end
    else if arguments.count < 1
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 2
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure ceilCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(ceil(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure EnsureRangeCommande(arguments : TStringList) ;
begin
    if arguments.count = 3
    then begin
        if isFloat(arguments[0]) and isFloat(arguments[1]) and isFloat(arguments[2])
        then begin
            ResultFunction := MyFloatToStr(EnsureRange(MyStrToFloat(arguments[0]), MyStrToFloat(arguments[1]), MyStrToFloat(arguments[2]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure floorCommande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(floor(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure FrexpCommande(arguments : TStringList) ;
var Mantissa : Extended ;
    Exponent : Integer ;
begin
    if arguments.count = 3
    then begin
        if isFloat(arguments[0])
        then begin
            if isVar(arguments[1])
            then begin
                if isVar(arguments[2])
                then begin
                    { Supprime les warning pour Lazarus }
                    Mantissa := 0 ;
                    Exponent := 0 ;
                    Frexp(MyStrToFloat(arguments[0]), Mantissa, Exponent) ;

                    SetVar(arguments[1], MyFloatToStr(Mantissa)) ;
                    SetVar(arguments[2], IntToStr(Exponent)) ;                    
                end
                else begin
                    ErrorMsg(Format(sNotAVariable, [arguments[1]])) ;
                end ;
            end
            else begin
                ErrorMsg(Format(sNotAVariable, [arguments[0]])) ;
            end ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure InRangeCommande(arguments : TStringList) ;
begin
    if arguments.count = 3
    then begin
        if isFloat(arguments[0]) and isFloat(arguments[1]) and isFloat(arguments[2])
        then begin
            if InRange(MyStrToFloat(arguments[0]), MyStrToFloat(arguments[1]), MyStrToFloat(arguments[2]))
            then
                ResultFunction := trueValue
            else
                ResultFunction := falseValue ; 
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure LdExpCommande(arguments : TStringList) ;
begin
    if arguments.count = 3
    then begin
        if isFloat(arguments[0])
        then begin
            if isFloat(arguments[1])
            then
                ResultFunction := MyFloatToStr(LdExp(MyStrToFloat(arguments[0]), MyStrToInt(arguments[1])))
            else
                ErrorMsg(sMustBeInteger) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure LnXP1Commande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(LnXP1(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure Log10Commande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(Log10(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure Log2Commande(arguments : TStringList) ;
begin
    if arguments.count = 1
    then begin
        if isFloat(arguments[0])
        then begin
            ResultFunction := MyFloatToStr(Log2(MyStrToFloat(arguments[0]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
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

procedure LogNCommande(arguments : TStringList) ;
begin
    if arguments.count = 2
    then begin
        if isFloat(arguments[0]) and isFloat(arguments[1])
        then begin
            ResultFunction := MyFloatToStr(LogN(MyStrToFloat(arguments[0]), MyStrToFloat(arguments[1]))) ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 2
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 2
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure PolyCommande(arguments : TStringList) ;
var  Resultat : Extended ;
     i : Integer ;
     Liste : TStringList ;
     X : Extended ;
begin
    if arguments.count = 2
    then begin
        if isFloat(arguments[0]) and Variables.InternalisArray(arguments[1])
        then begin
            Liste := TStringList.Create ;

            Variables.explode(Liste, arguments[1]) ;

            if not GlobalError
            then begin
                X := MyStrToFloat(arguments[0]) ;

                Resultat := 0 ;

                for i := 0 to Liste.Count - 1 do
                begin
                    Resultat := Resultat + MyStrToFloat(Liste[i]) * Power(X, i) ;

                    if GlobalError
                    then
                        break ;
                end ;

                ResultFunction := MyFloatToStr(Resultat) ;

            end ;

            Liste.Free ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 2
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 2
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure SameValueCommande(arguments : TStringList) ;
begin
    if arguments.count = 3
    then begin
        if isFloat(arguments[0]) and isFloat(arguments[1]) and isFloat(arguments[2])
        then begin
            if SameValue(MyStrToFloat(arguments[0]), MyStrToFloat(arguments[1]), MyStrToFloat(arguments[2]))
            then
                ResultFunction := trueValue
            else
                ResultFunction := falseValue ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure RoundToCommande(arguments : TStringList) ;
var F : Extended ;
begin
    if arguments.count = 2
    then begin
        if isFloat(arguments[0])
        then begin
            if isInteger(arguments[1])
            then begin
                F := IntPower(10, MyStrToInt(arguments[1])) ;
                ResultFunction := MyFloatToStr(Round(MyStrToFloat(arguments[0]) /F) * F) ;
            end
            else begin
                ErrorMsg(sMustBeInteger) ;
            end ;
        end
        else begin
            ErrorMsg(sNotAFloatValue) ;
        end ;
    end
    else if arguments.count < 3
    then begin
        ErrorMsg(sMissingargument) ;
    end
    else if arguments.count > 3
    then begin
        ErrorMsg(sTooArguments) ;
    end ;
end ;

procedure MathFunctionsInit ;
begin
    ListFunction.Add('extractintpart', @ExtractIntPartCommande, true) ;
    ListFunction.Add('extractfloatpart', @ExtractFloatPartCommande, true) ;
    ListFunction.Add('dectohex', @DecToHexCommande, true) ;
    ListFunction.Add('dectooct', @DecToOctCommande, true) ;
    ListFunction.Add('dectobin', @DecToBinCommande, true) ;
    ListFunction.Add('pi', @PiCommande, true) ;
    ListFunction.Add('uniqid', @uniqIdCommande, true) ;
    ListFunction.Add('max', @MaxCommande, true) ;
    ListFunction.Add('min', @MinCommande, true) ;
    ListFunction.Add('bintodec', @BinToDecCommande, true) ;
    ListFunction.Add('exp', @ExpCommande, true) ;
    ListFunction.Add('ln', @LnCommande, true) ;
    ListFunction.Add('odd', @oddCommande, true) ;
    ListFunction.Add('cos', @cosCommande, true) ;
    ListFunction.Add('acos', @acosCommande, true) ;
    ListFunction.Add('acosh', @acoshCommande, true) ;
    ListFunction.Add('sin', @sinCommande, true) ;
    ListFunction.Add('asin', @asinCommande, true) ;
    ListFunction.Add('asinh', @asinhCommande, true) ;
    ListFunction.Add('tan', @tanCommande, true) ;
    ListFunction.Add('atan', @atanCommande, true) ;
    ListFunction.Add('atanh', @atanhCommande, true) ;
    ListFunction.Add('atan2', @atan2Commande, true) ;
    ListFunction.Add('abs', @absCommande, true) ;
    ListFunction.Add('frac', @absCommande, true) ;
    ListFunction.Add('cot', @cotCommande, true) ;
    ListFunction.Add('acot', @acotCommande, true) ;
    ListFunction.Add('int', @intCommande, true) ;
    ListFunction.Add('round', @roundCommande, true) ;
    ListFunction.Add('sqrt', @sqrtCommande, true) ;
    ListFunction.Add('sqr', @sqrCommande, true) ;
    ListFunction.Add('trunc', @truncCommande, true) ;
    ListFunction.Add('rand', @randCommande, true) ;
    ListFunction.Add('ceil', @ceilCommande, true) ;
    ListFunction.Add('ensurerange', @EnsureRangeCommande, true) ;
    ListFunction.Add('floor', @FloorCommande, true) ;
    ListFunction.Add('frexp', @FrexpCommande, false) ;
    ListFunction.Add('inrange', @InRangeCommande, true) ;
    ListFunction.Add('ldexp', @LdExpCommande, true) ;
    ListFunction.Add('lnxp1', @LnXP1Commande, true) ;
    ListFunction.Add('log10', @Log10Commande, true) ;
    ListFunction.Add('log2', @Log2Commande, true) ;
    ListFunction.Add('logn', @LogNCommande, true) ;
    ListFunction.Add('poly', @PolyCommande, true) ;
    ListFunction.Add('samevalue', @SameValueCommande, true) ;
    ListFunction.Add('roundto', @RoundToCommande, true) ;                
end ;

end.
