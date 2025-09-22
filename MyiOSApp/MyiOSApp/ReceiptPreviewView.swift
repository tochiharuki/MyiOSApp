//
//  ReceiptPreviewView.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import SwiftUI

struct ReceiptPreviewView: View {
    var receiptData: ReceiptData
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("領収書プレビュー")
                .font(.title2)
                .fontWeight(.bold)
            
            Group {
                Text("発行日: \(previewDateFormatter.string(from: receiptData.issueDate))")
                Text("宛名: \(receiptData.recipient)")
                Text("金額: \(receiptData.amount)円 (\(receiptData.taxType)・税率 \(receiptData.taxRate))")
                Text("但し書き: \(receiptData.remarks)")
                Text("発行元: \(receiptData.companyName)")
            }
            .padding(.vertical, 2)
            
            Spacer()
            
            Button(action: {
                // 後でPDF生成処理を追加
                print("PDF生成予定")
            }) {
                Text("PDFを作成")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
}

// 日本語日付用フォーマッター
private let previewDateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "ja_JP")
    formatter.dateStyle = .long
    return formatter
}()