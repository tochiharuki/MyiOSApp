//
//  PDFPreviewWrapper.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/23.
//

import SwiftUI
import PDFKit
import Foundation  // Data を扱うため

struct PDFPreviewWrapper: View {
    let data: Data
    
    @State private var showShareSheet = false
    
    var body: some View {
        VStack {
            PDFKitView(data: data)
                .edgesIgnoringSafeArea(.all)
            Spacer(minLength: 20)
            Button("PDFを保存") {
                savePDF(data: data)  // self を使わない
            }
            .padding()
            .background(Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        // ✅ ナビゲーションバーを青背景・白アイコンに統一
        .toolbarBackground(Color.blue, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        // ✅ シェアシート
        .sheet(isPresented: $showShareSheet) {
            ActivityView(activityItems: [data])
        }
    }
}

// UIKit の UIActivityViewController を SwiftUI でラップ
struct ActivityView: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        return UIActivityViewController(activityItems: activityItems,
                                        applicationActivities: applicationActivities)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

private func savePDF(data: Data) {
    let fileName = "領収書_\(Date().timeIntervalSince1970).pdf"
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(fileName)
    
    do {
        try data.write(to: fileURL)
        let historyManager = ReceiptHistoryManager()
        let newEntry = ReceiptHistory(id: UUID(), data: data, date: Date())
        historyManager.add(entry: newEntry)
        print("PDF保存成功")
    } catch {
        print("PDF保存失敗: \(error)")
    }
}
