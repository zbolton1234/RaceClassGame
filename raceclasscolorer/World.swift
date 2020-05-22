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

let allBuildings = loadBuildings()

//npcs

class CityJson: Decodable {
    let name: String
    let id: String
    let tribeType: TribeType
    let locked: Bool
    let lockedRaces: [String]
    let unlockedRaces: [String]
    let primaryRace: String
    let startingBuildings: [String]
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
        
        for raceId in cityJson.unlockedRaces {
            lraces[raceId] = false
        }
        
        self.lockedRaces = lraces
        self.encounters = allEncounters.filter({ $0.cityLocationId == cityJson.id })
        
        var startingBuildings = [Building]()
        
        for buildingId in cityJson.startingBuildings {
            if let buildingJSON = allBuildings.first(where: { $0.id == buildingId }) {
                startingBuildings.append(Building(buildingJSON: buildingJSON))
            } else {
                print("\(buildingId) missing")
            }
        }
        
        buildings = startingBuildings
    }
    
    func unlockedRaces() -> [String] {
        var races = [String]()
        
        for key in lockedRaces.keys {
            if !(lockedRaces[key] ?? true) {
                races.append(key)
            }
        }
        
        return races
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

//How are buildings unlocked
//city starts with some
//some are unlocked via encounters
//some require the correct person to start
//some take gold

//How to level
//gold (but how much)
//person (maybe)
//items but that lattttter
//do all have the same max
//taverns for commoners are they different?
struct BuildingJSON: Decodable, Equatable {
    let name: String
    let id: String
    let cityId: String
    let groupId: String
    let description: String
    let levels: [String: [String]]
}

class Building {
    let name: String
    let id: String
    let cityId: String
    let groupId: String
    let bdescription: String
    let levels: [String: [String]]
    
    var currentLevel = 1 {
        didSet {
            if let currentLevelClasses = levels[String(currentLevel)] {
                validClasses.append(contentsOf: currentLevelClasses)
            }
        }
    }
    
    private var validClasses = [String]()
    
    init(buildingJSON: BuildingJSON) {
        self.name = buildingJSON.name
        self.id = buildingJSON.id
        self.cityId = buildingJSON.cityId
        self.groupId = buildingJSON.groupId
        self.bdescription = buildingJSON.description
        self.levels = buildingJSON.levels
        
        if let levelOneClasses = buildingJSON.levels["1"] {
            validClasses.append(contentsOf: levelOneClasses)
        }
    }
    
    func reward(city: City) -> BuildingReward {
        //TODO: what is this going to be?
        let randomGold = Int.random(in: 0...100)
        
        guard let selectedRace = city.unlockedRaces().randomElement(),
            let selectedClass = validClasses.randomElement() else {
                return BuildingReward(gold: randomGold, people: [])
        }
        
        return BuildingReward(gold: randomGold, people: [Person(globalRaceId: selectedRace, globalClassId: selectedClass)])
    }
}
