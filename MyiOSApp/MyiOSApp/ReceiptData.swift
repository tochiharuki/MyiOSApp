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
    var remarks: String = ""
    var companyName: String = ""

    // --- 金額関係 ---
    var subtotal8: Double? = nil    // 8%対象額
    var subtotal10: Double? = nil   // 10%対象額

    /// 税率の指定（"8%" or "10%" など）
    var taxRate: String = "10%"

    /// 税区分（"内税" or "外税"）
    var taxType: String = "外税"

    // --- 計算プロパティ ---
    
    /// 8%の税額
    var tax8: Double {
        (subtotal8 ?? 0) * 0.08
    }

    /// 10%の税額
    var tax10: Double {
        (subtotal10 ?? 0) * 0.10
    }

    /// 税込み合計
    var totalAmount: Double {
        let s8 = subtotal8 ?? 0
        let s10 = subtotal10 ?? 0

        if taxType == "内税" {
            // すでに税込み
            return s8 + s10
        } else {
            // 外税 → 税を加算
            return s8 + s10 + tax8 + tax10
        }
    }
}