//
//  Encounter.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/18/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class Encounter {
    let enemyTeam: [Person]
    
    init() {
        enemyTeam = [Person(), Person(), Person(), Person(), Person()]
    }
    
    func fight(team: [Person]) -> FightState {
        //TODO: actual fighting lol
        let testState = [true, false].randomElement()!
        
        let reward: Reward
        if testState {
            reward = Reward(people: [enemyTeam.randomElement()!], points: [Points(race: team.first!.race, points: 5)])
        } else {
            reward = Reward(people: [], points: [])
        }
        
        return FightState(won: testState, reward: reward)
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
