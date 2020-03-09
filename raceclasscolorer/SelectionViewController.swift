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

    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func selectedOur(_ sender: UIButton) {
        selectedOurTeam = team(tag: sender.tag)
    }
    
    @IBAction func selectedEnemy(_ sender: UIButton) {
        selectedEnemyTeam = team(tag: sender.tag)
    }
    
    func team(tag: Int) -> Team {
        var overriddenClass: Class?
        
        switch tag {
        case 0:
            overriddenClass = classWithId(classId: "warrior")
        case 1:
            overriddenClass = classWithId(classId: "wizard")
        case 2:
            overriddenClass = classWithId(classId: "cleric")
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
        
        return BattleViewController(coder: coder,
                                    ourTeam: selectedOurTeam,
                                    encounter: randomEncounter())
    }
}
