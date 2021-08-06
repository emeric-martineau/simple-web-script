unit InternalFunction;
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
 * Class to register pointer of function
 ******************************************************************************}

interface

{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses SysUtils, Classes ;

type
  ModelProcedure = procedure (arguments : TStringList) ;

  TInternalFunction = class
  private
      poFunctionName : TStringList ;
      paFunction: array of ModelProcedure ;
      paParseArgument : array of boolean ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(asFunctionName : string; aFunction : ModelProcedure; abParsed : boolean) ;
      procedure Change(asFunctionName : string; aFunction : ModelProcedure; abParsed : boolean) ;
      function Give(asFunctionName : string) : ModelProcedure;
      function GiveFunctionNameByIndex(aiIndex : Integer) : string ;
      procedure Delete(asFunctionName : String) ;
      function Count : integer ;
      procedure Clear ;
      function IsSet(asFunctionName : string) : boolean ;
      function IsParse(asFunctionName : String) : boolean ;
      function Rename(asOldName, asNewName : String) : boolean ;
  end ;

Var goInternalFunction : TInternalFunction ;
    
implementation

{******************************************************************************
 * Create
 * MARTINEAU Emeric
 *
 * Consructeur
 ******************************************************************************}
constructor TInternalFunction.Create ;
begin
    inherited Create();

    { Cr�er l'objet FileName }
    poFunctionName := TStringList.Create ;
end ;

{******************************************************************************
 * Free
 * MARTINEAU Emeric
 *
 * Destructeur
 ******************************************************************************}
destructor TInternalFunction.Free ;
begin
    poFunctionName.Free ;
    SetLength(paFunction, 0) ;
end ;

{*****************************************************************************
 * Add
 * MARTINEAU Emeric
 *
 * Ajoute une fonction
 *
 * Param�tres d'entr�e :
 *   - asFunctionName : nom de la fonction,
 *   - aFunction : pointeur de fonction,
 *   - abParsed : est-ce que les arguments doivent �tre pars�
 *
 *****************************************************************************}
procedure TInternalFunction.Add(asFunctionName : string; aFunction : ModelProcedure; abParsed : boolean) ;
var
    { Taille du tableau contenant les pointeurs de fonction }
    liLength : Integer ;
begin
    poFunctionName.Add(LowerCase(asFunctionName)) ;

    liLength := poFunctionName.Count ;

    SetLength(paFunction, liLength) ;
    paFunction[liLength - 1] := aFunction ;

    SetLength(paParseArgument, liLength) ;
    paParseArgument[liLength - 1] := abParsed ;
end ;

{*****************************************************************************
 * Delete
 * MARTINEAU Emeric
 *
 * Supprimer l'entr�e correspondant dans le tableau.
 *
 * Param�tres d'entr�e :
 *   - asFunctionName : nom de la fonction
 *
 *****************************************************************************}
procedure TInternalFunction.Delete(asFunctionName : String) ;
Var
    { Pointe sur la fonction dans le tableau de nom de fonction pass� en
      param�tre }
    liIndexFunction : Integer ;
    { Compteur de boucle }
    liCountFunction : Integer ;
begin
    liIndexFunction := poFunctionName.IndexOf(LowerCase(asFunctionName)) ;

    if (liIndexFunction <> -1)
    then begin
        poFunctionName.Delete(liIndexFunction) ;

        for liCountFunction := liIndexFunction to poFunctionName.Count - 1 do
        begin
            paFunction[liCountFunction] := paFunction[liCountFunction + 1] ;
            paParseArgument[liCountFunction] := paParseArgument[liCountFunction + 1] ;
        end ;

        SetLength(paFunction, poFunctionName.Count) ;
        SetLength(paParseArgument, poFunctionName.Count) ;
    end ;
end;

{*****************************************************************************
 * Count
 * MARTINEAU Emeric
 *
 * Donne le nombre de fonction enregistr�
 *
 * Retour : nombre de fonction enregistr�
 *****************************************************************************}
function TInternalFunction.Count : Integer ;
begin
    Result := poFunctionName.Count ;
end ;

{*****************************************************************************
 * Give
 * MARTINEAU Emeric
 *
 * Donne la fichier correspondant � l'index.
 *
 * Param�tres d'entr�e :
 *   - asFunctionName : nom de la fonction,
 *
 * Retour : pointeur de fonction
 *****************************************************************************}
function TInternalFunction.Give(asFunctionName : string) : ModelProcedure ;
Var
    { Pointe sur la fonction pass�e en param�tre }
    liIndex : Integer ;
begin
    liIndex := poFunctionName.IndexOf(LowerCase(asFunctionName)) ;

    if liIndex <> -1
    then begin
        Result := paFunction[liIndex] ;
    end
    else begin
        Result := nil ;
    end ;
end ;

{*****************************************************************************
 * IsSet
 * MARTINEAU Emeric
 *
 * Indique si la variable existe.
 *
 * Param�tres d'entr�e :
 *   - asFunctionName : nom de la fonction,
 *
 * Retour : true si la fonction existe
 *****************************************************************************}
function TInternalFunction.IsSet(asFunctionName : string) : boolean ;
Var
    { Pointe sur la fonction en param�tre }
    liIndex : Integer ;
begin
    liIndex := poFunctionName.IndexOf(LowerCase(asFunctionName)) ;

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
 * Vide la liste.
 *****************************************************************************}
procedure TInternalFunction.Clear ;
begin
    poFunctionName.Clear ;
    SetLength(paFunction, 0) ;
end ;

{*****************************************************************************
 * GiveFunctionNameByIndex
 * MARTINEAU Emeric
 *
 * Retourne le nom de la fonction en fonction de sont index.
 *
 * Param�tres d'entr�e :
 *   - aiIndex : index de la fonction,
 *****************************************************************************}
function TInternalFunction.GiveFunctionNameByIndex(aiIndex : Integer) : string ;
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
 * IsParse
 * MARTINEAU Emeric
 *
 * Indique s'il faut parser les arguments (convertir $var en valeur).
 *
 * Param�tres d'entr�e :
 *   - asFunctionName : nom de la fonction,
 *
 * Retour : true si les arguments de la fonction doivent �tre pars�s
 *****************************************************************************}
