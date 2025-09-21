import SwiftUI

// カスタムDatePicker（選択後自動で閉じる）
struct AutoClosingDatePicker: UIViewRepresentable {
    @Binding var selection: Date
    
    func makeUIView(context: Context) -> UIDatePicker {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.locale = Locale(identifier: "ja_JP") // 日本カレンダー
        picker.preferredDatePickerStyle = .compact
        picker.addTarget(context.coordinator, action: #selector(Coordinator.dateChanged), for: .valueChanged)
        return picker
    }
    
    func updateUIView(_ uiView: UIDatePicker, context: Context) {
        uiView.date = selection
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject {
        var parent: AutoClosingDatePicker
        init(_ parent: AutoClosingDatePicker) {
            self.parent = parent
        }
        
        @objc func dateChanged(_ sender: UIDatePicker) {
            parent.selection = sender.date
            sender.resignFirstResponder() // 選択後閉じる
        }
    }
}

struct ReceiptView: View {
    @State private var issueDate = Date()
    @State private var recipient = ""
    @State private var amount = ""
    @State private var taxRate = "10%" // デフォルト10%
    @State private var taxType = "外税" // 内税／外税
    @State private var remarks = ""
    @State private var companyName = ""
    
    let taxOptions = ["8%", "10%", "非課税"]
    let taxTypeOptions = ["内税", "外税"]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("領収書作成")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                
                // 発行日
                Group {
                    Text("発行日")
                        .fontWeight(.medium)
                    AutoClosingDatePicker(selection: $issueDate)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                }
                
                // 宛名
                Group {
                    Text("宛名")
                        .fontWeight(.medium)
                    TextField("例：山田太郎 様", text: $recipient)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                }
                
                // 金額（内税／外税 選択付き）
                Group {
                    Text("金額")
                        .fontWeight(.medium)
                    
                    HStack {
                        Picker("税種別", selection: $taxType) {
                            ForEach(taxTypeOptions, id: \.self) { type in
                                Text(type)
                            }
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 160)
                        
                        TextField("例：10000", text: $amount)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                    }
                    
                    // 消費税率
                    Picker("消費税", selection: $taxRate) {
                        ForEach(taxOptions, id: \.self) { rate in
                            Text(rate)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 但し書き
                Group {
                    Text("但し書き")
                        .fontWeight(.medium)
                    TextEditor(text: $remarks)
                        .frame(height: 100)
                        .padding(4)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                }
                
                // 会社名／担当者名
                Group {
                    Text("会社名／担当者名")
                        .fontWeight(.medium)
                    TextField("例：株式会社ABC 田中", text: $companyName)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                }
                
                // 保存ボタンテスト
                Button(action: {
                    print("保存")
                }) {
                    Text("保存")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
            }
            .padding()
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("領収書作成")
        .navigationBarTitleDisplayMode(.inline)
    }
}