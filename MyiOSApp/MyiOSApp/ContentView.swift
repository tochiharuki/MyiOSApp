import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
            // 背景色を薄い水色に設定
            Color(red: 0.85, green: 0.95, blue: 1.0)
                .edgesIgnoringSafeArea(.all)
            
            // 文字を中央に配置
            Text("領収書")
                .font(.system(size: 48, weight: .bold)) // 大きめの太字
                .multilineTextAlignment(.center)
                .foregroundColor(.accentColor)
                .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
