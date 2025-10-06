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

    var body: some View {
        VStack {
            // ✅ PDFプレビュー
            PDFKitView(data: data)
                .edgesIgnoringSafeArea(.all)

            Spacer(minLength: 20)

            // ✅ 共有ボタン（保存ボタンの代わり）
            // ✅ 共有ボタン（押すと履歴にも保存）
            Button("PDFを共有") {
                saveToHistory() // ← 履歴に追加
                showShareSheet = true
            }

            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .padding(.bottom, 30)
        }
        // ✅ ナビゲーションバー統一
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
        // PDF元データがない場合は簡単なダミーで保存
        let dummyReceipt = ReceiptData(recipient: "共有済みPDF", remarks: "PDFを共有しました")
        let entry = ReceiptHistory(
            id: UUID(),
            date: Date(),
            data: try! JSONEncoder().encode(dummyReceipt)
        )
        historyManager.add(entry: entry)
        print("✅ 履歴に保存しました: \(entry.id)")
    }
}

struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}