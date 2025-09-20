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
            Color(.systemGray6).ignoresSafeArea() // 薄いグレー背景
            Text("領収書くん")
                .font(.title)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
}

// メイン画面
struct MainView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("領収書くん")
                    .font(.title2)
                    .foregroundColor(.primary)
                
                NavigationLink(destination: ReceiptView()) {
                    MenuButton(title: "領収書を作成", color: .blue)
                }
                
                NavigationLink(destination: HistoryView()) {
                    MenuButton(title: "履歴を見る", color: .gray)
                }
            }
            .padding()
            .navigationTitle("ホーム")
        }
    }
}

// 共通ボタンスタイル
struct MenuButton: View {
    let title: String
    let color: Color
    
    var body: some View {
        Text(title)
            .font(.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(color)
            .cornerRadius(8)
            .shadow(color: color.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

// 領収書作成画面
struct ReceiptView: View {
    var body: some View {
        VStack {
            Text("領収書作成画面")
                .font(.title3)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

// 履歴画面
struct HistoryView: View {
    var body: some View {
        VStack {
            Text("履歴画面")
                .font(.title3)
        }
        .padding()
        .background(Color(.systemBackground))
    }
}

#Preview {
    ContentView()
}