//
//  AppSettings.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/28.
//

import Foundation

struct AppSettings {
    static var issuer: String {
        get {
            UserDefaults.standard.string(forKey: "issuer") ?? ""
        }
        set {
            UserDefaults.standard.set(newValue, forKey: "issuer")
        }
    }
}
