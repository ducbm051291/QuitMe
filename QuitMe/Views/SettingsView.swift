//
//  SettingsView.swift
//  QuitMe
//
//  Created by burak şen on 25.05.24.
//

import SwiftUI
import SwiftData
import LaunchAtLogin
import KeyboardShortcuts

struct PreferencesView: View {

    @EnvironmentObject var appDelegate: AppDelegate
    @Environment(\.modelContext) var modelContext
    @Query(sort: \IgnoredItem.id) var ignoredItems: [IgnoredItem]
    
    var ignoredItemList: [MenuItem] {
        appDelegate.menuItems.filter { menuItem in
            ignoredItems.contains { $0.id == menuItem.id }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("preferences")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("ignored_apps")
                .font(.headline)
            ScrollView {
                IgnoredAppsSection(ignoredItemList: ignoredItemList, ignoredItems: ignoredItems, modelContext: modelContext)
            }
            .frame(maxHeight: 500) 
            
            Divider()
            
            ShortcutsSection()
            
            Divider()
            
            LaunchAtLogin.Toggle {
                Text("launch_at_login")
                    .font(.subheadline)
            }
        }
        .padding()
        .frame(width: 300, height: 400)
        .background(Color(.windowBackgroundColor))
    }
}

struct IgnoredAppsSection: View {

    let ignoredItemList: [MenuItem]
    let ignoredItems: [IgnoredItem]
    let modelContext: ModelContext
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            ForEach(ignoredItemList) { ignoredItem in
                IgnoredItemRow(ignoredItem: ignoredItem, ignoredItems: ignoredItems, modelContext: modelContext)
            }
            
            if ignoredItemList.isEmpty {
                Text("no_ignored_apps")
                    .foregroundColor(.secondary)
                    .italic()
            }
        }
    }
}

struct ShortcutsSection: View {

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("shortcuts")
                .font(.headline)
            
            KeyboardShortcuts.Recorder(NSLocalizedString("quit_all", comment: "Shortcut label for Quit All"), name: .quitMode)
                .padding(.vertical, 4)
            
            KeyboardShortcuts.Recorder(NSLocalizedString("force_quit_all", comment: "Shortcut label for Force Quit All"), name: .forceQuitMode)
                .padding(.vertical, 4)
        }
    }
}

struct IgnoredItemRow: View {

    let ignoredItem: MenuItem
    let ignoredItems: [IgnoredItem]
    let modelContext: ModelContext
    
    var body: some View {
        HStack(spacing: 12) {
            if let icon = ignoredItem.item.icon {
                Image(nsImage: icon)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
            } else {
                Image(systemName: "app")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 30, height: 30)
                    .foregroundColor(.secondary)
            }
            
            Text(ignoredItem.item.localizedName ?? NSLocalizedString("unknown", comment: "Fallback for unknown app name"))
                .font(.system(size: 14))
                .lineLimit(1)
                .truncationMode(.tail)
            
            Spacer()
        
            Button(action: removeIgnoredItem) {
                Image(systemName: "eye")
                    .foregroundColor(.green)
                    .frame(width: 25, height: 25)
                    .background(Color.green.opacity(0.1))
                    .clipShape(Circle())
            }
            .padding(.trailing, 15)
            .buttonStyle(PlainButtonStyle())
            .help(NSLocalizedString("remove_ignored_item_help", comment: "Help text for remove ignored item button"))
        }
        .padding(.vertical, 4)
    }
    
    private func removeIgnoredItem() {
        do {
            if let itemToDelete = ignoredItems.first(where: { $0.id == ignoredItem.id }) {
                modelContext.delete(itemToDelete)
                try modelContext.save()
            }
        } catch {
            print("Error deleting ignored item: \(error.localizedDescription)")
        }
    }
}

#Preview {
    PreferencesView()
        .environmentObject(AppDelegate())
        .modelContainer(for: IgnoredItem.self)
}
