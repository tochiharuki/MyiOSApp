//
//  RequestFormView.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/10/13.
//

import SwiftUI
import MessageUI

struct RequestFormView: View {
    @State private var showMailView = false
    @State private var result: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Text("ご要望・不具合報告はこちらから")
                .font(.headline)
            
            Button(action: {
                showMailView = true
            }) {
                Text("メールで送信")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $showMailView) {
                MailView(result: $result)
            }
        }
        .padding()
    }
}

struct MailView: UIViewControllerRepresentable {
    @Binding var result: Result<MFMailComposeResult, Error>?

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.setToRecipients(["tochi.haruki@gmail.com"]) // ←自分のメールアドレスに変更
        vc.setSubject("アプリへのご要望・ご意見")
        vc.setMessageBody("以下にご要望をご記入ください：\n\n", isHTML: false)
        vc.mailComposeDelegate = context.coordinator
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailView
        init(_ parent: MailView) {
            self.parent = parent
        }
        func mailComposeController(_ controller: MFMailComposeViewController,
                                   didFinishWith result: MFMailComposeResult,
                                   error: Error?) {
            if let error = error {
                parent.result = .failure(error)
            } else {
                parent.result = .success(result)
            }
            controller.dismiss(animated: true)
        }
    }
}
