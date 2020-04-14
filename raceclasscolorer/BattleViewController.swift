//
//  BattleViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class BattleViewController: UIViewController {

    @IBOutlet weak var battleFieldView: BattleFieldView!

    let ourTeam: Team
    let encounter: Encounter
    let battleGround: BattleGround
    
    init?(coder: NSCoder, ourTeam: Team, encounter: Encounter) {
        self.ourTeam = ourTeam
        self.encounter = encounter
        self.battleGround = BattleGround(ourTeam: ourTeam,
                                         enemyTeam: encounter.enemyTeam,
                                         groundJson: encounter.groundJson)
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        battleFieldView.updateBattleGround(battleGround: battleGround)
        
        let introView = FancyTextView(text: encounter.introString)
        view.showFullScreen(view: introView)
    }
    
    @IBAction func attack(_ sender: Any) {
        battleGround.fight(stateChanged: {
            self.battleFieldView.updateBattleGround(battleGround: self.battleGround)
        }, completion: { (fightResult) in
            let resultView = FancyTextView(text: fightResult.won ? self.encounter.winString : self.encounter.lossString, dismiss: {
                self.navigationController?.popViewController(animated: true)
            })
            self.view.showFullScreen(view: resultView)
        })
    }
}
