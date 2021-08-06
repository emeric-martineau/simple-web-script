unit VariableList;
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

uses Windows, Messages, Registry, SysUtils ;

type
  TVariables = class
  private
      VarName : TLiteStrings ;
      VarValue: TLiteStrings ;
  protected
      function getValueOfArray(Text : String; Index : Integer) : string ;  
      procedure setValueOfArray(NameOfVar : String; Value : String; Index : Integer) ;
      procedure explode(var Liste : TLiteStrings; Tab : String) ;
      function InternalGive(NameOfVar : String) : String ;
      procedure InternalAdd(NameOfVar, Value : String) ;
      procedure internalExplodeNumber(Text : String; Liste : TLiteStrings) ;
      function InternalisArray(value : String) : boolean ;
      function InternalCreateArray(Liste : TLiteStrings) : String ;
      procedure QuickSort(Tab : TLiteStrings) ;
  public
      constructor Create ;
      destructor Free ;
      procedure Add(NameOfVar : string; ValueOfVar : string) ;
      function Give(NameOfVar : string) : string;
      function GiveVarNameByIndex(Index : Integer) : string ;
      procedure Delete(NameOfVar : String) ;
      function Count : integer ;
      procedure Clear ;
      function isSet(NameOfVar : string) : boolean ;
      function isArray(NameOfVar : string) : boolean ;
      function length(NameOfVar : string) : Integer ;
      function AddSlashes(text : string) : string ;
      function DeleteSlashes(text : string) : string ;
      procedure Push(NameOfVar : String; Value : String) ;
      function Insert(NameOfVar : String; Index : Integer; Value : String) : Boolean ;
      function Pop(NameOfVar : String) : string ;
      function Exchange(NameOfVar : String; Index1, Index2 : Integer) : Boolean ;
      function Chunk(NameOfVar : String; Size : Integer) : boolean ;
      function Merge(NameOfVars : TLiteStrings) : string ;
      function CreateArray(Value : TLiteStrings) : string ;
      function ArrayFill(VarName : String; Value : String) : boolean ;
      function arraySort(var Tableau : String) : boolean ;
      function arraySearch(Tableau : string; ChaineARechercher : String; CaseSensitive : Boolean) : Integer ;      
  end ;

implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TVariables.Create ;
begin
    inherited Create();

    { Créer l'objet FileName }
    VarName := TLiteStrings.Create ;
    VarValue := TLiteStrings.Create ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TVariables.Free ;
begin
    VarName.Free ;
    VarValue.Free ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TVariables.Add(NameOfVar : string; ValueOfVar : string) ;
Var Index, Index2 : Integer ;
    tmp : string ;
    posTabStart : Integer ;
    len : Integer ;
    i : Integer ;
    Tab : TLiteStrings ;
    Tableau : TLiteStrings ;
begin
    posTabStart := pos('[', NameOfVar) ;
    Tab := TLiteStrings.Create ;

    tmp := '0' ;
    
    if posTabStart <> 0
    then begin
        len := System.length(NameOfVar) ;
        tmp := copy(NameOfVar, posTabStart, len - posTabStart + 1) ;

        internalExplodeNumber(tmp, Tab) ;

        NameOfVar := copy(NameOfVar, 1, posTabStart - 1) ;
    end ;

    if posTabStart = 0
    then
        InternalAdd(NameOfVar, ValueOfVar)
    else if (not isArray(NameOfVar)) and (isSet(NameOfVar))
    then begin
        { Il ne s'agit pas d'un tableau }
        Index := VarName.IndexOf(NameOfVar) ;

        if Index = -1
        then begin
            { On créer un tableau }
            Index := StrToInt(Tab[Tab.Count - 1]) ;
            tmp := 'a{' ;

            for i := 1 to Index-1 do
            begin
                tmp := tmp + '"";' ;
            end ;

            { Variable non présente, on ajoute }
            ValueOfVar := tmp + '"' + AddSlashes(ValueOfVar) + '"}' ;

            if Tab.Count = 1
            then
                InternalAdd(NameOfVar, ValueOfVar)
            else begin
                tmp := '' ;

                { Créer les sous tableaux on par de 2 car le premier niveau à été
                  créé juste au dessus }
                for i := 0 to Tab.Count -2 do
                begin
                    tmp := tmp + '[' + Tab[i] + ']' ;

                    Add(NameOfVar + tmp, '') ;
                end ;

                Add(NameOfVar + tmp + '[' + Tab[Tab.Count - 1] + ']', ValueOfVar)
            end ;
        end
        else begin
            { La variable n'est pas un tableau mais une chaine }
            if posTabStart <> 0
            then begin
                if Tab.Count = 1
                then begin
                    { On copie seulement le premier caractère }
                    Index2 := StrToInt(Tab[0]) ;
                    tmp := VarValue[Index] ;

                    if Index2 <= System.Length(tmp)
                    then begin
                        tmp[Index2] := ValueOfVar[1] ;
                        VarValue[Index] := tmp ;
                    end ;
                end ;
            end
            else begin
                VarValue[Index] := ValueOfVar ;
            end ;
        end ;
    end
    else begin
        { C'est un tableau }

        if Tab.Count = 1
        then begin
            setValueOfArray(NameOfVar, ValueOfVar, StrToInt(Tab[0]))
        end
        else begin
            Tableau := TLiteStrings.Create ;
            Tableau.Add(Give(NameOfVar)) ;

            tmp := '' ;
                        
            for i := 1 to Tab.Count - 1 do
            begin
                tmp := tmp + '[' + Tab[i - 1] + ']' ;
                Tableau.Add(Give(NameOfVar + tmp)) ;
            end ;

            { L'avant dernier tableau est-il un tableau }
            if InternalisArray(Tableau[Tableau.Count - 1])
            then begin
                { Si c'est un tableu, le dernier élément de Tableau c'est le
                  tableau dans lequel on doit affecter la variable. Or si ce
                  n'est pas un tableau, il contient la chaine à modifier.
                  On ajoute dans la valeur à mettre à jour }
                Tableau.Add(ValueOfVar) ;
            end
            else begin
                tmp := Tableau[Tableau.Count - 1] ;
                tmp[StrToInt(Tab[Tab.Count - 1])] := ValueOfVar[1] ;
                Tableau[Tableau.Count - 1] := tmp ;
            end ;

            { Tableau.Count - 1 contient la donnée qui va mettre à jour le
              tableau }
            for i := Tableau.Count - 2 downto 0 do
            begin
                add(NameOfVar, Tableau[i]) ;

                setValueOfArray(NameOfVar, Tableau[i + 1], StrToInt(Tab[i])) ;

                Tableau[i] := InternalGive(NameOfVar) ;
            end ;

            Tableau.Free ;
        end ;
    end ;

    Tab.Free ;
end ;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TVariables.Delete(NameOfVar : String) ;
Var Index : Integer ;
    len : Integer ;
    tmp : String ;
    Liste : TLiteStrings ;
    i : Integer ;
    posTabStart : Integer ;
    Tableau, Tab : TLiteStrings ;
begin
    posTabStart := pos('[', NameOfVar) ;

    tmp := '0' ;

    if posTabStart = 0
    then begin
        Index := VarName.IndexOf(NameOfVar) ;

        if (Index <> -1)
        then begin
            VarName.Delete(Index) ;
            VarValue.Delete(Index) ;
        end ;
    end
    else begin
            Tab := TLiteStrings.Create ;
            Liste := TLiteStrings.Create ;

            if posTabStart <> 0
            then begin
                len := System.length(NameOfVar) ;
                tmp := copy(NameOfVar, posTabStart, len - posTabStart + 1) ;

                internalExplodeNumber(tmp, Tab) ;

                NameOfVar := copy(NameOfVar, 1, posTabStart - 1) ;
            end ;

            Tableau := TLiteStrings.Create ;

            Tableau.Add(Give(NameOfVar)) ;

            tmp := '' ;
                        
            for i := 1 to Tab.Count - 1 do
            begin
                tmp := tmp + '[' + Tab[i - 1] + ']' ;
                Tableau.Add(Give(NameOfVar + tmp)) ;
            end ;

            { L'avant dernier tableau est-il un tableau }
            if InternalisArray(Tableau[Tableau.Count - 1])
            then begin
                // On ne fait rien
            end
            else begin
                { On pointe sur le contenu d'une chaine on supprime dons le
                  niveau inférieur }
                Tableau.Delete(Tableau.Count - 1) ;
            end ;

            { Tableau.Count - 1 contient la donnée qui va mettre à jour le
              tableau }
            for i := Tableau.Count - 1 downto 0 do
            begin
                add(NameOfVar, Tableau[i]) ;

                if i = (Tableau.Count - 1)
                then begin
                    Explode(Liste, Tableau[i]) ;

                    if (StrToInt(Tab[i]) > 0) and (StrToInt(Tab[i]) <= Liste.Count)
                    then begin

                        tmp := InternalCreateArray(Liste) ;

                        InternalAdd(NameOfVar, tmp) ;
                    end ;
                end
                else begin
                    setValueOfArray(NameOfVar, Tableau[i + 1], StrToInt(Tab[i])) ;
                end ;

                Tableau[i] := InternalGive(NameOfVar) ;
            end ;

            Tableau.Free ;
    end ;
end;

{******************************************************************************
 * Donne le nombre de fichiers récents
 ******************************************************************************}
function TVariables.Count : Integer ;
begin
    Result := VarName.Count ;
end ;

{******************************************************************************
 * Donne la fichier correspondant à l'index.
 ******************************************************************************}
function TVariables.Give(NameOfVar : string) : string ;
Var Index, Index2 : Integer ;
    posTabStart : Integer ;
    len : Integer ;
    tmp : String ;
    Tab : TLiteStrings ;
    i : Integer ;
begin
    posTabStart := pos('[', NameOfVar) ;
    Tab := TLiteStrings.Create ;

    tmp := '0' ;

    if posTabStart <> 0
    then begin
        len := System.length(NameOfVar) ;
        tmp := copy(NameOfVar, posTabStart, len - posTabStart + 1) ;

        internalExplodeNumber(tmp, Tab) ;

        NameOfVar := copy(NameOfVar, 1, posTabStart - 1) ;
    end ;

    if posTabStart = 0
    then
        Result := InternalGive(NameOfVar)
    else if not isArray(NameOfVar)
    then begin
        Index := VarName.IndexOf(NameOfVar) ;

        if Index <> -1
        then begin
            if posTabStart = 0
            then begin
                Result := VarValue[index] ;
            end
            else begin
                Index2 := StrToInt(tab[0]) ;
                tmp := VarValue[Index] ;

                if Index2 <= System.Length(tmp)
                then begin
                    Result := VarValue[index][Index2] ;
                end
                else
                     Result := '' ;
            end ;
        end
        else
            Result := '' ;
    end
    else begin
        { Le premier élément est forcément un tableau }
        tmp := InternalGive(NameOfVar) ;
        tmp := getValueOfArray(tmp, StrToInt(Tab[0])) ;

        { Parcous tout les sous tableau }
        for i := 1 to Tab.Count - 1 do
        begin
            if InternalisArray(tmp)
            then
                tmp := getValueOfArray(tmp, StrToInt(Tab[i]))
            else begin
                tmp := tmp[StrToInt(Tab[i])] ;

                { Si ce n'ai pas un tableau on doit arrêter la recherche de
                  tableau }
                break ;
            end ;
        end ;

        Result := Tmp ;
    end ;

    Tab.Free ;
end ;

{******************************************************************************
 * Indique si la variable existe
 ******************************************************************************}
function TVariables.isSet(NameOfVar : string) : boolean ;
Var Index : Integer ;
    Liste, Tab : TLiteStrings ;
    posTabStart : Integer ;
    len : Integer ;
    tmp : String ;
    i : Integer ;
    Value : String ;
begin
    posTabStart := pos('[', NameOfVar) ;
    Result := False ;

    if posTabStart = 0
    then begin
        Index := VarName.IndexOf(NameOfVar) ;
            
        if Index <> -1
        then
            Result := True
        else
            Result := False ;
    end
    else begin
        Tab := TLiteStrings.Create ;
        Liste := TLiteStrings.Create ;

        len := System.length(NameOfVar) ;
        tmp := copy(NameOfVar, posTabStart, len - posTabStart + 1) ;

        internalExplodeNumber(tmp, Tab) ;

        NameOfVar := copy(NameOfVar, 1, posTabStart - 1) ;

        tmp := '' ;

        for i := 0 to Tab.Count - 1 do
        begin
            { On récupère le contenu de la variable (la première est sans
              crochet) }
            Value := Give(NameOfVar + tmp) ;

            Explode(Liste, Value) ;

            if StrToInt(Tab[i]) <= Liste.Count
            then
                Result := True
            else begin
                Result := False ;
                Break ;
            end ;

            { Récupère le tableau suivant }
            tmp := tmp + '[' + Tab[i] + ']' ;
        end ;

        Tab.Free ;

        Liste.Free ;
    end ;

end ;

procedure TVariables.Clear ;
begin
    VarValue.Clear ;
    VarName.Clear ;
end ;

{*******************************************************************************
 * Retourne le nom de la variable par l'index
 ******************************************************************************}
function TVariables.GiveVarNameByIndex(Index : Integer) : string ;
begin
    Result := '' ;

    if Index <> -1
    then begin
        if Index < VarName.Count
        then begin
            Result := VarName[Index] ;
        end
    end
end ;

{*******************************************************************************
 * Indique s'il s'agit d'un tableau
 ******************************************************************************}
function TVariables.isArray(NameOfVar : string) : boolean ;
var value : String ;
begin
    Result := False ;

    if isset(NameOfVar)
    then begin
        if isSet(NameOfVar)
        then begin
            value := Give(NameOfVar) ;
            Result := InternalisArray(value) ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Longueur de la chaine ou du tableau
 ******************************************************************************}
function TVariables.length(NameOfVar : string) : Integer ;
var i : Integer ;
    len : Integer ;
    value : String ;
begin
    if isSet(NameOfVar)
    then begin
        value := Give(NameOfVar) ;
        len := System.Length(value) ;

        if InternalisArray(value)
        then begin
            Result := 0 ;
            i := 3 ;

            while i < len do
            begin
                if value[i] = '"'
                then begin
                    Inc(i) ;
                    Inc(Result) ;

                    while value[i] <> '"' do
                    begin
                        if value[i] = '\'
                        then
                            Inc(i) ;
                        Inc(i) ;
                    end ;
                end ;

                Inc(i) ;
            end ;
        end
        else
            Result := Len ;
    end
    else
        Result := 0 ;
end ;

(*******************************************************************************
 * Remplit une TLiteStrings avec un tableau a{"2222";"555"}
 ******************************************************************************)
procedure TVariables.explode(var Liste : TLiteStrings; Tab : String) ;
var i, len : Integer ;
    tmp : String ;
begin
    i := 3 ;
    len := System.Length(Tab) ;

    while i < len do
    begin
        if Tab[i] = '"'
        then begin
            tmp := '' ;
            Inc(i) ;

            while Tab[i] <> '"' do
            begin
                if Tab[i] = '\'
                then begin
                    tmp := tmp + Tab[i] ;
                    Inc(i) ;
                end ;
                tmp := tmp + Tab[i] ;
                Inc(i) ;
            end ;

            Liste.Add(DeleteSlashes(tmp)) ;
        end ;

        Inc(i) ;
    end ;
end ;

{*******************************************************************************
 * Remplit un tableau depuis un index
 ******************************************************************************}
procedure TVariables.setValueOfArray(NameOfVar : String; Value : String; Index : Integer) ;
var tmp : string ;
    i : Integer ;
    len : Integer ;
    ValueOfVar : String ;
    ListOfArray : TLiteStrings ;
begin
    ListOfArray := TLiteStrings.Create ;
    
    if isArray(NameOfVar)
    then begin
        Len := Length(NameOfVar) ;

        if Index > Len
        then begin
            tmp := InternalGive(NameOfVar) ;

            explode(ListOfArray, tmp) ;

            for i := Len to Index - 2 do
            begin
                ListOfArray.Add('') ;
            end ;

            ListOfArray.Add(Value) ;

            tmp := InternalCreateArray(ListOfArray) ;

            InternalAdd(NameOfVar, tmp) ;
        end
        else begin
            { Explose le tableau }
            ValueOfVar := InternalGive(NameOfVar) ;

            explode(ListOfArray, ValueOfVar) ;

            ListOfArray[Index - 1] := Value ;

            tmp := InternalCreateArray(ListOfArray) ;

            InternalAdd(NameOfVar, tmp) ;
        end ;
    end
    else begin
        for i := 1 to Index - 1 do
        begin
            ListOfArray.Add('') ;
        end ;

        ListOfArray.Add(Value) ;

        tmp := InternalCreateArray(ListOfArray) ;

        InternalAdd(NameOfVar, tmp) ;
    end ;

    ListOfArray.Free ;
end ;

{*******************************************************************************
 * Remplit un tableau depuis un index
 ******************************************************************************}
function TVariables.getValueOfArray(Text : String; Index : Integer) : string ;
var Liste : TLiteStrings ;
begin
    Liste := TLiteStrings.Create ;

    Explode(Liste, Text) ;

    if Index > Liste.Count
    then
        Result := ''
    else
        Result := Liste[Index-1] ;

    Liste.Free ;
end ;

{*******************************************************************************
 * Ajoute des \ devant \ et "
 ******************************************************************************}
function TVariables.AddSlashes(text : string) : string ;
var i, nb : Integer ;
begin
    nb := System.Length(text) ;
    Result := '' ;

    for i := 1 to nb do
    begin
         if (Text[i] = '\') or (Text[i] = '"')
         then
             Result := Result + '\' ;

         Result := Result + Text[i] ;
    end ;
end ;

{*******************************************************************************
 * Supprime les \
 ******************************************************************************}
function TVariables.DeleteSlashes(text : string) : string ;
var i, nb : Integer ;
begin
    nb := System.Length(text) ;
    Result := '' ;

    i := 1 ;
    while i <= nb do
    begin
        if Text[i] = '\'
        then
            Inc(i) ;

        Result := Result + Text[i] ;
        Inc(i) ;
    end ;
end ;

function TVariables.InternalGive(NameOfVar : String) : String ;
var Index : Integer ;
begin
    Index := VarName.IndexOf(NameOfVar) ;

    if Index <> -1
    then
        Result := VarValue[Index]
    else
        Result := '' ;
end ;

procedure TVariables.InternalAdd(NameOfVar, Value : String) ;
var Index : Integer ;
begin
    NameOfVar := LowerCase(NameOfVar) ;
    
    Index := VarName.IndexOf(NameOfVar) ;

    if Index = - 1
    then begin
        VarName.Add(NameOfVar) ;
        VarValue.Add(Value) ;
    end
    else begin
        VarValue[Index] := Value ;
    end ;
end ;

{*******************************************************************************
 * Convertit une chaine "[1][1]" en liste
 ******************************************************************************}
procedure TVariables.internalExplodeNumber(Text : String; Liste : TLiteStrings) ;
var i : Integer ;
    tmp : String ;
begin
    tmp := '' ;

    for i := 1 to System.Length(Text) do
    begin
        if Text[i] = ']'
        then
            Liste.Add(tmp)
        else if Text[i] = '['
        then
            tmp := ''
        else
            tmp := tmp + Text[i] ;
    end ;
end ;

function TVariables.InternalisArray(value : String) : boolean ;
Var len : Integer ;
begin
    Result := False ;

    len := System.length(value) ;

    if len > 2
    then
        if (value[1] = 'a') and (value[2] = '{') and (value[len] = '}')
        then
            Result := True ;
end ;

{*******************************************************************************
 * Ajoute un élément à la fin du tableau
 ******************************************************************************}
procedure TVariables.Push(NameOfVar : String; Value : String) ;
var nb : Integer ;
begin
    nb := Length(NameOfVar) + 1 ;
    Add(NameOfVar + '[' + IntToStr(nb) + ']', Value) ;
end ;

{*******************************************************************************
 * Insère un élément dans un tableau
 ******************************************************************************}
function TVariables.Insert(NameOfVar : String; Index : Integer; Value : String) : Boolean ;
var Liste : TLiteStrings ;
    tmp : String ;
begin
    Result := False ;

    if isSet(NameOfVar) and (Index > 0)
    then begin
        Liste := TLiteStrings.Create ;

        Explode(Liste, Give(NameOfVar)) ;

        Liste.Insert(Index - 1, Value) ;

        tmp := InternalCreateArray(Liste) ;

        InternalAdd(NameOfVar, tmp) ;

        Liste.Free ;

        Result := True ;
    end ;
end ;

{*******************************************************************************
 * Créer un tableau
 ******************************************************************************}
function TVariables.InternalCreateArray(Liste : TLiteStrings) : String ;
var i : Integer ;
begin
    Result := 'a{' ;

    for i := 1 to Liste.Count do
    begin
        Result := Result + '"' + AddSlashes(Liste[i - 1]) + '"' ;

        if i <> Liste.Count
        then
            Result := Result + ';' ;
    end ;

    Result := Result + '}' ;
end ;

{*******************************************************************************
 * Retourne et supprime le dernier élément d'un tableau
 ******************************************************************************}
function TVariables.Pop(NameOfVar : String) : string ;
var Liste : TLiteStrings ;
    tmp : String ;
begin
    Result := '' ;

    if isSet(NameOfVar)
    then begin
        if isArray(NameOfVar)
        then begin
            if Length(NameOfVar) > 0
            then begin
                Liste := TLiteStrings.Create ;

                Explode(Liste, Give(NameOfVar)) ;

                Result := Liste[Liste.Count - 1] ;

                Liste.Delete(Liste.Count - 1) ;

                tmp := InternalCreateArray(Liste) ;

                InternalAdd(NameOfVar, tmp) ;
                
                Liste.Free ;
            end ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Insère un élément dans un tableau
 ******************************************************************************}
function TVariables.Exchange(NameOfVar : String; Index1, Index2 : Integer) : Boolean ;
var Liste : TLiteStrings ;
    tmp : String ;
begin
    Result := False ;

    if isSet(NameOfVar) and (Index1 > 0) and (Index2 > 0)
    then begin
        if isArray(NameOfVar)
        then begin
            if Length(NameOfVar) > 0
            then begin
                Liste := TLiteStrings.Create ;

                Explode(Liste, Give(NameOfVar)) ;

                Liste.Exchange(Index1, Index2) ;

                tmp := InternalCreateArray(Liste) ;

                InternalAdd(NameOfVar, tmp) ;

                Liste.Free ;

                Result := True ;
            end ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Split un tableau en plusieurs tableau
 ******************************************************************************}
function TVariables.Chunk(NameOfVar : String; Size : Integer) : boolean ;
var Liste : TLiteStrings ;
    Tableau : TLiteStrings ;
    i : Integer ;
    tmp : String ;
    nbTab : Integer ;
begin
    Result := False ;

    if isSet(NameOfVar) and (Size > 0)
    then begin
        if isArray(NameOfVar)
        then begin
            Liste := TLiteStrings.Create ;
            Tableau := TLiteStrings.Create ;

            Explode(Liste, Give(NameOfVar)) ;

            nbTab := 1 ;

            { On supprime la valeur car on va la recréer ensuite }
            Delete(NameOfVar) ;

            for i := 0 to Liste.Count - 1 do
            begin
                Tableau.Add(Liste[i]) ;

                if (Tableau.Count = Size) or
                   ((Tableau.Count < Size) and (Tableau.Count > 0) and (i = Liste.Count - 1))
                then begin
                    tmp := InternalCreateArray(Tableau) ;
                    Add(NameOfVar + '[' + IntToStr(nbTab) + ']', tmp) ;
                    Inc(nbTab) ;
                    Tableau.Clear ;
                end ;
            end ;

            Liste.Free ;
            Tableau.Free ;

            Result := True ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Fusion 2 tableau
 ******************************************************************************}
function TVariables.Merge(NameOfVars : TLiteStrings) : string ;
var Liste : TLiteStrings ;
    Liste2 : TLiteStrings ;
    i, j : Integer ;
begin
    Result := '' ;

    Liste := TLiteStrings.Create ;
    Liste2 := TLiteStrings.Create ;

    for j := 0 to NameOfVars.Count - 1 do
    begin
        Explode(Liste2, NameOfVars[j]) ;

        for i := 0 to Liste2.Count - 1 do
        begin
            Liste.Add(Liste2[i]) ;
        end ;

        Liste2.Clear ;
    end ;

    Result := InternalCreateArray(Liste) ;

    Liste.Free ;
    Liste2.Free ;

end ;

{*******************************************************************************
 * Créer un tableau
 ******************************************************************************}
function TVariables.CreateArray(Value : TLiteStrings) : string ;
var tmp : string ;
    i : Integer ;
begin
    tmp := 'a{' ;

    for i := 0 to Value.Count - 1 do
    begin
        tmp := tmp + '"' + Value[i] + '"' ;

        if i <> (Value.Count - 1)
        then
            tmp := tmp + ';' ;
    end ;

    Result := tmp + '}' ;
end ;

{*******************************************************************************
 * Créer un tableau
 ******************************************************************************}
function TVariables.ArrayFill(VarName : String; Value : String) : boolean ;
Var nb : Integer ;
    i  : Integer ;
begin
     Result := False ;

     if isArray(VarName)
     then begin
         nb := Length(VarName) ;

         for i := 1 to nb do
         begin
             Add(VarName + '[' + IntToStr(i) + ']', Value) ;
         end ;

         Result := True ;
     end ;
end ;

{*******************************************************************************
 * Trie un TLiteStrings
 * D'après http://fr.wikipedia.org/wiki/Quicksort
 ******************************************************************************}
procedure TVariables.QuickSort(Tab : TLiteStrings) ;
    procedure Quick_Sort(Tab : TLiteStrings; iLo, iHi : Integer);
    var
       Lo, Hi : Integer ;
       Mid, Tmp : string;
    begin
        Lo := iLo;
        Hi := iHi ;

        Mid := Tab[(Lo + Hi) div 2] ;

        repeat
            while Tab[Lo] < Mid do
                Inc(Lo);

            while Tab[Hi] > Mid do
                Dec(Hi);

            if Lo <= Hi then
            begin
                Tmp := Tab[Lo];
                Tab[Lo] := Tab[Hi];
                Tab[Hi] := Tmp;
                Inc(Lo);
                Dec(Hi);
            end;
        until Lo > Hi;

        if Hi > iLo then
            Quick_Sort(Tab, iLo, Hi);

        if Lo < iHi then
            Quick_Sort(Tab, Lo, iHi);
    end;
begin
   Quick_Sort(Tab, 0, Tab.Count - 1);
end ;

{*******************************************************************************
 * Trie un tableau
 ******************************************************************************}
function TVariables.arraySort(var Tableau : String) : boolean ;
var ListOfArray : TLiteStrings ;
begin
    if InternalisArray(Tableau)
    then begin
        ListOfArray := TLiteStrings.Create ;

        explode(ListOfArray, Tableau) ;

        QuickSort(ListOfArray) ;

        Tableau := InternalCreateArray(ListOfArray) ;

        ListOfArray.Free ;

        Result := True ;
    end
    else
        Result := False ;
end ;

{*******************************************************************************
 * Recherche un élément dans un tableau
 ******************************************************************************}
function TVariables.arraySearch(Tableau : string; ChaineARechercher : String; CaseSensitive : Boolean) : Integer ;
var i, nb : Integer ;
    Resultat : Boolean ;
    ListOfArray : TLiteStrings ;
begin
    Result := 0 ;

    if InternalisArray(Tableau)
    then begin
        ListOfArray := TLiteStrings.Create ;

        explode(ListOfArray, Tableau) ;

        for i := 0 to ListOfArray.Count - 1 do
        begin
            if CaseSensitive
            then
                Resultat := ChaineARechercher = ListOfArray[i]
            else
                Resultat := LowerCase(ChaineARechercher) = LowerCase(ListOfArray[i]) ;

            if Resultat
            then begin
                { +1 car nos tableau commence à 1 }
                Result := i + 1 ;
                break ;
            end ;
        end ;

        ListOfArray.Free ;
    end ;
end ;

end.
