//
//  Loader.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/19/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import Foundation
import UIKit

private let directoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
private let fileURL = URL(fileURLWithPath: "cities", relativeTo: directoryURL)

func saveWorld() {
    do {
        let data = try NSKeyedArchiver.archivedData(withRootObject: allCities, requiringSecureCoding: false)
        try data.write(to: fileURL)
    } catch {
        print("failed to save cities: \(error)")
    }
}

let allRaces: [Race] = {
    print("loading races")
    return load(assetName: "races", decodeClass: [Race].self) ?? []
}()

let allClasses: [Class] = {
    print("loading classes")
    return load(assetName: "classes", decodeClass: [Class].self) ?? []
}()

let allEncounters: [Encounter] = {
    print("loading encounters")
    let jsons = load(assetName: "encounters", decodeClass: [EncounterJson].self) ?? []
    return jsons.map({ Encounter(encountJson: $0) })
}()

let allBuildings: [BuildingJSON] = {
    print("loading buildings")
    return load(assetName: "buildings", decodeClass: [BuildingJSON].self) ?? []
}()

let allCities: [City] = {
    print("loading cities")
    
    var loadedCities: [City]?
    
    do {
        let savedData = try Data(contentsOf: fileURL)
        loadedCities = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(savedData) as? [City]
    } catch {
        print(error)
    }
    
    if let cities = loadedCities {
        return cities
    } else {
        let jsons = load(assetName: "cities", decodeClass: [CityJson].self) ?? []
        return jsons.map({ City(cityJson: $0) })
    }
}()

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
