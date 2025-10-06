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
                generatePDFAndShowPicker()
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)

            // 🔻 エラーがある場合のみ表示
            if let errorMessage = errorMessage {
                Text("PDFを生成でききませんでした。\n\(errorMessage)")
                    .font(.footnote)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.top, 10)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut, value: errorMessage)
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .sheet(isPresented: $showDocumentPicker) {
            if let fileURL = tempFileURL {
                DocumentPickerView(fileURL: fileURL)
            }
        }
    }

    // 🔹 1回目から確実に動くようにしたバージョン
    private func generatePDFAndShowPicker() {
        // データチェック
        guard data.count > 0 else {
            errorMessage = "PDFデータが空です。"
            print("❌ PDFデータが空")
            return
        }

        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(
            "領収書_\(Date().timeIntervalSince1970).pdf"
        )

        do {
            try data.write(to: tempURL)
            tempFileURL = tempURL
            errorMessage = nil

            print("✅ 一時PDF作成成功: \(tempURL)")

            // 🔹 sheet 表示を遅延させる（SwiftUI のタイミングバグ対策）
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                showDocumentPicker = true
            }

        } catch {
            print("❌ PDF保存失敗: \(error)")
            errorMessage = error.localizedDescription
        }
    }
}

struct DocumentPickerView: UIViewControllerRepresentable {
    let fileURL: URL

    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forExporting: [fileURL])
        picker.allowsMultipleSelection = false
        return picker
    }

    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
}