//
//  Encounter.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/18/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

let allEncounters = loadEncounters()
let allGrounds = loadGrounds()

func randomEncounter() -> Encounter {
    let json = allEncounters.randomElement()!
    return Encounter(encountJson: json)
}

func groundWithId(id: String) -> GroundJson {
    //TODO: this should not be forced but ......
    return allGrounds.first(where: { $0.id == id })!
}

struct EncounterJson: Decodable {
    let name: String
    let raceId: String
    let groupId: String
    let groundId: String
}

struct GroundJson: Decodable {
    let id: String
    let ground: [[String]]
}

struct Encounter {
    let enemyTeam: Team
    //TODO: better story text about what this is wining/losing
    let name: String
    //TODO: what does a reward look like
    let groundJson: GroundJson
    
    init(encountJson: EncounterJson) {
        self.name = encountJson.name
        self.enemyTeam = Team(members: [Person(raceId: encountJson.raceId,
                                               groupId: encountJson.groupId),
                                        Person(raceId: encountJson.raceId,
                                               groupId: encountJson.groupId),
                                        Person(raceId: encountJson.raceId,
                                               groupId: encountJson.groupId)])
        self.groundJson = groundWithId(id: encountJson.groundId)
    }
}

struct FightState {
    let won: Bool
    let reward: Reward
}

struct Points {
    let race: Race
    let points: Int
}

struct Reward {
    let people: [Person]
    let points: [Points]
}
