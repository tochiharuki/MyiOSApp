import SwiftUI

struct ContentView: View {
    @State private var showMainView = false
    
    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea() // ← 背景を常に白に固定
            
            Group {
                if showMainView {
                    MainView() // メイン画面
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
}

// スプラッシュ画面
struct SplashView: View {
    var body: some View {
        VStack {
            Text("領収書くん")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.blue)
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 2)
                )
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
                    .foregroundColor(.black)
                
                NavigationLink("領収書を作成", destination: ReceiptView())
                NavigationLink("履歴を見る", destination: HistoryView())
            }
            .padding()
            .background(Color.white) // ← 明示的に白背景
            .navigationTitle("領収書くん")
        }
    }
}

// 領収書作成画面
struct ReceiptView: View {
    var body: some View {
        Text("領収書作成画面")
            .foregroundColor(.black)
            .background(Color.white.ignoresSafeArea())
    }
}

// 履歴画面
struct HistoryView: View {
    var body: some View {
        Text("履歴画面")
            .foregroundColor(.black)
            .background(Color.white.ignoresSafeArea())
    }
}

#Preview {
    ContentView()
        .preferredColorScheme(.light) // プレビューでもライト固定
}