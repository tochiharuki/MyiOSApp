//
//  ReceiptHistory.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/10/05.
//

import Foundation

struct ReceiptHistory: Identifiable, Codable {
    let id = UUID()
    let data: Data
    let date: Date
}
