unit UserLabel;
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
 * Class to register line of user label
 ******************************************************************************}

interface

{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses Classes, SysUtils ;

type
  TUserLabel = class
  private
      poLabelName : TStringList ;
      piLine: array of Integer ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(asNameOfLabel : string; aiLineNumber : integer) ;
      function Give(asNameOfLabel : string) : integer;
      function GiveLabelNameByIndex(aiIndex : Integer) : string ;
      procedure Delete(asNameOfLabel : String) ;
      function Count : integer ;
      procedure Clear ;
      function IsSet(asNameOfLabel : string) : boolean ;
      function Rename(asOldName, asNewName : String) : boolean ;
  end ;

Var goListLabel : TUserLabel ;
    
implementation

{*****************************************************************************
 * Create
 * MARTINEAU Emeric
 *
 * Consructeur
 *****************************************************************************}
constructor TUserLabel.Create ;
begin
    inherited Create();

    poLabelName := TStringList.Create ;
end ;

{*****************************************************************************
 * Free
 * MARTINEAU Emeric
 *
 * Destructeur
 *****************************************************************************}
destructor TUserLabel.Free ;
begin
    poLabelName.Free ;
    SetLength(piLine, 0) ;
end ;

{*****************************************************************************
 * Add
 * MARTINEAU Emeric
 *
 * Ajoute un label
 *
 * Paramètres d'entrée :
 *   - asNameOfLabel : nom du label,
 *   - aiLineNumber : position du label,
 *
 *****************************************************************************}
procedure TUserLabel.Add(asNameOfLabel : string; aiLineNumber : integer) ;
var nb : Integer ;
begin
    poLabelName.Add(LowerCase(asNameOfLabel)) ;

    nb := poLabelName.Count ;

    SetLength(piLine, nb) ;
    piLine[nb - 1] := aiLineNumber ;
end ;

{*****************************************************************************
 * Delete
 * MARTINEAU Emeric
 *
 * Supprimer l'entrée correspondant dans le tableau.
 *
 * Paramètres d'entrée :
 *   - asNameOfLabel : nom du label,
 *
 *****************************************************************************}
procedure TUserLabel.Delete(asNameOfLabel : String) ;
Var Index : Integer ;
    i : Integer ;
begin
    Index := poLabelName.IndexOf(LowerCase(asNameOfLabel)) ;

    if (Index <> -1)
    then begin
        poLabelName.Delete(Index) ;

        for i := Index to poLabelName.Count - 1 do
        begin
            piLine[i] := piLine[i + 1] ;
        end ;

        SetLength(piLine, poLabelName.Count) ;
    end ;
end;

{*****************************************************************************
 * Count
 * MARTINEAU Emeric
 *
 * Donne le nombre de fichiers récents
 *
 * Paramètres d'entrée :
 *   - asNameOfLabel : nom du label,
 *
 *****************************************************************************}
function TUserLabel.Count : Integer ;
begin
    Result := poLabelName.Count ;
end ;

{*****************************************************************************
 * Give
 * MARTINEAU Emeric
 *
 * Donne la fichier correspondant à l'index.
 *
 * Paramètres d'entrée :
 *   - asNameOfLabel : nom du label,
 *
 *****************************************************************************}
function TUserLabel.Give(asNameOfLabel : string) : integer ;
Var Index : Integer ;
begin
    Index := poLabelName.IndexOf(LowerCase(asNameOfLabel)) ;

    if Index <> -1
    then begin
        Result := piLine[Index] ;
    end
    else begin
        Result := -1 ;
    end ;
end ;

{*****************************************************************************
 * IsSet
 * MARTINEAU Emeric
 *
 * Indique si le label existe
 *
 * Paramètres d'entrée :
 *   - asNameOfLabel : nom du label,
 *
 * Retour : true si le label existe
 *****************************************************************************}
function TUserLabel.IsSet(asNameOfLabel : string) : boolean ;
Var Index : Integer ;
begin
    Index := poLabelName.IndexOf(LowerCase(asNameOfLabel)) ;

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
 * Vide la liste
 *
 *****************************************************************************}
procedure TUserLabel.Clear ;
begin
    poLabelName.Clear ;
    SetLength(piLine, 0) ;
end ;

{*****************************************************************************
 * GiveLabelNameByIndex
 * MARTINEAU Emeric
 *
 * Retourne le nom du label suivant l'index
 *
 * Paramètres d'entrée :
 *   - aiIndex : index du label,
 *
 * Retour : nom de la fonction
 *****************************************************************************}
function TUserLabel.GiveLabelNameByIndex(aiIndex : Integer) : string ;
begin
    Result := '' ;

    if aiIndex <> -1
    then begin
        if aiIndex < poLabelName.Count
        then begin
            Result := poLabelName[aiIndex] ;
        end
    end
end ;

{*****************************************************************************
 * Rename
 * MARTINEAU Emeric
 *
 * Renomme le label OldName par NewName
 *
 * Paramètres d'entrée :
 *   - asOldName : nom de la fonction a renommer,
 *   - asNewName : nouveau nom.
 *
 *****************************************************************************}
function TUserLabel.Rename(asOldName, asNewName : String) : boolean ;
var
    liIndex : Integer ;
begin
    liIndex := poLabelName.IndexOf(LowerCase(asOldName)) ;

    if liIndex <> -1
    then begin
        poLabelName[liIndex] := LowerCase(asNewName) ;
        Result := True ;
    end
    else begin
        Result := False ;
    end ;
end ;

end.
