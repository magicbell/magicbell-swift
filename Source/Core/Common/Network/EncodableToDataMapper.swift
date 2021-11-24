//
//  EncodableToDataMapper.swift
//  MagicBell
//
//  Created by Javi on 23/11/21.
//

import Harmony

public class EncodableToDataMapper<T>: Mapper<T, Data> where T: Encodable {

    private let encoder = JSONEncoder()

    public override func map(_ from: T) throws -> Data {
        do {
            let value = try encoder.encode(from)
            return value
        } catch {
            throw MappingError(className: "\(T.self)")
        }
    }
}
