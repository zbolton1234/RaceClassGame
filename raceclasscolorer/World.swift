//
//  World.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 4/14/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

private let neturalEncounters = allEncounters.filter({ $0.cityLocationId == "any" })
private let neturalCivEncounters = allEncounters.filter({ $0.cityLocationId == "anyCivilized" })
private let neturalWildEncounters = allEncounters.filter({ $0.cityLocationId == "anyWild" })

//npcs

class CityJson: Decodable {
    let name: String
    let id: String
    let tribeType: TribeType
    let locked: Bool
    let lockedRaces: [String]
    let primaryRace: String
    let x: Int
    let y: Int
}

class City: Equatable {
    let name: String
    let id: String
    let position: CGPoint
    let tribeType: TribeType
    var buildings = [Building]()
    var locked: Bool
    private(set) var lockedRaces: [String: Bool]
    private(set) var primaryRace: String
    
    private let encounters: [Encounter]
    
    init(cityJson: CityJson) {
        self.name = cityJson.name
        self.id = cityJson.id
        self.position = CGPoint(x: cityJson.x, y: cityJson.y)
        self.tribeType = cityJson.tribeType
        self.locked = cityJson.locked
        self.primaryRace = cityJson.primaryRace
        
        var lraces = [String: Bool]()
        
        for raceId in cityJson.lockedRaces {
            lraces[raceId] = true
        }
        
        self.lockedRaces = lraces
        self.encounters = allEncounters.filter({ $0.cityLocationId == cityJson.id })
        
        let commonBuilding = Building(name: "Town Hall",
                                      id: "townHall",
                                      cityId: cityJson.id,
                                      classId: "common",
                                      description: "The town hall of \(cityJson.name) where the commoners gather.")
        self.buildings.append(commonBuilding)
    }
    
    func randomEncounter(team: Team) -> Encounter {
        var possibleEncounters = [Encounter]()
        
        for encounter in encounters {
            
            if lockedRaces[encounter.raceId] ?? false {
                continue
            }
            
            if !encounter.teamAllowed(team: team) {
                continue
            }
            
            var weight = encounter.weight
            for weightTag in encounter.weightTags {
                if team.teamTags().contains(weightTag) {
                    weight += 1
                }
            }
            
            if encounter.raceId == primaryRace {
                weight += 1
            }
            
            possibleEncounters.append(contentsOf: Array(repeating: encounter, count: weight))
        }
        
        possibleEncounters.append(contentsOf: neturalEncounters)
        
        switch tribeType {
        case .civilized:
            possibleEncounters.append(contentsOf: neturalCivEncounters)
        case .wild:
            possibleEncounters.append(contentsOf: neturalWildEncounters)
        case .custom:
            break
        }
        
        return possibleEncounters.randomElement()!
    }
    
    static func == (lhs: City, rhs: City) -> Bool {
        return lhs.id == rhs.id
    }
}

struct Building: Decodable, Equatable {
    let name: String
    let id: String
    let cityId: String
    let classId: String
    let description: String
}
