//
//  PDFPreviewWrapper.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/23.
//

import SwiftUI
import PDFKit
import UIKit

struct PDFPreviewWrapper: View {
    let data: Data
    @State private var showShareSheet = false

    // 履歴管理用
    private let historyManager = ReceiptHistoryManager()

    var body: some View {
        VStack {
            // ✅ PDFプレビュー
            PDFKitView(data: data)
                .edgesIgnoringSafeArea(.all)

            Spacer(minLength: 20)

            // ✅ 共有ボタン（押すと履歴に保存される）
            Button("PDFを共有") {
                saveToHistory()   // まず履歴に保存
                showShareSheet = true  // 共有シート表示
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 30)
        }
        // ✅ ナビゲーションバーを青背景・白アイコンに統一
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)

        // ✅ シェアシート
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [data])
        }
    }

    // ✅ 履歴へ保存する処理
    private func saveToHistory() {
        do {
            // ReceiptData にデコード
            let receiptData = try JSONDecoder().decode(ReceiptData.self, from: data)

            // ReceiptHistory 作成
            let entry = ReceiptHistory(
                id: UUID(),
                data: try JSONEncoder().encode(receiptData),
                date: Date()
            )

            // 保存
            historyManager.add(entry: entry)
            print("✅ 履歴に保存しました: \(entry.id)")
        } catch {
            print("⚠️ ReceiptData のデコードまたは履歴保存に失敗しました: \(error)")
        }
    }
}

// ✅ UIKit の UIActivityViewController を SwiftUI でラップ
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}