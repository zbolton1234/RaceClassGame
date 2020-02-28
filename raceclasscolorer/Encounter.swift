//
//  Encounter.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/18/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

enum Spot {
    case void
    case empty
    case terain(String)
    case person(Person)
}

class BattleGround {
    private(set) var ourTeamSide: [Spot]
    private(set) var enemyTeamSide: [Spot]
    
    init(ourTeam: Team, enemyTeam: Team) {
        ourTeamSide = [Spot]()
        ourTeamSide.append(.terain("Tree"))
        ourTeamSide.append(contentsOf: ourTeam.members.map({ Spot.person($0) }))
        ourTeamSide.append(.empty)
        ourTeamSide.append(.empty)
        ourTeamSide.append(.terain("Rock"))
        
        enemyTeamSide = [Spot]()
        enemyTeamSide.append(.terain("Wall"))
        enemyTeamSide.append(contentsOf: enemyTeam.members.map({ Spot.person($0) }))
        enemyTeamSide.append(.empty)
        enemyTeamSide.append(.empty)
        enemyTeamSide.append(.terain("Rock"))
    }
    
    func closestEnemy(attackingPerson: Person, onOur: Bool) -> Person? {
        let attackingTeam = onOur ? ourTeamSide : enemyTeamSide
        let defendingTeam = onOur ? enemyTeamSide : ourTeamSide
        
        //TODO: There has to be a better way then this messy switch right?
        guard let ourSpot = attackingTeam.firstIndex(where: { (spot) in
            switch spot {
            case .person(let personInSpot):
                if personInSpot.id == attackingPerson.id {
                    return true
                }
            default:
                break
            }
            return false
        }) else {
            print("Looked for a person not on our side")
            return nil
        }

        let closetSpot = defendingTeam[ourSpot]
        
        switch closetSpot {
        case .person(let personInSpot):
            return personInSpot
        default:
            break
        }
        
        return nil
    }
}

struct Encounter {
    let ourTeam: Team
    let enemyTeam: Team
    
    var battleGround: BattleGround
    
    init(ourTeam: Team, enemyTeam: Team) {
        self.ourTeam = ourTeam
        self.enemyTeam = enemyTeam
        
        self.battleGround = BattleGround(ourTeam: ourTeam, enemyTeam: enemyTeam)
    }
    
    private func teamAttack(attackingTeam: Team, defendingTeam: Team, isOurTeam: Bool) {
        attackingTeam.members.enumerated().forEach({ (index, member) in
            guard member.currentHp > 0 else {
                return
            }
            
            switch member.attackType {
            case .aoe:
                for enemy in defendingTeam.members {
                    enemy.currentHp -= Int(Float(2) * member.attackModifer(enemy: enemy))
                }
            case .ping:
                let enemy = defendingTeam.members.randomElement()!
                enemy.currentHp -= 1
            case .single:
                if let enemy = battleGround.closestEnemy(attackingPerson: member, onOur: isOurTeam) {
                    enemy.currentHp -= Int(Float(5) * member.attackModifer(enemy: enemy))
                }
            case .buff:
                for member in attackingTeam.members {
                    member.currentAttack += 1
                }
            }
        })
    }
    
    func fight() -> FightState {
        
        while ourTeam.isAlive && enemyTeam.isAlive {
            teamAttack(attackingTeam: ourTeam, defendingTeam: enemyTeam, isOurTeam: true)
            teamAttack(attackingTeam: enemyTeam, defendingTeam: ourTeam, isOurTeam: false)
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
