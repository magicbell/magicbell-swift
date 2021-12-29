//
//  MagicBellView.swift
//  Example
//
//  Created by Joan Martin on 28/12/21.
//

import SwiftUI
import MagicBell
import struct MagicBell.Notification

struct MagicBellView: View {
    let store: NotificationStore

    @ObservedObject
    private var rxStore: NotificationStorePublisher

    init(store: NotificationStore) {
        self.store = store
        self.rxStore = NotificationStorePublisher(store)
    }

    enum SheetType {
        case none
        case notification(Notification)
        case globalActions
    }

    @State var presentSheet = false
    @State var sheetType: SheetType = .none

    var body: some View {
        List {
            Section {
                ForEach(rxStore.notifications, id: \.id) { notification in
                    Button {
                        sheetType = .notification(notification)
                        presentSheet = true
                    } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(notification.title ?? "No Title")
                                    .font(Font.system(size: 16, weight: .semibold))
                                Spacer()
                                    .frame(height: 8)
                                Text(notification.content ?? "No Content")
                                    .font(Font.system(size: 14, weight: .regular))
                            }
                            Spacer()
                            if !notification.isRead {
                                Circle()
                                    .fill(Color(UIColor.magicBell))
                                    .frame(width: 6, height: 6)
                            }
                        }
                        .padding([.top, .bottom], 3)
                    }
                    .buttonStyle(.plain)
                }
            } header: {
                Text("\(rxStore.totalCount) Notifications (\(rxStore.unreadCount) unread)")
            } footer: {
                if rxStore.hasNextPage {
                    Button {
                        store.fetch { _ in }
                    } label: {
                        HStack {
                            Spacer()
                            Text("Load More")
                            Spacer()
                        }
                    }
                }
            }
        }
        .refreshable {
            // Pull-to-refresh action
            store.refresh { _ in }
        }
        .listRowInsets(.none)
        .listStyle(.grouped)
        .navigationBarTitle("MagicBell", displayMode: .inline)
        .navigationBarItems(
            trailing: Button(action: {
                sheetType = .globalActions
                presentSheet = true
            }, label: {
                ZStack(alignment: .top) {
                    Image("magicbellicon")
                        .renderingMode(.template)
                        .colorMultiply(.white)
                    if rxStore.unseenCount > 0 {
                        HStack {
                            Spacer()
                            Text("\(rxStore.unseenCount)")
                                .font(Font.system(size: 12, weight: .bold))
                                .padding([.trailing, .leading], 3)
                                .foregroundColor(.white)
                                .background(Color.red)
                                .cornerRadius(10)
                        }
                    }
                }
            })
        )
        .onAppear {
            store.refresh { _ in }
        }
        .actionSheet(isPresented: $presentSheet) {
            switch sheetType {
            case .none:
                fatalError("Should never happen")
            case .notification(let notification):
                return ActionSheet(
                    title: Text("\(notification.title ?? "No Title")"),
                    buttons: [
                        .default(Text("\(notification.isRead ? "Mark unread" : "Mark read")")) {
                            if notification.isRead {
                                _ = store.markAsUnread(notification)
                            } else {
                                _ = store.markAsRead(notification)
                            }
                        },
                        .default(Text("\(notification.isArchived ? "Unarchive": "Archive")")) {
                            if notification.isArchived {
                                _ = store.unarchive(notification)
                            } else {
                                _ = store.archive(notification)
                            }
                        },
                        .default(Text("Delete")) {
                            _ = store.delete(notification)
                        },
                        .cancel()
                    ]
                )
            case .globalActions:
                return ActionSheet(
                    title: Text("Action"),
                    buttons: [
                        .default(Text("Mark all read")) {
                            _ = store.markAllRead()
                        },
                        .default(Text("Mark all seen")) {
                            _ = store.markAllSeen()
                        },
                        .cancel()
                    ]
                )
            }
        }
    }
}

struct MagicBellView_Previews: PreviewProvider {
    static let user = magicBell.forUser(email: "john@doe.com")
    static var previews: some View {
        NavigationView {
            MagicBellView(store: user.store.forAll())
        }
    }
}
