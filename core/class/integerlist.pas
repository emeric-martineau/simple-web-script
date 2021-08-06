unit IntegerList;
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
 * Class to manage label. It's just 2 TIntegerList management.
 ******************************************************************************}

interface

uses SysUtils ;

type
  TIntegerList = class
  private
  protected
      IntegerArray : array of Integer ;
      Capacity : Integer ;
      { Utilise une variable pour être plus performant }
      Nb : Integer ;
      function Get(Index : Integer) : Integer ;
      procedure Put(Index : Integer; IntValue : Integer) ;
  public
      procedure Add(IntValue : Integer) ;
      procedure Clear ;
      function Count : integer ;
      constructor Create ;
      procedure Delete(Index : Integer) ;
      //procedure Exchange(Index1, Index2 : Integer) ;
      destructor Free ;
      //function IndexOf(IntValue : Integer) : Integer ; overload ;
      //function IndexOf(IntValue : Integer; Start : Integer) : Integer ; overload ;
      procedure Insert(Index : Integer; IntValue : Integer) ;
      property Integers[Index: Integer]: Integer read Get write Put; default;
  end ;

Const Range : Integer = 10 ;

implementation

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TIntegerList.Create ;
begin
    inherited Create();

    Capacity := 0 ;
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TIntegerList.Free ;
begin
    Clear ;
end ;

{******************************************************************************
 * Ajouter une variable
 ******************************************************************************}
procedure TIntegerList.Add(IntValue : Integer) ;
begin
    try
        if Capacity = Nb
        then begin
            SetLength(IntegerArray, Capacity + Range) ;

            Inc(Capacity, Range) ;
        end ;


        IntegerArray[Nb] := IntValue ;
        
        { On incrément après comme ça s'il y a une erreur, le count ne sera pas
          affecté }
        Inc(Nb) ;
    finally
    end ;
end ;

{******************************************************************************
 * Supprimer l'entrée correspondant dans le tableau.
 ******************************************************************************}
procedure TIntegerList.Delete(Index : Integer) ;
var i : Integer ;
begin
    { -2 car la dernière cas va être supprimée }
    for i := Index to Nb - 2 do
    begin
        IntegerArray[i] := IntegerArray[i + 1] ;
    end ;

    Dec(Nb) ;

    if (Capacity - Nb) > Range
    then begin
        SetLength(IntegerArray, Capacity - Range) ;

        Dec(Capacity, Range) ;
    end ;
end;

{******************************************************************************
 * Donne le nombre de fichiers récents
 ******************************************************************************}
function TIntegerList.Count : Integer ;
begin
    Result := Nb ;
end ;

{******************************************************************************
 * Efface la liste
 ******************************************************************************}
procedure TIntegerList.Clear ;
begin
    Nb := 0 ;
    SetLength(IntegerArray, 0) ;
end ;

{******************************************************************************
 * Retourne la valeur
 ******************************************************************************}
function TIntegerList.Get(Index : Integer) : Integer ;
begin
    Result := IntegerArray[Index] ;
end ;

{******************************************************************************
 * Affecte la valeur
 ******************************************************************************}
procedure TIntegerList.Put(Index : Integer; IntValue : Integer) ;
begin
    IntegerArray[Index] := IntValue ;
end ;

{******************************************************************************
 * Retourne la position du IntValue dans le tableau
 ******************************************************************************}
 {
function TIntegerList.IndexOf(IntValue : Integer) : Integer ;
var i : Integer ;
begin
    Result := -1 ;

    for i := Low(IntegerArray) to High(IntegerArray) do
    begin
        if IntValue = IntegerArray[i]
        then begin
            Result := i ;
            
            break ;
        end ;
    end ;
end ;
  }
{******************************************************************************
 * Retourne la position du IntValue dans le tableau
 ******************************************************************************}
 {
function TIntegerList.IndexOf(IntValue : Integer; Start : Integer) : Integer ;
var i : Integer ;
begin
    Result := -1 ;

    for i := Start to High(IntegerArray) do
    begin
        if IntValue = IntegerArray[i]
        then begin
            Result := i ;
            
            break ;
        end ;
    end ;
end ;
}
{******************************************************************************
 * Insert un élément
 ******************************************************************************}
procedure TIntegerList.Insert(Index : Integer; IntValue : Integer) ;
var i : Integer ;
begin
    try
        if Capacity = Nb
        then begin
            SetLength(IntegerArray, Capacity + Range) ;

            { On l'incrémente après comme ça en cas de problème il n'est pas
              incrémenté }
            Inc(Capacity, Range) ;
        end ;

        for i := Nb downto (Index + 1) do
        begin
            IntegerArray[i] := IntegerArray[i - 1] ;
        end ;

        IntegerArray[Index] := IntValue ;

        { On incrément après comme ça s'il y a une erreur, le count ne sera pas
          affecté }
        Inc(Nb) ;
    finally
    end ;
end ;

{******************************************************************************
 * Echange deux éléments
 ******************************************************************************}
 {
procedure TIntegerList.Exchange(Index1, Index2 : Integer) ;
var tmp : Integer ;
begin
    tmp := IntegerArray[Index1] ;
    IntegerArray[Index1] := IntegerArray[Index2] ;
    IntegerArray[Index2] := tmp ;
end ;
}
end.
