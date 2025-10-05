//
//  ReceiptHistory.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/10/05.
//

import Foundation

struct ReceiptHistory: Identifiable, Codable {
    var id: UUID 
    let data: Data
    let date: Date
}
