//
//  Encounter.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/18/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

let allEncounters = loadEncounters()

func randomEncounter() -> Encounter {
    let json = allEncounters.randomElement()!
    return Encounter(encountJson: json)
}

struct EncounterJson: Decodable {
    let name: String
    let raceId: String
    let groupId: String
}

struct Encounter {
    let enemyTeam: Team
    //TODO: better story text about what this is wining/losing
    let name: String
    //TODO: what does a reward look like
    
    init(encountJson: EncounterJson) {
        self.name = encountJson.name
        self.enemyTeam = Team(members: [Person(raceId: encountJson.raceId,
                                               groupId: encountJson.groupId),
                                        Person(raceId: encountJson.raceId,
                                               groupId: encountJson.groupId),
                                        Person(raceId: encountJson.raceId,
                                               groupId: encountJson.groupId)])
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
