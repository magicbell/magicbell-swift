//
//  UpdateStoreFromNotificationChangeInteractor.swift
//  MagicBell
//
//  Created by Javi on 30/11/21.
//

import Harmony

struct UpdateStoreFromNotificationChangeInteractor {
//    private let notificationStoreCoordinator: NotificationStoreCoordinator
//    private let graphQLInteractor: GetStorePagesInteractor
//
//    init(notificationStoreCoordinator: NotificationStoreCoordinator, graphQLInteractor: GetStorePagesInteractor) {
//        self.notificationStoreCoordinator = notificationStoreCoordinator
//        self.graphQLInteractor = graphQLInteractor
//    }
//
//    func execute(newNotification: Notification, in executor: Executor) -> Future<Void> {
//        executor.submit { resolver in
//            let notificationStores = notificationStoreCoordinator.notificationStores
//            for notificationStoreIndex in notificationStores.indices {
//                let storePredicate = notificationStoreCoordinator.notificationStores[notificationStoreIndex].storePredicate
//
//                let storeIndex = notificationStoreCoordinator.notificationStores[notificationStoreIndex].edges.firstIndex {
//                    $0.node.id == newNotification.id
//                }
//                let matchPredicate = storePredicate.matchNotification(newNotification)
//
//                let notificationStore = notificationStores[notificationStoreIndex]
//                var notificationEdges = notificationStore.edges
//
//                if let storeIndex = storeIndex, matchPredicate {
//                    // Replace notification
//                    notificationEdges[storeIndex].node = newNotification
//                } else if let storeIndex = storeIndex, !matchPredicate {
//                    // We must remove it
//                    // If edge array size is 1. just remove it and clear
//                    if notificationEdges.count == 1 {
//                        notificationStore.clear()
//                        // If position is first or last do network call with same page size
//                    } else if isNewNotificationMostRecent(notificationStore, newNotification) ||
//                                      isNewNotificationOldest(notificationStore, newNotification) {
////                        try notificationStore.reload().result.get()
//                        notificationEdges.remove(at: storeIndex)
//                    }
//                } else if matchPredicate {
//                    // We must add it
//                    // If there are no notifications, refresh them
//                    if notificationEdges.isEmpty {
////                        try notificationStore.reload().result.get()
//                    // If it's the first or last one, do refresh them with same page size
//                    } else if isNewNotificationMostRecent(notificationStore, newNotification) ||
//                                      isNewNotificationOldest(notificationStore, newNotification) {
////                        try notificationStore.reload().result.get()
//                    } else {
//                        for i in notificationEdges.indices {
//                            let notification = notificationEdges[i]
//                            if notification.node.sentAt < newNotification.sentAt {
//                                notificationEdges.insert(Edge<Notification>(node: newNotification), at: i)
//                                break
//                            }
//                        }
//                    }
//                }
//            }
//            resolver.set()
//        }
//    }
//
//    private func isNewNotificationMostRecent(_ notificationStore: NotificationStore, _ newNotification: Notification) -> Bool {
//        notificationStore.edges[0].node.sentAt > newNotification.sentAt
//    }
//
//    private func isNewNotificationOldest(_ notificationStore: NotificationStore, _ newNotification: Notification) -> Bool {
//        let notificationEdges = notificationStore.edges
//        return notificationEdges[notificationEdges.count - 1].node.sentAt < newNotification.sentAt
//    }
}
