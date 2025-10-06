import SwiftUI
import PDFKit
import UIKit

struct PDFPreviewWrapper: View {
    let data: Data

    @State private var showDocumentPicker = false
    @State private var tempFileURL: URL? = nil
    @State private var errorMessage: String? = nil   // ← エラー内容を保持

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

            // 🔻 エラーがある場合のみ表示
            if let errorMessage = errorMessage {
                Text("PDFを生成できませんでした。\n\(errorMessage)")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: errorMessage) // アニメーション表示
        // ✅ ナビゲーションバーを統一
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)

        // ✅ ピッカー表示
        .sheet(isPresented: $showDocumentPicker) {
            if let fileURL = tempFileURL {
                DocumentPickerView(fileURL: fileURL)
            }
        }
    }

    // 一時ファイルにPDFを書き出して → ピッカーで保存先選択
    private func savePDFToTemporaryFile() {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "領収書_\(Date().timeIntervalSince1970).pdf"
        )

        // 🔹 まずはデータサイズをチェック
        print("PDFサイズ:", data.count)
        guard data.count > 0 else {
            self.errorMessage = "PDFデータが空です。"
            return
        }

        do {
            try data.write(to: tempURL)
            self.tempFileURL = tempURL
            self.errorMessage = nil // ← 成功したらエラーを消す
            print("✅ 一時PDF作成: \(tempURL)")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.showDocumentPicker = true
            }
        } catch {
            print("❌ PDF一時保存失敗: \(error)")
            self.errorMessage = error.localizedDescription
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