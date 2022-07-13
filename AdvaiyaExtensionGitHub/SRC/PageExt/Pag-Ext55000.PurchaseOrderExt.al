pageextension 55000 PurchaseOrderExt extends "Purchase Order"
{
    actions
    {
        addafter("&Print")
        {
            action("Purchase Order Report")
            {
                ApplicationArea = All;
                Image = Report;
                Promoted = true;
                PromotedCategory = Category10;
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
