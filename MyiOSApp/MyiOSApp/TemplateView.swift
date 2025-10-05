//
//  TemplateView.swift
//  MyiOSApp
//
//  Created by Tochishita Haruki on 2025/09/21.
//

import SwiftUI

struct TemplateView: View {
    @State private var templates: [ReceiptTemplate] = []
    private let manager = TemplateManager()
    @State private var selectedTemplate: ReceiptTemplate?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(templates) { template in
                NavigationLink(destination: ReceiptView(prefilledData: template.data)) {
                    Text(template.name)
                }
            }
            .onDelete { indexSet in
                indexSet.forEach { manager.deleteTemplate(id: templates[$0].id) }
                templates = manager.loadTemplates()
            }
        }
        .navigationTitle("テンプレート一覧")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { dismiss() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.backward")
                        Text("戻る")
                    }
                }
            }
        }
        .onAppear {
            templates = manager.loadTemplates()
        }
    }
}
