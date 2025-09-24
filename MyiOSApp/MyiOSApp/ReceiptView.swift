//
//  ReceiptView.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import SwiftUI
import UIKit

struct ReceiptView: View {
    @State private var receiptData = ReceiptData()
    @State private var showPreview = false
    @State private var showDatePicker = false
    @State private var pdfData: Data? = nil
    @State private var errorMessage: String? = nil
    @State private var isGenerating = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                headerSection
                issueDateSection
                recipientSection
                taxSection
                amountSection
                remarksSection
                issuerSection
                createButtonSection
            }
            .padding()
        }
        .background(Color.white.ignoresSafeArea())
        .onTapGesture { hideKeyboard() }
        .navigationTitle("領収書作成")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showPreview) {
            if let data = pdfData {
                NavigationView {
                    PDFPreviewWrapper(data: data)
                        .navigationTitle("PDFプレビュー")
                        .navigationBarTitleDisplayMode(.inline)
                }
            } else {
                VStack(spacing: 12) {
                    Text("PDF生成に失敗しました")
                        .font(.headline)
                        .padding(.top)
                    if let msg = errorMessage {
                        Text(msg)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    } else {
                        Text("不明なエラーです。ログを確認してください。")
                            .foregroundColor(.secondary)
                    }
                    Button("閉じる") {
                        showPreview = false
                    }
                    .padding(.top)
                }
                .padding()
            }
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
                .padding()
                Button("閉じる") { showDatePicker = false }
                    .padding()
            }
        }
    }

    // MARK: - Sections
    private var headerSection: some View {
        Text("領収書作成")
            .font(.title2)
            .fontWeight(.semibold)
            .padding(.bottom, 4)
    }

    private var issueDateSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("発行日")
                .fontWeight(.medium)
            Button(action: { showDatePicker = true }) {
                HStack {
                    Text(dateFormatter.string(from: receiptData.issueDate))
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
            }
        }
    }

    private var recipientSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("宛名")
                .fontWeight(.medium)
            TextField("宛名", text: $receiptData.recipient)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
        }
    }

    private var taxSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("税率・税区分")
                .fontWeight(.medium)
            Picker("税率", selection: $receiptData.taxRate) {
                Text("8%").tag("8%")
                Text("10%").tag("10%")
                Text("非課税").tag("非課税")
            }
            .pickerStyle(SegmentedPickerStyle())

            Picker("内税・外税", selection: $receiptData.taxType) {
                Text("内税").tag("内税")
                Text("外税").tag("外税")
            }
            .pickerStyle(SegmentedPickerStyle())
        }
    }

    private var amountSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("金額")
                .fontWeight(.medium)

            HStack {
                Text("金額:")
                        TextField("金額を入力", value: $receiptData.amount, format: .number)
                        .keyboardType(.decimalPad)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
            }
        }
    }

    private var remarksSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("但し書き")
                .fontWeight(.medium)
            TextEditor(text: $receiptData.remarks)
                .frame(height: 100)
                .padding(4)
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
        }
    }

    private var issuerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("発行元")
                .fontWeight(.medium)
            TextField("発行元", text: $receiptData.companyName)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
        }
    }

    private var createButtonSection: some View {
        VStack {
            Button(action: generatePDF) {
                Group {
                    if isGenerating {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("作成")
                    }
                }
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundColor(.white)
                .background(isGenerating ? Color.gray : Color.blue)
                .cornerRadius(10)
            }
            .disabled(isGenerating)
        }
        .padding(.top, 20)
    }

    // MARK: - Actions
    private func generatePDF() {
        hideKeyboard()
        errorMessage = nil
        isGenerating = true

        DispatchQueue.global(qos: .userInitiated).async {
            let data = PDFGenerator.generate(from: receiptData) // Data? を返す想定
            DispatchQueue.main.async {
                self.isGenerating = false
                self.pdfData = data
                self.showPreview = true
                if data == nil {
                    self.errorMessage = "PDF生成に失敗しました"
                }
            }
        }
    }
}

// MARK: - 日付フォーマッター
private let dateFormatter: DateFormatter = {
    let f = DateFormatter()
    f.dateStyle = .long
    f.locale = Locale(identifier: "ja_JP")
    return f
}()

// MARK: - キーボードを閉じる拡張
#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder),
                                        to: nil, from: nil, for: nil)
    }
}
#endif
