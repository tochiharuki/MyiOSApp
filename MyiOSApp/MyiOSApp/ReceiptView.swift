//
//  ReceiptView.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import SwiftUI
import UIKit   // UIApplication を使うために明示的に import

struct ReceiptView: View {
    @State private var receiptData = ReceiptData()
    @State private var showPreview = false
    @State private var showDatePicker = false
    @State private var pdfData: Data? = nil
    @State private var errorMessage: String? = nil
    @State private var isGenerating = false   // ← 追加（生成中フラグ）

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {

                Text("領収書作成")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)

                // 発行日（ボタン式）
                VStack(alignment: .leading, spacing: 5) {
                    Text("発行日")
                        .fontWeight(.medium)

                    Button(action: {
                        showDatePicker = true
                    }) {
                        HStack {
                            Text(dateFormatter.string(from: receiptData.issueDate))
                                .foregroundColor(.black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.5))
                        )
                    }
                    .sheet(isPresented: $showDatePicker) {
                        VStack {
                            DatePicker(
                                "",
                                selection: $receiptData.issueDate,
                                displayedComponents: .date
                            )
                            .datePickerStyle(.graphical)
                            .environment(\.locale, Locale(identifier: "ja_JP"))
                            .onChange(of: receiptData.issueDate) { _ in
                                showDatePicker = false
                            }
                        }
                        .padding()
                    }
                }

                // 宛名
                Text("宛名")
                    .fontWeight(.medium)
                TextField("宛名", text: $receiptData.recipient)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

                // 税率
                VStack(alignment: .leading) {
                    Text("税率・税区分")
                        .fontWeight(.medium)
                    Picker("税率", selection: $receiptData.taxRate) {
                        Text("8%").tag("8%")
                        Text("10%").tag("10%")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // 内税・外税
                VStack(alignment: .leading) {
                    Picker("内税・外税", selection: $receiptData.taxType) {
                        Text("内税").tag("内税")
                        Text("外税").tag("外税")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                // 金額
                Text("金額")
                    .fontWeight(.medium)
                // ReceiptView.swift
                TextField("金額（数字のみ）", value: $receiptData.amount, format: .number)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

                // 但し書き
                Text("但し書き")
                    .fontWeight(.medium)

                TextEditor(text: $receiptData.remarks)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

                // 発行元
                Text("発行元")
                    .fontWeight(.medium)
                TextField("発行元", text: $receiptData.companyName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))

                // PDF生成ボタン
                Button(action: {
                    hideKeyboard()
                    errorMessage = nil
                    isGenerating = true  // ← 追加
                    DispatchQueue.global(qos: .userInitiated).async {
                        do {
                            let data = try PDFGenerator.generate(from: receiptData)
                            DispatchQueue.main.async {
                                self.pdfData = data
                                self.showPreview = true
                                self.isGenerating = false
                            }
                        } catch {
                            DispatchQueue.main.async {
                                self.errorMessage = error.localizedDescription
                                self.showPreview = true
                                self.pdfData = nil
                                self.isGenerating = false
                            }
                        }
                    }
                }) {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.gray)
                            .cornerRadius(10)
                    } else {
                        Text("作成")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .foregroundColor(.white)
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
                }
                .disabled(isGenerating)

                // プレビュー
                .sheet(isPresented: $showPreview) {
                    if let data = pdfData {
                        NavigationView {
                            PDFPreviewWrapper(data: data)
                                .navigationTitle("PDFプレビュー")
                                .navigationBarTitleDisplayMode(.inline)
                        }
                    } else {
                        // エラー時
                        VStack {
                            Text("PDF生成に失敗しました")
                                .font(.headline)
                                .padding(.bottom, 8)
                            if let message = errorMessage {
                                Text("エラー内容: \(message)")
                                    .foregroundColor(.red)
                                    .multilineTextAlignment(.center)
                            }
                        }
                        .padding()
                    }
                }

            } // VStack
            .padding()
        } // ScrollView
        .background(Color.white.ignoresSafeArea())
        .onTapGesture {
            hideKeyboard()
        }
        .navigationTitle("領収書作成")
        .navigationBarTitleDisplayMode(.inline)
    } // body
} // struct ReceiptView

// 日付表示用フォーマッター（ファイルスコープ）
private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.locale = Locale(identifier: "ja_JP")
    return formatter
}()

// キーボードを閉じる拡張（ファイルスコープ）
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}