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
    var position: Position?
    
    init(person: Person, teamType: TeamType) {
        self.person = person
        self.teamType = teamType
    }
    
    func distance(otherPerson: PersonState) -> Double? {
        guard let ourPosition = position,
            let otherPosition = otherPerson.position else {
            return nil
        }
        
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
    
    init(ourTeam: Team, enemyTeam: Team, groundJson: GroundJson) {
        self.ourTeam = ourTeam
        self.enemyTeam = enemyTeam
        
        print(ourTeam)
        print(enemyTeam)
        
        ourTeamSide = ourTeam.members.map({ PersonState(person: $0,
                                                        teamType: .our) })
        enemyTeamSide = enemyTeam.members.map({ PersonState(person: $0,
                                                            teamType: .enemy) })
        
        ourTeamSide.enumerated().forEach({ (index, state) in
            state.position = (index + 2, 0)
        })
        let convertedOur = ourTeamSide.map({ Spot.person($0) })
        enemyTeamSide.enumerated().forEach({ (index, state) in
            state.position = (index + 2, 5)
        })
        let convertedEnemy = enemyTeamSide.map({ Spot.person($0) })
        
        var ground = [[Spot]]()
        for line in groundJson.ground {
            var groundLine = [Spot]()
            for tile in line {
                switch tile {
                case "e":
                    groundLine.append(.empty)
                case "o":
                    groundLine.append(contentsOf: convertedOur)
                case "m":
                    groundLine.append(contentsOf: convertedEnemy)
                case "t":
                    groundLine.append(.terain("Tree"))
                default:
                    groundLine.append(.void)
                }
            }
            ground.append(groundLine)
        }
        self.ground = ground
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
            
            let reward: Reward
            if wonState {
                reward = Reward(people: [self.enemyTeam.members.randomElement()!],
                                points: [Points(race: self.ourTeam.members.first!.race, points: 5)])
            } else {
                reward = Reward(people: [], points: [])
            }
            
            DispatchQueue.main.sync {
                completion(FightState(won: wonState, reward: reward))
            }
        }
    }
    
    //TODO:s
    //test move and hit
    //clean up names
    //clean up edge cases
    //clean up force unwrap
    //aoe
    //extra affects
    //does range work right?
    //is melee do anything
    //corning
    //sight blocked
    //dead bodies
    //sight blocked
    //all
    //phases?  like all move then all attack?
    
    //summons
    //buffs
    //arc to support ^
    
    private func teamAttack(attackingTeam: [PersonState], defendingTeam: [PersonState]) {
        attackingTeam.enumerated().forEach({ (index, memberState) in
            let member = memberState.person
            guard member.currentHp > 0 else {
                return
            }
            
            print("\(member.id) is attacking \(member.attackMove.name)")
            
            let attackMove = member.attackMove
            var targets = closestEnemy(attackingPerson: memberState, numberOfTargets: attackMove.targets)
            
            //Also ensures targets is not empty
            guard let closestTarget = targets.first else {
                return
            }

            if closestTarget.distance >= Double(attackMove.range) + 1.0 || sightBlocked(attackingPosition: memberState.position!, defendingPosition: closestTarget.person.position!) {
                smartMove(personState: memberState, goalPosition: closestTarget.person.position!)
                //we moved need to update the states as we might be in range now
                targets = closestEnemy(attackingPerson: memberState, numberOfTargets: attackMove.targets)
            }

            for target in targets {
                if target.distance <= Double(attackMove.range) + 1.0 && !sightBlocked(attackingPosition: memberState.position!, defendingPosition: target.person.position!) {
                    target.person.person.currentHp -= Int(Float(attackMove.damage) * member.attackModifer(enemy: closestTarget.person.person)) + 1
                }
            }
        })
    }
}

//MARK: State Helpers
extension BattleGround {
    private func sightBlocked(attackingPosition: Position, defendingPosition: Position) -> Bool {
        let allPositions = smartVisionLine(position1: attackingPosition, position2: defendingPosition)
        
        for position in allPositions {
            if position != attackingPosition && position != defendingPosition {
                if case .empty = ground[position.y][position.x] {
                    //TODO: uuugggg
                } else {
                    return true
                }
            }
        }
        
        return false
    }
    
