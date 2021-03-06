{*****************************************************************************
 * ShowData
 * MARTINEAU Emeric
 *
 * Affiche les donn�es si c'est un tableau, un entier...
 *
 * Param�tres d'entr�e :
 *   - asData     : donn�e � afficher (entier, tableau, pointer)
 *   - asDecalage : texte � afficher devant la donn�e
 *   - aiIndex    : index dans le tableau
 *
 * Retour : chaine de caract�re contenant les donn�es � afficher. Contient
 *           '\n' donc il faut parser la chaine
 *****************************************************************************}
function ShowData(asData : string; asDecalage : String; aiIndex : Integer) : String ;
var
    { Type de donn�e }
    lsTypeData : string ;
    { Donn�e du tableau }
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