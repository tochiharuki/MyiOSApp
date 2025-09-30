import SwiftUI

import SwiftUI

@main
struct MyApp: App {
    init() {
        // --- NavigationBar 全体スタイル（青ベース） ---
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 18)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.boldSystemFont(ofSize: 24)
        ]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white // 戻るボタン色
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                // --- 全体のアクセントカラー（リンク、ボタン等） ---
                .tint(.blue)
                // --- 全体のデフォルトフォント ---
                .environment(\.font, .system(size: 16, weight: .regular))
                // --- 全体の背景色（白ベース） ---
                .background(Color.white)
        }
    }
}

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
            .background(Color.white) // 白ベース
            .navigationTitle("領収書さん")
        }
    }
}

#Preview {
    ContentView()
}