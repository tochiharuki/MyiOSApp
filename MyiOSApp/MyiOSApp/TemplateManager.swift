//
//  TemplateManager.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/10/05.
//

import Foundation

class TemplateManager {
    private let key = "receiptTemplates"

    // 保存されているテンプレート一覧を取得
    func loadTemplates() -> [ReceiptTemplate] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        if let templates = try? JSONDecoder().decode([ReceiptTemplate].self, from: data) {
            return templates
        }
        return []
    }

    // テンプレートを保存
    func saveTemplate(_ template: ReceiptTemplate) {
        var templates = loadTemplates()
        templates.append(template)
        if let data = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    // 削除（任意機能）
    func deleteTemplate(id: UUID) {
        var templates = loadTemplates()
        templates.removeAll { $0.id == id }
        if let data = try? JSONEncoder().encode(templates) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
}