function TInternalFunction.IsParse(asFunctionName : String) : boolean ;
var
    { Pointe sur la fonction pass� en param�tre }
    liIndex : Integer ;
begin
    liIndex := poFunctionName.IndexOf(LowerCase(asFunctionName)) ;

    if liIndex <> -1
    then begin
        Result := paParseArgument[liIndex]
    end
    else begin
        Result := False ;
    end ;
end ;

{*****************************************************************************
 * IsParse
 * MARTINEAU Emeric
 *
 * Renomme la fonction OldName par NewName.
 *
 * Param�tres d'entr�e :
 *   - asOldName : nom de la fonction � renomer,
 *   - asNewName : nouveau nom,
 *
 * Retour : true si la fonction asOldName existe
 *****************************************************************************}
function TInternalFunction.Rename(asOldName, asNewName : String) : boolean ;
var
    { Pointe sur la fonction pass� en param�tre }
    liIndex : Integer ;
begin
    liIndex := poFunctionName.IndexOf(LowerCase(asOldName)) ;

    if liIndex <> -1
    then begin
        poFunctionName[liIndex] := LowerCase(asNewName) ;
        Result := True ;
    end
    else begin
        Result := False ;
    end ;
end ;

{*****************************************************************************
 * IsParse
 * MARTINEAU Emeric
 *
 * Change le pointeur de fonction.
 *
 * Param�tres d'entr�e :
 *   - asFunctionName : nom de la fonction � changer,
 *   - aFunction : pointeur de fonction,
 *   - abParsed : les arguments doivent-ils �tre pars�
 *****************************************************************************}
procedure TInternalFunction.Change(asFunctionName : string; aFunction : ModelProcedure; abParsed : boolean) ;
var
    { Pointe sur la fonction pass� en param�tre }
    liIndex : Integer ;
begin
    liIndex := poFunctionName.IndexOf(LowerCase(asFunctionName)) ;

    if liIndex <> -1
    then begin
        paFunction[liIndex] := aFunction ;
        paParseArgument[liIndex] := abParsed ;
    end ;
end ;

end.
