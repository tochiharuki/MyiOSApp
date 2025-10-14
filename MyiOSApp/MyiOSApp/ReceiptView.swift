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
    init(prefilledData: ReceiptData? = nil) {
        _receiptData = State(initialValue: prefilledData ?? ReceiptData())
    }
    @State private var showPreview = false
    @State private var showDatePicker = false
    @State private var pdfData: Data? = nil
    @State private var errorMessage: String? = nil
    @State private var isGenerating = false
    @State private var isSaved = false
    @State private var showToast = false   // ← 通知表示フラグ
    @State private var showSaveAlert = false
    @State private var templateName = ""
    @Environment(\.dismiss) private var dismiss

    func saveAsTemplate() {
        showSaveAlert = true
    }
    

    var body: some View {
        ZStack {
            // ★ 全画面背景
            Color(red: 0.95, green: 0.97, blue: 1.0)
                .ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
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
        }
        .onTapGesture { hideKeyboard() }
        .navigationBarTitleDisplayMode(.inline)
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
        .sheet(isPresented: $showPreview) {
            if let data = pdfData {
                NavigationView {
                     PDFPreviewWrapper(pdfData: data, receiptData: receiptData)
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
            DatePicker(
                "",
                selection: Binding(
                    get: { receiptData.issueDate },
                    set: { newValue in
                        receiptData.issueDate = newValue
                        showDatePicker = false   // ← 選択したら即閉じる
                    }
                ),
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .environment(\.locale, Locale(identifier: "ja_JP"))
            .padding()
        }
        .onAppear {
            receiptData.issuer = AppSettings.issuer
        }
        // ✅ 全画面オーバーレイ
        .overlay(
            Group {
                if showToast {
                    ZStack {
                        Color.black.opacity(0.3) // 画面全体を薄暗く
                            .ignoresSafeArea()
                        Text("保存しました")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 12)
                            .background(Color.black.opacity(0.7))
                            .cornerRadius(10)
                    }
                    .transition(.opacity)
                    .onAppear {
                        // 1.5秒後に自動で非表示
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                            withAnimation {
                                showToast = false
                            }
                        }
                    }
                }
            }
        )
        .animation(.easeInOut(duration: 0.3), value: showToast)
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
    
            HStack {
                TextField("〇〇株式会社", text: $receiptData.recipient)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.gray.opacity(0.5))
                    )
    
                Picker("", selection: $receiptData.recipientSuffix) {
                    Text("様").tag("様")
                    Text("御中").tag("御中")
                }
            
                .pickerStyle(MenuPickerStyle()) // プルダウン形式
                .frame(width: 80)
            }
        }
    }

    private var taxSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("税率・税区分")
                .fontWeight(.medium)
            Picker("税率", selection: $receiptData.taxRate) {
                Text("8%").tag("8%")
                Text("10%").tag("10%")
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

            VStack(alignment: .leading, spacing: 6) {
                Text("金額")
                    .fontWeight(.medium)
                        TextField("10,000", value: $receiptData.amount, format: .number)
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
            
            TextField("〇〇代として", text: $receiptData.remarks)
                .padding()
                .background(Color.white)
                .cornerRadius(8)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5))
                )
        }
    }
    
    private var issuerSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("発行元")
                    .fontWeight(.medium)

                Spacer()

                Button(action: {
                    AppSettings.issuer = receiptData.issuer

                    // ✅ バイブ
                    let generator = UIImpactFeedbackGenerator(style: .light)
                    generator.impactOccurred()

                    // ✅ トーストを表示
                    withAnimation {
                        showToast = true
                    }
                    // 2秒後に非表示
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                        withAnimation {
                            showToast = false
                        }
                    }
                }) {
                    Text("発行元を保存")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.blue.opacity(0.85))
                        .foregroundColor(.white)
                        .cornerRadius(6)
                }
                .buttonStyle(.borderless)
                .opacityEffectOnPress()
            }

            // ✅ テキストエリア（左揃え、最大7行）
            TextField(
                "〇〇株式会社\n〒123-4567\n東京都新宿区〇〇町1-2-3\nTEL: 03-1234-5678\n登録番号：T1234567890123",
                text: $receiptData.issuer,
                axis: .vertical
            )
            .multilineTextAlignment(.leading) // ← 左揃えにする
            .lineLimit(7, reservesSpace: true) // ← 最大7行まで
            .padding(8)
            .background(Color.white)
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.gray.opacity(0.5))
            )
            .frame(maxWidth: .infinity, alignment: .trailing) // ← 全体は右下に配置
            .padding(.top, 4)

            stampSection
        }
        .frame(maxWidth: .infinity, alignment: .trailing) // ← 右下寄せ
    }

    // MARK: - 印紙枠切り替えセクション
    private var stampSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Toggle(isOn: $receiptData.showStampBox) {
                Text("収入印紙枠を表示")
                    .fontWeight(.medium)
            }
            .tint(.blue)
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

            // --- テンプレートとして保存ボタン ---
            Button("テンプレートとして保存") {
                saveAsTemplate()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue.opacity(0.1))
            .foregroundColor(.blue)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 1)
            )
        }
        .padding(.top, 20)
        // --- アラートをVStack全体に適用 ---
        .alert("テンプレート名を入力", isPresented: $showSaveAlert) {
            TextField("例：会社A用", text: $templateName)
            Button("保存") {
                guard !templateName.isEmpty else { return }
                let manager = TemplateManager()
                let template = ReceiptTemplate(name: templateName, data: receiptData)
                manager.saveTemplate(template)
                templateName = ""
            }
            Button("キャンセル", role: .cancel) { }
        }
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

// ✅ カスタムモディファイア
struct OpacityEffectOnPress: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .opacity(configuration.isPressed ? 0.6 : 1.0) // 押したら暗くなる
    }
}

extension View {
    func opacityEffectOnPress() -> some View {
        self.buttonStyle(OpacityEffectOnPress())
    }
}


