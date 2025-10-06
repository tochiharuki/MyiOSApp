//
//  ReceiptHistoryManager.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/10/05.
//

import Foundation

class ReceiptHistoryManager {
    private let key = "receipt_history"

    // ✅ 履歴を読み込み（UserDefaults）
    func loadHistory() -> [ReceiptHistory] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ReceiptHistory].self, from: data) {
            return decoded.sorted { $0.date > $1.date } // 新しい順
        }
        return []
    }

    // ✅ 履歴を保存（UserDefaults）
    func saveHistory(_ histories: [ReceiptHistory]) {
        if let encoded = try? JSONEncoder().encode(histories) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    // ✅ 履歴を追加
    func add(entry: ReceiptHistory) {
        var histories = loadHistory()
        histories.insert(entry, at: 0) // 最新を先頭に
        saveHistory(histories)
    }

    // ✅ 履歴を削除
    func delete(id: UUID) {
        var histories = loadHistory()
        histories.removeAll { $0.id == id }
        saveHistory(histories)
    }
}
