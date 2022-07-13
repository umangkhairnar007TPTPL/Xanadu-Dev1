tableextension 50101 SalLinExt extends "Sales Line"
{

    fields
    {
        field(50100; "TDS Selection Code"; Text[20])
        {
            DataClassification = ToBeClassified;
        }
    }

}