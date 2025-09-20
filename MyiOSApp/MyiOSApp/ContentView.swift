import SwiftUI

struct ContentView: View {
    @State private var showMainView = false
    
    var body: some View {
        Group {
            if showMainView {
                MainView() // ← メイン画面
            } else {
                SplashView() // ← スプラッシュ画面
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
            Color(red: 0.85, green: 0.95, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            Text("領収書くん")
                .font(.system(size: 48, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundColor(.accentColor)
                .padding()
        }
    }
}

// メイン画面
struct MainView: View {
    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                Text("メイン画面")
                    .font(.largeTitle)
                    .padding()
                
                NavigationLink("領収書を作成", destination: Text("作成画面"))
                NavigationLink("履歴を見る", destination: Text("履歴画面"))
            }
            .navigationTitle("領収書くん")
        }
    }
}

#Preview {
    ContentView()
}
