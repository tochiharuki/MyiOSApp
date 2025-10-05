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
            Spacer() // PDF とボタンを分ける
            Button(action: savePDF) {
                Text("PDFを保存")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .padding()
            }
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

private func savePDF() {
    let fileName = "領収書_\(Date().timeIntervalSince1970).pdf"
    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentsURL.appendingPathComponent(fileName)
    
    do {
        try data.write(to: fileURL)
        print("PDF保存完了: \(fileURL)")
        
        // 履歴に追加
        let historyManager = ReceiptHistoryManager()
        let newEntry = ReceiptHistory(data: data, date: Date())
        historyManager.add(entry: newEntry)
        
    } catch {
        print("PDF保存失敗: \(error)")
    }
}
