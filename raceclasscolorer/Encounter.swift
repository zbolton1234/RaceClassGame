//
//  Encounter.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/18/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

//TODO: Do I need this???
struct Encounter {
    //TODO: know have teams and battlegrounds they are duplicates (combine)
    let ourTeam: Team
    let enemyTeam: Team
    
    var battleGround: BattleGround
    
    init(ourTeam: Team, enemyTeam: Team) {
        self.ourTeam = ourTeam
        self.enemyTeam = enemyTeam
        
        self.battleGround = BattleGround(ourTeam: ourTeam, enemyTeam: enemyTeam)
    }
    
    private func teamAttack(attackingTeam: [PersonState], defendingTeam: [PersonState]) {
        attackingTeam.enumerated().forEach({ (index, memberState) in
            let member = memberState.person
            guard member.currentHp > 0 else {
                return
            }
            
            switch member.attackType {
            case .aoe:
                for enemyState in defendingTeam {
                    enemyState.person.currentHp -= Int(Float(2) * member.attackModifer(enemy: enemyState.person))
                }
            case .ping:
                let enemyState = defendingTeam.randomElement()!
                enemyState.person.currentHp -= 1
            case .single:
                if let enemyState = battleGround.closestEnemy(attackingPerson: memberState) {
                    enemyState.person.currentHp -= Int(Float(5) * member.attackModifer(enemy: enemyState.person))
                }
            case .buff:
                for memberState in attackingTeam {
                    memberState.person.currentAttack += 1
                }
            }
        })
    }
    
    func fight() -> FightState {
        
        while ourTeam.isAlive && enemyTeam.isAlive {
            teamAttack(attackingTeam: battleGround.ourTeamSide, defendingTeam: battleGround.enemyTeamSide)
            teamAttack(attackingTeam: battleGround.enemyTeamSide, defendingTeam: battleGround.ourTeamSide)
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
