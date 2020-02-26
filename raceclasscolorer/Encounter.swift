//
//  Encounter.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/18/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

struct Encounter {
    let ourTeam: Team
    let enemyTeam: Team
    
    func fight() -> FightState {
        
        while ourTeam.isAlive && enemyTeam.isAlive {
            ourTeam.members.enumerated().forEach({ (index, member) in
                switch member.attackType {
                case .aoe:
                    for enemy in enemyTeam.members {
                        enemy.currentHp -= Int(Float(2) * member.attackModifer(enemy: enemy))
                    }
                case .ping:
                    let enemy = enemyTeam.members.randomElement()!
                    enemy.currentHp -= 1
                case .single:
                    let enemy = enemyTeam.members[index]
                    enemy.currentHp -= Int(Float(5) * member.attackModifer(enemy: enemy))
                case .buff:
                    for member in ourTeam.members {
                        member.currentAttack += 1
                    }
                }
            })
        }
        
        let wonState = ourTeam.isAlive
        
        let reward: Reward
        if wonState {
            reward = Reward(people: [enemyTeam.members.randomElement()!], points: [Points(race: ourTeam.members.first!.race, points: 5)])
        } else {
            reward = Reward(people: [], points: [])
        }
        
        return FightState(won: wonState, reward: reward)
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
