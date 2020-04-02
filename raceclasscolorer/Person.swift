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
let anyConstant = "any"

func raceClass(globalRaceId: String, globalClassId: String) -> (Race?, Class?) {
    if globalRaceId == anyConstant && globalClassId == anyConstant {
        let randomRace = allRaces.randomElement()!
        let randomClass = allClasses(ofClassType: randomRace.tribeType).randomElement()
        
        return (randomRace, randomClass)
    }
    
    var preselectedRace: Race?
    
    if let tribeType = TribeType(rawValue: globalRaceId) {
        preselectedRace = allRacesForceType(ofRaceType: tribeType).randomElement()
    }
    
    let usingRaceId = allRaces(ofRaceId: globalRaceId)
    
    if usingRaceId.count > 0 {
        preselectedRace = usingRaceId.randomElement()
    }
    
    let usingId = allRaces(ofId: globalRaceId)
    
    if usingId.count > 0 {
        preselectedRace = usingId.randomElement()
    }
    
    if let preselectedRace = preselectedRace {
        var allowedClass: Class?
        
        if globalClassId == anyConstant {
            allowedClass = allClasses(ofClassType: preselectedRace.tribeType).randomElement()
        }
        
        if let classTribeType = TribeType(rawValue: globalClassId) {
            if invalidTribeTypes(classTribeType: classTribeType, raceTribeType: preselectedRace.tribeType) {
                print("invalid class selected \(globalRaceId) \(globalClassId)")
                allowedClass = allClasses(ofClassType: preselectedRace.tribeType).randomElement()
            } else {
                allowedClass = allClassesForceType(ofClassType: classTribeType).randomElement()
            }
        }
        
        let usingGroupId = allClasses(ofGroupId: globalClassId)
        
        if usingGroupId.count > 0 {
            let purposedClass = usingGroupId.randomElement()!
            
            if invalidTribeTypes(classTribeType: purposedClass.tribeType, raceTribeType: preselectedRace.tribeType) {
                print("invalid class selected \(globalRaceId) \(globalClassId)")
                allowedClass = allClasses(ofClassType: preselectedRace.tribeType).randomElement()
            } else {
                allowedClass = purposedClass
            }
        }
        
        let usingId = allClasses(ofId: globalClassId)
        
        if usingId.count > 0 {
            let purposedClass = usingId.randomElement()!
            
            if invalidTribeTypes(classTribeType: purposedClass.tribeType, raceTribeType: preselectedRace.tribeType) {
                print("invalid class selected \(globalRaceId) \(globalClassId)")
                allowedClass = allClasses(ofClassType: preselectedRace.tribeType).randomElement()
            } else {
                allowedClass = purposedClass
            }
        }
        
        return (preselectedRace, allowedClass)
    } else {
        var preselectedClass: Class?
        
        if let tribeType = TribeType(rawValue: globalClassId) {
            preselectedClass = allClassesForceType(ofClassType: tribeType).randomElement()
        }
        
        let usingRaceId = allClasses(ofGroupId: globalClassId)
        
        if usingRaceId.count > 0 {
            preselectedClass = usingRaceId.randomElement()
        }
        
        let usingId = allClasses(ofId: globalClassId)
        
        if usingId.count > 0 {
            preselectedClass = usingId.randomElement()
        }
        
        if let preselectedClass = preselectedClass {
            var allowedRace: Race?
            
            if globalRaceId == anyConstant {
                allowedRace = allRaces(ofClassType: preselectedClass.tribeType).randomElement()
            }
            
            if let raceTribeType = TribeType(rawValue: globalRaceId) {
                if invalidTribeTypes(classTribeType: preselectedClass.tribeType, raceTribeType: raceTribeType) {
                    print("invalid race selected \(globalRaceId) \(globalClassId)")
                    allowedRace = allRaces(ofRaceType: preselectedClass.tribeType).randomElement()
                } else {
                    allowedRace = allRacesForceType(ofRaceType: raceTribeType).randomElement()
                }
            }
            
            let usingGroupId = allRaces(ofRaceId: globalRaceId)
            
            if usingGroupId.count > 0 {
                let purposedRace = usingGroupId.randomElement()!
                
                if invalidTribeTypes(classTribeType: preselectedClass.tribeType, raceTribeType: purposedRace.tribeType) {
                    print("invalid race selected \(globalRaceId) \(globalClassId)")
                    allowedRace = allRaces(ofRaceType: preselectedClass.tribeType).randomElement()
                } else {
                    allowedRace = purposedRace
                }
            }
            
            let usingId = allRaces(ofId: globalRaceId)
            
            if usingId.count > 0 {
                let purposedRace = usingId.randomElement()!
                
                if invalidTribeTypes(classTribeType: preselectedClass.tribeType, raceTribeType: purposedRace.tribeType) {
                    print("invalid race selected \(globalRaceId) \(globalClassId)")
                    allowedRace = allRaces(ofRaceType: preselectedClass.tribeType).randomElement()
                } else {
                    allowedRace = purposedRace
                }
            }
            
            return (allowedRace, preselectedClass)
        }
    }
    
    print("everything failed \(globalRaceId) \(globalClassId)")
    return (nil, nil)
}

