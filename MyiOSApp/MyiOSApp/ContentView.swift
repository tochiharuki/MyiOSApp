import SwiftUI

struct ContentView: View {
    @State private var showMainView = false
    
    var body: some View {
        Group {
            if showMainView {
                MainView() // メイン画面へ
            } else {
                SplashView() // スプラッシュ画面
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                            withAnimation {
                                showMainView = true
                            }
                        }
                    }
            }
        }
    }
}

// スプラッシュ画面
struct SplashView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("領収書さん")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
        }
    }
}

// メイン画面
struct MainView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                NavigationLink(destination: ReceiptView()) {
                    Text("領収書を作成")
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
                
                NavigationLink(destination: TemplateView()) {
                    Text("テンプレートから作成")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.gray)
                        .background(Color.white)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray, lineWidth: 1.5)
                        )
                        .cornerRadius(10)
                }
                
                NavigationLink(destination: HistoryView()) {
                    Text("履歴を見る")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .foregroundColor(.gray)
                        .cornerRadius(10)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
            }
            .padding()
            .background(Color.white)
        }
    }
}

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
            sender.resignFirstResponder() // ✅ 選択後閉じる
        }
    }
}

struct ReceiptView: View {
    @State private var issueDate = Date()
    @State private var recipient = ""
    @State private var amount = ""
    @State private var taxRate = "10%" // デフォルト10%
    @State private var taxType = "外税" // ✅ 内税／外税を追加
    @State private var remarks = ""
    @State private var companyName = ""
    @State private var showDatePicker = false
    
    let taxOptions = ["8%", "10%", "非課税"]
    let taxTypeOptions = ["内税", "外税"] // ✅ 新しい選択肢
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("領収書作成")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                
                Group {
                    Text("発行日")
                        .fontWeight(.medium)
                
                    HStack {
                        Spacer()
                        Button(action: {
                            showDatePicker = true
                        }) {
                            Text(issueDate, style: .date) // 選択した日付を表示
                                .foregroundColor(.blue)
                        }
                    }
                }
                .sheet(isPresented: $showDatePicker) {
                    VStack {
                        DatePicker(
                            "発行日を選択",
                            selection: $issueDate,
                            displayedComponents: .date
                        )
                        .datePickerStyle(.graphical)
                        .labelsHidden()
                        .padding()
                
                        Button("決定") {
                            showDatePicker = false // ✅ 閉じる
                        }
                        .buttonStyle(.borderedProminent)
                        .padding()
                    }
                    .presentationDetents([.medium]) // シートの高さ調整（任意）
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
                
                // ✅ 金額（内税／外税 選択付き）
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
                
                // 保存ボタン
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

#Preview {
    ReceiptView()
}

// テンプレート作成画面
struct TemplateView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("テンプレートから作成画面")
        }
    }
}

// 履歴画面
struct HistoryView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("履歴画面")
        }
    }
}

#Preview {
    ContentView()
}