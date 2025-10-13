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
    @State private var showRequestForm = false
    var body: some View {
        NavigationStack {
            ZStack {
                // ★ 画面全体の背景
                Color(red: 0.95, green: 0.97, blue: 1.0)
                    .ignoresSafeArea()

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
                        Text("履歴から作成")
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
                    
                    // --- ご要望ボタン（右下固定） ---
                    Button(action: {
                        showRequestForm = true
                    }) {
                        HStack {
                            Image(systemName: "envelope.fill")
                            Text("ご要望はこちら")
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(25)
                        .shadow(radius: 3)
                    }
                    .padding(.top, 30)
                    .padding(.trailing, 20)
                    .padding(.bottom, 30)
                    .sheet(isPresented: $showRequestForm) {
                        RequestFormView() // ← ここでさっき作ったビューを呼び出す
                    }
                }
                .padding()
            }
            .navigationTitle("領収書作成")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}