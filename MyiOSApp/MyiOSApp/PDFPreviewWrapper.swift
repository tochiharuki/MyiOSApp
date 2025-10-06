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
    @State private var errorMessage: String? = nil

    var body: some View {
        VStack {
            PDFKitView(data: data)
                .edgesIgnoringSafeArea(.all)
            
            Spacer(minLength: 20)
            
            Button("PDFを保存") {
                savePDFToTemporaryFile()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            
            // ✅ エラーがある場合のみ表示
            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
        // ✅ ナビゲーションバー設定
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        
        // ✅ DocumentPicker 表示
        .sheet(isPresented: $showDocumentPicker) {
            if let fileURL = tempFileURL {
                DocumentPickerView(fileURL: fileURL)
            } else {
                Text("PDFを生成できませんでした。")
                    .foregroundColor(.red)
            }
        }
    }

    // MARK: - PDFを一時保存してPicker表示
    private func savePDFToTemporaryFile() {
        // まずエラーメッセージをクリア
        errorMessage = nil
        
        // 一時ファイルのパス
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("領収書_\(Date().timeIntervalSince1970).pdf")
        
        do {
            // PDFデータを書き込み
            try data.write(to: tempURL)
            
            // 少し遅延を入れて state 反映を安定化
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.tempFileURL = tempURL
                self.showDocumentPicker = true
            }
            
            print("✅ 一時PDF作成: \(tempURL)")
        } catch {
            // 失敗時のエラーメッセージ
            self.errorMessage = "PDFの作成に失敗しました: \(error.localizedDescription)"
            print("❌ PDF一時保存失敗: \(error)")
        }
    }
}

// MARK: - Document Picker
struct DocumentPickerView: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [fileURL])
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}