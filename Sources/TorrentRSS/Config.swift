//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 26/04/20.
//

import Foundation
import Yams

public struct Config: Codable {
    var server: URL
    var secondsTimeout: Int?
    var username: String?
    var password: String?

    public init?(yaml: String) {
        let decoder = YAMLDecoder()
        let decoded = try? decoder.decode(Config.self, from: yaml)

        if let d = decoded {
            self = d
        } else {
            return nil
        }
    }
}
