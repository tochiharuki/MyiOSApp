//
//  MyiOSAppApp.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/12.
//

import SwiftUI

@main
struct MyiOSAppApp: App {
    init() {
        // --- ナビゲーションバー全体のスタイルを一括指定 ---
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBlue
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]

        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // ライトモード固定
                .tint(.blue)                  // 全体のアクセントカラー
                .environment(\.font, .system(size: 16))
        }
    }
}