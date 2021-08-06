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

{$IFDEF FPC}
    {$mode objfpc}{$H+}
{$ENDIF}

interface

uses DoubleStrings, Classes, SysUtils
     {$IFNDEF COMMANDLINE}
     , UnitOS
     {$ENDIF}
     ;

type
  TGetPostCookieFileData = class
  private
      { Valeur de QueryString }
      psGetString : String ;
      {$IFNDEF COMMANDLINE}
      { Valeur du boundary pour les données post }
      psBoundary : String ;
      { Taille du content soit des données reçu en post }
      piContentLength : Int64 ;
      { Taille maximum du post }
      piMaxPostSize : Integer ;
      { Taille maximum des fichiers envoyé en post }
      piMaxUploadSize : Integer ;
      { Indique si l'envoie de fichier est autorisé }
      pbFileUpload : Boolean ;
      { Nom du script à exécuter }
      psNameOfScript : String ;
      {$ENDIF}
      { Liste des fichiers temporaires créé }
      poTmpFilesName : TStrings ;
  protected
      procedure ReadCookieData ;
      procedure ReadGetData ;
      {$IFNDEF COMMANDLINE}
      procedure ReadPostData ;
      procedure GetMultipartFormData ;
      function GetName(asText : String) : String ;
      procedure ReadLine(var aF : File; var asLine : String) ;
      function InternalGetFileNameOfScript : String ;
      {$ENDIF}
      procedure ReadDataEnv(aoTabString : String; var aoTab : TDoubleStrings; asSeparateur : String) ;
      procedure InternalExplodeNumber(asText : String; aoListe : TStringList) ;
      procedure SetVal(aoTab : TDoubleStrings; asNom : String; asValeur : String) ;
  public
      {$IFNDEF COMMANDLINE}
      constructor Create(aiLocalMaxPostSize : Integer; aiMaxSizeFile : Integer; lbFileUpload : Boolean) ;
      {$ELSE}
      constructor Create() ;
      {$ENDIF}
      destructor Free ;
      function GetCookie(asName : String) : String ;
      function GetGet(asName : String) : String ;
      function GetPost(asName : String) : String ;
      function GetFile(asName : String) : String ;
      function IsSetGet(asName : String) : boolean ;
      function IsSetPost(asName : String) : boolean ;
      function IsSetCookie(asName : String) : boolean ;
      function IsSetFile(asName : String) : boolean ;
      {$IFNDEF COMMANDLINE}
      function GetFileNameOfScript : String ;
      {$ENDIF}
      goGetData : TDoubleStrings ;
      goPostData : TDoubleStrings ;
      goCookieData : TDoubleStrings ;
      goFileData : TDoubleStrings ;
  end ;

var
    { Contient les données transmisent pas Get, Post, Cookie, File }
    goVarGetPostCookieFileData : TGetPostCookieFileData ;

implementation

uses Functions, Variable, UnitMessages, Code ;

{*****************************************************************************
 * Constructeur
 * MARTINEAU Emeric
 *
 * Paramètres d'entrée :
 *   - aiLocalMaxPostSize : taille maximume des données posts,
 *   - aiMaxSizeFile : taille maximum d'un fichier envoyé en post,
 *   - lbFileUpload : indique si l'upload de fichier est autorisé,
 *
 *****************************************************************************}
{$IFDEF COMMANDLINE}
constructor TGetPostCookieFileData.Create() ;
{$ELSE}
constructor TGetPostCookieFileData.Create(aiLocalMaxPostSize : Integer; aiMaxSizeFile : Integer; lbFileUpload : Boolean) ;
{$ENDIF}
begin
    inherited Create();

    goGetData := TDoubleStrings.Create ;
    goPostData := TDoubleStrings.Create ;
    goCookieData := TDoubleStrings.Create ;
    goFileData := TDoubleStrings.Create ;
    poTmpFilesName := TStringList.Create ;
    
    ReadCookieData ;
    ReadGetData ;
    {$IFNDEF COMMANDLINE}
    piMaxUploadSize := aiMaxSizeFile ;
    piMaxPostSize := aiLocalMaxPostSize ;
    pbFileUpload := lbFileUpload ;
    ReadPostData ;
    {$ENDIF}
end ;

{*****************************************************************************
 * Destructeur
 * MARTINEAU Emeric
 *
 *****************************************************************************}
destructor TGetPostCookieFileData.Free ;
var i : Integer ;
begin
    FreeAndNil(goGetData) ;
    FreeAndNil(goPostData) ;
    FreeAndNil(goCookieData) ;
    FreeAndNil(goFileData) ;

    for i := 0 to poTmpFilesName.Count - 1 do
    begin
        DeleteFile(poTmpFilesName[i]) ;
    end ;

    FreeAndNil(poTmpFilesName) ;
end ;

{*****************************************************************************
 * GetCookie
 * MARTINEAU Emeric
 *
 * Retourne le cookie
 *
 * Paramètres d'entrée :
 *   - asName : nom du cookie,
 *
 *****************************************************************************}
function TGetPostCookieFileData.GetCookie(asName : String) : String ;
begin
    Result := goCookieData.Give(asName) ;
end ;

{*****************************************************************************
 * GetGet
 * MARTINEAU Emeric
 *
 * Retourne la variable Get
 *
 * Paramètres d'entrée :
 *   - asName : nom de la variable,
 *
 *****************************************************************************}
function TGetPostCookieFileData.GetGet(asName : String) : String ;
begin
    Result := goGetData.Give(asName) ;
end ;

{*****************************************************************************
 * GetPost
 * MARTINEAU Emeric
 *
 * Retourne la variable post
 *
 * Paramètres d'entrée :
 *   - asName : nom de la variable,
 *
 *****************************************************************************}
function TGetPostCookieFileData.GetPost(asName : String) : String ;
begin
    Result := goPostData.Give(asName) ;
end ;

{*****************************************************************************
 * GetFile
 * MARTINEAU Emeric
 *
 * Retourne la variable file
 *
 * Paramètres d'entrée :
 *   - asName : nom de la variable,
 *
 *****************************************************************************}
function TGetPostCookieFileData.GetFile(asName : String) : String ;
begin
    Result := goFileData.Give(asName) ;
end ;

{$IFNDEF COMMANDLINE}
{*****************************************************************************
 * InternalGetFileNameOfScript
 * MARTINEAU Emeric
 *
 * Retourne le nom du fichier à exécuter
 *
 * Retour : nom du fichier
 *
 *****************************************************************************}
function TGetPostCookieFileData.InternalGetFileNameOfScript : String ;
var i : Integer ;
begin
   Result := '' ;

   for i := 1 to Length(psGetString) do
   begin
       if psGetString[i] = '&'
       then begin
           break ;
       end
       else if psGetString[i] = '='
       then begin
           Result := '' ;
           break ;
       end ;

       Result := Result + psGetString[i] ;
   end ;
end ;
{$ENDIF}

{*****************************************************************************
 * ReadCookieData
 * MARTINEAU Emeric
 *
 * Lit les donner des cookies et les affectes à la variable de cookie
 *
 *****************************************************************************}
procedure TGetPostCookieFileData.ReadCookieData ;
begin
    ReadDataEnv(GetEnvironmentVariable('HTTP_COOKIE'), goCookieData, '; ') ;
end ;

{*****************************************************************************
 * ReadGetData
 * MARTINEAU Emeric
 *
 * Lit les donner get
 *
 *****************************************************************************}
procedure TGetPostCookieFileData.ReadGetData ;
{$IFNDEF COMMANDLINE}
var
    { Reçoit les données QUERY_STRING sans le nom du script à exécuter }
    lsTmp : String ;
    { Longueur du nom de fichier }
    liLenNameOfString : Integer ;
{$ENDIF}
begin
    psGetString := GetEnvironmentVariable('QUERY_STRING') ;

    {$IFNDEF COMMANDLINE}
    psNameOfScript := InternalGetFileNameOfScript ;
    liLenNameOfString := Length(psNameOfScript) ;
    lsTmp := Copy(psGetString, liLenNameOfString + 2, Length(psGetString) - liLenNameOfString) ;
    ReadDataEnv(lsTmp, goGetData, '&') ;
    {$ELSE}
    ReadDataEnv(psGetString, goGetData, '&') ;
    {$ENDIF}
end ;

{*****************************************************************************
 * ReadPostData
 * MARTINEAU Emeric
 *
 * Lit les donner post
 *
 *****************************************************************************}
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

            if Length(tmp) < piMaxPostSize
            then begin
                ReadDataEnv(tmp, goPostData, '&')
            end
            else begin
                WarningMsg(csPostDataTooBig) ;
            end ;
        end
        else if pos('multipart/form-data;', tmp) <> 0
        then begin
            i := pos('boundary=', tmp) ;

            if i <> 0
            then begin
                { 9 = 'boundary=' }
                psBoundary := '--' + Copy(tmp, i + 9, length(tmp) - i - 9 + 1) ;
                piContentLength := MyStrToInt64(GetEnvironmentVariable('CONTENT_LENGTH')) ;

                GetMultipartFormData ;
            end ;
        end ;
    end ;
end ;
{$ENDIF}

{*****************************************************************************
 * ReadDataEnv
 * MARTINEAU Emeric
 *
 * Lit les donner depuis une variable d'environnement
 *
 * Paramètres d'entrée :
 *   - asTabString : chaine contenant val=truc,
 *   - aoTab : DoubleString de destination,
 *   - asSeparateur : séparateur entre les valeurs
 *****************************************************************************}
procedure TGetPostCookieFileData.ReadDataEnv(aoTabString : String; var aoTab : TDoubleStrings; asSeparateur : String) ;
var
    { Contient les couples var=valeur }
    loListe : TStringList ;
    { Contient val et valeur }
    loElement : TStringList ;
    { Compteur de loList }
    liIndex : Integer ;
    { Nom de la valeur (var) }
    lsNom : String ;
    { Valeur de la variable }
    lsValeur : String ;
begin
   if aoTabString <> ''
   then begin
       loListe := TStringList.Create ;
       loElement := TStringList.Create ;

       Explode(aoTabString, loListe, asSeparateur) ;

       for liIndex := 0 to loListe.Count - 1 do
       begin
           Explode(loListe[liIndex], loElement, '=') ;
           
           if loElement.Count > 0
           then begin
               lsNom := UrlDecode(loElement[0]) ;

               lsValeur := '' ;

               if loElement.Count > 1
               then begin
                   lsValeur := UrlDecode(loElement[1]) ;
               end ;

               SetVal(aoTab, lsNom, lsValeur) ;
           end ;
       end ;

       FreeAndNil(loListe) ;
       FreeAndNil(loElement) ;
   end ;
end ;

{*****************************************************************************
 * InternalExplodeNumber
 * MARTINEAU Emeric
 *
 * Convertit une chaine "[1][1]" en liste
 *
 * Paramètres d'entrée :
 *   - asText: chaine de type "[1][1]",
 *   - aoListe : contient les 1, 1,
 *****************************************************************************}
procedure TGetPostCookieFileData.InternalExplodeNumber(asText : String; aoListe : TStringList) ;
var
    { Conteur de boucle de chaine }
    liIndex : Integer ;
    { Variable temporaire }
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
            lsTmp := ''
        end
        else begin
            lsTmp := lsTmp + asText[liIndex] ;
        end ;
    end ;
end ;

{*****************************************************************************
 * SetVale
 * MARTINEAU Emeric
 *
 * Ajoute un élément à une variable si c'est un tableau
 *
 * Paramètres d'entrée :
 *   - aoTab : DoubleString dans lequel il faut ajouter la variable,
 *   - asNom : nom de la variable,
 *   - asValeur : valeur de la variable
 *****************************************************************************}
procedure TGetPostCookieFileData.SetVal(aoTab : TDoubleStrings; asNom : String; asValeur : String) ;
var
    { Variable temporaire contenant le nom de la variable }
    lsTmpName : String ;
    { Variable contenant [1] }
    lsTmpTab : String ;
    { Position de [ }
    liIndex : Integer ;
    { Contient la liste des indexs si asNom est un tableau }
    loTableau : TStringList ;
    { Objet variable }
    loLocalVariable : TVariables ;
    { Conteur de boucle }
    liIndexTableau : Integer ;
begin
    { Est-ce une variable tabeau ? }
    liIndex := pos('[', asNom) ;
    
    if liIndex <> 0
    then begin
        loTableau := TStringList.Create ;
        loLocalVariable := TVariables.Create ;

        lsTmpName := copy(asNom, 1, liIndex - 1) ;
        lsTmpTab := copy(asNom, liIndex, Length(asNom) - liIndex + 1) ;
        asNom := lsTmpName ;

        InternalExplodeNumber(lsTmpTab, loTableau) ;

        { Si la variable existe on la mémorise }
        if aoTab.isSet(asNom)
        then begin
            loLocalVariable.Add(asNom, aoTab.Give(asNom)) ;
        end ;

        for liIndexTableau := 0 to loTableau.Count - 1 do
        begin
           if not isInteger(loTableau[liIndexTableau])
           then begin
               lsTmpTab := IntToStr(loLocalVariable.Length(lsTmpName) + 1) ;
               loTableau[liIndexTableau] := lsTmpTab ;
           end
           else begin
               if MyStrToInt(loTableau[liIndexTableau]) > 0
               then begin
                   lsTmpTab := loTableau[liIndexTableau]
               end
               else begin
                   lsTmpTab := IntToStr(loLocalVariable.Length(lsTmpName) + 1) ;
                   loTableau[liIndexTableau] := lsTmpTab ;
               end ;
           end ;

           lsTmpName := lsTmpName + '[' + lsTmpTab + ']' ;
        end ;

        { On créer la variable }
        loLocalVariable.Add(lsTmpName, AddSlashes(asValeur)) ;

        asValeur := loLocalVariable.Give(asNom) ;

        FreeAndNil(loTableau) ;
        FreeAndNil(loLocalVariable) ;
    end
    else begin
       asValeur := AddSlashes(asValeur) ;
    end ;

    aoTab.Add(asNom, asValeur) ;
end ;

{$IFNDEF COMMANDLINE}
{*****************************************************************************
 * GetName
 * MARTINEAU Emeric
 *
 * Récupère le nom dans une ligne
 * Content-Disposition: form-data; name="textfield"
 *
 * Paramètres d'entrée :
 *   - aoTab : texte à lire Content-Disposition: form-data; name="textfield"
 *****************************************************************************}
function TGetPostCookieFileData.GetName(asText : String) : String ;
var
    { Position de name= }
    liIndex : Integer ;
    { Longueur de asText }
    liLenText : Integer ;
begin
    Result := '' ;
    liIndex := pos('name="', asText) ;
    liLenText := Length(asText) ;

    if liIndex > 0
    then begin
        Inc(liIndex, 6) ;

        while liIndex <= liLenText do
        begin
            if asText[liIndex] = '"'
            then begin
                break ;
            end
            else if asText[liIndex] = '\'
            then begin
                Inc(liIndex) ;
            end ;

            Result := Result + asText[liIndex] ;
            Inc(liIndex) ;
        end ;
    end ;
end ;

{*****************************************************************************
 * GetMultipartFormData
 * MARTINEAU Emeric
 *
 * Récupère le donnée d'un formulaire transmit pas multipart/form-data
 *
 *****************************************************************************}
procedure TGetPostCookieFileData.GetMultipartFormData ;
var
    { Longueur des données lues }
    liLenOfRead : Integer ;
    { Compteur de boucle de lignes }
    liIndexLignes : Integer ;
    { Ligne courante à traiter}
    lsCurrentLine : String ;
    { Comtpeur pour le buffer }
    liCountOfBuffer : Integer ;
    { Nom de la variable envoyée en post }
    lsName : String ;
    { Ligne dans la variable lorsqu'on est en variable "normale" pas en fichier }
    loLignes : TStringList ;
    { Buffer de lecture des données à mettre dans le fichier }
    lsBuffer : String ;
    { Caractère lu en cours }
    lcC : char ;
    { Fichier de lecture standard (ex : clavier) }
    lF : File ;
    { Compteur de la fonction BlockRead }
    liCountRead : Integer ;
    { Position filename= }
    liPosition : Integer ;
    { Fichier temporaire }
    lFileOut : File ;
    { Compteur de la fonction BlockWrite }
    liCountWrite : Integer ;
    { Position du boundary }
    liPosBoundary : Integer ;
    { Taille buffer }
    liLenOfBuffer : Integer ;
    { Nom du fichier temporaire }
    lsTmpFileName : String ;
    { EndOfLine + boundary }
    lsTmpBoundary : String ;
    { Indique s'il ne faut pas enregistrer les données }
    lbSkipData : Boolean ;
    { Taille du fichier en cours de constitution }
    liSizeOfFile : Integer ;
    { Taille des données post hors fichier }
    liSizeOfPostData : Integer ;
    { Nom du fichier en cours d'envoie }
    lsFileName : String ;
    { Permet le constitution des variables }
    loLocalVariable : TVariables ;
    { Nom de la variable du fichier temporaire }
    lsTmpVarName : String ;
    { Type des données text/html, image/gif }
    lsContentType : String ;
    { Boundary de fin de données post }
    lsEndBoundary : String ;
begin
    liLenOfRead := 1 ;
    loLignes := TStringList.Create ;
    lsTmpBoundary := OsEOL + psBoundary ;
    loLocalVariable := TVariables.Create ;
    liSizeOfPostData := 0 ;
    lsEndBoundary := psBoundary + '--' ;
    lsCurrentLine := '' ;
    lsTmpVarName := 'TmpVarFileName' ;

    try
        { Ouvre l'entrée standar en lecture seul }
        FileMode := fmOpenRead ;
        AssignFile(lF, '') ;
        Reset(lF, 1) ;
        Seek(lF, 0) ;

        while liLenOfRead <= piContentLength do
        begin
            { A-t-on atteind la taille maximal des données par post ? }
            if piMaxPostSize >= 0
            then begin
                if liSizeOfPostData >= piMaxPostSize
                then begin
                    break ;
                end ;
            end ;

            ReadLine(lF, lsCurrentLine) ;

            if (lsCurrentLine = '--') or (lsCurrentLine = lsEndBoundary)
            then begin
                break ;
            end ;

            Inc(liLenOfRead, Length(lsCurrentLine)) ;
            Inc(liSizeOfPostData, Length(lsCurrentLine)) ;

            { (line = Boundary) car la première ligne est égale à boundary }
            if (lsCurrentLine = psBoundary) or (pos('Content-Disposition: form-data;', lsCurrentLine) <> 0)
            then begin

                if (lsCurrentLine = psBoundary)
                then begin
                    ReadLine(lF, lsCurrentLine) ;
                    Inc(liLenOfRead, Length(lsCurrentLine)) ;
                end ;
                
                if pos('Content-Disposition: form-data;', lsCurrentLine) <> 0
                then begin
                    liPosition := pos('filename="', lsCurrentLine) ;

                    if liPosition <> 0
                    then begin
                        lsFileName := Copy(lsCurrentLine, liPosition + 10, Length(lsCurrentLine) - (liPosition + 10)) ;

                        if lsFileName <> ''
                        then begin
                            lsName := GetName(lsCurrentLine) ;

                            { Content-Type }
                            readline(lF, lsCurrentLine) ;

                            liPosition := pos('Content-Type: ', lsCurrentLine) ;
                            lsContentType := Copy(lsCurrentLine, liPosition + 14, Length(lsCurrentLine) - (liPosition + 13)) ;

                            { Doit-on ne pas enregistrer les données }
                            if pbFileUpload
                            then begin
                                lbSkipData := False
                            end
                            else begin
                                lbSkipData := True ;
                            end ;

                            liSizeOfFile := 0 ;

                            { Ligne vide après content-type }
                            readline(lF, lsCurrentLine) ;

                            {$I+}
                            FileMode := fmOpenWrite ;
                            lsTmpFileName := OsGetTmpFileName ;

                            poTmpFilesName.Add(lsTmpFileName) ;

                            AssignFile(lFileOut, lsTmpFileName) ;
                            Rewrite(lFileOut, SizeOf(lcC)) ;

                            if IOResult = 0
                            then begin
                                lsBuffer := '' ;
                                liPosBoundary := 1 ;

                                while liLenOfRead <= piContentLength do
                                begin
                                    if piMaxUploadSize >= 0
                                    then begin
                                        if liSizeOfFile > piMaxUploadSize
                                        then begin
                                            lbSkipData := True ;
                                        end ;
                                    end ;

                                    { Initialise la variable pour supression du message FPC }
                                    liCountRead := 0 ;
                                    lcC := #0 ;
                                    
                                    BlockRead(lF, lcC, SizeOf(lcC), liCountRead) ;
                                    Inc(liLenOfRead) ;

                                    if liCountRead <> 1
                                    then begin
                                        break ;
                                    end ;

                                    if lcC <> lsTmpBoundary[liPosBoundary]
                                    then begin
                                        liPosBoundary := 1 ;

                                        liLenOfBuffer := Length(lsBuffer) ;

                                        if liLenOfBuffer > 0
                                        then begin
                                            for liCountOfBuffer := 1 to liLenOfBuffer do
                                            begin
                                                if not lbSkipData
                                                then begin
                                                    { Suppression du Warning FPC }
                                                    liCountWrite := 0 ;
                                                    
                                                    BlockWrite(lFileOut, lsBuffer[liCountOfBuffer], SizeOf(lcC), liCountWrite) ;

                                                    if liCountWrite <> 1
                                                    then begin
                                                        break ;
                                                    end ;
                                                end ;

                                                Inc(liSizeOfFile) ;
                                            end ;

                                            lsBuffer := '' ;
                                        end ;


                                        if lcC <> lsTmpBoundary[liPosBoundary]
                                        then begin
                                            if not lbSkipData
                                            then begin
                                                BlockWrite(lFileOut, lcC, SizeOf(lcC), liCountWrite) ;

                                                if liCountWrite <> 1
                                                then begin
                                                    break ;
                                                end ;
                                            end ;

                                            Inc(liSizeOfFile) ;
                                        end
                                        else begin
                                            lsBuffer := lsBuffer + lcC ;

                                            { Il faut absolument incrémenter PosBoundary
                                              après }
                                            Inc(liPosBoundary) ;
                                        end ;
                                    end
                                    else begin
                                        lsBuffer := lsBuffer + lcC ;

                                        if liPosBoundary = length(lsTmpBoundary)
                                        then begin
                                            break ;
                                        end ;

                                        { Il faut absolument incrémenter PosBoundary
                                          après }
                                        Inc(liPosBoundary) ;
                                    end ;
                                end ;

                                CloseFile(lFileOut) ;
                                
                                loLocalVariable.Add(lsTmpVarName + '[1]', OSOsPathToSwsPath(lsTmpFileName));
                                loLocalVariable.Add(lsTmpVarName + '[2]', lsContentType);
                                loLocalVariable.Add(lsTmpVarName + '[3]', lsFileName);
                                loLocalVariable.Add(lsTmpVarName + '[4]', IntToStr(liSizeOfFile));

                                goFileData.Add(lsName, loLocalVariable.Give(lsTmpVarName)) ;

                                loLocalVariable.Delete(lsTmpVarName) ;
                                {$I-}
                            end ;
                        end ;
                    end
                    else begin
                        { Recopie le nom }
                        lsName := GetName(lsCurrentLine) ;

                        { En dessous, il y a une ligne vide }
                        ReadLine(lF, lsCurrentLine) ;

                        { Lit une première fois car si vide on à directement Boundary }
                        ReadLine(lF, lsCurrentLine) ;

                        { Lit toutes les lignes jusqu'à Boundary }
                        while (lsCurrentLine <> psBoundary) and (liLenOfRead < piContentLength) and (lsCurrentLine <> lsEndBoundary) do
                        begin
                            Inc(liLenOfRead, Length(lsCurrentLine)) ;
                            Inc(liSizeOfPostData, Length(lsCurrentLine)) ;
                            loLignes.Add(lsCurrentLine) ;
                            ReadLine(lF, lsCurrentLine) ;
                        end ;

                        { Réinitialise la ligne }
                        lsCurrentLine := '' ;

                        { Convertit toutes les lignes en une seul lignes }
                        for liIndexLignes := 0 to loLignes.Count - 1 do
                        begin
                            lsCurrentLine := lsCurrentLine + loLignes[liIndexLignes] ;

                            { On ne lit pas la dernière ligne car elle contient le boundary de fin }
                            if (liIndexLignes <> loLignes.Count - 1)
                            then begin
                                lsCurrentLine := lsCurrentLine + OsEOL ;
                            end ;
                        end ;

                        loLignes.Clear ;

                        SetVal(goPostData, lsName, lsCurrentLine) ;
                    end ;
                end ;
            end ;
        end ;
        
        CloseFile(lF) ;
    except
       on EInOutError do ;
    end ;

    FreeAndNil(loLignes) ;
    FreeAndNil(loLocalVariable) ;
end ;

{*****************************************************************************
 * GetName
 * MARTINEAU Emeric
 *
 * Lit une ligne dans un fichier binaire
 *
 * Paramètre d'entrée :
 *   - aF : variable fichier à lire,
 *   - asLine : ligne lue
 *****************************************************************************}
procedure TGetPostCookieFileData.ReadLine(var aF : File; var asLine : String) ;
var
    { Contient la fin de ligne pour comparaison }
    lsEndOfLine : String ;
    { Caracère lue }
    lcC1 : Char ;
    lcC2 : Char ;
    { Nombre de caractère lu par BlockRead }
    liCount : Integer ;
    { Longeur de la fin de ligne }
    liLenEnOfFile : Integer ;
begin
    lsEndOfLine := OsEOL ;
    liLenEnOfFile := Length(lsEndOfLine) ;
    asLine := '' ;
    
    repeat
        { Suppression du Warning FPC }
        lcC1 := #0 ;
        liCount := 0 ;
        
        BlockRead(aF, lcC1, 1, liCount) ;

        if liCount <> 1
        then
            break
        else if liLenEnOfFile = 2
        then begin
            if lcC1 = lsEndOfLine[1]
            then begin
                { Suppression du Waring FPC }
                lcC2 := #0 ;
                
                BlockRead(aF, lcC2, 1, liCount) ;

                if lcC2 = lsEndOfLine[2]
                then begin
                    break ;
                end
                else begin
                    asLine := asLine + lcC1 + lcC2 ;
                end ;
            end
            else begin
                asLine := asLine + lcC1 ;
            end ;
        end
        else begin
            if lcC1 = lsEndOfLine[1]
            then begin
                break ;
            end 
            else begin
                asLine := asLine + lcC1 ;
            end ;
        end ;
    until lcC1 = lsEndOfLine[1] ;
end ;
{$ENDIF}

{*****************************************************************************
 * GetFileNameOfScript
 * MARTINEAU Emeric
 *
 * Retourne le nom du script à exécuter
 *
 *****************************************************************************}
{$IFNDEF COMMANDLINE}
function TGetPostCookieFileData.GetFileNameOfScript : String ;
begin
    Result := psNameOfScript ;
end ;
{$ENDIF}

{*****************************************************************************
 * IsSetGet
 * MARTINEAU Emeric
 *
 * Indique si la donnée Get existe
 *
 * Paramètres d'entrée :
 *   - asName : nom de la variable,
 *
 * Retour : true si la donnée exist.
 *****************************************************************************}
function TGetPostCookieFileData.IsSetGet(asName : String) : boolean ;
begin
    Result := goGetData.IsSet(asName) ;
end ;

{*****************************************************************************
 * IsSetPost
 * MARTINEAU Emeric
 *
 * Indique si la donnée Post existe
 *
 * Paramètres d'entrée :
 *   - asName : nom de la variable,
 *
 * Retour : true si la donnée exist.
 *****************************************************************************}
function TGetPostCookieFileData.IsSetPost(asName : String) : boolean ;
begin
    Result := goPostData.IsSet(asName) ;
end ;

{*****************************************************************************
 * IsSetCookie
 * MARTINEAU Emeric
 *
 * Indique si la donnée Cookie existe
 *
 * Paramètres d'entrée :
 *   - asName : nom de la variable,
 *
 * Retour : true si la donnée exist.
 *****************************************************************************}
function TGetPostCookieFileData.IsSetCookie(asName : String) : boolean ;
begin
    Result := goCookieData.IsSet(asName) ;
end ;

{*****************************************************************************
 * IsSetFile
 * MARTINEAU Emeric
 *
 * Indique si la donnée Get existe
 *
 * Paramètres d'entrée :
 *   - asName : nom de la variable,
 *
 * Retour : true si la donnée exist.
 *****************************************************************************}
function TGetPostCookieFileData.IsSetFile(asName : String) : boolean ;
begin
    Result := goFileData.IsSet(asName) ;
end ;

end.
