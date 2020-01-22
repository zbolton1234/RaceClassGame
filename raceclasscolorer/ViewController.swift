//
//  ViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 1/11/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var enemyTeam: UIStackView!
    @IBOutlet weak var ourTeam: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //need a race/class by id
        let human1 = Person(preRace: allRaces[0], preClass: allClasses[0], preColor: .red)
        let human2 = Person(preRace: allRaces[0], preClass: allClasses[1], preColor: .blue)
        
        let humanTeam = Team(members: [human1, human2])
        print(human1.totalBuffs(team: humanTeam))
        
        let elf1 = Person(preRace: allRaces[1], preClass: allClasses[0], preColor: .green)
        humanTeam.members.append(elf1)
        print(human1.totalBuffs(team: humanTeam))
        
        ourTeam.show(team: humanTeam)
        
        let otherTeam = Team(members: [Person(), Person(), Person()])
        enemyTeam.show(team: otherTeam)
    }
}

extension UIStackView {
    func show(team: Team) {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        team.members.forEach({
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.backgroundColor = .lightGray
            
            label.text = "\($0.race.name)\n\($0.pclass.name)\n\($0.color)\n\($0.hp) \($0.attack) \($0.defense)\n\($0.totalBuffs(team: team))"
            
            addArrangedSubview(label)
        })
    }
}
