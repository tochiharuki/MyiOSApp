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
    @State private var showDocumentPicker = false
    @State private var tempFileURL: URL? = nil

    var body: some View {
        VStack {
            PDFKitView(data: data)
                .edgesIgnoringSafeArea(.all)
            Spacer(minLength: 20)
            Button("PDFを保存") {
                // ボタンを押した瞬間に一時ファイルを生成
                savePDFToTemporaryFile()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .sheet(isPresented: $showDocumentPicker) {
                if let fileURL = tempFileURL {
                    DocumentPickerView(fileURL: fileURL)
                } else {
                    Text("PDFを生成できませんでした。")
                }
            }
        }
        // ✅ ナビゲーションバーを統一
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // ✅ 保存時にドキュメントピッカーを開く
        .sheet(isPresented: $showDocumentPicker) {
            if let fileURL = tempFileURL {
                DocumentPickerView(fileURL: fileURL)
            }
        }
    }

    // 一時ファイルにPDFを書き出して → ピッカーで保存先選択
    private func savePDFToTemporaryFile() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("領収書_\(Date().timeIntervalSince1970).pdf")
        do {
            try data.write(to: tempURL)
            self.tempFileURL = tempURL
            self.showDocumentPicker = true
            print("✅ 一時PDF作成: \(tempURL)")
        } catch {
            print("❌ PDF一時保存失敗: \(error)")
        }
    }
}

// ✅ ファイル保存先をユーザーに選ばせる
struct DocumentPickerView: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [fileURL])
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}

