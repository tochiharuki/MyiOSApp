//
//  ReceiptTemplate.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/10/05.
//

import Foundation

struct ReceiptTemplate: Identifiable, Codable {
    var id = UUID()
    var name: String      // テンプレート名
    var data: ReceiptData // 領収書内容
}

