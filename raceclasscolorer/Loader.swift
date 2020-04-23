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
    return load(assetName: "races", decodeClass: [Race].self) ?? []
}

func loadClasses() -> [Class] {
    return load(assetName: "classes", decodeClass: [Class].self) ?? []
}

func loadEncounters() -> [Encounter] {
    let jsons = load(assetName: "encounters", decodeClass: [EncounterJson].self) ?? []
    return jsons.map({ Encounter(encountJson: $0) })
}

func loadCities() -> [City] {
    let jsons = load(assetName: "cities", decodeClass: [CityJson].self) ?? []
    return jsons.map({ City(cityJson: $0) })
}

func loadGrounds() -> [GroundJson] {
    return load(assetName: "ground", decodeClass: [GroundJson].self)!
}

private func load<T: Decodable>(assetName: String, decodeClass: T.Type) -> T? {
    guard let asset = NSDataAsset(name: assetName) else {
            print("Failed to load \(assetName)")
            return nil
    }
    
    let decoded: T
    
    do {
        decoded = try JSONDecoder().decode(T.self, from: asset.data)
    } catch {
        print("Failed to load \(assetName)")
        print(error)
        return nil
    }
    
    return decoded
}
