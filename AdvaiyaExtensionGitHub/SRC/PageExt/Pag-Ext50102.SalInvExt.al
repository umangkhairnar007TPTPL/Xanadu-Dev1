pageextension 50102 SalInvExt extends "Sales Invoice"

{
    layout
    {
        addafter("Posting Date")
        {
            field("TDS Selection Code"; rec."TDS Selection Code")
            {
                ApplicationArea = All;
                ToolTip = 'TDS Selection';
            }
        }
    }
    actions
    {
        addafter("Update Reference Invoice No.")
        {
            action(TDS)
            {
                ApplicationArea = All;
                trigger OnAction()
                var
                    genledsetup_lrec: Record "General Ledger Setup";
                    Customer_lrec: Record Customer;
                    TaxRates: Record "Tax Rate";
                    taxrateId: Text;
                    TaxRateValue: Record "Tax Rate Value";
                    TaxRateGuId: Guid;
                    GenJorBatch: Record "Gen. Journal Batch";
                begin
                    // if genledsetup_lrec.Get() then;
                    // if rec."TDS Selection Code" = genledsetup_lrec."TDS Selection Code" then begin
                    //     if Customer_lrec.Get(rec."Bill-to Customer No.") then begin
                    //         if (Customer_lrec."P.A.N. No." <> '') then begin
                    //             taxrateId := Rec."TDS Selection Code" + '|COM|*';
                    //             TaxRates.Reset();
                    //             TaxRates.SetRange("Tax Type", 'TDS');
                    //             TaxRates.SetFilter("Tax Rate ID", '%1', taxrateId);
                    //             IF TaxRates.FindSet() then begin
                    //                 repeat
                    //                     TaxRateGuId := TaxRates.ID;
                    //                     Message(TaxRates."Tax Rate ID");
                    //                     TaxRateValue.Reset();
                    //                     TaxRateValue.SetFilter("Tax Rate ID", '%1', taxrateId);
                    //                     // TaxRateValue.SetFilter(ID, '%1', TaxRateGuId);
                    //                     TaxRateValue.SetRange("Column ID", 33);
                    //                     if TaxRateValue.FindSet() then begin
                    //                         Message(TaxRateValue.Value);
                    //                     end;
                    //                 until TaxRates.Next() = 0
                    //             end;
                    //         end
                    //     end;
                    // end;
                    GenJorBatch.Reset();
                    if GenJorBatch.FindFirst() then
                        repeat
                            Message(GenJorBatch."Journal Template Name");
                        until GenJorBatch.Next() = 0;
                end;
            }
        }
    }
}
