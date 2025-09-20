import SwiftUI

struct SwiftUIView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("SwiftUIViewの例")
                .font(.largeTitle)
                .fontWeight(.bold)
                .padding()

            Text("ここはテスト用のSwiftUI画面です。")
                .font(.title2)
                .foregroundColor(.secondary)

            Button(action: {
                print("ボタンが押されました")
            }) {
                Text("アクションボタン")
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
        }
        .padding()
    }
}

#Preview {
    SwiftUIView()
}