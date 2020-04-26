//
//  File.swift
//
//
//  Created by Ataias Pereira Reis on 26/04/20.
//

import Foundation
import Yams

public struct FeedOption: Codable {
    var link: URL
    var include: [String]

    init?(yaml: String) {
        let decoder = YAMLDecoder()
        let decoded = try? decoder.decode(FeedOption.self, from: yaml)

        if let d = decoded {
            self.link = d.link
            self.include = d.include
        } else {
            return nil
        }
    }

    public static func array(yaml: String) -> [FeedOption]? {
        let decoder = YAMLDecoder()
        let decoded = try? decoder.decode([FeedOption].self, from: yaml)
        return decoded
    }
}
