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
                        // 1秒後にメイン画面へ遷移
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
                Text("メイン画面")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                
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
            .navigationTitle("領収書さん")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white) // 白ベース
        }
    }
}

// 領収書作成画面
struct ReceiptView: View {
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()
            Text("領収書作成画面")
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