//
//  raceclasscolorerTests.swift
//  raceclasscolorerTests
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import XCTest
@testable import raceclasscolorer

class raceclasscolorerTests: XCTestCase {
    
    func testBasicWin() {
        let ourTestTeam = Team(members: [Person(preClass: classWithId(classId: "wizard"))])
        let enemyTeam = Team(members: [Person.testDummy()])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "e", "o", "e", "e"],["e", "e", "e", "e", "e"],["e", "e", "m", "e", "e"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertFalse(battleGround.enemyTeam.isAlive)
            XCTAssertTrue(battleGround.ourTeam.isAlive)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
    func testBasicLose() {
        let ourTestTeam = Team(members: [Person.testDummy()])
        let enemyTeam = Team(members: [Person(preClass: classWithId(classId: "wizard"))])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "e", "o", "e", "e"],["e", "e", "e", "e", "e"],["e", "e", "m", "e", "e"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertFalse(battleGround.ourTeam.isAlive)
            XCTAssertTrue(battleGround.enemyTeam.isAlive)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
    func testStepUpAndShoot() {
        let ourTestTeam = Team(members: [Person(preClass: classWithId(classId: "wizard"))])
        let enemyTeam = Team(members: [Person.testDummy()])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "e", "o", "e", "e"],["e", "e", "e", "e", "e"],["e", "e", "e", "e", "e"],["e", "e", "e", "e", "e"],["e", "e", "e", "e", "e"],["e", "e", "e", "e", "e"],["e", "e", "m", "e", "e"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertFalse(battleGround.enemyTeam.isAlive)
            XCTAssertTrue(battleGround.ourTeam.isAlive)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
    func testShootNextThruTrees() {
        let nonMovingWiz = Person(preClass: classWithId(classId: "wizard"))
        nonMovingWiz.currentSpeed = 0
        let ourTestTeam = Team(members: [nonMovingWiz])
        let enemyTeam = Team(members: [Person.testDummy()])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "t", "o", "t", "e"],["e", "t", "e", "t", "e"],["e", "t", "m", "t", "e"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertFalse(battleGround.enemyTeam.isAlive)
            XCTAssertTrue(battleGround.ourTeam.isAlive)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
    func testConerShootThruTrees() {
        let nonMovingWiz = Person(preClass: classWithId(classId: "wizard"))
        nonMovingWiz.currentSpeed = 0
        let ourTestTeam = Team(members: [nonMovingWiz])
        let enemyTeam = Team(members: [Person.testDummy()])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "e", "e", "o", "e"],["e", "e", "e", "e", "e"],["e", "t", "m", "t", "e"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertFalse(battleGround.enemyTeam.isAlive)
            XCTAssertTrue(battleGround.ourTeam.isAlive)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
    func testTreeInFrontWay() {
        let nonMovingWiz = Person(preClass: classWithId(classId: "wizard"))
        nonMovingWiz.currentSpeed = 0
        let ourTestTeam = Team(members: [nonMovingWiz])
        let enemyTeam = Team(members: [Person.testDummy()])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "e", "o", "e", "e"],["e", "e", "t", "e", "e"],["e", "e", "m", "e", "e"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertTrue(battleGround.ourTeam.isAlive)
            XCTAssertTrue(battleGround.enemyTeam.isAlive)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
    func testTreeToTheSideInWay() {
        let nonMovingWiz = Person(preClass: classWithId(classId: "wizard"))
        nonMovingWiz.currentSpeed = 0
        let ourTestTeam = Team(members: [nonMovingWiz])
        let enemyTeam = Team(members: [Person.testDummy()])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "e", "e", "o", "e"],["e", "e", "e", "t", "e"],["e", "e", "m", "e", "e"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertTrue(battleGround.ourTeam.isAlive)
            XCTAssertTrue(battleGround.enemyTeam.isAlive)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
    func testMultiHit() {
        let nonMovingWiz = Person(preClass: classWithId(classId: "wizard"))
        nonMovingWiz.currentSpeed = 0
        let ourTestTeam = Team(members: [nonMovingWiz])
        let enemyTeam = Team(members: [Person.testDummy(), Person.testDummy(), Person.testDummy(), Person.testDummy(), Person.testDummy()])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "e", "o", "e", "e"],["e", "e", "t", "e", "e"],["m"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertTrue(battleGround.ourTeam.isAlive)
            XCTAssertTrue(battleGround.enemyTeam.members.filter({ $0.currentHp > 0 }).count == 3)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
    func testAllHit() {
        let nonMovingWiz = Person(preClass: classWithId(classId: "bloodmage"))
        nonMovingWiz.currentSpeed = 0
        let ourTestTeam = Team(members: [nonMovingWiz])
        let enemyTeam = Team(members: [Person.testDummy(), Person.testDummy(), Person.testDummy(), Person.testDummy(), Person.testDummy()])
        let testGround = GroundJson(id: "testGround", ground:  [["e", "e", "o", "e", "e"],["e", "e", "t", "e", "e"],["m"]])
        let battleGround = BattleGround(ourTeam: ourTestTeam,
                                        enemyTeam: enemyTeam,
                                        groundJson: testGround)
        
        let expection = expectation(description: "one shot")
        
        battleGround.fight(stateChanged: {
            XCTAssertTrue(battleGround.ourTeam.isAlive)
            XCTAssertFalse(battleGround.enemyTeam.isAlive)
            expection.fulfill()
        }, completion: { (_) in

        })
        
        wait(for: [expection], timeout: 5)
    }
    
}
