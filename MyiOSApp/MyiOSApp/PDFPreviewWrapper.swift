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
    let pdfData: Data           // ← PDFプレビュー用
    let receiptData: ReceiptData  // ← 履歴保存用
    @State private var showShareSheet = false

    // 履歴管理
    private let historyManager = ReceiptHistoryManager()

    var body: some View {
        VStack {
            // ✅ PDFプレビュー
            PDFKitView(data: pdfData)
                .edgesIgnoringSafeArea(.all)

            Spacer(minLength: 20)

            // ✅ 共有ボタン（押すと履歴にも保存）
            Button("PDFを共有") {
                saveToHistory()      // 履歴に保存
                showShareSheet = true  // シェアシート表示
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
            ActivityView(activityItems: [pdfData])
        }
    }

    // ✅ 履歴へ保存
    private func saveToHistory() {
        do {
            let entry = ReceiptHistory(
                id: UUID(),
                data: try JSONEncoder().encode(receiptData),
                date: Date()
            )
            historyManager.add(entry: entry)
            print("✅ 履歴に保存しました: \(entry.id)")
        } catch {
            print("⚠️ 履歴保存に失敗: \(error)")
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