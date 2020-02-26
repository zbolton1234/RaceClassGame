//
//  Person.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import GameKit
import UIKit

let allRaces = loadRaces()
let allClasses = loadClasses()

func allClasses(ofType: TribeType) -> [Class] {
    return allClasses.filter({ $0.tribeType == ofType })
}

func allRaceIds() -> [String] {
    return Array(Set(allRaces.map({ $0.raceId })))
}

func allRaces(ofRaceId: String) -> [Race] {
    return allRaces.filter({ $0.raceId == ofRaceId })
}

let random = GKRandomSource()
let randomPersentage = GKGaussianDistribution(randomSource: random, mean: 100, deviation: 20)

class Person: CustomStringConvertible {
    let id = UUID()
    let race: Race
    let pclass: Class
    let color: Color
    let hp: Int
    let attack: Int
    let defense: Int
    let attackType: AttackType
    let secondary: AttackType
    
    var currentHp: Int
    var currentAttack: Int
    var currentDefense: Int
    
    init(preRace: Race? = nil, preClass: Class? = nil, preColor: Color? = nil) {
        let selectedRace: Race
        let selectedClass: Class
        let selectedColor: Color
        
        if let preRace = preRace {
            selectedRace = preRace
        } else {
            let randomType = allRaceIds().randomElement()!
            selectedRace = allRaces(ofRaceId: randomType).randomElement()!
        }
        
        if let preClass = preClass {
            selectedClass = preClass
        } else {
            let validClasses: [Class]
            
            if selectedRace.tribeType == .wild {
                validClasses = allClasses(ofType: .wild)
            } else {
                validClasses = allClasses
            }
            
            selectedClass = validClasses.randomElement()!
        }
        
        if let preColor = preColor {
            selectedColor = preColor
        } else {
            selectedColor = Color.allCases.randomElement()!
        }
        
        race = selectedRace
        pclass = selectedClass
        color = selectedColor
        
        hp = Int(Double(pclass.hp) * (Double(randomPersentage.nextInt()) / 100.0))
        attack = Int(Double(pclass.attack) * (Double(randomPersentage.nextInt()) / 100.0))
        defense = Int(Double(pclass.defense) * (Double(randomPersentage.nextInt()) / 100.0))
     
        currentHp = hp
        currentAttack = attack
        currentDefense = defense
        
        attackType = pclass.attackType
        secondary = pclass.secondary
    }
    
    var description: String {
        return "race: \(race) class: \(pclass) color: \(color)"
    }
    
    func totalBuffs(team: Team) -> Int {
        return team.members.reduce(0) { (total, otherPerson) -> Int in
            if self.id == otherPerson.id {
                return total
            }
            
            return total + self.compareRace(person: otherPerson) + self.compareClass(person: otherPerson)
        }
    }
    
    func attackModifer(enemy: Person) -> Float {
        return Float(attack / enemy.defense)
    }
    
    func compareRace(person: Person) -> Int {
        if race.raceId == person.race.raceId {
            //extra bonus if same sub race?
            return Buffs.same
        } else if person.race.friendlyRaces.contains(race.raceId) {
            return Buffs.liked
        } else if person.race.hatedRaces.contains(race.raceId) {
            return Buffs.hated
        }
        return Buffs.other
    }
    
    func compareClass(person: Person) -> Int {
        if pclass.groupId == person.pclass.groupId {
            if color == color {
                return Buffs.identical
            } else {
                return Buffs.same
            }
        }
        return 0
    }
}

enum TribeType: String, Decodable {
    case civilized
    case wild
    case custom
}

enum AttackType: String, Decodable {
    case aoe
    case ping
    case single
    case buff
}

struct Race: Decodable {
    let name: String
    let raceId: String
    let id: String
    let tribeType: TribeType
    let description: String
    let friendlyRaces: [String]
    let animals: [String]
    let hatedRaces: [String]
}

struct Class: Decodable {
    let name: String
    let groupId: String
    let id: String
    let tribeType: TribeType
    let description: String
    let hp: Int
    let attack: Int
    let defense: Int
    let attackType: AttackType
    let secondary: AttackType
}

enum Color: Int, CaseIterable {
    case red
    case blue
    case green
}
