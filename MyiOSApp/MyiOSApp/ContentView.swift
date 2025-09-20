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
            Color.blue.opacity(0.2).ignoresSafeArea()
            Text("領収書くん")
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
            VStack(spacing: 20) {
                Text("メイン画面")
                    .font(.title)
                
                NavigationLink("領収書を作成", destination: ReceiptView())
                NavigationLink("履歴を見る", destination: HistoryView())
            }
            .navigationTitle("領収書くん")
        }
    }
}

// 領収書作成画面
struct ReceiptView: View {
    var body: some View {
        Text("領収書作成画面")
    }
}

// 履歴画面
struct HistoryView: View {
    var body: some View {
        Text("履歴画面")
    }
}

#Preview {
    ContentView()
}