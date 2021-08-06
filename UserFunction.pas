unit UserFunction;
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
 * Class to register line of user function
 ******************************************************************************}

interface

{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses Classes, SysUtils ;

type
  TUserFunction = class
  private
      poFunctionName : TStringList ;
      poArguments : TStringList ;
      paLine: array of Integer ;
      paLineToEnd : array of Integer ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(asNameOfFunction : string; aiStartPos : integer; aiEndPos : Integer; aoArgumentsList : String) ;
      function Give(asNameOfFunction : string) : integer;
      function GiveEnd(asNameOfFunction : string) : integer ;
      function GiveFunctionNameByIndex(aiIndex : Integer) : string ;
      procedure Delete(asNameOfFunction : String) ;
      function Count : integer ;
      procedure Clear ;
      function IsSet(asNameOfFunction : string) : boolean ;
      function Rename(asOldName, asNewName : String) : boolean ;
      function GiveArguments(asNameOfFunction : string) : string ;
  end ;

Var goListProcedure : TUserFunction ;
    
implementation

{*****************************************************************************
 * Create
 * MARTINEAU Emeric
 *
 * Consructeur
 *****************************************************************************}
constructor TUserFunction.Create ;
begin
    inherited Create();

    poFunctionName := TStringList.Create ;
    poFunctionName.CaseSensitive := True ;
    poArguments := TStringList.Create ;
end ;

{*****************************************************************************
 * Free
 * MARTINEAU Emeric
 *
 * Destructeur
 *****************************************************************************}
destructor TUserFunction.Free ;
begin
    FreeAndNil(poFunctionName) ;
    FreeAndNil(poArguments) ;
    SetLength(paLine, 0) ;
end ;

{*****************************************************************************
 * Add
 * MARTINEAU Emeric
 *
 * Ajoute une fonction
 *
 * Paramètres d'entrée :
 *   - asNameOfFunction : nom de la fonction,
 *   - aiStartPos : début de la fonction (après la ligne function),
 *   - aiEndPost : fin de la fonction,
 *   - aoArgumentsList : argument de la fonction,
 *
 *****************************************************************************}
procedure TUserFunction.Add(asNameOfFunction : string; aiStartPos : integer; aiEndPos : Integer; aoArgumentsList : String) ;
var nb : Integer ;
begin
    poFunctionName.Add(asNameOfFunction) ;
    poArguments.Add(aoArgumentsList) ;
    
    nb := poFunctionName.Count ;

    SetLength(paLine, nb) ;
    SetLength(paLineToEnd, nb) ;
    paLine[nb - 1] := aiStartPos ;
    paLineToEnd[nb - 1] := aiEndPos ;
end ;

{*****************************************************************************
 * Delete
 * MARTINEAU Emeric
 *
 * Supprimer l'entrée correspondant dans le tableau.
 *
 * Paramètres d'entrée :
 *   - asNameOfFunction : nom de la fonction,
 *
 *****************************************************************************}
procedure TUserFunction.Delete(asNameOfFunction : String) ;
Var
    { Position de la fonction }
    liIndexFunction : Integer ;
    { Compteur de fonction }
    liIndex : Integer ;
begin
    liIndexFunction := poFunctionName.IndexOf(asNameOfFunction) ;

    if (liIndexFunction <> -1)
    then begin
        poFunctionName.Delete(liIndexFunction) ;

        for liIndex := liIndexFunction to poFunctionName.Count - 1 do
        begin
            paLine[liIndex] := paLine[liIndex + 1] ;
            paLineToEnd[liIndex] := paLineToEnd[liIndex + 1] ;
        end ;

