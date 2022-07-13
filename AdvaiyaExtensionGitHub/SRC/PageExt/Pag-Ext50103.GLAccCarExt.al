pageextension 50103 GlAccountCard extends "G/L Account Card"

{
    layout
    {
        addafter("Omit Default Descr. in Jnl.")
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