tableextension 55000 "Finance Cue Ext" extends "Finance Cue"
{
    fields
    {
        field(55000; "Purchase Invoice Ready To Post"; Integer)
        {
            CalcFormula = Count("Purchase Header" WHERE("Document Type" = CONST(Invoice),
                                                         Status = FILTER(Released)));
            Caption = 'Purchase Invoices';
            FieldClass = FlowField;

        }
    }
}
