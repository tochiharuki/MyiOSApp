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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor.systemBlue
    
        // タイトル文字色
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
    
        // 戻るボタンなどの色
        appearance.buttonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.doneButtonAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
    
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
        UINavigationBar.appearance().tintColor = .white  // ← アイコン色を白に
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // ★ 全画面の背景（薄い水色）
                Color(red: 0.95, green: 0.97, blue: 1.0)
                    .ignoresSafeArea()

                ContentView()
                    .preferredColorScheme(.light) // ライトモード固定
                    .environment(\.font, .system(size: 16))
            }
        }
    }
}