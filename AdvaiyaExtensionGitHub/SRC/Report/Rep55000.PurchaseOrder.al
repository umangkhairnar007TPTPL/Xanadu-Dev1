report 55000 PurchaseOrder
{
    DefaultLayout = RDLC;
    RDLCLayout = './SRC/Layouts/PurchaseOrder.rdl';
    Caption = 'PurchaseOrder';
    dataset
    {
        dataitem("Purchase Header"; "Purchase Header")
        {
            column(CompanyInfoName; CompanyInfo.Name) { }
            column(CompanyInfoName2; CompanyInfo."Name 2") { }
            column(CompanyInfoAddress; CompanyInfo.Address) { }
            column(CompanyInfoAddress2; CompanyInfo."Address 2") { }
            column(CompanyInfoCity; CompanyInfo.City) { }
            column(CompanyInfoStateCode; CompanyInfo."State Code") { }
            column(CompanyInfoCounty; CompanyInfo.County) { }
            column(CompanyInfoPostCode; CompanyInfo."Post Code") { }
            column(CompanyInfoGSTRegistrationNo; CompanyInfo."GST Registration No.") { }
            column(CompanyInfoPANNo; CompanyInfo."P.A.N. No.") { }
            column(CompanyInfoStateDesc; CompinfoState.Description) { }
            column(No_; "No.") { }
            column(Order_Date; "Order Date") { }
            column(Vendor_Order_No_; "Vendor Order No.") { }
            column(Buy_from_Vendor_Name; "Buy-from Vendor Name") { }
            column(Buy_from_Address; "Buy-from Address") { }
            column(Buy_from_Address_2; "Buy-from Address 2") { }
            column(Buy_from_City; "Buy-from City") { }
            column(BuyFromVendorGSTNo; Vendor."GST Registration No.") { }
            column(BuyFromVendorPANNo; Vendor."P.A.N. No.") { }
            column(Buy_fromStateDesc; BuyFromState.Description) { }
            column(BuyFromStateCode; BuyFromState."State Code (GST Reg. No.)") { }
            column(Buy_from_Post_Code; "Buy-from Post Code") { }

            column(Buy_fromCountryDesc; CountryRegion.Name) { }
            column(Currency_Code; "Currency Code") { }
            column(currencycode; CurrencyCode) { }
            column(CurrencySymbol; CurrencySymbol) { }
            column(BudgetDesc; BudgetDesc) { }
            column(PurchaserDesc; PurchaserDescemail) { }

            dataitem("Purchase Line"; "Purchase Line")
            {
                DataItemLink = "Document No." = FIELD("No.");
                DataItemTableView = sorting("Line No.");

                column(Document_No_; "Document No.") { }
                column(Line_No_; "Line No.") { }
                column(Description; Description) { }
                column(QuantityLines; Quantity) { }
                column(Unit_Cost; "Unit Cost") { }
                column(SrNo; SrNo) { }
                column(CGSTAmount; CGSTAmount) { }
                column(IGSTAmount; IGSTAmount) { }
                column(SGSTAmount; SGSTAmount) { }
                column(TotalCGSTAmount; TotalCGSTAmount) { }
                column(TotalIGSTAmount; TotalIGSTAmount) { }
                column(TotalSGSTAmount; TotalSGSTAmount) { }
                column(TotalLineAmount; TotalLineAmount) { }
                column(TotalLineAmounttoConvert; TotalLineAmounttoConvert) { }
                column(AmountinWords; AmountinWords) { }
                column(GLDescription; GLDescription) { }


                trigger OnAfterGetRecord()
                var
                    Check: Report Check;
                    GenPostingSetup: Record "General Posting Setup";
                    GLAccount: Record "G/L Account";
                begin
                    clear(GLDescription);
                    SrNo += 1;
                    GetCGSTAmount("Purchase Line".RecordId, CGSTAmount);
                    GetSGSTAmount("Purchase Line".RecordId, SGSTAmount);
                    GetIGSTAmount("Purchase Line".RecordId, IGSTAmount);
                    TotalCGSTAmount += CGSTAmount;
                    TotalIGSTAmount += IGSTAmount;
                    TotalSGSTAmount += SGSTAmount;
                    TotalLineAmount += "Line Amount";
                    TotalLineAmounttoConvert := TotalLineAmount + TotalCGSTAmount + TotalIGSTAmount + TotalSGSTAmount;

                    // Check.InitTextVariable();
                    // Check.FormatNoText(NoText, TotalLineAmounttoConvert, "Purchase Header"."Currency Code");
                    // AmountinWords := NoText[1] + NoText[2];

                    if GenPostingSetup.get("Gen. Bus. Posting Group", "Gen. Prod. Posting Group") then
                        if GLAccount.Get(GenPostingSetup."Purch. Account") then
                            GLDescription := GLAccount.Name;


                end;
            }

            trigger OnAfterGetRecord()
            var
                PurchHeader: Record "Purchase Header";
                PurchaseLines: Record "Purchase Line";
                SalesPersonpurchaser: Record "Salesperson/Purchaser";
            begin
                Clear(PurchaserDescEmail);
                Clear(SrNo);
                Clear(TotalCGSTAmount);
                Clear(TotalIGSTAmount);
                Clear(TotalSGSTAmount);
                Clear(TotalLineAmount);
                Clear(TotalLineAmounttoConvert);
                if "Currency Code" = '' then begin
                    CurrencyCode := GLSetup."LCY Code";
                    CurrencySymbol := GLSetup."Local Currency Symbol";
                end else begin
                    CurrencyCode := "Currency Code";
                    if Currency.get(CurrencyCode) then;
                    CurrencySymbol := Currency.Symbol;
                end;
                if PurchHeader.get("Purchase Header"."Document Type", "Purchase Header"."No.") then;
                if Vendor.get(PurchHeader."Buy-from Vendor No.") then;
                if BuyFromState.Get(Vendor."State Code") then;
                if CountryRegion.Get(PurchHeader."Buy-from Country/Region Code") then;

                DocDateMonth := Date2DMY("Purchase Header"."Document Date", 2);
                DocDateYear := Date2DMY("Purchase Header"."Document Date", 3);
                DocDate := DMY2Date(1, DocDateMonth, DocDateYear);


                PurchaseLines.Reset();
                PurchaseLines.SetRange("Document Type", "Purchase Header"."Document Type"::Order);
                PurchaseLines.SetRange("Document No.", "Purchase Header"."No.");
                if PurchaseLines.FindSet() then begin
                    repeat
                        if PurchaseLines.type = PurchaseLines.Type::"G/L Account" then begin
                            if BudgetDesc = '' then begin
                                GLBudget.Reset();
                                GLBudget.SetRange("G/L Account No.", PurchaseLines."No.");
                                GLBudget.SetRange(Date, DocDate);
                                if GLBudget.FindFirst() then begin
                                    if GLBudgetName.Get(GLBudget."Budget Name") then
                                        BudgetDesc := GLBudgetName.Description;
                                end;
                            end;
                        end;
                    until PurchaseLines.Next() = 0;
                end;

                if "Purchaser Code" <> '' then begin
                    if SalesPersonpurchaser.get("Purchaser Code") then begin
                        if SalesPersonpurchaser."E-Mail" <> '' then
                            PurchaserDescEmail := SalesPersonpurchaser.Name + ' - ' + SalesPersonpurchaser."E-Mail"
                        else
                            PurchaserDescEmail := SalesPersonpurchaser.Name;
                    end;
                end;

            end;
        }
    }

    labels
    {
        POLabel = 'PURCHASE ORDER';
        Invoiceto = 'Invoice To';
        Supplier = 'Supplier';
        PONo = 'PO No.';
        Dated = 'Dated';
        InvoiceNo = 'Invoice No';
        ModeTermsofPayment = 'Mode/Terms of Payment:';
        DespatchThrough = 'Despatch Through';
        Destination = 'Destination';
        AddLbl = 'Add';
        PAN = 'PAN';
        GST = 'GST';
        StateCode = 'State Code';
        Name = 'Name';
        BudgetName = 'Budget Name';
        BudgetCostHead = 'Budget Cost Head';
        SlNo = 'Sl No.';
        DescriptionofGoodsServices = 'Description of Goods/Services';
        Quantity = 'Quantity';
        Rate = 'Rate';
        Per = 'Per';
        Amount = 'Amount';
        TOTAL = 'TOTAL';
        IGST = 'IGST';
        CGST = 'CGST';
        SGST = 'SGST';
        GRANDTOTAL = 'GRAND TOTAL';
        EOE = 'E. & O.E';
        AuthorisedSignatory = 'Authorised Signatory';
        AmountChargeableinwords = 'Amount Chargeable(in words)';
        ForXanaduRealtyPvtLtd = 'For Xanadu Realty Pvt. Ltd.';
        PreparedBy = 'Prepared by';
    }

    trigger OnPreReport()
    begin
        CompanyInfo.get();
        CompinfoState.Get(CompanyInfo."State Code");
        GLSetup.Get();
    end;

    procedure GetIGSTAmount(RecID: RecordID; var GSTAmount: Decimal)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        i: Integer;
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;
        TaxComponent.Reset();
        TaxComponent.SetCurrentKey(ID, "Visible On Interface");
        TaxComponent.SetRange("Visible On Interface", true);
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetFilter(Name, 'IGST');
        if TaxComponent.FindFirst() then begin
            TaxTransactionValue.SetRange("Tax Record ID", RecID);
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            TaxTransactionValue.SetFilter(Amount, '<>%1', 0);
            TaxTransactionValue.SetRange("Value ID", TaxComponent.ID);
            if TaxTransactionValue.FindFirst() then begin
                GSTAmount := TaxTransactionValue.Amount;
            end;
        end;
    end;

    procedure GetCGSTAmount(RecID: RecordID; var GSTAmount: Decimal)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        i: Integer;
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;
        TaxComponent.Reset();
        TaxComponent.SetCurrentKey(ID, "Visible On Interface");
        TaxComponent.SetRange("Visible On Interface", true);
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetFilter(Name, 'CGST');
        if TaxComponent.FindFirst() then begin
            TaxTransactionValue.SetRange("Tax Record ID", RecID);
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            TaxTransactionValue.SetFilter(Amount, '<>%1', 0);
            TaxTransactionValue.SetRange("Value ID", TaxComponent.ID);
            if TaxTransactionValue.FindFirst() then begin
                GSTAmount := TaxTransactionValue.Amount;
            end;
        end;
    end;

    procedure GetSGSTAmount(RecID: RecordID; var GSTAmount: Decimal)
    var
        TaxTransactionValue: Record "Tax Transaction Value";
        GSTSetup: Record "GST Setup";
        i: Integer;
        TaxComponent: Record "Tax Component";
    begin
        if not GSTSetup.Get() then
            exit;
        TaxComponent.Reset();
        TaxComponent.SetCurrentKey(ID, "Visible On Interface");
        TaxComponent.SetRange("Visible On Interface", true);
        TaxComponent.SetRange("Tax Type", GSTSetup."GST Tax Type");
        TaxComponent.SetFilter(Name, 'SGST');
        if TaxComponent.FindFirst() then begin
            TaxTransactionValue.SetRange("Tax Record ID", RecID);
            TaxTransactionValue.SetRange("Value Type", TaxTransactionValue."Value Type"::COMPONENT);
            TaxTransactionValue.SetRange("Tax Type", GSTSetup."GST Tax Type");
            TaxTransactionValue.SetFilter(Percent, '<>%1', 0);
            TaxTransactionValue.SetFilter(Amount, '<>%1', 0);
            TaxTransactionValue.SetRange("Value ID", TaxComponent.ID);
            if TaxTransactionValue.FindFirst() then begin
                GSTAmount := TaxTransactionValue.Amount;
            end;
        end;
    end;

    var
        PurchaserDescEmail: Text;
        DocDateMonth: Integer;
        DocDateYear: Integer;
        DocDate: Date;
        GLBudgetName: Record "G/L Budget Name";
        GLBudget: Record "G/L Budget Entry";
        BudgetDesc: Text;
        GLDescription: Text;
        Currency: Record Currency;
        CurrencySymbol: Text;
        GLSetup: Record "General Ledger Setup";
        CurrencyCode: Code[10];
        AmountinWords: Text;
        NoText: array[5] of Text;
        TotalLineAmounttoConvert: Decimal;
        TotalLineAmount: Decimal;
        TotalSGSTAmount: Decimal;
        TotalCGSTAmount: Decimal;
        TotalIGSTAmount: Decimal;
        SGSTAmount: Decimal;
        CGSTAmount: Decimal;
        IGSTAmount: Decimal;
        SrNo: Integer;
        CountryRegion: Record "Country/Region";
        BuyFromState: Record State;
        CompinfoState: Record State;
        Vendor: Record Vendor;
        CompanyInfo: Record "Company Information";

}
