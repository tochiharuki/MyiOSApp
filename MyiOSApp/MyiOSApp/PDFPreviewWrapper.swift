//
//  PDFPreviewWrapper.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/23.
//

import SwiftUI
import PDFKit
import UniformTypeIdentifiers

struct PDFPreviewWrapper: View {
    let data: Data  // ✅ 生成済みPDFデータを受け取る

    @State private var showFileExporter = false
    @State private var showErrorMessage = false

    var body: some View {
        VStack(spacing: 20) {
            // PDF表示
            if let document = PDFDocument(data: data) {
                PDFKitView(pdfDocument: document)
                    .frame(maxHeight: 450)
            } else {
                Text("PDFの読み込みに失敗しました。")
                    .foregroundColor(.red)
            }

            // 保存ボタン
            Button("PDFを保存") {
                if !data.isEmpty {
                    showFileExporter = true
                } else {
                    showErrorMessage = true
                }
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 20)

            // 失敗時メッセージ
            if showErrorMessage {
                Text("PDFデータが無効です。")
                    .foregroundColor(.red)
                    .bold()
            }
        }
        .padding()
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // ✅ ファイル保存先選択
        .fileExporter(
            isPresented: $showFileExporter,
            document: PDFDocumentData(data: data),
            contentType: .pdf,
            defaultFilename: "領収書"
        ) { result in
            switch result {
            case .success(let url):
                print("✅ 保存完了: \(url.path)")
            case .failure(let error):
                print("❌ 保存失敗: \(error.localizedDescription)")
            }
        }
    }
}

// MARK: - PDF表示ビュー
struct PDFKitView: UIViewRepresentable {
    let pdfDocument: PDFDocument

    func makeUIView(context: Context) -> PDFView {
        let view = PDFView()
        view.autoScales = true
        view.displayMode = .singlePageContinuous
        view.displayDirection = .vertical
        view.document = pdfDocument
        return view
    }

    func updateUIView(_ uiView: PDFView, context: Context) {
        uiView.document = pdfDocument
    }
}

// MARK: - FileDocument準拠で保存処理
struct PDFDocumentData: FileDocument {
    static var readableContentTypes: [UTType] { [.pdf] }
    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        self.data = Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}