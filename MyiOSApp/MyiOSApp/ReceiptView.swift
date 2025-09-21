import SwiftUI

struct ReceiptView: View {
    @State private var receiptData = ReceiptData()
    @State private var showPreview = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                
                Text("領収書作成")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .padding(.bottom, 10)
                
                // 発行日
                DatePicker("発行日", selection: $receiptData.issueDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                
                // 宛名
                TextField("宛名", text: $receiptData.recipient)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                
                // 金額
                TextField("金額（数字のみ）", text: $receiptData.amount)
                    .keyboardType(.numberPad)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                
                // 税率
                VStack(alignment: .leading) {
                    Text("税率")
                        .fontWeight(.medium)
                    Picker("税率", selection: $receiptData.taxRate) {
                        Text("8%").tag("8%")
                        Text("10%").tag("10%")
                        Text("非課税").tag("非課税")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 内税・外税
                VStack(alignment: .leading) {
                    Text("税込方式")
                        .fontWeight(.medium)
                    Picker("内税・外税", selection: $receiptData.taxType) {
                        Text("内税").tag("内税")
                        Text("外税").tag("外税")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                // 但し書き
                TextEditor(text: $receiptData.remarks)
                    .frame(height: 100)
                    .padding(4)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                
                // 会社名／担当者名
                TextField("会社名／担当者名", text: $receiptData.companyName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.5)))
                
                // 作成ボタン
                Button(action: {
                    showPreview = true
                }) {
                    Text("作成")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)
                }
                .padding(.top, 20)
                .sheet(isPresented: $showPreview) {
                    ReceiptPreviewView(receiptData: receiptData)
                }
            }
            .padding()
        }
        .background(Color.white.ignoresSafeArea())
        .navigationTitle("領収書作成")
        .navigationBarTitleDisplayMode(.inline)
    }
}