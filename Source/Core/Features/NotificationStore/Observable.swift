//
//  Observable.swift
//  MagicBell
//
//  Created by Javi on 28/11/21.
//

import Foundation

public class Observable<T> {

    public typealias CompletionHandler = ((T) -> Void)

    var value: T {
        didSet {
            self.notifyObservers(self.observers)
        }
    }

    var observers: [Int: CompletionHandler] = [ : ]

    init(value: T) {
        self.value = value
    }

    public func addObserver(_ observer: Int, completion: @escaping CompletionHandler) {
        self.observers[observer] = completion
    }

    public func removeObserver(_ observer: Int) {
        self.observers.removeValue(forKey: observer)
    }

    func notifyObservers(_ observers: [Int: CompletionHandler]) {
        observers.forEach { $0.value(value) } 
    }

    deinit {
        observers.removeAll()
    }
}
