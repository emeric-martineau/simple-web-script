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

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses Functions, UnitMessages, InternalFunction, classes, Math, Variable ;

procedure MathFunctionsInit ;
procedure ExtractIntPartCommande(aoArguments : TStringList) ;
procedure ExtractFloatPartCommande(aoArguments : TStringList) ;
procedure DecToHexCommande(aoArguments : TStringList) ;
procedure DecToOctCommande(aoArguments : TStringList) ;
procedure DecToBinCommande(aoArguments : TStringList) ;
procedure PiCommande(aoArguments : TStringList) ;
procedure uniqIdCommande(aoArguments : TStringList) ;
procedure MaxCommande(aoArguments : TStringList) ;
procedure MinCommande(aoArguments : TStringList) ;
procedure BinToDecCommande(aoArguments : TStringList) ;
procedure ExpCommande(aoArguments : TStringList) ;
procedure LnCommande(aoArguments : TStringList) ;
procedure oddCommande(aoArguments : TStringList) ;
procedure cosCommande(aoArguments : TStringList) ;
procedure acosCommande(aoArguments : TStringList) ;
procedure acoshCommande(aoArguments : TStringList) ;
procedure sinCommande(aoArguments : TStringList) ;
procedure asinCommande(aoArguments : TStringList) ;
procedure asinhCommande(aoArguments : TStringList) ;
procedure tanCommande(aoArguments : TStringList) ;
procedure atanCommande(aoArguments : TStringList) ;
procedure atanhCommande(aoArguments : TStringList) ;
procedure atan2Commande(aoArguments : TStringList) ;
procedure absCommande(aoArguments : TStringList) ;
procedure fracCommande(aoArguments : TStringList) ;
procedure cotCommande(aoArguments : TStringList) ;
procedure acotCommande(aoArguments : TStringList) ;
procedure intCommande(aoArguments : TStringList) ;
procedure roundCommande(aoArguments : TStringList) ;
procedure sqrtCommande(aoArguments : TStringList) ;
procedure sqrCommande(aoArguments : TStringList) ;
procedure truncCommande(aoArguments : TStringList) ;
procedure randCommande(aoArguments : TStringList) ;
procedure ceilCommande(aoArguments : TStringList) ;
procedure EnsureRangeCommande(aoArguments : TStringList) ;
procedure floorCommande(aoArguments : TStringList) ;
procedure FrexpCommande(aoArguments : TStringList) ;
procedure InRangeCommande(aoArguments : TStringList) ;
procedure LdExpCommande(aoArguments : TStringList) ;
procedure LnXP1Commande(aoArguments : TStringList) ;
procedure Log10Commande(aoArguments : TStringList) ;
procedure Log2Commande(aoArguments : TStringList) ;
procedure LogNCommande(aoArguments : TStringList) ;
procedure PolyCommande(aoArguments : TStringList) ;
procedure SameValueCommande(aoArguments : TStringList) ;
procedure RoundToCommande(aoArguments : TStringList) ;

implementation

uses Code, SysUtils ;


procedure ExtractIntPartCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := ExtractIntPart(aoArguments[0])
    end
        else begin
            WarningMsg(csNotAFloatValue) ;
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

procedure ExtractFloatPartCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := '0.' + ExtractFloatPart(aoArguments[0])
        end
        else begin
            WarningMsg(csNotAFloatValue) ;
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

procedure DecToHexCommande(aoArguments : TStringList) ;
var valeur : Int64 ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            valeur := MyStrToInt64(ExtractIntPart(aoArguments[0])) ;
            gsResultFunction := DecToHex(valeur) ;
        end
        else begin
            WarningMsg(csNotAFloatValue) ;
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

procedure DecToOctCommande(aoArguments : TStringList) ;
var valeur : Int64 ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            valeur := MyStrToInt64(ExtractIntPart(aoArguments[0])) ;
            gsResultFunction := DecToOct(valeur) ;
        end
        else begin
            WarningMsg(csNotAFloatValue) ;
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

procedure DecToBinCommande(aoArguments : TStringList) ;
var valeur : Int64 ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            valeur := MyStrToInt64(ExtractIntPart(aoArguments[0])) ;
            gsResultFunction := DecToBin(valeur) ;
        end
        else begin
            WarningMsg(csNotAFloatValue) ;
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

