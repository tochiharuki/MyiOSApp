//
//  MyiOSAppApp.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/12.
//

import SwiftUI

@main
struct MyiOSAppApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(.light) // ← ここでライト固定
        }
    }
}