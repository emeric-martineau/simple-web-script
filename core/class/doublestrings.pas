unit DoubleStrings;
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
 ******************************************************************************
 *
 * Variables names :
 *  xyZZZZZ :
 *            x : l : local variable
 *                g : global variable/public variable
 *                p : private/protected variable
 *                a : argument variable
 *
 *            y : s : string
 *                i : integer
 *                f : fload
 *                d : double
 *                a : array
 *                l : list<>
 *                o : object
 *                b : bool
 *                c : char
 *                l : long
 *
 *           ZZZZ : name of variable
 *******************************************************************************
 * Class to manage String with other string. It's just 2 TStringList management.
 ******************************************************************************}
{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

interface

uses SysUtils, Classes ;

type
  TDoubleStrings = class
  private
      { Nom de la variable }
      poVarName : TStringList ;
      { Valeur de la variable }
      poVarValue: TStringList ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(asNameOfVar : string; asValueOfVar : string) ;
      function Give(asNameOfVar : string) : string;
      function GiveVarNameByIndex(aiIndex : Integer) : string ;
      procedure Delete(asNameOfVar : String) ;
      function Count : integer ;
      procedure Clear ;
      function isSet(asNameOfVar : string) : boolean ;
  end ;

implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TDoubleStrings.Create ;
begin
    inherited Create();

    { Créer l'objet FileName }
    poVarName := TStringList.Create ;
    poVarValue := TStringList.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TDoubleStrings.Free ;
begin
    FreeAndNil(poVarName) ;
    FreeAndNil(poVarValue) ;
end ;

{******************************************************************************
 * Add
 *
 * Ajouter une variable
 *
 * Paramètre d'entrée :
 *   - asNameOfVar : nom de la variable à ajouter,
 *   - asValueOfVar : valeur associée
 *
 ******************************************************************************}
procedure TDoubleStrings.Add(asNameOfVar : string; asValueOfVar : string) ;
var
    { Index du nom de la variable }
    liIndex : Integer ;
begin
    asNameOfVar := asNameOfVar ;

    liIndex := poVarName.IndexOf(asNameOfVar) ;

    if liIndex = -1
    then begin
        poVarName.Add(asNameOfVar) ;
        poVarValue.Add(asValueOfVar) ;
    end
    else begin
        poVarValue[liIndex] := asValueOfVar ;
    end ;
end ;

{******************************************************************************
 * Add
 *
 * Supprimer l'entrée correspondant dans le tableau.
 *
 * Paramètre d'entrée :
 *   - asNameOfVar : nom de la variable à ajouter,
 *
 ******************************************************************************}
procedure TDoubleStrings.Delete(asNameOfVar : String) ;
Var
    { Index du nom de la variable }
    liIndex : Integer ;
begin
    liIndex := poVarName.IndexOf(asNameOfVar) ;

    if (liIndex <> -1)
    then begin
        poVarName.Delete(liIndex) ;
        poVarValue.Delete(liIndex) ;
    end ;
end;

{******************************************************************************
 * Count
 *
 * Donne le nombre de variable
 ******************************************************************************}
function TDoubleStrings.Count : Integer ;
begin
    Result := poVarName.Count ;
end ;

{******************************************************************************
 * Give
 *
 * Donne la fichier correspondant à l'index.
 *
 * Paramètre d'entrée :
 *   - asNameOfVar : nom de la variable retourner. Vide si pas de variable
 *     trouvée
 *
 ******************************************************************************}
function TDoubleStrings.Give(asNameOfVar : string) : string ;
Var
    { Index du nom de la variable }
    liIndex : Integer ;
begin
    liIndex := poVarName.IndexOf(asNameOfVar) ;

    if liIndex <> -1
    then begin
        Result := poVarValue[liIndex]
    end
    else begin
        Result := ''
    end ;
end ;

{******************************************************************************
 * Add
 *
 * Indique si la variable existe
 *
 * Paramètre d'entrée :
 *   - asNameOfVar : nom de la variable à contrôler,
 *
 * Retour : true si la variable existe
 *
 ******************************************************************************}
function TDoubleStrings.IsSet(asNameOfVar : string) : boolean ;
Var
    { Index du nom de la variable }
    liIndex : Integer ;
begin
    liIndex := poVarName.IndexOf(asNameOfVar) ;

    if liIndex <> -1
    then begin
        Result := True
    end
    else begin
        Result := False ;
    end ;
end ;

{******************************************************************************
 * Clear
 *
 * Efface la liste
 *
 ******************************************************************************}
procedure TDoubleStrings.Clear ;
begin
    poVarValue.Clear ;
    poVarName.Clear ;
end ;

{******************************************************************************
 * Add
 *
 * Retourne le nom de la variable par l'index
 *
 * Paramètre d'entrée :
 *   - aiIndex : nom de la variable à contrôler,
 *
 * Retour : le nom de la variable
 *
 ******************************************************************************}
function TDoubleStrings.GiveVarNameByIndex(aiIndex : Integer) : string ;
begin
    Result := '' ;

    if aiIndex >= 0
    then begin
        if aiIndex < poVarName.Count
        then begin
            Result := poVarName[aiIndex] ;
        end
    end
end ;

end.