procedure PiCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 0
    then begin
        gsResultFunction := MyFloatToStr(Pi) ;
    end
    else if aoArguments.count < 0
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 0
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure uniqIdCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 0
    then begin
        gsResultFunction := UniqId ;
    end
    else if aoArguments.count < 0
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 0
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure MaxCommande(aoArguments : TStringList) ;
var i : Integer ;
    MaxValue : Int64 ;
    CurrentValue : Int64 ;
begin
    if aoArguments.count > 0
    then begin
        if isFloat(aoArguments[0])
        then begin
            MaxValue := MyStrToInt64(aoArguments[0]) ;
            gsResultFunction := aoArguments[0] ;

            for i := 1 to aoArguments.Count - 1 do
            begin
                if isFloat(aoArguments[i])
                then begin
                    CurrentValue := MyStrToInt64(aoArguments[i]) ;

                    if CurrentValue > MaxValue
                    then begin
                        MaxValue := CurrentValue ;
                        gsResultFunction := aoArguments[i] ;
                    end ;
                end
                else begin
                    ErrorMsg(csMustBeNumber + ' ' + aoArguments[i]) ;
                    break ;
                end ;
            end ;
        end
        else begin
            ErrorMsg(csMustBeNumber) ;
        end ;
    end
    else if aoArguments.count < 0
    then begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure MinCommande(aoArguments : TStringList) ;
var i : Integer ;
    MinValue : Int64 ;
    CurrentValue : Int64 ;
begin
    if aoArguments.count > 0
    then begin
        if isFloat(aoArguments[0])
        then begin
            MinValue := MyStrToInt64(aoArguments[0]) ;
            gsResultFunction := aoArguments[0] ;

            for i := 1 to aoArguments.Count - 1 do
            begin
                if isFloat(aoArguments[i])
                then begin
                    CurrentValue := MyStrToInt64(aoArguments[i]) ;

                    if CurrentValue < MinValue
                    then begin
                        MinValue := CurrentValue ;
                        gsResultFunction := aoArguments[i] ;
                    end ;
                end
                else begin
                    ErrorMsg(csMustBeNumber + ' ' + aoArguments[i]) ;
                    break ;
                end ;
            end ;
        end
        else begin
            ErrorMsg(csMustBeNumber) ;
        end ;
    end
    else if aoArguments.count < 0
    then begin
        ErrorMsg(csMissingargument) ;
    end ;
end ;

procedure BinToDecCommande(aoArguments : TStringList) ;
var i : Integer ;
    val : Integer ;
    index : Integer ;
begin
    if aoArguments.count = 1
    then begin
        val := 0 ;
        index := 0 ;
        for i := Length(aoArguments[0]) downto 1 do
        begin
            if (aoArguments[0][i] = '1') or (aoArguments[0][i] = '0')
            then begin
                val := val + StrToInt(aoArguments[0][i]) * MyAbsPower(2, index) ;
                Inc(index) ;
            end
            else begin
                ErrorMsg(csMustBeOneOrZero) ;
                break ;
            end ;
        end ;

        gsResultFunction := IntToStr(val) ;
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

