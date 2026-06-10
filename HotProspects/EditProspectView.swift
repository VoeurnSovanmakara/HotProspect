//
//  EditProspectView.swift
//  HotProspects
//
//  Created by sovanmakara on 10/6/26.
//

import SwiftUI

struct EditProspectView: View {
    @Bindable var prospect: Prospect
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        Form {
            Section("Contact Information"){
                TextField("Name", text: $prospect.name)
                    .textContentType(.name)
                
                TextField("Email Address", text: $prospect.emailAddress)
                    .textContentType(.emailAddress)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
            }
        }
        .navigationTitle("Edit Prospect")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing){
                Button("Done"){
                    dismiss()
                }
            }
        }
    }
}

#Preview {
    EditProspectView(
        prospect: Prospect(
        name: "Paul Hudson",
        emailAddress: "paul@hackingwithswift.com",
        isContacted: true,
        createdAt: .now
        )
    )
}
