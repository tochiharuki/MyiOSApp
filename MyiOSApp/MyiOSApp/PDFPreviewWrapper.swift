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
    @State private var showPicker = false
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

            if let error = errorMessage {
                Text(error)
                    .foregroundColor(.red)
                    .padding(.top, 10)
            }
        }
        // ✅ ナビゲーションバー統一
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // ✅ ピッカーを自動表示
        .fullScreenCover(isPresented: $showPicker) {
            if let fileURL = tempFileURL {
                AutoPresentingDocumentPicker(fileURL: fileURL) {
                    // Pickerを閉じた後に一時ファイル削除（任意）
                    try? FileManager.default.removeItem(at: fileURL)
                }
            }
        }
    }

    // 一時ファイルを生成してピッカーを開く
    private func savePDFToTemporaryFile() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("領収書_\(Date().timeIntervalSince1970).pdf")

        do {
            try data.write(to: tempURL)
            tempFileURL = tempURL
            showPicker = true
            errorMessage = nil
            print("✅ 一時PDF作成: \(tempURL)")
        } catch {
            errorMessage = "PDFの作成に失敗しました: \(error.localizedDescription)"
            print("❌ PDF一時保存失敗: \(error)")
        }
    }
}

//
// ✅ Pickerを自動的に表示するUIViewControllerRepresentable
//
struct AutoPresentingDocumentPicker: UIViewControllerRepresentable {
    let fileURL: URL
    let onDismiss: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = UIViewController()
        controller.view.backgroundColor = .clear
        DispatchQueue.main.async {
            let picker = UIDocumentPickerViewController(forExporting: [fileURL])
            picker.allowsMultipleSelection = false
            picker.delegate = context.coordinator
            controller.present(picker, animated: true)
        }
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onDismiss: onDismiss)
    }

    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDismiss: () -> Void

        init(onDismiss: @escaping () -> Void) {
            self.onDismiss = onDismiss
        }

        func documentPickerWasCancelled(_ controller: UIDocumentPickerViewController) {
            onDismiss()
        }

        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            onDismiss()
        }
    }
}