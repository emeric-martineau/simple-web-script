unit GetPostCookieFileData;
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
 * Class to Get, Post, Cookie, File data
 ******************************************************************************}
{$I config.inc}

interface

uses DoubleStrings, Classes, SysUtils
     {$IFNDEF COMMANDLINE}
     , UnitOS
     {$ENDIF}
     ;

type
  TGetPostCookieFileData = class
  private
      GetString : String ;
      {$IFNDEF COMMANDLINE}
      Boundary : String ;
      longueur : Integer ;
      MaxPostSize : Integer ;
      uploadSize : Integer ;
      {$ENDIF}
      TmpFilesName : TStrings ;
  protected
      procedure ReadCookieData ;
      procedure ReadGetData ;
      {$IFNDEF COMMANDLINE}
      procedure ReadPostData ;
      procedure GetMultipartFormData ;
      function GetName(Text : String) : String ;
      procedure ReadLine(var F : File; var Line : String) ;
      {$ENDIF}
      procedure ReadDataEnv(pTabString : String; var Tab : TDoubleStrings; Separateur : String) ;
      procedure internalExplodeNumber(Text : String; Liste : TStringList) ;
      procedure SetVal(Tab : TDoubleStrings; Nom : String; Valeur : String) ;
  public
      GetData : TDoubleStrings ;
      PostData : TDoubleStrings ;
      CookieData : TDoubleStrings ;
      FileData : TDoubleStrings ;
      constructor Create(LocalMaxPostSize : Integer; MaxSizeFile : Integer) ;
      destructor Free ;
      function getCookie(Name : String) : String ;
      function getGet(Name : String) : String ;
      function getPost(Name : String) : String ;
      function getFile(Name : String) : String ;      
      {$IFNDEF COMMANDLINE}
      function getFileNameOfScript : String ;
      {$ENDIF}
  end ;

implementation

uses Functions, Variable, UnitMessages, Code ;

{******************************************************************************
 * Consructeur
 ******************************************************************************}
