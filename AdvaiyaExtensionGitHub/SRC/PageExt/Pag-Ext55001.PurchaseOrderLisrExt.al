pageextension 55001 PurchaseOrderLisrExt extends "Purchase Order List"
{
    actions
    {
        addafter(Print)
        {
            action("Purchase Order Report")
            {
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Category5;
                trigger OnAction()
                var
                    PurchaseHeader: Record "Purchase Header";
                begin
                    PurchaseHeader.Reset();
                    PurchaseHeader.SetRange("Document Type", Rec."Document Type");
                    PurchaseHeader.SetRange("No.", Rec."No.");
                    if PurchaseHeader.FindFirst() then;
                    Report.RunModal(Report::PurchaseOrder, true, false, PurchaseHeader);
                end;
            }
        }
    }
}