func invalidTribeTypes(classTribeType: TribeType, raceTribeType: TribeType) -> Bool {
    //Currently the only invalid combo is wild race with civ class aka a Gnoll Wizard
    return classTribeType == .civilized && raceTribeType == .wild
}

//Accepts 4 different types of values raceId "elf", tribeType "civilized", id "forsestElf", any "any" to get the correct Race from the list
func raceWith(globalId: String) -> Race? {
    if globalId == anyConstant {
        return allRaces.randomElement()
    }
    
    if let tribeType = TribeType(rawValue: globalId) {
        return allRaces(ofRaceType: tribeType).randomElement()
    }
    
    let usingRaceId = allRaces(ofRaceId: globalId)
    
    if usingRaceId.count > 0 {
        return usingRaceId.randomElement()
    }
    
    let usingId = allRaces(ofId: globalId)
    
    if usingId.count > 0 {
        return usingId.randomElement()
    }
    
    print("Error: could not find a Race of \(globalId)")
    return nil
}

//Accepts 4 different types of values groupId "magic", tribeType "civilized", id "wizard", any "any" to get the correct Race from the list
func classWith(globalId: String) -> Class? {
    if globalId == anyConstant {
        return allClasses.randomElement()
    }
    
    if let tribeType = TribeType(rawValue: globalId) {
        return allClasses(ofClassType: tribeType).randomElement()
    }
    
    let usingGroupId = allClasses(ofGroupId: globalId)
    
    if usingGroupId.count > 0 {
        return usingGroupId.randomElement()
    }
    
    let usingId = allClasses(ofId: globalId)
    
    if usingId.count > 0 {
        return usingId.randomElement()
    }
    
    print("Error: could not find a Class of \(globalId)")
    return nil
}

func allClassesForceType(ofClassType: TribeType) -> [Class] {
    return allClasses.filter({ $0.tribeType == ofClassType })
}

func allRacesForceType(ofRaceType: TribeType) -> [Race] {
    return allRaces.filter({ $0.tribeType == ofRaceType })
}

func allClasses(ofClassType: TribeType) -> [Class] {
    if ofClassType == .civilized {
        return allClasses
    }
    
    return allClasses.filter({ $0.tribeType == ofClassType })
}

func allRaces(ofClassType: TribeType) -> [Race] {
    if ofClassType == .wild {
        return allRaces
    }
    
    return allRaces.filter({ $0.tribeType == ofClassType })
}

func allRaces(ofRaceType: TribeType) -> [Race] {
    if ofRaceType == .civilized {
        return allRaces
    }
    
    return allRaces.filter({ $0.tribeType == ofRaceType })
}

func allRaceIds() -> [String] {
    return Array(Set(allRaces.map({ $0.raceId })))
}

func allRaces(ofRaceId: String) -> [Race] {
    return allRaces.filter({ $0.raceId == ofRaceId })
}

func allRaces(ofId: String) -> [Race] {
    return allRaces.filter({ $0.id == ofId })
}

func allClasses(ofGroupId: String) -> [Class] {
    return allClasses.filter({ $0.groupId == ofGroupId })
}

func allClasses(ofId: String) -> [Class] {
    return allClasses.filter({ $0.id == ofId })
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
    
    convenience init(globalRaceId: String, globalClassId: String) {
        let preRace = raceWith(globalId: globalRaceId)
        let preClass = classWith(globalId: globalClassId)
        
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
                validClasses = allClasses(ofClassType: .wild)
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
