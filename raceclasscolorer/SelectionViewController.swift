//
//  SelectionViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 3/5/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class SelectionViewController: UIViewController {
    
    private var selectedEnemyTeam: Team?
    private var selectedOurTeam: Team?
    @IBOutlet weak var fontTestLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fontTestLabel.font = UIFont(name: "YosterIslandReg", size: 20.0)
        
        let testView = FancyTextView()
        view.showFullScreen(view: testView)
    }
    
    @IBAction func selectedOur(_ sender: UIButton) {
        selectedOurTeam = team(tag: sender.tag)
    }
    
    func team(tag: Int) -> Team {
        var overriddenClass: Class?
        
        switch tag {
        case 0:
            overriddenClass = classWithId(classId: "barb")
        case 1:
            overriddenClass = classWithId(classId: "wizard")
        case 2:
            overriddenClass = classWithId(classId: "cleric")
        case 3:
            overriddenClass = classWithId(classId: "elementalist")
        default:
            break
        }
        
        return Team(members: [Person(preClass: overriddenClass),
                              Person(preClass: overriddenClass),
                              Person(preClass: overriddenClass)])
    }
    
    @IBAction func selectedBattle(_ sender: Any) {
        performSegue(withIdentifier: "showBattleViewController", sender: nil)
    }
    
    @IBSegueAction func showBattleSegue(_ coder: NSCoder) -> BattleViewController? {
        guard let selectedOurTeam = selectedOurTeam else {
            return nil
        }
        
        let testCity = loadCities().first!
        
        for _ in 0...10 {
            let e = testCity.randomEncounter(team: selectedOurTeam)
            print(e.name)
        }
        
        return BattleViewController(coder: coder,
                                    ourTeam: selectedOurTeam,
                                    encounter: randomEncounter(team: selectedOurTeam))
    }
}
