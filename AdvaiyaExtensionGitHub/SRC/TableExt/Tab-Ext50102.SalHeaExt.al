tableextension 50102 SalHeaExt extends "Sales Header"
{
    fields
    {
        field(50100; "TDS Selection Code"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;


}