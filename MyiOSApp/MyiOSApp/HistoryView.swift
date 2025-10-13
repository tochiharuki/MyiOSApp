//
//  HistoryView.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import SwiftUI
import Foundation  // JSONDecoder, Data など

struct HistoryView: View {
    @State private var histories: [ReceiptHistory] = []
    private let manager = ReceiptHistoryManager()
    
    var body: some View {
        List {
            ForEach(histories) { history in
                NavigationLink(destination: ReceiptView(prefilledData: decodeData(history.data))) {
                    VStack(alignment: .leading) {
                        Text("日付: \(formattedDate(history.date))")   // ← ✅ 日本語形式
                        Text("宛名: \(decodeData(history.data).recipient)")
                        Text("但し書き: \(decodeData(history.data).remarks)")
                    }
                }
            }
            .onDelete(perform: deleteHistory)
        }
        .navigationTitle("履歴")
        .onAppear {
            histories = manager.loadHistory()
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                            .foregroundColor(.white)
                        Text("戻る")
                            .foregroundColor(.white)  // ← ここで白に固定
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true) // ← 標準の戻るを非表示に
    }
    
    /// ✅ ReceiptData を安全に復元
    private func decodeData(_ data: Data) -> ReceiptData {
        (try? JSONDecoder().decode(ReceiptData.self, from: data)) ?? ReceiptData()
    }
    
    /// ✅ 履歴削除処理
    private func deleteHistory(at offsets: IndexSet) {
        histories.remove(atOffsets: offsets)
        manager.saveHistory(histories)
    }
    
    /// ✅ 日付を日本語形式で表示する関数
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ja_JP") // ← 日本語ロケール
        formatter.dateFormat = "yyyy年MM月dd日"         // ← 任意のフォーマット
        return formatter.string(from: date)
    }
}