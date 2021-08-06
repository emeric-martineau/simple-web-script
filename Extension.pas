unit Extension;
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
 * Class to manage extension.
 ******************************************************************************}
{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

interface

uses SysUtils, Classes;

type
  TProcExt = function (Commande : PChar; Parameters : PChar; scriptname : PChar; versionofsws : PChar; line : Integer; GlobalError : PBoolean) : boolean ; stdcall;
  TProcResult = function(Resultat : Pointer) : Integer ; stdcall;
  TProcInit = procedure(DocRoot : PChar; TmpDir : PChar; SafeMode : Boolean) ; stdcall ;

  TExtension = class
  private
      { Tableau contenant les pointeurs de fonction Execute }
      paExtension : array of TProcExt ;
      { Tableau contenant les pointeurs de fonction GetResult }
      paExtensionGetResult : array of TProcResult ;
      { Tableau contenant les handles de fonction }
      paHandleExt : array of Integer ;
      { Nom des extensions }
      poNameOfExtension : TStringList ;
  protected
  public
      constructor Create ;
      destructor Free ;
      procedure Add(asNameOfExt : String; aiHandleOfExt : Integer; aProc : TProcExt; aProcResult : TProcResult) ;
      procedure Give(asNameOfExt : String; var aiHandleOfExt : Integer; var aProc : TProcExt) ;
      function GiveProcByIndex(aiIndex : Integer) : TProcExt ;
      procedure DeleteByIndex(aiIndex : Integer) ;
      procedure DeleteByName(asNameOfExt : String) ;
      function  Count : integer ;
      procedure Clear ;
      function  GiveNameByIndex(aiIndex : Integer) : String ;
      function GetResult(aiIndex : Integer) : String ;
      function isExists(asNameOfExt : String) : boolean ;
  end ;

Var goListOfExtension : TExtension ;

implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TExtension.Create ;
begin
    inherited Create();
    poNameOfExtension := TStringList.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TExtension.Free ;
begin
    Clear ;
    poNameOfExtension.Free ;
end ;

{******************************************************************************
 * Add
 *
 * Ajouter une extension
 *
 * Param�tre d'entr�e :
 *   - asNameOfVar : nom de la variable � ajouter,
 *   - aiHandleOfExt : handle de la DLL,
 *   - aProc : proc�dure ajoutant les nouvelles fonctions,
 *   - aProcResult : resultat de la commande
 *
 ******************************************************************************}
procedure TExtension.Add(asNameOfExt : String; aiHandleOfExt : Integer; aProc : TProcExt; aProcResult : TProcResult) ;
var
    { Nombre d'extension }
    liNbExt : Integer ;
begin
    poNameOfExtension.Add(asNameOfExt) ;

    liNbExt := poNameOfExtension.Count ;

    SetLength(paExtension, liNbExt) ;
    SetLength(paHandleExt, liNbExt) ;
    SetLength(paExtensionGetResult, liNbExt) ;

    paExtension[liNbExt - 1] := aProc ;
    paHandleExt[liNbExt - 1] := aiHandleOfExt ;
    paExtensionGetResult[liNbExt - 1] := aProcResult ;
end ;

{******************************************************************************
 * DeleteByName
 *
 * Supprimer l'entr�e correspondant dans le tableau.
 *
 * Param�tre d'entr�e :
 *   - asNameOfExt : nom de l'extension � ajouter,
 *
 ******************************************************************************}
procedure TExtension.DeleteByName(asNameOfExt : String) ;
Var
    { Index de l'extension � supprimer }
    liIndex : Integer ;
begin
    liIndex := poNameOfExtension.IndexOf(asNameOfExt) ;

    if (liIndex <> -1)
    then begin
        DeleteByIndex(liIndex) ;
    end ;
end;

{******************************************************************************
 * DeleteByIndex
 *
 * Supprimer l'entr�e correspondant dans le tableau.
 *
 * Param�tre d'entr�e :
 *   - aiIndex : index de l'extension,
 *
 ******************************************************************************}
procedure TExtension.DeleteByIndex(aiIndex : Integer) ;
Var
    { Compteur de boucle }
    liCompteur : Integer ;
    { Nombre d'extension pr�sente dans la liste }
    liNbExt : Integer ;
begin
    if (aiIndex > -1)
    then begin
        liNbExt := poNameOfExtension.Count ;

        for liCompteur := aiIndex to liNbExt - 1 do
        begin
            paExtension[liCompteur] := paExtension[liCompteur + 1] ;
            paHandleExt[liCompteur] := paHandleExt[liCompteur + 1] ;
            paExtensionGetResult[liCompteur] := paExtensionGetResult[liCompteur + 1] ;
        end ;

        Dec(liNbExt) ;

        SetLength(paExtension, liNbExt) ;
        SetLength(paHandleExt, liNbExt) ;
        SetLength(paExtensionGetResult, liNbExt) ;

        poNameOfExtension.Delete(aiIndex);
    end ;
end;

{******************************************************************************
 * Count
 *
 * Donne le nombre de fichiers r�cents
 ******************************************************************************}
function TExtension.Count : Integer ;
begin
     result := poNameOfExtension.Count ;
end ;

{******************************************************************************
 * Give
 *
 * Donne la fichier correspondant � l'index.
 *
 * Param�tre d'entr�e :
 *   - asNameOfExt : nom de l'extension,
 *
 * Param�tres de sortie :
 *   - aiHandleOfExt : handle de l'extension,
 *   - aProc : pointeur sur la fonction,
 *
 ******************************************************************************}
procedure TExtension.Give(asNameOfExt : String; var aiHandleOfExt : Integer; var aProc : TProcExt) ;
Var
    { Index de l'extension }
    liIndex : Integer ;
begin
    liIndex := poNameOfExtension.IndexOf(asNameOfExt) ;

    if liIndex <> -1
    then begin
        aProc := paExtension[liIndex] ;
        aiHandleOfExt := paHandleExt[liIndex] ;
    end
    else begin
        aProc := nil ;
        aiHandleOfExt := -1;
    end ;
end ;

{******************************************************************************
 * GiveNameByIndex
 *
 * Donne la fichier correspondant � l'index.
 *
 * Param�tre d'entr�e :
 *   - asIndex : index de l'extension,
 *
 * Retour : nom de l'extension
 ******************************************************************************}
function TExtension.GiveNameByIndex(aiIndex : Integer) : String ;
begin
    Result := '' ;
    
    if (aiIndex > -1) and (aiIndex < poNameOfExtension.Count - 1)
    then begin
        Result := poNameOfExtension[aiIndex] ;
    end
end ;

{******************************************************************************
 * GiveNameByIndex
 *
 * Donne la proc�dure par rapport � l'index.
 *
 * Param�tre d'entr�e :
 *   - aiIndex : index de l'extension,
 *
 * Retour : proc�dure Execute de l'extension
 ******************************************************************************}
function TExtension.GiveProcByIndex(aiIndex : Integer) : TProcExt ;
begin
    if aiIndex > -1
    then begin
        Result := paExtension[aiIndex] ;
    end
    else begin
        Result := nil ;
    end ;
end ;

{*******************************************************************************
 * Clear
 *
 * Efface la liste
 ******************************************************************************}
procedure TExtension.Clear ;
begin
    SetLength(paExtension, 0) ;
    SetLength(paHandleExt, 0) ;
    SetLength(paExtensionGetResult, 0) ;

    poNameOfExtension.Clear ;
end ;

{******************************************************************************
 * GetResult
 *
 * R�cup�re la valeur de retour.
 *
 * Param�tre d'entr�e :
 *   - aiIndex : index de l'extension,
 *
 * Retour : r�sultat de la commande ex�cut�e.
 ******************************************************************************}
function TExtension.GetResult(aiIndex : Integer) : String ;
var
    { Proc�dure retournant le r�sultat }
    lProcResult : TProcResult ;
    { Longueur de r�sultat }
    liLenResult : Integer ;
begin
    Result := '' ;
    
    { Prend le pointeur su la fonction GetResult }
    lProcResult := paExtensionGetResult[aiIndex] ;

    { Appel � GetResult }
    liLenResult := lProcResult(nil) ;

    if liLenResult > 0
    then begin
        SetLength(Result, liLenResult) ;

        lProcResult(Pchar(Result)) ;
    end ;
end ;

{******************************************************************************
 * IsExists
 *
 * Indique si une extension existe.
 *
 * Param�tre d'entr�e :
 *   - asNameOfExt : nom de l'extension,
 *
 * Retour : true si l'extension existe.
 ******************************************************************************}
function TExtension.IsExists(asNameOfExt : String) : boolean ;
var
    { Position de l'extension }
    liIndex : Integer ;
begin
     liIndex := poNameOfExtension.IndexOf(asNameOfExt) ;

     if liIndex <> -1
     then begin
         Result := True
     end
     else begin
         Result := False ;
     end ;
end ;

end.
