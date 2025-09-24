//
//  ReceiptData.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import Foundation

/// 領収書データをまとめる構造体
struct ReceiptData: Identifiable, Codable {
    let id = UUID()
    var issueDate: Date = Date()
    var recipient: String = ""
    var amount: Int = 0
    var taxRate: String = "10%"   // デフォルト
    var taxType: String = "外税"  // 内税 or 外税
    var remarks: String = ""
    var companyName: String = ""
}
