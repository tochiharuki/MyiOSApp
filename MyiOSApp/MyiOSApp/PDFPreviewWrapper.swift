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
    @State private var showDocumentPicker = false
    @State private var tempFileURL: URL? = nil
    @State private var showError = false

    var body: some View {
        VStack {
            // ✅ PDFプレビュー
            PDFKitView(data: data)
                .edgesIgnoringSafeArea(.all)

            Spacer(minLength: 20)

            // ✅ 保存ボタン
            Button("PDFを保存") {
                savePDFToTemporaryFile()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        // ✅ ナビゲーションバー設定
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)

        // ✅ 保存先選択シート
        .sheet(isPresented: $showDocumentPicker) {
            if let fileURL = tempFileURL {
                DocumentPickerView(fileURL: fileURL)
            } else {
                Text("PDFを生成できませんでした。")
                    .foregroundColor(.red)
                    .padding()
            }
        }

        // ✅ 失敗時アラート
        .alert("PDFの保存に失敗しました", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        }
    }

    // MARK: - PDFを一時ファイルとして保存
    private func savePDFToTemporaryFile() {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("領収書_\(Int(Date().timeIntervalSince1970)).pdf")

        do {
            try data.write(to: tempURL)
            self.tempFileURL = tempURL
            self.showDocumentPicker = true
            print("✅ 一時PDF作成成功: \(tempURL)")
        } catch {
            print("❌ PDF一時保存失敗: \(error)")
            self.showError = true
        }
    }
}

// MARK: - DocumentPickerView
struct DocumentPickerView: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [fileURL])
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}