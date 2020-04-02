//
//  RaceClassSelectorTests.swift
//  raceclasscolorerTests
//
//  Created by Zach Bolton on 4/1/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import XCTest
@testable import raceclasscolorer

//forestElf is civ redOrc is wild
//wizard is civ barb is wild
class RaceClassSelectorTests: XCTestCase {

    //MARK: Any Any
    //Not sure how helpful this will be as it is the most random
    func testAnyAny() {
        let testPerson = raceClass(globalRaceId: "any", globalClassId: "any")
        XCTAssertNotNil(testPerson.0)
        XCTAssertNotNil(testPerson.1)
        XCTAssertFalse(invalidTribeTypes(classTribeType: testPerson.1!.tribeType, raceTribeType: testPerson.0!.tribeType))
    }
    
    //MARK: Spefic race Spefic class
    func testForestElfWizard() {
        let testPerson = raceClass(globalRaceId: "forestElf", globalClassId: "wizard")
        XCTAssertTrue(testPerson.0?.id == "forestElf")
        XCTAssertTrue(testPerson.1?.id == "wizard")
    }
    
    func testForestElfBarb() {
        let testPerson = raceClass(globalRaceId: "forestElf", globalClassId: "barb")
        XCTAssertTrue(testPerson.0?.id == "forestElf")
        XCTAssertTrue(testPerson.1?.id == "barb")
    }

    func testRedOrcBarb() {
        let testPerson = raceClass(globalRaceId: "redOrc", globalClassId: "barb")
        XCTAssertTrue(testPerson.0?.id == "redOrc")
        XCTAssertTrue(testPerson.1?.id == "barb")
    }
    
    func testRedOrcWirazrd() {
        let testPerson = raceClass(globalRaceId: "redOrc", globalClassId: "wizard")
        XCTAssertTrue(testPerson.0?.id == "redOrc")
        XCTAssertFalse(testPerson.1?.id == "wizard")
    }
    
    //MARK: Spefic race General class
    func testForestElfMagic() {
        let testPerson = raceClass(globalRaceId: "forestElf", globalClassId: "magic")
        XCTAssertTrue(testPerson.0?.id == "forestElf")
        XCTAssertTrue(testPerson.1?.groupId == "magic")
    }
    
    func testForestElfWildMagic() {
        let testPerson = raceClass(globalRaceId: "forestElf", globalClassId: "naturemagic")
        XCTAssertTrue(testPerson.0?.id == "forestElf")
        XCTAssertTrue(testPerson.1?.groupId == "naturemagic")
    }

    func testRedOrcWildMagic() {
        let testPerson = raceClass(globalRaceId: "redOrc", globalClassId: "naturemagic")
        XCTAssertTrue(testPerson.0?.id == "redOrc")
        XCTAssertTrue(testPerson.1?.groupId == "naturemagic")
    }
    
    func testRedOrcMagic() {
        let testPerson = raceClass(globalRaceId: "redOrc", globalClassId: "magic")
        XCTAssertTrue(testPerson.0?.id == "redOrc")
        XCTAssertFalse(testPerson.1?.groupId == "magic")
    }
    
    //MARK: General race Spefic class
    func testElfWizard() {
        let testPerson = raceClass(globalRaceId: "elf", globalClassId: "wizard")
        XCTAssertTrue(testPerson.0?.raceId == "elf")
        XCTAssertTrue(testPerson.1?.id == "wizard")
    }
    
    func testElfBarb() {
        let testPerson = raceClass(globalRaceId: "elf", globalClassId: "barb")
        XCTAssertTrue(testPerson.0?.raceId == "elf")
        XCTAssertTrue(testPerson.1?.id == "barb")
    }

    func testOrcBarb() {
        let testPerson = raceClass(globalRaceId: "orc", globalClassId: "barb")
        XCTAssertTrue(testPerson.0?.raceId == "orc")
        XCTAssertTrue(testPerson.1?.id == "barb")
    }
    
    func testOrcWirazrd() {
        let testPerson = raceClass(globalRaceId: "orc", globalClassId: "wizard")
        XCTAssertTrue(testPerson.0?.raceId == "orc")
        XCTAssertFalse(testPerson.1?.id == "wizard")
    }
    
