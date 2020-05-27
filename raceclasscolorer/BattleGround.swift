//
//  BattleGround.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 3/2/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

enum Spot {
    case void
    case empty
    case terain(String)
    case person(PersonState)
}

enum TeamType {
    case our
    case enemy
}

class PersonState {
    let person: Person
    let teamType: TeamType
    var position: Position
    
    init(person: Person, teamType: TeamType, position: Position) {
        self.person = person
        self.teamType = teamType
        self.position = position
    }
    
    func distance(otherPerson: PersonState) -> Double {
        let ourPosition = position
        let otherPosition = otherPerson.position
        
        let xDiff = pow(Double(ourPosition.x - otherPosition.x), 2)
        let yDiff = pow(Double(ourPosition.y - otherPosition.y), 2)
        return sqrt(xDiff + yDiff)
    }
}

class BattleGround {
    let ourTeamSide: [PersonState]
    let enemyTeamSide: [PersonState]
    
    let ourTeam: Team
    let enemyTeam: Team
    
    private(set) var ground: [[Spot]]
    
    //TODO: fix ground logic
    init(ourTeam: Team, enemyTeam: Team, groundJson: GroundJson) {
        self.ourTeam = ourTeam
        self.enemyTeam = enemyTeam
        
        print(ourTeam)
        print(enemyTeam)
        
        var convertedOur = [PersonState]()
        var convertedEnemy = [PersonState]()
        
        var ground = [[Spot]]()
        for (lineIndex, line) in groundJson.ground.enumerated() {
            var groundLine = [Spot]()
            for (tileIndex, tile) in line.enumerated() {
                switch tile {
                case "e":
                    groundLine.append(.empty)
                case "o":
                    let extraSpace = enemyTeam.members.count - ourTeam.members.count
                    let firstHalf = extraSpace / 2
                    let secondHalf = extraSpace - firstHalf
                    
                    if firstHalf > 0 {
                        for _ in 0...firstHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                    
                    convertedOur = ourTeam.members.enumerated().map({ (index, person) in
                        PersonState(person: person,
                                    teamType: .our,
                                    position: (groundLine.count + index + tileIndex, lineIndex))
                    })
                    
                    groundLine.append(contentsOf: convertedOur.map({ Spot.person($0) }))
                    
                    if secondHalf > 0 {
                        for _ in 0...secondHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                case "m":
                    let extraSpace = ourTeam.members.count - enemyTeam.members.count
                    let firstHalf = extraSpace / 2
                    let secondHalf = extraSpace - firstHalf
                    
                    if firstHalf > 0 {
                        for _ in 0...firstHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                    
                    convertedEnemy = enemyTeam.members.enumerated().map({ (index, person) in
                        PersonState(person: person,
                                    teamType: .enemy,
                                    position: (groundLine.count + index + tileIndex, lineIndex))
                    })
                    
                    groundLine.append(contentsOf: convertedEnemy.map({ Spot.person($0) }))
                    
                    if secondHalf > 0 {
                        for _ in 0...secondHalf - 1 {
                            groundLine.append(.empty)
                        }
                    }
                case "t":
                    groundLine.append(.terain("Tree"))
                default:
                    groundLine.append(.void)
                }
            }
            ground.append(groundLine)
        }
        self.ground = ground
        self.ourTeamSide = convertedOur
        self.enemyTeamSide = convertedEnemy
    }
    
    func fight(stateChanged: @escaping (() -> Void), completion: @escaping ((FightState) -> Void)) {
        
        DispatchQueue.global(qos: .background).async {
            while self.ourTeam.isAlive && self.enemyTeam.isAlive {
                DispatchQueue.main.sync {
                    self.teamAttack(attackingTeam: self.ourTeamSide, defendingTeam: self.enemyTeamSide)
                    self.teamAttack(attackingTeam: self.enemyTeamSide, defendingTeam: self.ourTeamSide)
                    stateChanged()
                }
                sleep(3)
            }
            
            let wonState = self.ourTeam.isAlive
            
            DispatchQueue.main.sync {
                completion(FightState(won: wonState))
            }
        }
    }
    
    //TODO:s
    //extra affects
    //is melee do anything
    //all
    //phases? Buffs
    //fix speed
    //unit test the math problems to guard againts bad numbers
    //sometimes we don't attack all valid if there are bad targets
    //attack less
    
    //summons
    //buffs
    //arc to support ^
    
    private func teamAttack(attackingTeam: [PersonState], defendingTeam: [PersonState]) {
        attackingTeam.enumerated().forEach({ (index, attackingPersonState) in
            let attackingPerson = attackingPersonState.person
            guard attackingPerson.isAlive else {
                return
            }
            
            print("\(attackingPerson.id) is attacking \(attackingPerson.attackMove.name)")
            
            let onOur = attackingPersonState.teamType == .our
            let defendingTeam = (onOur ? enemyTeamSide : ourTeamSide).filter({ $0.person.isAlive })
            let defendingTeamIndexs = defendingTeam.map({ $0.position.x })
            let attackMove = attackingPerson.attackMove
            
            //TODO: fix infinate range
            if attackMove.range == -1 {
                return
            }
            
            for _ in 1...attackMove.targets {
                
                guard let leftMostDefending = defendingTeamIndexs.min(),
                    let rightMostDefending = defendingTeamIndexs.max() else {
                        return
                }
                
                print("Im \(attackingPersonState.position.x)")
                print("left most \(leftMostDefending) right most \(rightMostDefending)")
                
                //Find the closest index to our index if we are on the outside.
                let targetIndex = min(max(attackingPersonState.position.x, leftMostDefending), rightMostDefending)
                
                print("targeting \(targetIndex)")
                
                let minRange = max(targetIndex - attackMove.range, leftMostDefending)
                let maxRange = min(targetIndex + attackMove.range, rightMostDefending)
                
                let targetedIndex = (minRange...maxRange).randomElement() ?? 0
                
                print("updated target \(targetedIndex)")
                                
                let hitEnemies = defendingTeam.filter({ $0.position.x >= targetedIndex - attackMove.size && $0.position.x <= targetIndex + attackMove.size })
                
                //TODO: More math problems ensure this can't be 0
                print("hitting \(hitEnemies)")
                for hitEnemy in hitEnemies {
                    hitEnemy.person.currentHp -= Int(Float(attackMove.damage) * attackingPerson.attackModifer(enemy: hitEnemy.person)) + 1
                }
            }
        })
    }
}
