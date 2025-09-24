//
//  ReceiptData.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import Foundation

/// 領収書データをまとめる構造体
struct ReceiptData: Identifiable, Codable {
    var id = UUID()
    var issueDate: Date = Date()
    var recipient: String = ""
    var amount: Double? = nil
    var taxRate: String = "10%"   // デフォルト
    var taxType: String = "外税"  // 内税 or 外税
    var remarks: String = ""
    var companyName: String = ""

    // MARK: - 計算プロパティ
    private var rateValue: Double {
        switch taxRate {
        case "8%": return 0.08
        case "10%": return 0.10
        default: return 0.0
        }
    }

    /// 税額
    var tax: Double {
        guard let amount else { return 0 }
        if taxType == "内税" {
            return amount - (amount / (1 + rateValue))
        } else {
            return amount * rateValue
        }
    }

    /// 小計（税抜）
    var subtotal: Double {
        guard let amount else { return 0 }
        if taxType == "内税" {
            return amount / (1 + rateValue)
        } else {
            return amount
        }
    }

    /// 合計（税込み最終額）
    var totalAmount: Double {
        guard let amount else { return 0 }
        if taxType == "内税" {
            return amount
        } else {
            return amount + tax
        }
    }
}