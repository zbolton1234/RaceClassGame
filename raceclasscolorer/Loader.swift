//
//  Loader.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/19/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import Foundation
import UIKit

func loadRaces() -> [Race] {
    return load(assetName: "races", decodeClass: [Race].self)!
}

func loadClasses() -> [Class] {
    return load(assetName: "classes", decodeClass: [Class].self)!
}

func loadEncounters() -> [EncounterJson] {
    return load(assetName: "encounters", decodeClass: [EncounterJson].self)!
}

func loadGrounds() -> [GroundJson] {
    return load(assetName: "ground", decodeClass: [GroundJson].self)!
}

private func load<T: Decodable>(assetName: String, decodeClass: T.Type) -> T? {
    guard let asset = NSDataAsset(name: assetName),
        let decoded = try? JSONDecoder().decode(T.self, from: asset.data) else {
            print("Failed to load \(assetName)")
            return nil
    }
    
    return decoded
}
