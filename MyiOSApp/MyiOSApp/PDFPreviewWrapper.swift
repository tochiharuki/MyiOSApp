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
    @State private var tempFileURL: URL? = nil
    @State private var showDocumentPicker = false

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
        }
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showDocumentPicker) {
            if let fileURL = tempFileURL {
                // ✅ ピッカーは内部で自動表示する（1回目から確実）
                AutoPresentingDocumentPicker(fileURL: fileURL)
            } else {
                Text("PDFを生成できませんでした。")
            }
        }
    }

    // 一時ファイルにPDFを書き出して → ピッカーで保存先選択
    private func savePDFToTemporaryFile() {
        let tempURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("領収書_\(Date().timeIntervalSince1970).pdf")
        do {
            try data.write(to: tempURL)
            tempFileURL = tempURL
            showDocumentPicker = true
            print("✅ 一時PDF作成: \(tempURL)")
        } catch {
            print("❌ PDF一時保存失敗: \(error)")
        }
    }
}

// ✅ ピッカーが自動で表示される UIViewControllerRepresentable
struct AutoPresentingDocumentPicker: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIViewController {
        let viewController = UIViewController()
        DispatchQueue.main.async {
            let picker = UIDocumentPickerViewController(forExporting: [fileURL])
            picker.allowsMultipleSelection = false
            picker.modalPresentationStyle = .formSheet
            viewController.present(picker, animated: true)
        }
        return viewController
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}
}