        SetLength(paLine, poFunctionName.Count) ;
        SetLength(paLineToEnd, poFunctionName.Count) ;
    end ;
end;

{*****************************************************************************
 * Count
 * MARTINEAU Emeric
 *
 * Donne le nombre de fichiers récents
 *****************************************************************************}
function TUserFunction.Count : Integer ;
begin
    Result := poFunctionName.Count ;
end ;

{*****************************************************************************
 * Give
 * MARTINEAU Emeric
 *
 * Donne le numéro de ligne de début de la fonction.
 *
 * Paramètres d'entrée :
 *   - asNameOfFunction : nom de la fonction,
 *
 *****************************************************************************}
function TUserFunction.Give(asNameOfFunction : string) : integer ;
Var Index : Integer ;
begin
    Index := poFunctionName.IndexOf(asNameOfFunction) ;

    if Index <> -1
    then begin
        Result := paLine[Index] ;
    end
    else begin
        Result := -1 ;
    end ;
end ;

{*****************************************************************************
 * GiveEnd
 * MARTINEAU Emeric
 *
 * Donne le numéro de ligne de fin de la fonction.
 *
 * Paramètres d'entrée :
 *   - asNameOfFunction : nom de la fonction,
 *
 *****************************************************************************}
function TUserFunction.GiveEnd(asNameOfFunction : string) : integer ;
Var Index : Integer ;
begin
    Index := poFunctionName.IndexOf(asNameOfFunction) ;

    if Index <> -1
    then begin
        Result := paLineToEnd[Index] ;
    end
    else begin
        Result := -1 ;
    end ;
end ;

{*****************************************************************************
 * IsSend
 * MARTINEAU Emeric
 *
 * Indique si la fonction existe
 *
 * Paramètres d'entrée :
 *   - asNameOfFunction : nom de la fonction,
 *
 * Retour : true si la fonction existe
 *****************************************************************************}
function TUserFunction.IsSet(asNameOfFunction : string) : boolean ;
Var Index : Integer ;
begin
    Index := poFunctionName.IndexOf(asNameOfFunction) ;

    if Index <> -1
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
 * Vide la liste de fonction
 *****************************************************************************}
procedure TUserFunction.Clear ;
begin
    poFunctionName.Clear ;
    SetLength(paLine, 0) ;
    SetLength(paLineToEnd, 0);
end ;

{*****************************************************************************
 * GiveFunctionNameByIndex
 * MARTINEAU Emeric
 *
 * Retourne le nom de la variable par l'index
 *
 * Paramètres d'entrée :
 *   - aiIndex : index dans la liste de fonction,
 *
 * Retour : nom de la fonction
 *****************************************************************************}
function TUserFunction.GiveFunctionNameByIndex(aiIndex : Integer) : string ;
begin
    Result := '' ;

    if aiIndex <> -1
    then begin
        if aiIndex < poFunctionName.Count
        then begin
            Result := poFunctionName[aiIndex] ;
        end
    end
end ;

{*****************************************************************************
 * Rename
 * MARTINEAU Emeric
 *
 * Renomme la fonction OldName par NewName
 *
 * Paramètres d'entrée :
 *   - asOldName : nom de la fonction a renommer,
 *   - asNewName : nouveau nom.
 *
 *****************************************************************************}
function TUserFunction.Rename(asOldName, asNewName : String) : boolean ;
var Index : Integer ;
begin
    Index := poFunctionName.IndexOf(LowerCase(asOldName)) ;

    if Index <> -1
    then begin
        poFunctionName[Index] := asNewName ;
        Result := True ;
    end
    else begin
        Result := False ;
    end ;
end ;

{*****************************************************************************
 * GiveArguments
 * MARTINEAU Emeric
 *
 * Donne les arguments correspondant à l'index.
 *
 * Paramètres d'entrée :
 *   - asNameOfFunction : nom de la fonction
 *
 *****************************************************************************}
function TUserFunction.GiveArguments(asNameOfFunction : string) : string ;
Var Index : Integer ;
begin
    Index := poFunctionName.IndexOf(asNameOfFunction) ;

    if Index <> -1
    then begin
        Result := poArguments[Index] ;
    end
    else begin
        Result := '' ;
    end ;
end ;

end.
