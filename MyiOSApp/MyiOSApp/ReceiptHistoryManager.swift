//
//  ReceiptHistoryManager.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/10/05.
//

import Foundation

class ReceiptHistoryManager {
    private let key = "receipt_history"
    
    func loadHistory() -> [ReceiptHistory] {
        if let data = UserDefaults.standard.data(forKey: key),
           let decoded = try? JSONDecoder().decode([ReceiptHistory].self, from: data) {
            return decoded.sorted { $0.date > $1.date } // 新しい順
        }
        return []
    }
    // 履歴を保存するファイルURLを取得
    private func getFileURL() -> URL {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documents.appendingPathComponent(fileName)
    }

    func saveHistory(_ histories: [ReceiptHistory]) {
        let url = getFileURL()
        if let data = try? JSONEncoder().encode(histories) {
            try? data.write(to: url)
        }
    }
    
    func add(entry: ReceiptHistory) {
        var histories = loadHistory()
        histories.insert(entry, at: 0) // 最新を先頭に
        if let encoded = try? JSONEncoder().encode(histories) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
    
    func delete(id: UUID) {
        var histories = loadHistory()
        histories.removeAll { $0.id == id }
        if let encoded = try? JSONEncoder().encode(histories) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }
}
