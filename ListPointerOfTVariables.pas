unit ListPointerOfTVariables;
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
 * Class to make link between pointer of tvariable and pointer in script
 ******************************************************************************}

interface

{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses Classes, SysUtils, Variable ;

type
  TPointerOfTVariable = class
  private
      poPointerName : TStringList ;
      poVarName : TStringList ;
      paPointerOfTVariable : array of TVariables ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(asNameOfPointer : string; asNameOfVar : String ; aoPointer : TVariables) ;
      function Give(asNameOfPointer : string) : TVariables;
      function GivePointerByIndex(aiIndex : Integer) : string ;
      function GivePointerByVarName(asNameOfVar : String) : String ;
      procedure Delete(asNameOfPointer : String) ;
      function Count : integer ;
      procedure Clear ;
      function IsSet(asNameOfPointer : string) : boolean ;
      function IsSetByVarName(asNameOfVar : string) : boolean ;
  end ;

Var goPointerOFVariables : TPointerOfTVariable ;
    
implementation

{*****************************************************************************
 * Create
 * MARTINEAU Emeric
 *
 * Consructeur
 *****************************************************************************}
constructor TPointerOfTVariable.Create ;
begin
    inherited Create();

    poPointerName := TStringList.Create ;
    poVarName := TStringList.Create ;
end ;

{*****************************************************************************
 * Free
 * MARTINEAU Emeric
 *
 * Destructeur
 *****************************************************************************}

destructor TPointerOfTVariable.Free ;
begin
    poPointerName.Free ;
    poVarName.Free ;
    SetLength(paPointerOfTVariable, 0) ;
end ;

{*****************************************************************************
 * Add
 * MARTINEAU Emeric
 *
 * Ajoute un pointeur de variable
 *
 * Paramètres d'entrée :
 *   - asNameOfPointer : nom du pointeur,
 *   - aoPointeur ; pointeur de TVariable,
 *
 *****************************************************************************}
procedure TPointerOfTVariable.Add(asNameOfPointer : string; asNameOfVar : String ; aoPointer : TVariables) ;
var
    { Taille du tableau de pointeur }
    liLength : Integer ;
begin
    poPointerName.Add(LowerCase(asNameOfPointer)) ;
    poVarName.Add(asNameOfVar) ;

    liLength := poPointerName.Count ;

    SetLength(paPointerOfTVariable, liLength) ;
    paPointerOfTVariable[liLength - 1] := aoPointer ;
end ;

{*****************************************************************************
 * Delete
 * MARTINEAU Emeric
 *
 * Supprime un pointeur
 *
 * Paramètres d'entrée :
 *   - asNameOfPointer : nom du pointeur,
 *
 *****************************************************************************}
procedure TPointerOfTVariable.Delete(asNameOfPointer : String) ;
Var
    { Index du pointeur }
    liIndex : Integer ;
    { Compteur de boucle }
    liCount : Integer ;
begin
    liIndex := poPointerName.IndexOf(asNameOfPointer) ;

    if (liIndex <> -1)
    then begin
        poPointerName.Delete(liIndex) ;
        poVarName.Delete(liIndex) ;

        for liCount := liIndex to poPointerName.Count - 1 do
        begin
            paPointerOfTVariable[liCount] := paPointerOfTVariable[liCount + 1] ;
        end ;

        SetLength(paPointerOfTVariable, poPointerName.Count) ;
    end ;
end;

{*****************************************************************************
 * Count
 * MARTINEAU Emeric
 *
 * Donne le nombre de pointeur enregistré
 *****************************************************************************}
function TPointerOfTVariable.Count : Integer ;
begin
    Result := poPointerName.Count ;
end ;

{*****************************************************************************
 * Give
 * MARTINEAU Emeric
 *
 * Retourne un pointeur
 *
 * Paramètres d'entrée :
 *   - asNameOfPointer : nom du pointeur,
 *
 *****************************************************************************}
function TPointerOfTVariable.Give(asNameOfPointer : string) : TVariables ;
Var
    { Index du pointeur }
    liIndex : Integer ;
begin
    liIndex := poPointerName.IndexOf(asNameOfPointer) ;

    if liIndex <> -1
    then begin
        Result := paPointerOfTVariable[liIndex] ;
    end
    else begin
        Result := nil ;
    end ;
end ;

{*****************************************************************************
 * IsSet
 * MARTINEAU Emeric
 *
 * Indique si le pointeur existe
 *
 * Paramètres d'entrée :
 *   - asNameOfPointer : nom du pointeur,
 *
 *****************************************************************************}
function TPointerOfTVariable.IsSet(asNameOfPointer : string) : boolean ;
Var
    { Index du pointeur }
    liIndex : Integer ;
begin
    liIndex := poPointerName.IndexOf(asNameOfPointer) ;

    if liIndex <> -1
    then begin
        Result := True ;
    end 
    else begin
        Result := False ;
    end ;
end ;

{*****************************************************************************
 * Clear
 * MARTINEAU Emeric
 *
 * Efface la liste de pointeur
 *****************************************************************************}
procedure TPointerOfTVariable.Clear ;
begin
    poPointerName.Clear ;
    SetLength(paPointerOfTVariable, 0) ;
end ;

{*****************************************************************************
 * IsSet
 * MARTINEAU Emeric
 *
 * Indique si le pointeur existe
 *
 * Paramètres d'entrée :
 *   - asNameOfPointer : nom du pointeur,
 *
 *****************************************************************************}
function TPointerOfTVariable.GivePointerByIndex(aiIndex : Integer) : string ;
begin
    Result := '' ;

    if aiIndex <> -1
    then begin
        if aiIndex < poPointerName.Count
        then begin
            Result := poPointerName[aiIndex] ;
        end
    end
end ;

{*****************************************************************************
 * GivePointerByVarName
 * MARTINEAU Emeric
 *
 * retourne le pointeur en fonction du nom de la variable
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable
 *
 *****************************************************************************}
function TPointerOfTVariable.GivePointerByVarName(asNameOfVar : String) : String ;
Var
    { Index du pointeur }
    liIndex : Integer ;
begin
    liIndex := poVarName.IndexOf(asNameOfVar) ;

    if liIndex <> -1
    then begin
        Result := poPointerName[liIndex] ;
    end
    else begin
        Result := '' ;
    end ;
end ;

{*****************************************************************************
 * IsSetByVarName
 * MARTINEAU Emeric
 *
 * Indique si le pointeur existe
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable
 *
 *****************************************************************************}
function TPointerOfTVariable.IsSetByVarName(asNameOfVar : string) : boolean ;
Var
    { Index du pointeur }
    liIndex : Integer ;
begin
    liIndex := poVarName.IndexOf(asNameOfVar) ;

    if liIndex <> -1
    then begin
        Result := True ;
    end
    else begin
        Result := False ;
    end ;
end ;

end.
