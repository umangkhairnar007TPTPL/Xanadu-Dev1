pageextension 55002 "Accountant Activities Ext" extends "Accountant Activities"
{
    layout
    {
        addafter("Document Approvals")
        {
            cuegroup("Ready To Post")
            {
                
                field("Purchase Invoice Ready To Post"; Rec."Purchase Invoice Ready To Post")
                {
                    ToolTip = 'Specifies the value of the Purchase Invoice Ready To Post field.';
                    DrillDownPageID = "Purchase Invoices";
                    ApplicationArea = All;
                }
            }
        }
    }
}
