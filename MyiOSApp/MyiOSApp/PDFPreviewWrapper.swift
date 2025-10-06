import SwiftUI
import PDFKit
import UIKit

struct PDFPreviewWrapper: View {
    let data: Data

    @State private var showDocumentPicker = false
    @State private var tempFileURL: URL? = nil
    @State private var showErrorAlert = false
    @State private var errorMessage = ""

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
        // ✅ ナビゲーションバーを統一
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)

        // ✅ ドキュメントピッカー
        .sheet(isPresented: $showDocumentPicker) {
            if let fileURL = tempFileURL {
                DocumentPickerView(fileURL: fileURL)
            } else {
                Text("PDFを生成できませんでした。")
            }
        }

        // ✅ エラーアラート
        .alert("PDFの保存に失敗しました", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text(errorMessage)
        }
    }

    /// 一時ファイルにPDFを書き出して → ピッカーで保存先選択
    private func savePDFToTemporaryFile() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "領収書_\(Date().timeIntervalSince1970).pdf"
        )

        do {
            try data.write(to: tempURL)
            self.tempFileURL = tempURL
            print("✅ 一時PDF作成: \(tempURL)")
            // 少し遅延させてピッカーを確実に表示
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showDocumentPicker = true
            }
        } catch {
            print("❌ PDF一時保存失敗: \(error)")
            self.errorMessage = error.localizedDescription
            self.showErrorAlert = true
        }
    }
}

/// ✅ ファイル保存先をユーザーに選ばせる
struct DocumentPickerView: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [fileURL])
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}