import SwiftUI

struct ContentView: View {
    @State private var showMainView = false
    
    var body: some View {
        Group {
            if showMainView {
                MainView()
            } else {
                SplashView()
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
            Color(.systemBackground).ignoresSafeArea()
            Text("領収書くん")
                .font(.title2)
                .fontWeight(.medium)
                .foregroundColor(.blue)
        }
    }
}

// メイン画面
struct MainView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                MenuCard(title: "領収書を作成", color: .blue, destination: ReceiptView())
                MenuCard(title: "履歴を見る", color: .gray, destination: HistoryView())
            }
            .padding()
            .navigationTitle("領収書くん")
        }
    }
}

// 共通カード風メニュー
struct MenuCard<Destination: View>: View {
    let title: String
    let color: Color
    let destination: Destination
    
    var body: some View {
        NavigationLink(destination: destination) {
            HStack {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.primary)
                Spacer()
                Image(systemName: "chevron.right")
                    .foregroundColor(color)
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color(.systemGray4), lineWidth: 1) // グレー枠
            )
        }
    }
}

// 領収書作成画面
struct ReceiptView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("領収書作成画面")
                .font(.title3)
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(.systemGray6))
                .frame(height: 120)
                .overlay(Text("入力フォームエリア").foregroundColor(.gray))
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// 履歴画面
struct HistoryView: View {
    var body: some View {
        List {
            ForEach(0..<5) { i in
                HStack {
                    Text("領収書 #\(i+1)")
                    Spacer()
                    Text("¥1,000").foregroundColor(.blue)
                }
            }
        }
        .navigationTitle("履歴")
    }
}

#Preview {
    ContentView()
}