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
            guard member.currentHp > 0,
                let memberPosition = memberState.position else {
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
                    print("I'm \(member.race.name)\(member.pclass.name)\(member.color) and \(enemyState.1.person.race.name)\(enemyState.1.person.pclass.name)\(enemyState.1.person.color) is \(enemyState.0)")
                    
                    if enemyState.0 < 2.0 {
                        enemyState.1.person.currentHp -= Int(Float(5) * member.attackModifer(enemy: enemyState.1.person))
                    } else {
                        var newPostion = memberPosition
                        
                        if enemyState.1.position?.y ?? 0 > memberPosition.y {
                            newPostion.y += 1
                        } else if enemyState.1.position?.y ?? 0 < memberPosition.y {
                            newPostion.y -= 1
                        }
                        
                        if enemyState.1.position?.x ?? 0 > memberPosition.x {
                            newPostion.x += 1
                        } else if enemyState.1.position?.x ?? 0 < memberPosition.x {
                            newPostion.x -= 1
                        }
                        
                        battleGround.move(person: memberState, position: newPostion)
                    }
                }
            case .buff:
                for memberState in attackingTeam {
                    memberState.person.currentAttack += 1
                }
            }
        })
    }
    
    //TODO: the passing this view here feels bad should be a block
    func fight(battleFieldView: BattleFieldView, completion: @escaping ((FightState) -> Void)) {
        
        DispatchQueue.global(qos: .background).async {
            while self.ourTeam.isAlive && self.enemyTeam.isAlive {
                DispatchQueue.main.sync {
                    self.teamAttack(attackingTeam: self.battleGround.ourTeamSide, defendingTeam: self.battleGround.enemyTeamSide)
                    self.teamAttack(attackingTeam: self.battleGround.enemyTeamSide, defendingTeam: self.battleGround.ourTeamSide)
                    battleFieldView.updateBattleGround(battleGround: self.battleGround)
                }
                sleep(3)
            }
            
            let wonState = self.ourTeam.isAlive
            
            let reward: Reward
            if wonState {
                reward = Reward(people: [self.enemyTeam.members.randomElement()!],
                                points: [Points(race: self.ourTeam.members.first!.race, points: 5)])
            } else {
                reward = Reward(people: [], points: [])
            }
            
            completion(FightState(won: wonState, reward: reward))
        }
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