procedure ExpCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(exp(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure LnCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(Ln(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure oddCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isInteger(aoArguments[0])
        then begin
            if Odd(MyStrToInt64(aoArguments[0]))
            then begin
                gsResultFunction := csTrueValue ;
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csMustBeInteger) ;
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

procedure cosCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(cos(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure acosCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(ArcCos(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure acoshCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(ArcCosh(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure sinCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(sin(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure asinCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(Arcsin(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure asinhCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(Arcsinh(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure tanCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(tan(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure atanCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(Arctan(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure atanhCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(Arctanh(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure atan2Commande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 2
    then begin
        if isFloat(aoArguments[0]) and isFloat(aoArguments[1])
        then begin
            gsResultFunction := MyFloatToStr(Arctan2(MyStrToFloat(aoArguments[0]), MyStrToFloat(aoArguments[1]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure absCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(abs(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure fracCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(frac(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure cotCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(cot(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure acotCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(Tan(1 / MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure intCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(int(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure roundCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(round(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure sqrtCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(sqrt(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure sqrCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(sqr(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure truncCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(trunc(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure randCommande(aoArguments : TStringList) ;
var aMax : Int64 ;
    aMin : Int64 ;
begin
    if (aoArguments.count = 1) or (aoArguments.count = 2)
    then begin
        if isInteger(aoArguments[0])
        then begin
            Randomize ;

            if (aoArguments.count = 1)
            then begin
                gsResultFunction := MyFloatToStr(Random(MyStrToInt64(aoArguments[0]))) ;
            end
            else begin
                if isInteger(aoArguments[1])
                then begin
                    aMin := MyStrToInt64(aoArguments[0]) ;
                    aMax := MyStrToInt64(aoArguments[1]) ;
                    gsResultFunction := MyFloatToStr(Random(aMax - aMin) + aMin) ;
                end
                else
                    ErrorMsg(csMustBeInteger) ;
            end ;
        end
        else begin
            ErrorMsg(csMustBeInteger) ;
        end ;
    end
    else if aoArguments.count < 1
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure ceilCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(ceil(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure EnsureRangeCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 3
    then begin
        if isFloat(aoArguments[0]) and isFloat(aoArguments[1]) and isFloat(aoArguments[2])
        then begin
            gsResultFunction := MyFloatToStr(EnsureRange(MyStrToFloat(aoArguments[0]), MyStrToFloat(aoArguments[1]), MyStrToFloat(aoArguments[2]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure floorCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(floor(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure FrexpCommande(aoArguments : TStringList) ;
var Mantissa : Extended ;
    Exponent : Integer ;
begin
    if aoArguments.count = 3
    then begin
        if isFloat(aoArguments[0])
        then begin
            if isVar(aoArguments[1])
            then begin
                if isVar(aoArguments[2])
                then begin
                    { Supprime les warning pour Lazarus }
                    Mantissa := 0 ;
                    Exponent := 0 ;
                    Frexp(MyStrToFloat(aoArguments[0]), Mantissa, Exponent) ;

                    SetVar(aoArguments[1], MyFloatToStr(Mantissa)) ;
                    SetVar(aoArguments[2], IntToStr(Exponent)) ;
                end
                else begin
                    ErrorMsg(Format(csNotAVariable, [aoArguments[1]])) ;
                end ;
            end
            else begin
                ErrorMsg(Format(csNotAVariable, [aoArguments[0]])) ;
            end ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure InRangeCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 3
    then begin
        if isFloat(aoArguments[0]) and isFloat(aoArguments[1]) and isFloat(aoArguments[2])
        then begin
            if InRange(MyStrToFloat(aoArguments[0]), MyStrToFloat(aoArguments[1]), MyStrToFloat(aoArguments[2]))
            then begin
                gsResultFunction := csTrueValue ;
            end
            else begin
                gsResultFunction := csFalseValue ;
            end ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure LdExpCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 3
    then begin
        if isFloat(aoArguments[0])
        then begin
            if isFloat(aoArguments[1])
            then
                gsResultFunction := MyFloatToStr(LdExp(MyStrToFloat(aoArguments[0]), MyStrToInt(aoArguments[1])))
            else
                ErrorMsg(csMustBeInteger) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure LnXP1Commande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(LnXP1(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure Log10Commande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(Log10(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure Log2Commande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 1
    then begin
        if isFloat(aoArguments[0])
        then begin
            gsResultFunction := MyFloatToStr(Log2(MyStrToFloat(aoArguments[0]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
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

procedure LogNCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 2
    then begin
        if isFloat(aoArguments[0]) and isFloat(aoArguments[1])
        then begin
            gsResultFunction := MyFloatToStr(LogN(MyStrToFloat(aoArguments[0]), MyStrToFloat(aoArguments[1]))) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure PolyCommande(aoArguments : TStringList) ;
var  Resultat : Extended ;
     i : Integer ;
     Liste : TStringList ;
     X : Extended ;
begin
    if aoArguments.count = 2
    then begin
        if isFloat(aoArguments[0]) and goVariables.InternalisArray(aoArguments[1])
        then begin
            Liste := TStringList.Create ;

            goVariables.explode(Liste, aoArguments[1]) ;

            if not gbQuit
            then begin
                X := MyStrToFloat(aoArguments[0]) ;

                Resultat := 0 ;

                for i := 0 to Liste.Count - 1 do
                begin
                    Resultat := Resultat + MyStrToFloat(Liste[i]) * Power(X, i) ;

                    if gbQuit
                    then begin
                        break ;
                    end ;
                end ;

                gsResultFunction := MyFloatToStr(Resultat) ;

            end ;

            FreeAndNil(Liste) ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 2
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 2
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure SameValueCommande(aoArguments : TStringList) ;
begin
    if aoArguments.count = 3
    then begin
        if isFloat(aoArguments[0]) and isFloat(aoArguments[1]) and isFloat(aoArguments[2])
        then begin
            if SameValue(MyStrToFloat(aoArguments[0]), MyStrToFloat(aoArguments[1]), MyStrToFloat(aoArguments[2]))
            then begin
                gsResultFunction := csTrueValue ;
            end
            else begin
                gsResultFunction := csFalseValue ;
        end ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure RoundToCommande(aoArguments : TStringList) ;
var F : Extended ;
begin
    if aoArguments.count = 2
    then begin
        if isFloat(aoArguments[0])
        then begin
            if isInteger(aoArguments[1])
            then begin
                F := IntPower(10, MyStrToInt(aoArguments[1])) ;
                gsResultFunction := MyFloatToStr(Round(MyStrToFloat(aoArguments[0]) /F) * F) ;
            end
            else begin
                ErrorMsg(csMustBeInteger) ;
            end ;
        end
        else begin
            ErrorMsg(csNotAFloatValue) ;
        end ;
    end
    else if aoArguments.count < 3
    then begin
        ErrorMsg(csMissingargument) ;
    end
    else if aoArguments.count > 3
    then begin
        ErrorMsg(csTooArguments) ;
    end ;
end ;

procedure MathFunctionsInit ;
begin
    goInternalFunction.Add('extractIntPart', @ExtractIntPartCommande, true) ;
    goInternalFunction.Add('extractFloatPart', @ExtractFloatPartCommande, true) ;
    goInternalFunction.Add('decToHex', @DecToHexCommande, true) ;
    goInternalFunction.Add('decToOct', @DecToOctCommande, true) ;
    goInternalFunction.Add('decToBin', @DecToBinCommande, true) ;
    goInternalFunction.Add('pi', @PiCommande, true) ;
    goInternalFunction.Add('uniqID', @uniqIdCommande, true) ;
    goInternalFunction.Add('max', @MaxCommande, true) ;
    goInternalFunction.Add('min', @MinCommande, true) ;
    goInternalFunction.Add('binToDec', @BinToDecCommande, true) ;
    goInternalFunction.Add('exp', @ExpCommande, true) ;
    goInternalFunction.Add('ln', @LnCommande, true) ;
    goInternalFunction.Add('odd', @oddCommande, true) ;
    goInternalFunction.Add('cos', @cosCommande, true) ;
    goInternalFunction.Add('aCos', @acosCommande, true) ;
    goInternalFunction.Add('aCosh', @acoshCommande, true) ;
    goInternalFunction.Add('sin', @sinCommande, true) ;
    goInternalFunction.Add('aSin', @asinCommande, true) ;
    goInternalFunction.Add('aSinh', @asinhCommande, true) ;
    goInternalFunction.Add('tan', @tanCommande, true) ;
    goInternalFunction.Add('aTan', @atanCommande, true) ;
    goInternalFunction.Add('aTanh', @atanhCommande, true) ;
    goInternalFunction.Add('aTan2', @atan2Commande, true) ;
    goInternalFunction.Add('abs', @absCommande, true) ;
    goInternalFunction.Add('frac', @absCommande, true) ;
    goInternalFunction.Add('cot', @cotCommande, true) ;
    goInternalFunction.Add('aCot', @acotCommande, true) ;
    goInternalFunction.Add('int', @intCommande, true) ;
    goInternalFunction.Add('round', @roundCommande, true) ;
    goInternalFunction.Add('sqrt', @sqrtCommande, true) ;
    goInternalFunction.Add('sqr', @sqrCommande, true) ;
    goInternalFunction.Add('trunc', @truncCommande, true) ;
    goInternalFunction.Add('rand', @randCommande, true) ;
    goInternalFunction.Add('ceil', @ceilCommande, true) ;
    goInternalFunction.Add('ensureRange', @EnsureRangeCommande, true) ;
    goInternalFunction.Add('floor', @FloorCommande, true) ;
    goInternalFunction.Add('frexp', @FrexpCommande, false) ;
    goInternalFunction.Add('inRange', @InRangeCommande, true) ;
    goInternalFunction.Add('ldexp', @LdExpCommande, true) ;
    goInternalFunction.Add('lnxp1', @LnXP1Commande, true) ;
    goInternalFunction.Add('log10', @Log10Commande, true) ;
    goInternalFunction.Add('log2', @Log2Commande, true) ;
    goInternalFunction.Add('logn', @LogNCommande, true) ;
    goInternalFunction.Add('poly', @PolyCommande, true) ;
    goInternalFunction.Add('sameValue', @SameValueCommande, true) ;
    goInternalFunction.Add('roundTo', @RoundToCommande, true) ;
end ;

end.
