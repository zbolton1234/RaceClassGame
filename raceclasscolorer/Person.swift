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

func allClasses(ofGroupId: String) -> [Class] {
    return allClasses.filter({ $0.groupId == ofGroupId })
}

func classWithId(classId: String) -> Class? {
    return allClasses.first(where: { $0.id == classId })
}

let random = GKRandomSource()
let randomPersentage = GKGaussianDistribution(randomSource: random, mean: 100, deviation: 20)

enum TribeType: String, Decodable {
    case civilized
    case wild
    case custom
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
    let bounusSpeed: Int
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
    let speed: Int
    let attackMove: Attack
}

struct Attack: Decodable {
    let name: String
    //extra affect
    let targets: Int
    let range: Int
    let isMelee: Bool
    let size: Int
    let damage: Int
}

enum Color: Int, CaseIterable {
    case red
    case blue
    case green
}

class Person: Battler, CustomStringConvertible {
    let id = UUID()
    let race: Race
    let pclass: Class
    let color: Color
    let hp: Int
    let attack: Int
    let defense: Int
    let speed: Int
    let attackMove: Attack
    
    var currentHp: Int
    var currentAttack: Int
    var currentDefense: Int
    var currentSpeed: Int
    
    convenience init(raceId: String, groupId: String) {
        let preRace = allRaces(ofRaceId: raceId).randomElement()!
        let preClass = allClasses(ofGroupId: groupId).randomElement()!
        
        self.init(preRace: preRace, preClass: preClass)
    }
    
    //TODO: made debug only or move to test???
    class func testDummy() -> Person {
        let dummy = Person()
        
        dummy.currentHp = 1
        dummy.currentAttack = 0
        dummy.currentDefense = 0
        dummy.currentSpeed = 0
        
        return dummy
    }
    
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
        
        //TODO: math!  need to ensure we never get a 0 here
        hp = Int(Double(pclass.hp) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        attack = Int(Double(pclass.attack) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        defense = Int(Double(pclass.defense) * (Double(randomPersentage.nextInt()) / 100.0)) + 1
        speed = pclass.speed + race.bounusSpeed
        
        currentHp = hp
        currentAttack = attack
        currentDefense = defense
        currentSpeed = speed
        
        attackMove = pclass.attackMove
    }
    
    var description: String {
        return "race: \(race.id) class: \(pclass.id) color: \(color)"
    }
    
    func totalBuffs(team: Team) -> Int {
        return team.members.reduce(0) { (total, otherPerson) -> Int in
            if self.id == otherPerson.id {
                return total
            }
            
            return total + self.buffForRace(person: otherPerson) + self.buffForClass(person: otherPerson)
        }
    }
    
    func buffForRace(person: Person) -> Int {
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
    
    func buffForClass(person: Person) -> Int {
        if pclass.groupId == person.pclass.groupId {
            if color == color {
                return Buffs.identical
            } else {
                return Buffs.same
            }
        }
        return 0
    }
    
    func personImage() -> UIImage {
        return imageFromString(string: NSString(string: race.name))
    }
    
    private func imageFromString(string: NSString) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        string.draw(in: CGRect(x: 0, y: 0, width: 100, height: 100), withAttributes: nil)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
    }
}
