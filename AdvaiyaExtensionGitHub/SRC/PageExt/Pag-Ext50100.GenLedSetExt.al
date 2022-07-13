pageextension 50100 GenLedSetExt extends "General Ledger Setup"

{
    layout
    {
        addafter("Bank Account Nos.")
        {
            field("TDS Selection Code"; rec."TDS Selection Code")
            {
                ApplicationArea = All;
                ToolTip = 'TDS Selection';
                TableRelation = "TDS Section";
            }
        }
    }
}