//
//  PDFPreviewWrapper.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/23.
//

import SwiftUI

struct PDFPreviewWrapper: View {
    let data: Data
    
    @State private var showShareSheet = false
    
    var body: some View {
        VStack {
            PDFKitView(data: data)
                .edgesIgnoringSafeArea(.all)
        }
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
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