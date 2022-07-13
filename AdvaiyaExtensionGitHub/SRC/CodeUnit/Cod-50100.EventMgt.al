codeunit 50100 EventMgt
{
    var

    [EventSubscriber(ObjectType::Table, DataBase::"sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure ValidateTDSSelectionCodeinHeader(var Rec: Record "Sales Line")
    var
        GLAccRec_lrec: Record "G/L Account";
        SalesHeader_lrec: Record "Sales Header";
    begin
        SalesHeader_lrec.Get(Rec."Document Type", Rec."Document No.");
        if (rec.Type = rec.Type::"G/L Account") then begin
            If GLAccRec_lrec.Get(rec."No.") then begin
                SalesHeader_lrec.validate("TDS Selection Code", GLAccRec_lrec."TDS Selection Code");
                SalesHeader_lrec.Modify(false);
            end
        end
        else begin
            SalesHeader_lrec."TDS Selection Code" := '';
            SalesHeader_lrec.Modify(false);
        end;
    end;

    [EventSubscriber(ObjectType::Table, DataBase::"sales Line", 'OnAfterValidateEvent', 'No.', false, false)]
    local procedure ValidateTDSSelectionCodeinSalesLine(var Rec: Record "Sales Line")
    var
        GLAccRec_lrec: Record "G/L Account";
    begin
        if (rec.Type = rec.Type::"G/L Account") then begin
            If GLAccRec_lrec.Get(rec."No.") then begin
                Rec.validate("TDS Selection Code", GLAccRec_lrec."TDS Selection Code");
                // Rec.Modify(false);
            end
        end
    end;

    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Sales-Post", 'OnAfterSalesInvLineInsert', '', false, false)]
    local procedure OnAfterSalesInvLineInsert(var SalesInvLine: Record "Sales Invoice Line"; var SalesHeader: Record "Sales Header"; SalesInvHeader: Record "Sales Invoice Header")
    var
        genledsetup_lrec: Record "General Ledger Setup";
        GenJorLin_lrec: Record "Gen. Journal Line";
        GenJorLinlast_lrec: Record "Gen. Journal Line";
        GenJorBatch: Record "Gen. Journal Batch";
        Customer_lrec: Record Customer;
        TdsPostSet_lrec: Record "TDS Posting Setup";
        TdsAmount: Decimal;
        invNo: Code[20];
        GenJouLinNo: Integer;
        GenJouLastLinNo: Integer;
        TdsFix: Decimal;
        TaxRates: Record "Tax Rate";
        taxrateId: Text;
        TaxRateValue: Record "Tax Rate Value";
        TaxRateGuId: Guid;
        taxratepercent: Decimal;
    begin
        if genledsetup_lrec.Get() then;
        if SalesHeader."TDS Selection Code" = genledsetup_lrec."TDS Selection Code" then begin
            if Customer_lrec.Get(SalesHeader."Bill-to Customer No.") then begin
                if (Customer_lrec."P.A.N. No." <> '') then begin
                    taxrateId := SalesHeader."TDS Selection Code" + '|COM|*';
                    TaxRates.Reset();
                    TaxRates.SetRange("Tax Type", 'TDS');
                    TaxRates.SetFilter("Tax Rate ID", '%1', taxrateId);
                    IF TaxRates.FindSet() then begin
                        repeat
                            TaxRateGuId := TaxRates.ID;
                            // Message(TaxRates."Tax Rate ID");
                            TaxRateValue.Reset();
                            TaxRateValue.SetFilter("Tax Rate ID", '%1', taxrateId);
                            // TaxRateValue.SetFilter(ID, '%1', TaxRateGuId);
                            TaxRateValue.SetRange("Column ID", 33);
                            if TaxRateValue.FindSet() then;
                        until TaxRates.Next() = 0
                    end;
                end
                else begin
                    taxrateId := SalesHeader."TDS Selection Code" + '|COM|*';
                    TaxRates.Reset();
                    TaxRates.SetRange("Tax Type", 'TDS');
                    TaxRates.SetFilter("Tax Rate ID", '%1', taxrateId);
                    IF TaxRates.FindSet() then begin
                        repeat
                            TaxRateGuId := TaxRates.ID;
                            // Message(TaxRates."Tax Rate ID");
                            TaxRateValue.Reset();
                            TaxRateValue.SetFilter("Tax Rate ID", '%1', taxrateId);
                            // TaxRateValue.SetFilter(ID, '%1', TaxRateGuId);
                            TaxRateValue.SetRange("Column ID", 34);
                            if TaxRateValue.FindSet() then;
                        until TaxRates.Next() = 0
                    end;
                end;
            end;
        end;
        If TaxRateValue.Value <> '' then
            Evaluate(taxratepercent, TaxRateValue.Value);
        GenJorBatch.Reset();
        GenJorBatch.SetRange("Template Type", GenJorBatch."Template Type"::General);
        if GenJorBatch.FindFirst() then;
        GenJorLinlast_lrec.Reset();
        GenJorLinlast_lrec.SetRange("Journal Batch Name", GenJorBatch.Name);
        GenJorLinlast_lrec.SetRange("Journal Template Name", GenJorBatch."Journal Template Name");
        if GenJorLinlast_lrec.FindLast() then;
        // GenJouLastLinNo := GenJorLin_lrec."Line No.";
        // GenJouLinNo := GenJouLastLinNo + 10000;
        GenJorLin_lrec.Init();
        GenJorLin_lrec."Journal Batch Name" := GenJorBatch.Name;
        GenJorLin_lrec."Journal Template Name" := GenJorBatch."Journal Template Name";
        GenJorLin_lrec.Validate("Line No.", GenJorLinlast_lrec."Line No." + 10000);
        GenJorLin_lrec.validate("Document Type", GenJorLin_lrec."Document Type"::Payment);
        GenJorLin_lrec.validate("Document No.", SalesInvHeader."No.");
        GenJorLin_lrec.validate("Party Type", GenJorLin_lrec."Party Type"::Customer);
        GenJorLin_lrec.validate("Party Code", SalesInvHeader."Bill-to Customer No.");
        GenJorLin_lrec.Validate("Posting Date", SalesInvHeader."Posting Date");
        TdsAmount := -(SalesInvLine.Amount * taxratepercent) / 100;
        GenJorLin_lrec.validate(Amount, TdsAmount);
        GenJorLin_lrec.validate("Bal. Account Type", GenJorLin_lrec."Bal. Account Type"::"G/L Account");
        TdsPostSet_lrec.Reset();
        TdsPostSet_lrec.SetFilter("TDS Section", SalesHeader."TDS Selection Code");
        if TdsPostSet_lrec.FindFirst() then begin
            GenJorLin_lrec.validate("Bal. Account No.", TdsPostSet_lrec."TDS Receivable Account");
        end;
        GenJorLin_lrec.Insert(true);
    end;
    // end;

    // KD :: 12052022 ++
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Role Center Notification Mgt.", 'OnBeforeShowNotifications', '', false, false)]
    local procedure ShowNotification()
    begin
        ShowNotificationOnRoleCenter();
    end;

    procedure ShowNotificationOnRoleCenter()
    var
        MyNotification: Notification;
        Profile: Record "User Personalization";
    begin

        if Profile.Get(UserSecurityId()) then
            if Profile."Profile ID" = 'ACCOUNTANT' then begin
                PurchaseHeader.Reset();
                PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
                PurchaseHeader.SetRange(Status, PurchaseHeader.Status::Released);
                if PurchaseHeader.FindSet() then begin
                    MyNotification.MESSAGE := 'You have got Purchase Invoice ready to post.';
                    MyNotification.SCOPE := NOTIFICATIONSCOPE::LocalScope;
                    MyNotification.ADDACTION('Click here!', CODEUNIT::EventMgt, 'RunAction1');
                    MyNotification.Send();
                end;
            end;
    end;

    PROCEDURE RunAction1(MyNotification1000: Notification);
    begin
        PurchaseHeader.Reset();
        PurchaseHeader.SetRange("Document Type", PurchaseHeader."Document Type"::Invoice);
        PurchaseHeader.SetRange(Status, PurchaseHeader.Status::Released);
        if PurchaseHeader.FindSet() then begin
            Clear(PurchaseInvoicesList);
            PurchaseInvoicesList.LookupMode; // Any user-defined method  
            PurchaseInvoicesList.SetTableView(PurchaseHeader);
            PurchaseInvoicesList.SetRecord(PurchaseHeader);
            if PurchaseInvoicesList.RunModal = Action::LookupOK then
                PurchaseInvoicesList.GetRecord(PurchaseHeader)
        end;
    end;

    // KD :: 12052022 --

    var
        PurchaseHeader: Record "Purchase Header";
        PurchaseInvoicesList: Page "Purchase Invoices";
}