unit Variable;
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
 * Class to manage variables.
 ******************************************************************************}

interface

{$I config.inc}

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

uses SysUtils, classes ;

type
  TVariables = class
  private
      poVarName : TStringList ;
      poVarValue: TStringList ;
  protected
      function GetValueOfArray(asText : String; aiIndex : Integer) : string ;
      procedure SetValueOfArray(asNameOfVar : String; asValue : String; aiIndex : Integer) ;
      function InternalGive(asNameOfVar : String) : String ;
      procedure InternalAdd(asNameOfVar, Value : String) ;
      procedure internalExplodeNumber(asText : String; aoListe : TStringList) ;
      function InternalCreateArray(aoListe : TStringList) : String ;
      procedure QuickSort(aoTab : TStringList) ;
      procedure QuickRSort(aoTab : TStringList) ;
  public
      constructor Create ;
      destructor Free ;
      procedure Add(asNameOfVar : string; asValueOfVar : string) ;
      function Give(asNameOfVar : string) : string;
      procedure Delete(asNameOfVar : String) ;
      function Count : integer ;
      procedure Clear ;
      function IsSet(asNameOfVar : string) : boolean ;
      function IsArray(asNameOfVar : string) : boolean ;
      function Length(asNameOfVar : string) : Integer ;
      function AddSlashes(asText : string) : string ;
      function DeleteSlashes(asText : string) : string ;
      procedure Push(asNameOfVar : String; asValue : String) ;
      function Insert(asNameOfVar : String; aiIndex : Integer; asValue : String) : Boolean ;
      function Pop(asNameOfVar : String) : string ;
      function Exchange(asNameOfVar : String; aiIndex1, aiIndex2 : Integer) : Boolean ;
      function Chunk(asNameOfVar : String; aiSize : Integer) : boolean ;
      function Merge(aoNameOfVars : TStringList) : string ;
      function CreateArray(aoValue : TStringList) : string ;
      function ArrayFill(asNameOfVar : String; asValue : String) : boolean ;
      function ArraySort(var asTableau : String) : boolean ;
      function ArraySearch(asTableau : string; asChaineARechercher : String; abCaseSensitive : Boolean) : Integer ;
      function ArrayRSort(var asTableau : String) : boolean ;
      function GiveVarNameByIndex(aiIndex : Integer) : string ;
      // Public uniquement pour utilisation avec les fonctions qui ne parse pas
      // automatiquement
      function InternalIsArray(asValue : String) : boolean ;
      procedure Explode(var aoListe : TStringList; asTab : String) ;
      function InternalLength(asValue : string) : integer ;
  end ;

Var goVariables : TVariables ;
  
implementation

{*****************************************************************************
 * Create
 * MARTINEAU Emeric
 *
 * Consructeur
 *****************************************************************************}
constructor TVariables.Create ;
begin
    inherited Create();

    poVarName := TStringList.Create ;
    poVarValue := TStringList.Create ;
end ;

{*****************************************************************************
 * Free
 * MARTINEAU Emeric
 *
 * Destructeur
 *****************************************************************************}
destructor TVariables.Free ;
begin
    poVarName.Free ;
    poVarValue.Free ;
end ;

{*****************************************************************************
 * Add
 * MARTINEAU Emeric
 *
 * Ajoute une variable
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable,
 *   - asValueOfVar : valeur de la variable
 *
 *****************************************************************************}
