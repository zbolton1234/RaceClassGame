//
//  BattleFieldView.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 2/28/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class BattleFieldView: UIView {
    
    @IBOutlet private var stackView: UIStackView!

    private var currentBattleGround: BattleGround?
    
    func updateBattleGround(battleGround: BattleGround) {
        currentBattleGround = battleGround
        
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        for row in battleGround.ground {
            let rowStackView = UIStackView()
            rowStackView.axis = .horizontal
            rowStackView.alignment = .fill
            rowStackView.distribution = .fillEqually
            rowStackView.spacing = 0
            
            rowStackView.show(spots: row)
            
            stackView.addArrangedSubview(rowStackView)
        }
    }
}

extension UIStackView {
    func show(spots: [Spot]) {
        arrangedSubviews.forEach({ $0.removeFromSuperview() })
        
        spots.forEach({ (spot) in
            let label = UILabel()
            label.numberOfLines = 0
            label.textAlignment = .center
            label.font = .systemFont(ofSize: 10)
            label.textColor = .black
            
            switch spot {
            case .void:
                label.backgroundColor = .black
                label.text = "v"
            case .empty:
                label.backgroundColor = .lightGray
                label.text = "e"
            case .terain(let name):
                label.backgroundColor = .lightGray
                label.text = name
            case .person(let personInSpot):
                label.backgroundColor = .lightGray
  
                label.text = "\(personInSpot.person.race.name)\n\(personInSpot.person.pclass.name)\n\(personInSpot.person.color) \(personInSpot.person.currentHp)"//"\n\(personInSpot.hp) \(personInSpot.attack) \(personInSpot.defense)\n\(personInSpot.totalBuffs(team: team))"
                
                switch personInSpot.teamType {
                case .our:
                    label.textColor = .green
                case .enemy:
                    label.textColor = .red
                }
            }
            
            addArrangedSubview(label)
        })
    }
}
