pageextension 50101 SalInvSubformExt extends "Sales Invoice Subform"

{
    layout
    {
        addafter(Description)
        {
            field("TDS Selection Code"; rec."TDS Selection Code")
            {
                ApplicationArea = All;
                ToolTip = 'TDS Selection';
                Editable = false;

            }
        }
    }
}