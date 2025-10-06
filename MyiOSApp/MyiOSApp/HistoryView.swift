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
                        Text("日付: \(history.date.formatted(.dateTime.year().month().day()))")
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
    }
    
    private func decodeData(_ data: Data) -> ReceiptData {
        (try? JSONDecoder().decode(ReceiptData.self, from: data)) ?? ReceiptData()
    }
    private func deleteHistory(at offsets: IndexSet) {
        // 選択された履歴を削除
        histories.remove(atOffsets: offsets)
        // 保存データを更新
        manager.saveHistory(histories)
    }
}