    //MARK: General race General class
    func testElfMagic() {
        let testPerson = raceClass(globalRaceId: "elf", globalClassId: "magic")
        XCTAssertTrue(testPerson.0?.raceId == "elf")
        XCTAssertTrue(testPerson.1?.groupId == "magic")
    }
    
    func testElfWildMagic() {
        let testPerson = raceClass(globalRaceId: "elf", globalClassId: "naturemagic")
        XCTAssertTrue(testPerson.0?.raceId == "elf")
        XCTAssertTrue(testPerson.1?.groupId == "naturemagic")
    }

    func testOrcWildMagic() {
        let testPerson = raceClass(globalRaceId: "orc", globalClassId: "naturemagic")
        XCTAssertTrue(testPerson.0?.raceId == "orc")
        XCTAssertTrue(testPerson.1?.groupId == "naturemagic")
    }
    
    func testOrcMagic() {
        let testPerson = raceClass(globalRaceId: "orc", globalClassId: "magic")
        XCTAssertTrue(testPerson.0?.raceId == "orc")
        XCTAssertFalse(testPerson.1?.groupId == "magic")
    }

    //MARK: tribe race Spefic class
    func testCivWizard() {
        let testPerson = raceClass(globalRaceId: "civilized", globalClassId: "wizard")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "civilized")
        XCTAssertTrue(testPerson.1?.id == "wizard")
    }
    
    func testCivBarb() {
        let testPerson = raceClass(globalRaceId: "civilized", globalClassId: "barb")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "civilized")
        XCTAssertTrue(testPerson.1?.id == "barb")
    }

    func testWildBarb() {
        let testPerson = raceClass(globalRaceId: "wild", globalClassId: "barb")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "wild")
        XCTAssertTrue(testPerson.1?.id == "barb")
    }
    
    func testWildWizard() {
        let testPerson = raceClass(globalRaceId: "wild", globalClassId: "wizard")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "wild")
        XCTAssertFalse(testPerson.1?.id == "wizard")
    }
    
    //MARK: tribe race General class
    func testCivMagic() {
        let testPerson = raceClass(globalRaceId: "civilized", globalClassId: "magic")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "civilized")
        XCTAssertTrue(testPerson.1?.groupId == "magic")
    }
    
    func testCivWildMagic() {
        let testPerson = raceClass(globalRaceId: "civilized", globalClassId: "naturemagic")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "civilized")
        XCTAssertTrue(testPerson.1?.groupId == "naturemagic")
    }

    func testWildWildMagic() {
        let testPerson = raceClass(globalRaceId: "wild", globalClassId: "naturemagic")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "wild")
        XCTAssertTrue(testPerson.1?.groupId == "naturemagic")
    }
    
    func testWildMagic() {
        let testPerson = raceClass(globalRaceId: "wild", globalClassId: "magic")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "wild")
        XCTAssertFalse(testPerson.1?.groupId == "magic")
    }

    //MARK: Spefic race tribe class
    func testForestElfCiv() {
        let testPerson = raceClass(globalRaceId: "forestElf", globalClassId: "civilized")
        XCTAssertTrue(testPerson.0?.id == "forestElf")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "civilized")
    }
    
    func testForestElfWild() {
        let testPerson = raceClass(globalRaceId: "forestElf", globalClassId: "wild")
        XCTAssertTrue(testPerson.0?.id == "forestElf")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "wild")
    }

    func testRedOrcWild() {
        let testPerson = raceClass(globalRaceId: "redOrc", globalClassId: "wild")
        XCTAssertTrue(testPerson.0?.id == "redOrc")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "wild")
    }
    
    func testRedOrcCiv() {
        let testPerson = raceClass(globalRaceId: "redOrc", globalClassId: "civilized")
        XCTAssertTrue(testPerson.0?.id == "redOrc")
        XCTAssertFalse(testPerson.1?.tribeType.rawValue == "civilized")
    }
    
    //MARK: General race tribe class
    func testElfCiv() {
        let testPerson = raceClass(globalRaceId: "elf", globalClassId: "civilized")
        XCTAssertTrue(testPerson.0?.raceId == "elf")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "civilized")
    }
    
    func testElfWild() {
        let testPerson = raceClass(globalRaceId: "elf", globalClassId: "wild")
        XCTAssertTrue(testPerson.0?.raceId == "elf")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "wild")
    }

    func testOrcWild() {
        let testPerson = raceClass(globalRaceId: "orc", globalClassId: "wild")
        XCTAssertTrue(testPerson.0?.raceId == "orc")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "wild")
    }
    
    func testOrcCiv() {
        let testPerson = raceClass(globalRaceId: "orc", globalClassId: "civilized")
        XCTAssertTrue(testPerson.0?.raceId == "orc")
        XCTAssertFalse(testPerson.1?.tribeType.rawValue == "civilized")
    }
    
    //MARK: Tribe race Tribe class
    func testCivCiv() {
        let testPerson = raceClass(globalRaceId: "civilized", globalClassId: "civilized")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "civilized")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "civilized")
    }
    
    func testCivWild() {
        let testPerson = raceClass(globalRaceId: "civilized", globalClassId: "wild")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "civilized")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "wild")
    }

    func testWildWild() {
        let testPerson = raceClass(globalRaceId: "wild", globalClassId: "wild")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "wild")
        XCTAssertTrue(testPerson.1?.tribeType.rawValue == "wild")
    }
    
    func testWildCiv() {
        let testPerson = raceClass(globalRaceId: "wild", globalClassId: "civilized")
        XCTAssertTrue(testPerson.0?.tribeType.rawValue == "wild")
        XCTAssertFalse(testPerson.1?.tribeType.rawValue == "civilized")
    }
    
    //MARK: Spefic race Any class
    func testForestElfAny() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "forestElf", globalClassId: "any")
            XCTAssertTrue(testPerson.0?.id == "forestElf")
            results.append(testPerson.1?.tribeType)
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }

    func testRedOrcAny() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "redOrc", globalClassId: "any")
            XCTAssertTrue(testPerson.0?.id == "redOrc")
            results.append(testPerson.1?.tribeType)
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertFalse(results.contains(.civilized))
    }
    
    //MARK: Any race Spefic class
    func testAnyWizard() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "any", globalClassId: "wizard")
            results.append(testPerson.0?.tribeType)
            XCTAssertTrue(testPerson.1?.id == "wizard")
        }
        
        XCTAssertFalse(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }
    
    func testAnyBarb() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "any", globalClassId: "barb")
            results.append(testPerson.0?.tribeType)
            XCTAssertTrue(testPerson.1?.id == "barb")
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }

    //MARK: Genral race Any class
    func testElfAny() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "elf", globalClassId: "any")
            XCTAssertTrue(testPerson.0?.raceId == "elf")
            results.append(testPerson.1?.tribeType)
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }

    func testOrcAny() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "orc", globalClassId: "any")
            XCTAssertTrue(testPerson.0?.raceId == "orc")
            results.append(testPerson.1?.tribeType)
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertFalse(results.contains(.civilized))
    }
    
    //MARK: Any race General class
    func testAnyMagic() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "any", globalClassId: "magic")
            results.append(testPerson.0?.tribeType)
            XCTAssertTrue(testPerson.1?.groupId == "magic")
        }
        
        XCTAssertFalse(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }
    
    func testAnyWildMagic() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "any", globalClassId: "naturemagic")
            results.append(testPerson.0?.tribeType)
            XCTAssertTrue(testPerson.1?.groupId == "naturemagic")
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }
    
    //MARK: Tribe race Any class
    func testCivAny() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "civilized", globalClassId: "any")
            XCTAssertTrue(testPerson.0?.tribeType.rawValue == "civilized")
            results.append(testPerson.1?.tribeType)
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }

    func testWildAny() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "wild", globalClassId: "any")
            XCTAssertTrue(testPerson.0?.tribeType.rawValue == "wild")
            results.append(testPerson.1?.tribeType)
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertFalse(results.contains(.civilized))
    }
    
    //MARK: Any race Tribe class
    func testAnyCiv() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "any", globalClassId: "civilized")
            results.append(testPerson.0?.tribeType)
            XCTAssertTrue(testPerson.1?.tribeType.rawValue == "civilized")
        }
        
        XCTAssertFalse(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }
    
    func testAnyWild() {
        var results = [TribeType?]()
        
        for _ in 0...10 {
            let testPerson = raceClass(globalRaceId: "any", globalClassId: "wild")
            results.append(testPerson.0?.tribeType)
            XCTAssertTrue(testPerson.1?.tribeType.rawValue == "wild")
        }
        
        XCTAssertTrue(results.contains(.wild))
        XCTAssertTrue(results.contains(.civilized))
    }
}