    typealias Distance = (distance: Double, person: PersonState)
    private func closestEnemy(attackingPerson: PersonState, numberOfTargets: Int) -> [Distance] {
        let onOur = attackingPerson.teamType == .our
        let defendingTeam = onOur ? enemyTeamSide : ourTeamSide
        
        let distances = defendingTeam.compactMap({ (defender) -> Distance? in
            guard defender.person.currentHp > 0 else {
                return nil
            }
            
            guard let distance = attackingPerson.distance(otherPerson: defender) else {
                return nil
            }
            return (distance, defender)
        }).sorted(by: { $0.distance < $1.distance })
        let allTargets = distances.count > numberOfTargets ? Array(distances[0...(numberOfTargets - 1)]) : distances
        return allTargets
    }
}

// MARK: Mutable Helpers
extension BattleGround {
    private func move(person: PersonState, position: Position) {
        guard spotEmpty(position: position) else {
            return
        }

        ground[position.y][position.x] = .person(person)

        if let oldPosition = person.position {
            ground[oldPosition.y][oldPosition.x] = .empty
        }

        person.position = position
    }
    
    private func smartMove(personState: PersonState, goalPosition: Position) {
        guard let startPosition = personState.position else {
            return
        }
        
        var openList = [PositionNode]()
        var closedList = [PositionNode]()
        
        let startNode = PositionNode(postion: startPosition)
        let endNode = PositionNode(postion: goalPosition)
        
        openList.append(startNode)
        
        while openList.count > 0 {
            var currentNode = openList.first!
            var currentIndex = 0
            
            for (index, item) in openList.enumerated() {
                if item.fScore < currentNode.fScore {
                    currentNode = item
                    currentIndex = index
                }
            }
            
            openList.remove(at: currentIndex)
            closedList.append(currentNode)
            
            if currentNode == endNode {
                if let nextNode = currentNode.nextNode(startNode: startNode) {
                    move(person: personState, position: nextNode.position)
                }
                
                print("we got it")
                return
            }
            
            let validSpots = validNearSpots(position: currentNode.position).map({ PositionNode(postion: $0) })
            
            for validSpot in validSpots {
                if closedList.contains(validSpot) {
                    continue
                }
                
                validSpot.parent = currentNode
                validSpot.gScore = currentNode.gScore + 1
                validSpot.hScore = distanceHisc(position1: validSpot.position, position2: endNode.position)
                
                for openNode in openList {
                    if validSpot == openNode && validSpot.gScore > openNode.gScore {
                        continue
                    }
                }
                
                openList.append(validSpot)
            }
        }
        
        print("Did not find it")
    }
    
    private func spotValidPath(position: Position) -> Bool {
        switch ground[position.y][position.x] {
        case .terain(_):
            return false
        case .void:
            return false
        default:
            return true
        }
    }
    
    private func spotEmpty(position: Position) -> Bool {
        //TODO: do this better
        if case .person(let personInSpot) = ground[position.y][position.x] {
            if personInSpot.person.currentHp <= 0 {
                ground[position.y][position.x] = .empty
            }
        }
        
        guard case .empty = ground[position.y][position.x] else {
            return false
        }
        
        return true
    }
    
    private func validNearSpots(position: Position) -> [Position] {
        var spots = [Position]()
        
        for xChange in -1...1 {
            for yChange in -1...1 {
                let possiblePosition = Position(x: position.x + xChange, y: position.y + yChange)
                
                let validX = possiblePosition.x >= 0 && possiblePosition.x < ground.first!.count
                let validY = possiblePosition.y >= 0 && possiblePosition.y < ground.count
                let isStartSpot = xChange == 0 && yChange == 0
                if validX && validY && !isStartSpot && spotValidPath(position: possiblePosition) {
                    spots.append(possiblePosition)
                }
            }
        }
        
        return spots
    }
}

private class PositionNode: Hashable {
    let position: Position
    var parent: PositionNode?
    
    var gScore = 0.0
    var hScore = 0.0
    var fScore: Double {
        return gScore + hScore
    }
    
    init(postion: Position) {
        self.position = postion
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(position.x)
        hasher.combine(position.y)
    }
    
    func nextNode(startNode: PositionNode) -> PositionNode? {
        if parent == startNode {
            return self
        } else {
            return parent?.nextNode(startNode: startNode)
        }
    }
}

private func ==(lhs: PositionNode, rhs: PositionNode) -> Bool {
  return lhs.position == rhs.position
}
