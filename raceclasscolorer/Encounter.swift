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
    let intro: String
    let win: String
    let loss: String
    let reward: String
    let raceId: String
    let groupId: String
    let groundId: String
    let enemySpawnRate: Int
    let difficulty: Int
    let restrictions: [String]
}

struct GroundJson: Decodable {
    let id: String
    let ground: [[String]]
}

struct Encounter {
    let name: String
    let introString: String
    let winString: String
    let lossString: String
    let rewards: [RewardType] //TODO: reward system
    let difficulty: Int //TODO: should this be an enum?  What am I doing with this?
    let restrictions: [String] //TODO: need the new buff more global system now
    
    let enemyTeam: Team
    let groundJson: GroundJson
    
    init(encountJson: EncounterJson) {
        self.name = encountJson.name
        self.introString = encountJson.intro
        self.winString = encountJson.win
        self.lossString = encountJson.loss
        self.rewards = Encounter.rewards(rewardString: encountJson.reward)
        self.difficulty = encountJson.difficulty
        self.restrictions = encountJson.restrictions
        
        var personArray = [Person]()
        
        for _ in 0...encountJson.enemySpawnRate - 1 {
            //TODO: These names are now miss matched
            personArray.append(Person(globalRaceId: encountJson.raceId,
                                      globalClassId: encountJson.groupId))
        }
        
        self.enemyTeam = Team(members: personArray)
        self.groundJson = groundWithId(id: encountJson.groundId)
    }
    
    private static func rewards(rewardString: String) -> [RewardType] {
        //TODO: temp logic for now need to think this thur does difficulty affect this or do I need to add more info then a string
        var rewards = [RewardType]()
        
        for char in rewardString {
            if char == "p" {
                rewards.append(.person)
            } else if char == "g" {
                rewards.append(.gold)
            }
        }
        
        return rewards
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

//TODO: beef this out for how much gold and how to select person
enum RewardType {
    case gold
    case person
}

struct Reward {
    let people: [Person]
    let points: [Points]
}