procedure TVariables.Add(asNameOfVar : string; asValueOfVar : string) ;
Var
    { Index de la variable dans la liste }
    liIndexVar : Integer ;
    { Index du caractère à copier si la variable est une chaine }
    liIndexOfChar : Integer ;
    { Variable temporaire }
    lsTmp : string ;
    { position du crochet ouvrant }
    liPosTabStart : Integer ;
    { Longueur de la variable si c'est une chaine }
    liLengthOfNameOfVar : Integer ;
    { Compteur de tableau }
    liIndexTab : Integer ;
    { Reçoit le tableau d'index venant de la variable }
    loTabIndex : TStringList ;
    { Contient le tableau en cours de traitement}
    loTableau : TStringList ;
begin
    liPosTabStart := pos('[', asNameOfVar) ;
    loTabIndex := TStringList.Create ;

    lsTmp := '0' ;
    
    if liPosTabStart <> 0
    then begin
        liLengthOfNameOfVar := System.length(asNameOfVar) ;
        lsTmp := copy(asNameOfVar, liPosTabStart, liLengthOfNameOfVar - liPosTabStart + 1) ;

        internalExplodeNumber(lsTmp, loTabIndex) ;

        asNameOfVar := copy(asNameOfVar, 1, liPosTabStart - 1) ;
    end ;

    if liPosTabStart = 0
    then begin
        InternalAdd(asNameOfVar, asValueOfVar) ;
    end
    else if (not isArray(asNameOfVar)) and (isSet(asNameOfVar))
    then begin
        liIndexVar := poVarName.IndexOf(asNameOfVar) ;
        
        { La variable n'est pas un tableau mais une chaine }
        if liPosTabStart <> 0
        then begin
            if loTabIndex.Count = 1
            then begin
                { On copie seulement le caractère }
                liIndexOfChar := StrToInt(loTabIndex[0]) ;

                lsTmp := poVarValue[liIndexVar] ;

                if liIndexOfChar < System.Length(lsTmp)
                then begin
                    { +1 car en pascal sur les chaines commence à 1 }
                    lsTmp[liIndexOfChar + 1] := asValueOfVar[1] ;
                    poVarValue[liIndexVar] := lsTmp ;
                end ;
            end ;
        end
        else begin
            poVarValue[liIndexVar] := asValueOfVar ;
        end ;
    end
    else begin
        { C'est un tableau }

        if loTabIndex.Count = 1
        then begin
            setValueOfArray(asNameOfVar, asValueOfVar, StrToInt(loTabIndex[0]))
        end
        else begin
            loTableau := TStringList.Create ;
            loTableau.Add(Give(asNameOfVar)) ;

            lsTmp := '' ;
                        
            for liIndexTab := 1 to loTabIndex.Count - 1 do
            begin
                lsTmp := lsTmp + '[' + loTabIndex[liIndexTab - 1] + ']' ;
                loTableau.Add(Give(asNameOfVar + lsTmp)) ;
            end ;

            { L'avant dernier tableau est-il un tableau }
            if InternalisArray(loTableau[loTableau.Count - 1])
            then begin
                { Si c'est un tableau, le dernier élément de Tableau c'est le
                  tableau dans lequel on doit affecter la variable. Or si ce
                  n'est pas un tableau, il contient la chaine à modifier.
                  On ajoute dans la valeur à mettre à jour }
                loTableau.Add(asValueOfVar) ;
            end
            else begin
                lsTmp := loTableau[loTableau.Count - 1] ;
                lsTmp[StrToInt(loTabIndex[loTabIndex.Count - 1])] := asValueOfVar[1] ;
                loTableau[loTableau.Count - 1] := lsTmp ;
            end ;

            { Tableau.Count - 1 contient la donnée qui va mettre à jour le
              tableau }
            for liIndexTab := loTableau.Count - 2 downto 0 do
            begin
                add(asNameOfVar, loTableau[liIndexTab]) ;

                setValueOfArray(asNameOfVar, loTableau[liIndexTab + 1], StrToInt(loTabIndex[liIndexTab])) ;

                loTableau[liIndexTab] := InternalGive(asNameOfVar) ;
            end ;

            loTableau.Free ;
        end ;
    end ;

    loTabIndex.Free ;
end ;

{*****************************************************************************
 * Delete
 * MARTINEAU Emeric
 *
 * Supprimer l'entrée correspondant dans le tableau.
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable,
 *
 *****************************************************************************}
procedure TVariables.Delete(asNameOfVar : String) ;
Var
    { Position de la variable dans la liste de variables }
    liIndexOfVar : Integer ;
    { Longueur de la variable }
    liLength : Integer ;
    { Variable temporaire }
    lsTmp : String ;
    { Index du tableau à supprimer }
    liIndexTabToDelete : Integer ;
    { Lise des éléments de la variable si c'est un taleau}
    loTableau : TStringList ;
    { Compteur de liste tableau }
    liIndexListeTableau : Integer ;
    { Compteur de loTableauIndex }
    liIndexTab : Integer;
    { Position du crochet ouvrant }
    liPosTabStart : Integer ;
    { Contient la liste des variables tableau à lire $truc[0] + $truc[0][1] }
    loListeTableau : TStringList ;
    { Contient la liste des index de la variable si c'est un tableau }
    loIndexTab : TStringList ;
begin
    liPosTabStart := pos('[', asNameOfVar) ;

    lsTmp := '0' ;

    if liPosTabStart = 0
    then begin
        liIndexOfVar := poVarName.IndexOf(asNameOfVar) ;

        if (liIndexOfVar <> -1)
        then begin
            poVarName.Delete(liIndexOfVar) ;
            poVarValue.Delete(liIndexOfVar) ;
        end ;
    end
    else begin
        loIndexTab := TStringList.Create ;
        loTableau := TStringList.Create ;

        if liPosTabStart <> 0
        then begin
            liLength := System.length(asNameOfVar) ;
            lsTmp := copy(asNameOfVar, liPosTabStart, liLength - liPosTabStart + 1) ;

            internalExplodeNumber(lsTmp, loIndexTab) ;

            asNameOfVar := copy(asNameOfVar, 1, liPosTabStart - 1) ;
        end ;

        loListeTableau := TStringList.Create ;

        loListeTableau.Add(Give(asNameOfVar)) ;

        lsTmp := '' ;
                    
        for liIndexTab := 1 to loIndexTab.Count - 1 do
        begin
            lsTmp := lsTmp + '[' + loIndexTab[liIndexTab - 1] + ']' ;
            loListeTableau.Add(Give(asNameOfVar + lsTmp)) ;
        end ;

        { L'avant dernier tableau est-il un tableau }
        if InternalisArray(loListeTableau[loListeTableau.Count - 1])
        then begin
            // On ne fait rien
        end
        else begin
            { On pointe sur le contenu d'une chaine on supprime dons le
              niveau inférieur }
            loListeTableau.Delete(loListeTableau.Count - 1) ;
        end ;

        { Tableau.Count - 1 contient la donnée qui va mettre à jour le
          tableau }
        for liIndexListeTableau := loListeTableau.Count - 1 downto 0 do
        begin
            add(asNameOfVar, loListeTableau[liIndexListeTableau]) ;

            if liIndexListeTableau = (loListeTableau.Count - 1)
            then begin
                Explode(loTableau, loListeTableau[liIndexListeTableau]) ;

                liIndexTabToDelete := StrToInt(loIndexTab[liIndexListeTableau]) ;

                if (liIndexTabToDelete >= 0) and (liIndexTabToDelete <= loTableau.Count)
                then begin
                    loTableau.Delete(liIndexTabToDelete);
                    
                    lsTmp := InternalCreateArray(loTableau) ;

                    InternalAdd(asNameOfVar, lsTmp) ;
                end ;
            end
            else begin
                setValueOfArray(asNameOfVar, loListeTableau[liIndexListeTableau + 1], StrToInt(loIndexTab[liIndexListeTableau])) ;
            end ;

            loListeTableau[liIndexListeTableau] := InternalGive(asNameOfVar) ;
        end ;

        loListeTableau.Free ;
    end ;
end;

{******************************************************************************
 * Count
 * MARTINEAU Emeric
 *
 * Donne le nombre de variable
 ******************************************************************************}
function TVariables.Count : Integer ;
begin
    Result := poVarName.Count ;
end ;

{*****************************************************************************
 * Give
 * MARTINEAU Emeric
 *
 * Donne la fichier correspondant à l'index.
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable
 *
 * Retour : valeur de la variable
 *****************************************************************************}
function TVariables.Give(asNameOfVar : string) : string ;
Var
    { Index de la variable dans la liste de variable }
    liIndexOfVar : Integer ;
    { Index du caractère si la variable est une chaine de caractère }
    liIndexOfChar : Integer ;
    { Position du crochet ouvrant }
    liPosTabStart : Integer ;
    { Longueur de la variable si c'est une chaine de caractère }
    liLength : Integer ;
    { Variable temporaire }
    lsTmp : String ;
    { Liste des éléments de la variable si c'est un tableau }
    loTab : TStringList ;
    { Compteur du tableau }
    liIndexTab : Integer ;
begin
    liPosTabStart := pos('[', asNameOfVar) ;
    loTab := TStringList.Create ;

    lsTmp := '0' ;

    if liPosTabStart <> 0
    then begin
        liLength := System.length(asNameOfVar) ;
        lsTmp := copy(asNameOfVar, liPosTabStart, liLength - liPosTabStart + 1) ;

        internalExplodeNumber(lsTmp, loTab) ;

        asNameOfVar := copy(asNameOfVar, 1, liPosTabStart - 1) ;
    end ;

    if liPosTabStart = 0
    then
        Result := InternalGive(asNameOfVar)
    else if not isArray(asNameOfVar)
    then begin
        liIndexOfVar := poVarName.IndexOf(asNameOfVar) ;

        if liIndexOfVar <> -1
        then begin
            if liPosTabStart = 0
            then begin
                Result := poVarValue[liIndexOfVar] ;
            end
            else begin

                liIndexOfChar := StrToInt(loTab[0]) ;
                lsTmp := poVarValue[liIndexOfVar] ;

                if liIndexOfChar < System.Length(lsTmp)
                then begin
                    { + 1 car en pascal les chaines commence à 1 }
                    Result := poVarValue[liIndexOfVar][liIndexOfChar + 1] ;
                end
                else begin
                     Result := '' ;
                end ;
            end ;
        end
        else
            Result := '' ;
    end
    else begin
        { Le premier élément est forcément un tableau }
        lsTmp := InternalGive(asNameOfVar) ;
        lsTmp := GetValueOfArray(lsTmp, StrToInt(loTab[0])) ;

        { Parcours tout les sous tableau }
        for liIndexTab := 1 to loTab.Count - 1 do
        begin
            if InternalisArray(lsTmp)
            then begin
                lsTmp := getValueOfArray(lsTmp, StrToInt(loTab[liIndexTab])) ;
            end
            else begin
                lsTmp := lsTmp[StrToInt(loTab[liIndexTab])] ;

                { Si ce n'ai pas un tableau on doit arrêter la recherche de
                  tableau }
                break ;
            end ;
        end ;

        Result := lsTmp ;
    end ;

    loTab.Free ;
end ;

{*****************************************************************************
 * IsSet
 * MARTINEAU Emeric
 *
 * Indique si la variable existe
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable,
 *
 *****************************************************************************}
function TVariables.IsSet(asNameOfVar : string) : boolean ;
Var
    { Position de la variable dans la liste de variable }
    liIndexOfVar : Integer ;
    { Elément de la variable si c'est un tableau }
    loItemOfArray : TStringList ;
    { Liste des index de la variable si c'est un tableau }
    loListIndexOfArray : TStringList ;
    { Position du crochet ouvrant }
    liPosTabStart : Integer ;
    { Taille du nom de la variable }
    liLengthOfNameVar : Integer ;
    { Variable temporaire }
    lsTmp : String ;
    { Index de ListIndexOfArray }
    liIndexListIndexOfArray : Integer ;
    { Valeur de la variable }
    lsValueOfVar : String ;
begin
    liPosTabStart := pos('[', asNameOfVar) ;
    Result := False ;

    if liPosTabStart = 0
    then begin
        liIndexOfVar := poVarName.IndexOf(LowerCase(asNameOfVar)) ;
            
        if liIndexOfVar <> -1
        then begin
            Result := True ;
        end
        else begin
            Result := False ;
        end ;
    end
    else begin
        liLengthOfNameVar := System.length(asNameOfVar) ;
        lsTmp := copy(asNameOfVar, liPosTabStart, liLengthOfNameVar - liPosTabStart + 1) ;

        asNameOfVar := copy(asNameOfVar, 1, liPosTabStart - 1) ;

        loListIndexOfArray := TStringList.Create ;
        loItemOfArray := TStringList.Create ;

        internalExplodeNumber(lsTmp, loListIndexOfArray) ;

        lsTmp := '' ;

        for liIndexListIndexOfArray := 0 to loListIndexOfArray.Count - 1 do
        begin
            { On récupère le contenu de la variable (la première est sans
              crochet) }
            lsValueOfVar := Give(asNameOfVar + lsTmp) ;

            Explode(loItemOfArray, lsValueOfVar) ;

            if isArray(lsTmp)
            then begin
                if StrToInt(loListIndexOfArray[liIndexListIndexOfArray]) <= loItemOfArray.Count
                then begin
                    Result := True ;
                end
                else begin
                    Result := False ;
                    Break ;
                end ;
            end
            else begin
                if Length(asNameOfVar + lsTmp) >= StrToInt(loListIndexOfArray[liIndexListIndexOfArray])
                then begin
                    Result := True ;
                end
                else begin
                    Result := False ;
                    break ;
                end ;
            end ;

            { Récupère le tableau suivant }
            lsTmp := lsTmp + '[' + loListIndexOfArray[liIndexListIndexOfArray] + ']' ;
        end ;

        loListIndexOfArray.Free ;

        loItemOfArray.Free ;
    end ;

end ;

{******************************************************************************
 * Clear
 * MARTINEAU Emeric
 *
 * Efface la liste de variable
 ******************************************************************************}
procedure TVariables.Clear ;
begin
    poVarValue.Clear ;
    poVarName.Clear ;
end ;

{*****************************************************************************
 * IsArray
 * MARTINEAU Emeric
 *
 * Indique s'il s'agit d'un tableau
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable,
 *
 * Retour : true si la variable est un tableau
 *****************************************************************************}
function TVariables.IsArray(asNameOfVar : string) : boolean ;
var
    { Valeur de la variable }
    lsValueOfVar : String ;
begin
    Result := False ;

    if IsSet(asNameOfVar)
    then begin
        lsValueOfVar := Give(asNameOfVar) ;
        Result := InternalIsArray(lsValueOfVar) ;
    end ;
end ;

{*****************************************************************************
 * Length
 * MARTINEAU Emeric
 *
 * Longueur d'une variable
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable
 *
 * Retour : longueur de la variable
 *****************************************************************************}
function TVariables.Length(asNameOfVar : string) : Integer ;
var
    { Valeur de la variable }
    lsValueOfVar : String ;
begin
    if IsSet(asNameOfVar)
    then begin
        lsValueOfVar := Give(asNameOfVar) ;

        Result := InternalLength(lsValueOfVar) ;
    end
    else begin
        Result := 0 ;
    end ;
end ;

{*****************************************************************************
 * InternalLength
 * MARTINEAU Emeric
 *
 * Longueur de la chaine ou du tableau
 *
 * Paramètres d'entrée :
 *   - asValeur : valeur à traiter. Soit une chaine soit un tableau
 *
 * Retour : longueur de la valeur
 *****************************************************************************}
function TVariables.InternalLength(asValue : string) : integer ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longueur de asValue }
    liLength : Integer ;
begin
    liLength := System.Length(asValue) ;

    if InternalisArray(asValue)
    then begin
        Result := 0 ;
        liIndex := 3 ;

        while liIndex < liLength do
        begin
            if asValue[liIndex] = '"'
            then begin
                Inc(liIndex) ;
                Inc(Result) ;

                while asValue[liIndex] <> '"' do
                begin
                    if asValue[liIndex] = '\'
                    then begin
                        Inc(liIndex) ;
                    end ;
                    
                    Inc(liIndex) ;
                end ;
            end ;

            Inc(liIndex) ;
        end ;
    end
    else begin
        Result := liLength ;
    end ;
end ;

{*****************************************************************************
 * Explode
 * MARTINEAU Emeric
 *
 * Remplit une TStringList avec un tableau a{"2222";"555"}
 *
 * Paramètres d'entrée :
 *   - aoListe : TStringList à remplir,
 *   - asTab : tableau sous forme de chaine à traiter,
 *
 * Retour : nombre de bidule
 *****************************************************************************}
procedure TVariables.Explode(var aoListe : TStringList; asTab : String) ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Longeur de asTab }
    liLength : Integer ;
    { Valeur de l'élément courant }
    lsValueOfItem : String ;
begin
    liIndex := 3 ;
    liLength := System.Length(asTab) ;

    while liIndex < liLength do
    begin
        if asTab[liIndex] = '"'
        then begin
            lsValueOfItem := '' ;
            Inc(liIndex) ;

            while asTab[liIndex] <> '"' do
            begin
                if asTab[liIndex] = '\'
                then begin
                    lsValueOfItem := lsValueOfItem + asTab[liIndex] ;
                    Inc(liIndex) ;
                end ;
                
                lsValueOfItem := lsValueOfItem + asTab[liIndex] ;
                Inc(liIndex) ;
            end ;

            aoListe.Add(DeleteSlashes(lsValueOfItem)) ;
        end ;

        Inc(liIndex) ;
    end ;
end ;

{*****************************************************************************
 * SetValueOfArray
 * MARTINEAU Emeric
 *
 * Remplit un tableau depuis un index
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la variable tableau,
 *   - asValue : valeur,
 *   - aiIndex : index à ajouter,
 *
 * Retour : nombre de bidule
 *****************************************************************************}
procedure TVariables.SetValueOfArray(asNameOfVar : String; asValue : String; aiIndex : Integer) ;
var
    { Compteur de boucle }
    liIndexBoucle : Integer ;
    { Nouveau tableau }
    lsNewArray : string ;
    { Valeur de la variable }
    lsValueOfVar : String ;
    { Taille du tableau }
    liCountOfArray : Integer ;
    { Elément du tableau }
    loListOfArray : TStringList ;
begin
    loListOfArray := TStringList.Create ;
    
    if IsArray(asNameOfVar)
    then begin
        liCountOfArray := Length(asNameOfVar) ;

        if aiIndex > (liCountOfArray - 1)
        then begin
            lsValueOfVar := InternalGive(asNameOfVar) ;

            explode(loListOfArray, lsValueOfVar) ;

            for liIndexBoucle := liCountOfArray to aiIndex - 1 do
            begin
                loListOfArray.Add('') ;
            end ;

            loListOfArray.Add(asValue) ;

            lsNewArray := InternalCreateArray(loListOfArray) ;

            InternalAdd(asNameOfVar, lsNewArray) ;
        end
        else begin
            { Explose le tableau }
            lsValueOfVar := InternalGive(asNameOfVar) ;

            explode(loListOfArray, lsValueOfVar) ;

            loListOfArray[aiIndex] := asValue ;

            lsNewArray := InternalCreateArray(loListOfArray) ;

            InternalAdd(asNameOfVar, lsNewArray) ;
        end ;
    end
    else begin
        for liIndexBoucle := 0 to aiIndex - 1 do
        begin
            loListOfArray.Add('') ;
        end ;

        loListOfArray.Add(asValue) ;

        lsNewArray := InternalCreateArray(loListOfArray) ;

        InternalAdd(asNameOfVar, lsNewArray) ;
    end ;

    loListOfArray.Free ;
end ;

(*****************************************************************************
 * GetValueOfArray
 * MARTINEAU Emeric
 *
 * Retour un élément d'un tableau
 *
 * Paramètres d'entrée :
 *   - asText : valeur du tableau a{..}
 *   - aiIndex : index du tableau à retourner
 *
 * Retour : valeur de l'élément du tableau
 *****************************************************************************)
function TVariables.GetValueOfArray(asText : String; aiIndex : Integer) : string ;
var
    { Liste contenant les éléments du tableau }
    loListe : TStringList ;
begin
    loListe := TStringList.Create ;

    Explode(loListe, asText) ;

    if aiIndex > loListe.Count
    then begin
        Result := ''
    end
    else begin
        Result := loListe[aiIndex] ;
    end ;

    loListe.Free ;
end ;

(*****************************************************************************
 * AddSlashes
 * MARTINEAU Emeric
 *
 * Ajoute des \ devant \ et "
 *
 * Paramètres d'entrée :
 *   - asText : chaine à traiter
 *
 * Retour : chaine traitée
 *****************************************************************************)
function TVariables.AddSlashes(asText : string) : string ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Taille de la chaine à traiter }
    liLength : Integer ;
begin
    liLength := System.Length(asText) ;
    Result := '' ;

    for liIndex := 1 to liLength do
    begin
        if (asText[liIndex] = '\') or (asText[liIndex] = '"') or (asText[liIndex] = '''')
        then begin
            Result := Result + '\' ;
        end ;

         Result := Result + asText[liIndex] ;
    end ;
end ;

(*****************************************************************************
 * DeleteSlashes
 * MARTINEAU Emeric
 *
 * Supprime les \
 *
 * Paramètres d'entrée :
 *   - asText : chaine à traiter
 *
 * Retour : chaine traitée
 *****************************************************************************)
function TVariables.DeleteSlashes(asText : string) : string ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Taille de la chaine à traiter }
    liLength : Integer ;
begin
    liLength := System.Length(asText) ;
    Result := '' ;

    liIndex := 1 ;
    
    while liIndex <= liLength do
    begin
        if asText[liIndex] = '\'
        then begin
            Inc(liIndex) ;
        end ;

        Result := Result + asText[liIndex] ;
        Inc(liIndex) ;
    end ;
end ;

{*****************************************************************************
 * InternalGive
 * MARTINEAU Emeric
 *
 * Retour la valeur brut d'une variable
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la bariable
 *
 * Retour : valeur brut de la variable
 *****************************************************************************}
function TVariables.InternalGive(asNameOfVar : String) : String ;
var
    { Position de la variable dans la liste des variables }
    liIndex : Integer ;
begin
    liIndex := poVarName.IndexOf(LowerCase(asNameOfVar)) ;

    if liIndex <> -1
    then begin
        Result := poVarValue[liIndex] ;
    end
    else begin
        Result := '' ;
    end ;
end ;

{*****************************************************************************
 * InternalAdd
 * MARTINEAU Emeric
 *
 * Ajoute la valeur brut d'une variable
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la bariable
 *****************************************************************************}
procedure TVariables.InternalAdd(asNameOfVar, Value : String) ;
var
    { Position de la variable dans la liste des variables }
    liIndex : Integer ;
begin
    asNameOfVar := LowerCase(asNameOfVar) ;
    
    liIndex := poVarName.IndexOf(asNameOfVar) ;

    if liIndex = -1
    then begin
        poVarName.Add(asNameOfVar) ;
        poVarValue.Add(Value) ;
    end
    else begin
        poVarValue[liIndex] := Value ;
    end ;
end ;

{*****************************************************************************
 * InternalExplodeNumber
 * MARTINEAU Emeric
 *
 * Convertit une chaine "[1][1]" en liste
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la bariable
 *
 * Paramètre de sortie :
 *   - aoListe : liste contenant les nombres
 *****************************************************************************}
procedure TVariables.InternalExplodeNumber(asText : String; aoListe : TStringList) ;
var
    { Compteur de chaine }
    liIndex : Integer ;
    { Variable temporaire recevant les nombres entre crochet }
    lsTmp : String ;
begin
    lsTmp := '' ;

    for liIndex := 1 to System.Length(asText) do
    begin
        if asText[liIndex] = ']'
        then begin
            aoListe.Add(lsTmp) ;
        end
        else if asText[liIndex] = '['
        then begin
            lsTmp := '' ;
        end
        else begin
            lsTmp := lsTmp + asText[liIndex] ;
        end ;
    end ;
end ;

{*****************************************************************************
 * InternalIsArray
 * MARTINEAU Emeric
 *
 * Indique s'il s'agit d'un tableau
 *
 * Paramètres d'entrée :
 *   - asValue : valeur à regarder
 *
 * Retour : true si c'est un tableau
 *****************************************************************************}
function TVariables.InternalIsArray(asValue : String) : boolean ;
Var
     { Longueur de asValue }
    liLength : Integer ;
begin
    Result := False ;

    liLength := System.length(asValue) ;

    if liLength > 2
    then begin
        if (asValue[1] = 'a') and (asValue[2] = '{') and (asValue[liLength] = '}')
        then begin
            Result := True ;
        end ;
    end ;
end ;

{*****************************************************************************
 * Push
 * MARTINEAU Emeric
 *
 * Ajoute un élément à la fin du tableau
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la bariable
 *   - asValue : valeur du tableau
 *
 *****************************************************************************}
procedure TVariables.Push(asNameOfVar : String; asValue : String) ;
var
    { Nombre d'élément dans le tableau }
    liCount : Integer ;
begin
    liCount := Length(asNameOfVar) + 1 ;
    Add(asNameOfVar + '[' + IntToStr(liCount) + ']', asValue) ;
end ;

{*****************************************************************************
 * Insert
 * MARTINEAU Emeric
 *
 * Insère un élément dans un tableau
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom de la bariable
 *   - asValue : valeur du tableau
 *   - asIndex : position où il faut insérer l'élément
 *
 *****************************************************************************}
function TVariables.Insert(asNameOfVar : String; aiIndex : Integer; asValue : String) : Boolean ;
var
    { Contient la liste des éléments du tableau }
    liTableau : TStringList ;
    { Varaible temporaire }
    lsTmp : String ;
begin
    Result := False ;

    if isSet(asNameOfVar) and (aiIndex > 0)
    then begin
        liTableau := TStringList.Create ;

        Explode(liTableau, Give(asNameOfVar)) ;

        liTableau.Insert(aiIndex - 1, asValue) ;

        lsTmp := InternalCreateArray(liTableau) ;

        InternalAdd(asNameOfVar, lsTmp) ;

        liTableau.Free ;

        Result := True ;
    end ;
end ;

(*****************************************************************************
 * InternalCreateArray
 * MARTINEAU Emeric
 *
 * Créer un tableau a{} depuis un liste
 *
 * Paramètres d'entrée :
 *   - aoList : Liste de valeur
 *
 * Retour : chaine représentant le tableau
 *****************************************************************************)
function TVariables.InternalCreateArray(aoListe : TStringList) : String ;
var
    { Compteur d'élément du tableau}
    liIndex : Integer ;
begin
    Result := 'a{' ;

    for liIndex := 1 to aoListe.Count do
    begin
        Result := Result + '"' + AddSlashes(aoListe[liIndex - 1]) + '"' ;

        if liIndex <> aoListe.Count
        then begin
            Result := Result + ';' ;
        end ;
    end ;

    Result := Result + '}' ;
end ;

(*****************************************************************************
 * Pop
 * MARTINEAU Emeric
 *
 * Retourne et supprime le dernier élément d'un tableau
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom du tableau à traiter
 *
 * Retour : valeur supprimée
 *****************************************************************************)
function TVariables.Pop(asNameOfVar : String) : string ;
var
    { Tableau à traiter }
    loTableau : TStringList ;
    { Variable temporaire }
    lsTmp : String ;
begin
    Result := '' ;

    if isSet(asNameOfVar)
    then begin
        if isArray(asNameOfVar)
        then begin
            if Length(asNameOfVar) > 0
            then begin
                loTableau := TStringList.Create ;

                Explode(loTableau, Give(asNameOfVar)) ;

                Result := loTableau[loTableau.Count - 1] ;

                loTableau.Delete(loTableau.Count - 1) ;

                lsTmp := InternalCreateArray(loTableau) ;

                InternalAdd(asNameOfVar, lsTmp) ;
                
                loTableau.Free ;
            end ;
        end ;
    end ;
end ;

(*****************************************************************************
 * Exchange
 * MARTINEAU Emeric
 *
 * Echange deux éléments d'un tableau
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom du tableau à traiter
 *
 * Retour : true si traitée
 *****************************************************************************)
function TVariables.Exchange(asNameOfVar : String; aiIndex1, aiIndex2 : Integer) : Boolean ;
var
    { Tableau à traiter }
    loTableau : TStringList ;
    { Varaible temporaire }
    lsTmp : String ;
begin
    Result := False ;

    if IsSet(asNameOfVar) and (aiIndex1 >= 0) and (aiIndex2 >= 0)
    then begin
        if IsArray(asNameOfVar)
        then begin
            loTableau := TStringList.Create ;

            Explode(loTableau, Give(asNameOfVar)) ;
            
            if  (loTableau.Count > 0) and (aiIndex1 < loTableau.Count) and (aiIndex2 < loTableau.Count)
            then begin
                loTableau.Exchange(aiIndex1, aiIndex2) ;

                lsTmp := InternalCreateArray(loTableau) ;

                InternalAdd(asNameOfVar, lsTmp) ;

                Result := True ;
            end ;
            
            loTableau.Free ;
        end ;
    end ;
end ;

(*****************************************************************************
 * Chunk
 * MARTINEAU Emeric
 *
 * Split un tableau en plusieurs tableau
 *
 * Paramètres d'entrée :
 *   - asNameOfVar : nom du tableau à traiter,
 *   - aiSize : taille d'élément maximum
 *
 * Retour : true si traitée
 *****************************************************************************)
function TVariables.Chunk(asNameOfVar : String; aiSize : Integer) : boolean ;
var
    { Tableau à traiter }
    loTableauATraiter : TStringList ;
    { Nouveau tableau }
    loNouveauTableau : TStringList ;
    { Index du tableau à traiter }
    liIndexTableauATraiter : Integer ;
    { Valeur du nouveau tableau }
    lsNouveauTableau : String ;
    { Nombre de tableau créé }
    liNbTab : Integer ;
begin
    Result := False ;

    if isSet(asNameOfVar) and (aiSize > 0)
    then begin
        if isArray(asNameOfVar)
        then begin
            loTableauATraiter := TStringList.Create ;
            loNouveauTableau := TStringList.Create ;

            Explode(loTableauATraiter, Give(asNameOfVar)) ;

            liNbTab := 1 ;

            { On supprime la valeur car on va la recréer ensuite }
            Delete(asNameOfVar) ;

            for liIndexTableauATraiter := 0 to loTableauATraiter.Count - 1 do
            begin
                loNouveauTableau.Add(loTableauATraiter[liIndexTableauATraiter]) ;

                if (loNouveauTableau.Count = aiSize) or
                   ((loNouveauTableau.Count < aiSize) and
                    (loNouveauTableau.Count > 0) and
                    (liIndexTableauATraiter = loTableauATraiter.Count - 1))
                then begin
                    lsNouveauTableau := InternalCreateArray(loNouveauTableau) ;
                    Add(asNameOfVar + '[' + IntToStr(liNbTab) + ']', lsNouveauTableau) ;
                    Inc(liNbTab) ;
                    loNouveauTableau.Clear ;
                end ;
            end ;

            loTableauATraiter.Free ;
            loNouveauTableau.Free ;

            Result := True ;
        end ;
    end ;
end ;

(*****************************************************************************
 * Chunk
 * MARTINEAU Emeric
 *
 * Fusionne des tableau
 *
 * Paramètres d'entrée :
 *   - aoNameOfVar : nom des tableau à traiter,
 *
 * Retour : true si traitée
 *****************************************************************************)
function TVariables.Merge(aoNameOfVars : TStringList) : string ;
var
    { Nouveau tableau }
    loNouveauTableau : TStringList ;
    { Tableau en cours }
    loTableauEnCours : TStringList ;
    { Index tableau à traiter }
    liIndexTableauATraiter : Integer ;
    { Index tableau en cours }
    liIndexTableauEnCours : Integer ;
begin
    Result := '' ;

    loNouveauTableau := TStringList.Create ;
    loTableauEnCours := TStringList.Create ;

    for liIndexTableauATraiter := 0 to aoNameOfVars.Count - 1 do
    begin
        Explode(loTableauEnCours, aoNameOfVars[liIndexTableauATraiter]) ;

        for liIndexTableauEnCours := 0 to loTableauEnCours.Count - 1 do
        begin
            loNouveauTableau.Add(loTableauEnCours[liIndexTableauEnCours]) ;
        end ;

        loTableauEnCours.Clear ;
    end ;

    Result := InternalCreateArray(loNouveauTableau) ;

    loNouveauTableau.Free ;
    loTableauEnCours.Free ;
end ;

(*****************************************************************************
 * CreateArray
 * MARTINEAU Emeric
 *
 * Créer un tableau
 *
 * Paramètres d'entrée :
 *   - aoValue: valeur du tableau
 *
 * Retour : chaine représentant le tableau
 *****************************************************************************)
function TVariables.CreateArray(aoValue : TStringList) : string ;
begin
    Result := InternalCreateArray(aoValue) ;
end ;

(*****************************************************************************
 * ArrayFill
 * MARTINEAU Emeric
 *
 * Créer un tableau
 *
 * Paramètres d'entrée :
 *   - aoValue: valeur de remplissage
 *   - asNameOfVar : nom de la variable tableau
 *
 * Retour : true si tableau traité
 *****************************************************************************)
function TVariables.ArrayFill(asNameOfVar : String; asValue : String) : boolean ;
Var
    { Nombre d'élément du tableau }
    liCount : Integer ;
    { Compteur de boucle du tableau }
    liIndex  : Integer ;
begin
     Result := False ;

     if isArray(asNameOfVar)
     then begin
         liCount := Length(asNameOfVar) ;

         for liIndex := 1 to liCount do
         begin
             Add(asNameOfVar + '[' + IntToStr(liIndex) + ']', asValue) ;
         end ;

         Result := True ;
     end ;
end ;

{*****************************************************************************
 * Trie un TStringList
 * MARTINEAU Emeric
 *
 * Trie un TStringList
 * D'après http://fr.wikipedia.org/wiki/Quicksort et
 * http://www.dsdt.info/tipps/?id=380
 *
 * Paramètres d'entrée :
 *   - aoTab : tableau à trier
 *
 * Paramètre de sortie :
 *   - aoTab : tableau trié
 *****************************************************************************}
procedure TVariables.QuickSort(aoTab : TStringList) ;
    procedure Quick_Sort(aoTab : TStringList; aiLo, aiHi : Integer);
    var
        { Pointeur sur le haut du tableau }
        liLo : Integer ;
        { Pointeur sur le bas du tableau }
        liHi : Integer ;
        { Valeur du milieu du tableau }
        lsMid : string ;
        { Varaible temporaire pour l'échange d'élément }
        lsTmp : string;
    begin
        liLo := aiLo;
        liHi := aiHi ;

        lsMid := aoTab[(liLo + liHi) div 2] ;

        repeat
            while aoTab[liLo] < lsMid do
            begin
                Inc(liLo);
            end ;

            while aoTab[liHi] > lsMid do
            begin
                Dec(liHi);
            end ;

            if liLo <= liHi then
            begin
                lsTmp := aoTab[liLo];
                aoTab[liLo] := aoTab[liHi];
                aoTab[liHi] := lsTmp;
                Inc(liLo);
                Dec(liHi);
            end;
        until liLo > liHi;

        if liHi > aiLo then
        begin
            Quick_Sort(aoTab, aiLo, liHi);
        end ;

        if liLo < aiHi then
        begin
            Quick_Sort(aoTab, liLo, aiHi);
        end ;
    end;
begin
   Quick_Sort(aoTab, 0, aoTab.Count - 1);
end ;

(*****************************************************************************
 * ArrayFill
 * MARTINEAU Emeric
 *
 * Trie un tableau
 *
 * Paramètres d'entrée :
 *   - asTableau : tableau à trier
 *
 * Paramètre de sortie :
 *   - asTableau : tableau trié
 *
 * Retour : true si tableau traité
 *****************************************************************************)
function TVariables.arraySort(var asTableau : String) : boolean ;
var
    { Contenu du tableau }
    aoListOfArray : TStringList ;
begin
    if InternalIsArray(asTableau)
    then begin
        aoListOfArray := TStringList.Create ;

        explode(aoListOfArray, asTableau) ;

        QuickSort(aoListOfArray) ;

        asTableau := InternalCreateArray(aoListOfArray) ;

        aoListOfArray.Free ;

        Result := True ;
    end
    else begin
        Result := False ;
    end ;
end ;

(*****************************************************************************
 * ArraySearch
 * MARTINEAU Emeric
 *
 * Recherche un élément dans un tableau
 *
 * Paramètres d'entrée :
 *   - asTableau : tableau dans lequel il faut chercher,
 *   - asChaineARechercher : chaine à rechercher,
 *   - abCaseSensitive : sensible à la case
 *
 * Retour : position de l'élément
 *****************************************************************************)
function TVariables.ArraySearch(asTableau : string; asChaineARechercher : String; abCaseSensitive : Boolean) : Integer ;
var
    { Compteur de boucle }
    liIndex : Integer ;
    { Indique si la chaine a été trouvée }
    lbResultatTrouve : Boolean ;
    { Elément du tableau }
    loListOfArray : TStringList ;
begin
    Result := 0 ;

    if InternalisArray(asTableau)
    then begin
        loListOfArray := TStringList.Create ;

        explode(loListOfArray, asTableau) ;

        if abCaseSensitive = True
        then begin
            asChaineARechercher := LowerCase(asChaineARechercher) ;
        end ;

        for liIndex := 0 to loListOfArray.Count - 1 do
        begin
            if abCaseSensitive = True
            then begin
                lbResultatTrouve := asChaineARechercher = loListOfArray[liIndex] ;
            end
            else begin
                lbResultatTrouve :=  asChaineARechercher = LowerCase(loListOfArray[liIndex]) ;
            end ;

            if lbResultatTrouve = True
            then begin
                Result := liIndex ;
                break ;
            end ;
        end ;

        loListOfArray.Free ;
    end ;
end ;

{*****************************************************************************
 * Trie un TStringList en sens inverse
 * MARTINEAU Emeric
 *
 * Trie un TStringList
 * D'après http://fr.wikipedia.org/wiki/Quicksort et
 * http://www.dsdt.info/tipps/?id=380
 *
 * Paramètres d'entrée :
 *   - aoTab : tableau à trier
 *
 * Paramètre de sortie :
 *   - aoTab : tableau trié
 *****************************************************************************}
procedure TVariables.QuickRSort(aoTab : TStringList) ;
    procedure Quick_r_Sort(aoTab : TStringList; aiLo, aiHi : Integer);
    var
        { Pointeur sur le haut du tableau }
        liLo : Integer ;
        { Pointeur sur le bas du tableau }
        liHi : Integer ;
        { Valeur du milieu du tableau }
        lsMid : string ;
        { Varaible temporaire pour l'échange d'élément }
        lsTmp : string;
    begin
        liLo := aiLo;
        liHi := aiHi ;

        lsMid := aoTab[(liLo + liHi) div 2] ;

        repeat
            while aoTab[liHi] < lsMid do
            begin
                Dec(liHi) ;
            end ;

            while aoTab[liLo] > lsMid do
            begin
                Inc(liLo) ;
            end ;

            if liHi >= liLo
            then begin
                lsTmp := aoTab[liHi] ;
                aoTab[liHi] := aoTab[liLo] ;
                aoTab[liLo] := lsTmp ;
                Inc(liLo);
                Dec(liHi);
            end ;
        until liLo > liHi ;

        if liHi > aiLo then
        begin
            Quick_r_Sort(aoTab, aiLo, liHi);
        end ;

        if liLo < aiHi then
        begin
            Quick_r_Sort(aoTab, liLo, aiHi);
        end ;
    end;
begin
   Quick_r_Sort(aoTab, 0, aoTab.Count - 1);
end ;

(*****************************************************************************
 * ArraySearch
 * MARTINEAU Emeric
 *
 * Trie un tableau à l'envers
 *
 * Paramètres d'entrée :
 *   - asTableau : tableau dans lequel il faut chercher,
 *
 * Paramètres de sortie :
 *   - asTableau : taleau trié
 *
 * Retour : true si tableau trié
 *****************************************************************************)
function TVariables.ArrayRSort(var asTableau : String) : boolean ;
var
    { Elément du tableau }
    loListOfArray : TStringList ;
begin
    if InternalisArray(asTableau)
    then begin
        loListOfArray := TStringList.Create ;

        explode(loListOfArray, asTableau) ;

        QuickRSort(loListOfArray) ;

        asTableau := InternalCreateArray(loListOfArray) ;

        loListOfArray.Free ;

        Result := True ;
    end
    else begin
        Result := False ;
    end ;
end ;

(*****************************************************************************
 * GiveVarNameByIndex
 * MARTINEAU Emeric
 *
 * Retourne le nom de la variable par l'index
 *
 * Paramètres d'entrée :
 *   - aiIndex : index de la variable
 *
 * Retour : nom de la variable
 *****************************************************************************)
function TVariables.GiveVarNameByIndex(aiIndex : Integer) : string ;
begin
    Result := '' ;

    if aiIndex <> -1
    then begin
        if aiIndex < poVarName.Count
        then begin
            Result := poVarName[aiIndex] ;
        end
    end
end ;

end.
