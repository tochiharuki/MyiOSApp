import SwiftUI

struct MainView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // 背景は薄いグレー
                Color(.systemGray6)
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 30) {
                    
                    // タイトル
                    Text("領収書くん")
                        .font(.largeTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .padding(.top, 40)
                    
                    Spacer()
                    
                    // ボタン群
                    VStack(spacing: 16) {
                        NavigationLink(destination: Text("作成画面")) {
                            Text("領収書を作成")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        
                        NavigationLink(destination: Text("履歴画面")) {
                            Text("履歴を見る")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .foregroundColor(.blue)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.blue, lineWidth: 1)
                                )
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarHidden(true) // ナビバー非表示でスッキリ
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        MainView()
    }
}
