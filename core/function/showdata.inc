{*****************************************************************************
 * ShowData
 * MARTINEAU Emeric
 *
 * Affiche les données si c'est un tableau, un entier...
 *
 * Paramètres d'entrée :
 *   - asData     : donnée à afficher (entier, tableau, pointer)
 *   - asDecalage : texte à afficher devant la donnée
 *   - aiIndex    : index dans le tableau
 *
 * Retour : chaine de caractère contenant les données à afficher. Contient
 *           '\n' donc il faut parser la chaine
 *****************************************************************************}
function ShowData(asData : string; asDecalage : String; aiIndex : Integer) : String ;
var
    { Type de donnée }
    lsTypeData : string ;
    { Donnée du tableau }
    loArrayData : TStringList ;
    { Compteur de boucle }
    liIndex : Integer ;
begin
    Result := '' ;

    if goVariables.InternalisArray(asData)
    then begin
        Result := Result + asDecalage + csArray + ' = {\n' ;

        loArrayData := TStringList.Create ;

        goVariables.explode(loArrayData, asData);

        for liIndex := 0 to loArrayData.Count - 1 do
        begin
            Result := Result + ShowData(loArrayData[liIndex], asDecalage + '    ', liIndex + 1) ;
        end ;

        FreeAndNil(loArrayData) ;

        Result := Result + '}\n' ;
    end
    else begin
        lsTypeData := csString ;

        if isHexa(asData)
        then begin
            lsTypeData := csHexa  ;
        end
        else if isInteger(asData)
        then begin
            lsTypeData := csInteger ;
        end
        else if isFloat(asData)
        then begin
            lsTypeData := csFloat ;
        end ;

        Result := Result + asDecalage ;

        if aiIndex > 0
        then begin
            Result := Result + '[' + IntToStr(aiIndex) + '] ' ;
        end ;

        Result := Result + lsTypeData + ' : ' + asData + '\n';
    end ;
end ;