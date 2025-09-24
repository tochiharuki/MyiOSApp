struct ReceiptData: Identifiable, Codable {
    var id = UUID()
    var issueDate: Date = Date()
    var recipient: String = ""
    var remarks: String = ""
    var companyName: String = ""

    // 入力されるのは合計金額のみ
    var amount: Double? = nil

    /// 税率の指定（"8%" or "10%"）
    var taxRate: String = "10%"

    /// 税区分（"内税" or "外税"）
    var taxType: String = "外税"

    // --- 計算プロパティ ---

    /// 税率を数値化
    private var rateValue: Double {
        taxRate == "8%" ? 0.08 : 0.10
    }

    /// 税額
    var tax: Double {
        guard let amount = amount else { return 0 }
        if taxType == "内税" {
            return amount - (amount / (1 + rateValue))
        } else {
            return amount * rateValue
        }
    }

    /// 税抜き金額
    var subtotal: Double {
        guard let amount = amount else { return 0 }
        if taxType == "内税" {
            return amount / (1 + rateValue)
        } else {
            return amount
        }
    }

    /// 税込み合計
    var totalAmount: Double {
        guard let amount = amount else { return 0 }
        if taxType == "内税" {
            return amount
        } else {
            return amount + tax
        }
    }
}