//
//  ProspectsView.swift
//  HotProspects
//
//  Created by sovanmakara on 8/6/26.
//

import AVFoundation
import CodeScanner
import SwiftUI
import SwiftData
import UserNotifications

struct ProspectsView: View {
    let filter: FilterType
    var title: String {
        switch filter {
        case .none:
            "Everyone"
        case .contacted:
            "Contacted people"
        case .uncontacted:
            "Uncontacted people"
        }
    }
    
    @Environment(\.modelContext) var modelContext
    @Query(sort: \Prospect.name) var prospects: [Prospect]
    @State private var isShowingScanner = false
    @State private var selectedProspects = Set<Prospect>()
    @Environment(\.editMode) private var editMode
    
    // sort property
    @State private var sortType: SortType = .name
    var sortProspects: [Prospect] {
        switch sortType {
        case .name:
            prospects.sorted {
                $0.name.localizedStandardCompare($1.name) == .orderedAscending
            }
        case .recent:
            prospects.sorted {
                $0.createdAt > $1.createdAt
            }
        }
    }
    
    init(filter: FilterType) {
        self.filter = filter
        
        if filter != .none {
            let showContactedOnly = filter == .contacted
            
            _prospects = Query(filter: #Predicate {
                $0.isContacted == showContactedOnly
            }, sort: [SortDescriptor(\Prospect.name)])
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>){
        isShowingScanner = false
        
        switch result {
        case .success(let result):
            let details = result.string.components(separatedBy: "\n")
            guard details.count == 2 else { return }
            
            let person = Prospect(name: details[0], emailAddress: details[1], isContacted: false, createdAt: .now)
            
            modelContext.insert(person)
            
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
    
    func delete(){
        for prospect in selectedProspects {
            modelContext.delete(prospect)
        }
        selectedProspects.removeAll()
    }
    
    func addNotification(for prospect: Prospect){
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = UNNotificationSound.default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            // For schedule notification
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            // For testing
//            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { setting in
            if setting.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
                    if success {
                        addRequest()
                    } else if let error {
                        print(error.localizedDescription)
                    }
                }
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            List(sortProspects, selection: $selectedProspects) { prospect in
                NavigationLink {
                    EditProspectView(prospect: prospect)
                } label: {
                    ProspectRow(prospect: prospect)
                }
                .swipeActions {
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        modelContext.delete(prospect)
                    }
                    .tint(.red)
                    if prospect.isContacted {
                        Button("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark"){
                            prospect.isContacted.toggle()
                        }
                        .tint(.blue)
                    } else {
                        Button("Mark Connected", systemImage: "person.crop.circle.fill.badge.checkmark"){
                            prospect.isContacted.toggle()
                        }
                        .tint(.green)
                    }
                    Button("Remind Me", systemImage: "bell") {
                        addNotification(for: prospect)
                    }
                    .tint(.orange)
                }
                .tag(prospect)
            }
            .disabled(editMode?.wrappedValue.isEditing == true)
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Scan", systemImage: "qrcode.viewfinder") {
                        isShowingScanner = true
                    }
                }
                
                ToolbarItemGroup(placement: .topBarLeading) {
                    EditButton()

                    Menu {
                        Picker("Sort", selection: $sortType) {
                            ForEach(SortType.allCases, id: \.self) { sort in
                                Text(sort.rawValue)
                                    .tag(sort)
                            }
                        }
                    } label: {
                        Label("Sort", systemImage: "arrow.up.arrow.down")
                    }
                }
                
                if !selectedProspects.isEmpty {
                    ToolbarItem(placement: .topBarTrailing) {
                        Button(role: .destructive) {
                            delete()
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                }
            }
            .sheet(isPresented: $isShowingScanner){
                CodeScannerView(codeTypes: [.qr], simulatedData: "Paul Hudson\npaul@hackingwithswift.com", completion: handleScan)
            }
        }
    }
}

struct ProspectRow: View {
    let prospect: Prospect

    var body: some View {
        HStack(spacing: 16) {

            Circle()
                .fill(prospect.isContacted ? .green : .orange)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(prospect.name)
                    .font(.headline)

                Text(prospect.emailAddress)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName:
                    prospect.isContacted
                    ? "checkmark.circle.fill"
                    : "clock.badge.questionmark")
                .foregroundStyle(
                    prospect.isContacted
                    ? .green
                    : .orange
                )
        }
        .padding(.vertical, 6)
    }
}

#Preview {
    ProspectsView(filter: .none)
}
