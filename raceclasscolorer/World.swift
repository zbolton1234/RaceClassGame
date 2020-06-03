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

//TODO: npcs

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

class City: NSObject, NSCoding {
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
    
    //MARK: NSCoding
    struct PropertyKey {
        static let name = "name"
        static let id = "id"
        static let position = "position"
        static let tribeType = "tribeType"
        static let buildings = "buildings"
        static let locked = "locked"
        static let lockedRaces = "lockedRaces"
        static let primaryRace = "primaryRace"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(id, forKey: PropertyKey.id)
        coder.encode(position, forKey: PropertyKey.position)
        coder.encode(tribeType.rawValue, forKey: PropertyKey.tribeType)
        coder.encode(buildings, forKey: PropertyKey.buildings)
        coder.encode(locked, forKey: PropertyKey.locked)
        coder.encode(lockedRaces, forKey: PropertyKey.lockedRaces)
        coder.encode(primaryRace, forKey: PropertyKey.primaryRace)
    }
    
    required init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String,
            let id = coder.decodeObject(forKey: PropertyKey.id) as? String,
            let tribeTypeString = coder.decodeObject(forKey: PropertyKey.tribeType) as? String,
            let tribeType = TribeType(rawValue: tribeTypeString),
            let buildings = coder.decodeObject(forKey: PropertyKey.buildings) as? [Building],
            let lockedRaces = coder.decodeObject(forKey: PropertyKey.lockedRaces) as? [String: Bool],
            let primaryRace = coder.decodeObject(forKey: PropertyKey.primaryRace) as? String else {
                return nil
        }
        
        let locked = coder.decodeBool(forKey: PropertyKey.locked)
        let position = coder.decodeCGPoint(forKey: PropertyKey.position)
        
        self.name = name
        self.id = id
        self.position = position
        self.tribeType = tribeType
        self.buildings = buildings
        self.locked = locked
        self.lockedRaces = lockedRaces
        self.primaryRace = primaryRace
        self.encounters = allEncounters.filter({ $0.cityLocationId == id })
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

class Building: NSObject, NSCoding {
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

    //MARK: NSCoding
    struct PropertyKey {
        static let name = "name"
        static let id = "id"
        static let cityId = "cityId"
        static let groupId = "groupId"
        static let buildings = "buildings"
        static let bdescription = "bdescription"
        static let levels = "levels"
        static let currentLevel = "currentLevel"
        static let encounters = "encounters"
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(name, forKey: PropertyKey.name)
        coder.encode(id, forKey: PropertyKey.id)
        coder.encode(cityId, forKey: PropertyKey.cityId)
        coder.encode(groupId, forKey: PropertyKey.groupId)
        coder.encode(bdescription, forKey: PropertyKey.bdescription)
        coder.encode(levels, forKey: PropertyKey.levels)
        coder.encode(currentLevel, forKey: PropertyKey.currentLevel)
    }
    
    required init?(coder: NSCoder) {
        guard let name = coder.decodeObject(forKey: PropertyKey.name) as? String,
            let id = coder.decodeObject(forKey: PropertyKey.id) as? String,
            let cityId = coder.decodeObject(forKey: PropertyKey.cityId) as? String,
            let groupId = coder.decodeObject(forKey: PropertyKey.groupId) as? String,
            let bdescription = coder.decodeObject(forKey: PropertyKey.bdescription) as? String,
            let levels = coder.decodeObject(forKey: PropertyKey.levels) as? [String: [String]] else {
                return nil
        }
        
        let currentLevel = coder.decodeInteger(forKey: PropertyKey.currentLevel)
        
        self.name = name
        self.id = id
        self.cityId = cityId
        self.groupId = groupId
        self.bdescription = bdescription
        self.levels = levels
        self.currentLevel = currentLevel
    }
}
