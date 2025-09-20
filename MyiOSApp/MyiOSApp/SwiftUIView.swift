import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack(spacing: 20) { // 縦に並べる
            Text("領収書アプリ")
                .font(.largeTitle)   // フォントサイズ大
                .fontWeight(.bold)   // 太字
                .padding()           // 内側余白
                .background(Color.blue.opacity(0.2)) // 背景色
                .cornerRadius(10)    // 角丸

            Text("ここにメインの画面を作っていきます")
                .font(.body)
                .foregroundColor(.gray)

            Button(action: {
                print("ボタンが押されました")
            }) {
                Text("開始する")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity) // 横いっぱい
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    ContentView()
}