constructor TGetPostCookieFileData.Create(LocalMaxPostSize : Integer; MaxSizeFile : Integer) ;
begin
    inherited Create();

    { Créer l'objet FileName }
    GetData := TDoubleStrings.Create ;
    PostData := TDoubleStrings.Create ;
    CookieData := TDoubleStrings.Create ;
    FileData := TDoubleStrings.Create ;
    TmpFilesName := TStringList.Create ;
    
    ReadCookieData ;
    ReadGetData ;
    {$IFNDEF COMMANDLINE}
    uploadSize := MaxSizeFile ;
    MaxPostSize := LocalMaxPostSize ;
    ReadPostData ;
    {$ENDIF}
end ;

{******************************************************************************
 * Destructeur
 ******************************************************************************}
destructor TGetPostCookieFileData.Free ;
var i : Integer ;
begin
    GetData.Free ;
    PostData.Free ;
    CookieData.Free ;
    FileData.Free ;

    for i := 0 to TmpFilesName.Count - 1 do
    begin
        //DeleteFile(TmpFilesName[i]) ;
    end ;

    TmpFilesName.Free ;
end ;

{******************************************************************************
 * Retourne le cookie
 ******************************************************************************}
function TGetPostCookieFileData.getCookie(Name : String) : String ;
begin
    Result := CookieData.Give(Name) ;
end ;

{******************************************************************************
 * Retourne la variable get
 ******************************************************************************}
function TGetPostCookieFileData.getGet(Name : String) : String ;
begin
    Result := GetData.Give(Name) ;
end ;

{******************************************************************************
 * Retourne la variable post
 ******************************************************************************}
function TGetPostCookieFileData.getPost(Name : String) : String ;
begin
    Result := PostData.Give(Name) ;
end ;

{******************************************************************************
 * Retourne le cookie
 ******************************************************************************}
function TGetPostCookieFileData.getFile(Name : String) : String ;
begin
    Result := FileData.Give(Name) ;
end ;

{$IFNDEF COMMANDLINE}
{******************************************************************************
 * Retourn la ligne qui a été lu pour les cookies
 ******************************************************************************}
function TGetPostCookieFileData.getFileNameOfScript : String ;
var i : Integer ;
begin
   Result := '' ;

   for i := 1 to Length(GetString) do
   begin
       if GetString[i] = '&'
       then
           break
       else if GetString[i] = '='
       then begin
           Result := '' ;
           break ;
       end ;

       Result := Result + GetString[i] ;
   end ;
end ;
{$ENDIF}

{******************************************************************************
 * Lit les donner des cookies
 ******************************************************************************}
procedure TGetPostCookieFileData.ReadCookieData ;
begin
    ReadDataEnv(GetEnvironmentVariable('HTTP_COOKIE'), CookieData, '; ') ;
end ;

{******************************************************************************
 * Lit les donner des cookies
 ******************************************************************************}
procedure TGetPostCookieFileData.ReadGetData ;
{$IFNDEF COMMANDLINE}
var tmp, tmp2 : String ;
    len : Integer ;
{$ENDIF}
begin
    GetString := GetEnvironmentVariable('QUERY_STRING') ;

    {$IFNDEF COMMANDLINE}
    tmp2 := getFileNameOfScript ;
    len := length(tmp2) ;
    tmp := Copy(GetString, len + 2, length(GetString) - len) ;
    ReadDataEnv(tmp, GetData, '&') ;
    {$ELSE}
    ReadDataEnv(GetString, GetData, '&') ;
    {$ENDIF}
end ;

{******************************************************************************
 * Lit les donner des post
 ******************************************************************************}
{$IFNDEF COMMANDLINE}
procedure TGetPostCookieFileData.ReadPostData ;
var tmp : String ;
    i : Integer ;
begin
    if UpperCase(GetEnvironmentVariable('REQUEST_METHOD')) = 'POST'
    then begin
        tmp := LowerCase(GetEnvironmentVariable('CONTENT_TYPE')) ;

        if tmp = 'application/x-www-form-urlencoded'
        then begin
            while not eof do
            begin
                readln(tmp) ;
            end ;

            if Length(tmp) < MaxPostSize
            then
                ReadDataEnv(tmp, PostData, '&')
            else
                WarningMsg(sPostDataTooBig) ;
        end
        else if pos('multipart/form-data;', tmp) <> 0
        then begin
            i := pos('boundary=', tmp) ;

            if i <> 0
            then begin
                { 9 = 'boundary=' }
                Boundary := '--' + Copy(tmp, i + 9, length(tmp) - i - 9 + 1) ;
                longueur := MyStrToInt(GetEnvironmentVariable('CONTENT_LENGTH')) ;

                GetMultipartFormData ;
            end ;
        end ;
    end ;
end ;
{$ENDIF}

{******************************************************************************
 * Lit les donner depuis une variable d'environnement
 ******************************************************************************}
procedure TGetPostCookieFileData.ReadDataEnv(pTabString : String; var Tab : TDoubleStrings; Separateur : String) ;
var Liste, Element : TStringList ;
    i : Integer ;
    Nom, valeur : String ;
begin
   if pTabString <> ''
   then begin
       Liste := TStringList.Create ;
       Element := TStringList.Create ;

       Explode(pTabString, Liste, Separateur) ;

       for i := 0 to Liste.Count - 1 do
       begin
           Explode(Liste[i], Element, '=') ;
           if Element.Count > 0
           then begin
               Nom := UrlDecode(Element[0]) ;

               Valeur := '' ;

               if Element.Count > 1
               then
                   Valeur := UrlDecode(Element[1]) ;

               SetVal(Tab, Nom, Valeur) ;
           end ;
       end ;

       Liste.Free ;
       Element.Free ;
   end ;
end ;

{*******************************************************************************
 * Convertit une chaine "[1][1]" en liste
 ******************************************************************************}
procedure TGetPostCookieFileData.internalExplodeNumber(Text : String; Liste : TStringList) ;
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

{*******************************************************************************
 * Ajoute un élément à une variable si c'est un tableau
 ******************************************************************************}
procedure TGetPostCookieFileData.SetVal(Tab : TDoubleStrings; Nom : String; Valeur : String) ;
var
    tmpName, tmpTab : String ;
    index : Integer ;
    Tableau : TStringList ;
    LocalVariable : TVariables ;
    j : Integer ;
begin
    { Est-ce un variable tabeau ? }
    index := pos('[', Nom) ;
    if index <> 0
    then begin
        Tableau := TStringList.Create ;
        LocalVariable := TVariables.Create ;

        tmpName := copy(Nom, 1, index-1) ;
        tmpTab := copy(Nom, index, length(Nom) - index + 1) ;
        Nom := tmpName ;

        Tableau.Clear ;

        internalExplodeNumber(tmpTab, Tableau) ;

        if Tab.isSet(Nom)
        then begin
            LocalVariable.Add(Nom, Tab.Give(Nom)) ;
        end ;

        for j := 0 to Tableau.Count - 1 do
        begin
           if not isInteger(Tableau[j])
           then begin
               tmpTab := IntToStr(LocalVariable.Length(tmpName) + 1) ;
               Tableau[j] := tmpTab ;
           end
           else begin
               if MyStrToInt(Tableau[j]) > 0
               then
                   tmpTab := Tableau[j]
               else begin
                   tmpTab := IntToStr(LocalVariable.Length(tmpName) + 1) ;
                   Tableau[j] := tmpTab ;
               end ;
           end ;

           tmpName := tmpName + '[' + tmpTab + ']' ;
        end ;

        { On créer la variable }
        LocalVariable.Add(tmpName, AddSlashes(Valeur)) ;

        Valeur := LocalVariable.Give(Nom) ;

       Tableau.Free ;
       LocalVariable.Free ;
    end
    else begin
       Valeur := AddSlashes(Valeur) ;
    end ;

    Tab.Add(Nom, Valeur) ;
end ;

{$IFNDEF COMMANDLINE}
{*******************************************************************************
 * Récupère le nom dans une ligne
 * Content-Disposition: form-data; name="textfield"
 ******************************************************************************}
function TGetPostCookieFileData.GetName(Text : String) : String ;
var i : Integer ;
    len : Integer ;
begin
    Result := '' ;
    i := pos('name="', Text) ;
    len := Length(Text) ;

    if i > 0
    then begin
        Inc(i, 6) ;

        while i <= len do
        begin
            if Text[i] = '"'
            then
                break
            else if Text[i] = '\'
            then
                Inc(i) ;

            Result := Result + Text[i] ;
            Inc(i) ;
        end ;
    end ;
end ;

{*******************************************************************************
 * Récupère le donnée d'un formulaire transmit pas multipart/form-data
 ******************************************************************************}
procedure TGetPostCookieFileData.GetMultipartFormData ;
var i, j : Integer ;
    line : String ;
    Name : String ;
    Lignes : TStringList ;
    Buffer : String ;
    C : char ;
    F : File ;
    CountRead : Integer ;
    Position : Integer ;
    FileOut : File ;
    CountWrite : Integer ;
    posBoundary : Integer ;
    lenOfBuffer : Integer ;
    tmpFileName : String ;
    tmpBoundary : String ;
    SkipData : Boolean ;
    SizeOfFile : Integer ;
    SizeOfPostData : Integer ;
    FileName : String ;
    LocalVariable : TVariables ;
    tmpVarName : String ;
    ContentType : String ;
begin
    i := 1 ;
    Lignes := TStringList.Create ;
    tmpBoundary := OsEOL + Boundary ;
    LocalVariable := TVariables.Create ;
    SizeOfPostData := 0 ;
    
    try
        { Ouvre l'entrée standar en lecture seul }
        FileMode := fmOpenRead ;
        AssignFile(F, '') ;
        Reset(F, 1) ;
        Seek(F, 0) ;

        while i <= longueur do
        begin
            { A-t-on atteind la taille maximal des données par post ? }
            if MaxPostSize >= 0
            then begin
                if SizeOfPostData >= MaxPostSize
                then
                    break ;
            end ;

            ReadLine(F, line) ;

            if (line = '--') or (line = (Boundary + '--'))
            then
                break ;

            Inc(i, Length(line)) ;
            Inc(SizeOfPostData, Length(line)) ;

            { (line = Boundary) car la première ligne est égale à boundary }
            if (line = Boundary) or (pos('Content-Disposition: form-data;', line) <> 0)
            then begin

                if (line = Boundary)
                then begin
                    ReadLine(F, line) ;
                    Inc(i, Length(line)) ;
                end ;
                
                if pos('Content-Disposition: form-data;', line) <> 0
                then begin
                    Position := pos('filename="', line) ;

                    if Position <> 0
                    then begin
                        FileName := Copy(line, Position + 10, Length(line) - (Position + 10)) ;

                        if FileName <> ''
                        then begin
                            Name := GetName(line) ;

                            { Content-Type }
                            readline(F, line) ;

                            Position := pos('Content-Type: ', line) ;
                            ContentType := Copy(line, Position + 14, Length(line) - (Position + 13)) ;

                            tmpVarName := UniqId ;

                            { Doit-on ne pas enregistrer les données }
                            if fileUpload
                            then
                                SkipData := False
                            else
                                SkipData := True ;

                            SizeOfFile := 0 ;

                            { Ligne vide après content-type }
                            readline(F, line) ;

                            {$I+}
                            FileMode := fmOpenWrite ;
                            tmpFileName := OsGetTmpFileName ;

                            TmpFilesName.Add(tmpFileName) ;

                            AssignFile(FileOut, tmpFileName) ;
                            Rewrite(FileOut, SizeOf(C)) ;

                            if IOResult = 0
                            then begin
                                Buffer := '' ;
                                posBoundary := 1 ;

                                while i <= longueur do
                                begin
                                    if uploadSize >= 0
                                    then begin
                                        if SizeOfFile > uploadSize
                                        then
                                            SkipData := True ;
                                    end ;

                                    BlockRead(F, C, SizeOf(C), countRead) ;
                                    Inc(i) ;

                                    if countRead <> 1
                                    then
                                        break ;

                                    if C <> tmpBoundary[posBoundary]
                                    then begin
                                        PosBoundary := 1 ;

                                        lenOfBuffer := Length(Buffer) ;

                                        if lenOfBuffer > 0
                                        then begin
                                            for j := 1 to lenOfBuffer do
                                            begin
                                                if not SkipData
                                                then begin
                                                    BlockWrite(FileOut, Buffer[j], SizeOf(C), CountWrite) ;

                                                    if CountWrite <> 1
                                                    then
                                                        break ;
                                                end ;

                                                Inc(SizeOfFile) ;
                                            end ;

                                            Buffer := '' ;
                                        end ;


                                        if C <> tmpBoundary[posBoundary]
                                        then begin
                                            if not SkipData
                                            then begin
                                                BlockWrite(FileOut, C, SizeOf(C), CountWrite) ;

                                                if CountWrite <> 1
                                                then
                                                    break ;
                                            end ;

                                            Inc(SizeOfFile) ;
                                        end
                                        else begin
                                            Buffer := Buffer + C ;

                                            { Il faut absolument incrémenter PosBoundary
                                              après }
                                            Inc(PosBoundary) ;
                                        end ;
                                    end
                                    else begin
                                        Buffer := Buffer + C ;

                                        if posBoundary = length(tmpBoundary)
                                        then begin
                                            break ;
                                        end ;

                                        { Il faut absolument incrémenter PosBoundary
                                          après }
                                        Inc(PosBoundary) ;
                                    end ;
                                end ;

                                CloseFile(FileOut) ;

                                LocalVariable.Add(tmpVarName + '[1]', OSOsPathToSwsPath(tmpFileName));
                                LocalVariable.Add(tmpVarName + '[2]', ContentType);
                                LocalVariable.Add(tmpVarName + '[3]', FileName);
                                LocalVariable.Add(tmpVarName + '[4]', IntToStr(SizeOfFile));

                                FileData.Add(Name, LocalVariable.Give(tmpVarName)) ;

                                LocalVariable.Delete(tmpVarName) ;
                                {$I-}
                            end ;
                        end ;
                    end
                    else begin
                        { Recopie le nom }
                        Name := GetName(line) ;

                        { En dessous, il y a une ligne vide }
                        ReadLine(F, line) ;

                        { Lit une première fois car si vide on à directement Boundary }
                        ReadLine(F, line) ;

                        { Lit toutes les lignes jusqu'à Boundary }
                        while (line <> Boundary) and (i < longueur) and (line <> Boundary + '--') do
                        begin
                            Inc(i, Length(line)) ;
                            Inc(SizeOfPostData, Length(line)) ;
                            Lignes.Add(line) ;
                            ReadLine(F, line) ;
                        end ;

                        line := '' ;

                        { Convertit toutes les lignes en une seul lignes }
                        for j := 0 to Lignes.Count - 1 do
                        begin
                            line := line + Lignes[j] ;

                            if (j <> Lignes.Count - 1)
                            then
                                line := line + OsEOL ;
                        end ;

                        Lignes.Clear ;

                        SetVal(PostData, Name, line) ;
                    end ;
                end ;
            end ;
        end ;
        
        CloseFile(F) ;
    except
       on EInOutError do ;
    end ;

    Lignes.Free ;
    LocalVariable.Free ;
end ;

{*******************************************************************************
 * Lit une ligne dans un fichier binaire
 ******************************************************************************}
procedure TGetPostCookieFileData.ReadLine(var F : File; var Line : String) ;
var endOfLine : String ;
    C, C2 : Char ;
    count : Integer ;
    len : Integer ;
begin
    endOfLine := OsEOL ;
    len := Length(endOfLine) ;
    Line := '' ;
    
    repeat
        BlockRead(F, C, 1, count) ;

        if Count <> 1
        then
            break
        else if len = 2
        then begin
            if C = endOfLine[1]
            then begin
                BlockRead(F, C2, 1, count) ;

                if C2 = endOfLine[2]
                then
                    break
                else begin
                    Line := Line + C + C2 ;
                end ;
            end
            else
                Line := Line + C ;
        end
        else begin
            if C = endOfLine[1]
            then
                break
            else
                Line := Line + C ;
        end ;
    until C = endOfLine[1] ;
end ;
{$ENDIF}

end.
