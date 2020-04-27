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
    @IBOutlet weak var worldScrollView: UIScrollView!
    private var testGold = 0
    private var worldImageView = UIImageView(image: UIImage(named: "world"))
    
    override func viewDidLoad() {
        super.viewDidLoad()

        fontTestLabel.font = UIFont(name: "YosterIslandReg", size: 20.0)
        
        let testView = FancyTextView()
        view.showFullScreen(view: testView)
        
        worldScrollView.addSubview(worldImageView)
        worldScrollView.minimumZoomScale = 1.0
        worldScrollView.maximumZoomScale = 5.0
        
        for city in loadCities() {
            let cityButton = UIButton()
            cityButton.translatesAutoresizingMaskIntoConstraints = false
            cityButton.setTitle(city.name, for: .normal)
            cityButton.backgroundColor = .orange
            cityButton.titleLabel?.textColor = .black
            
            worldImageView.addSubview(cityButton)
            
            worldImageView.addConstraints([
                worldImageView.leftAnchor.constraint(equalTo: cityButton.leftAnchor, constant: -city.position.x),
                worldImageView.topAnchor.constraint(equalTo: cityButton.topAnchor, constant: -city.position.y)
            ])
            
            //cityButton.center = city.position
        }
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
                                    encounter: randomEncounter(team: selectedOurTeam), completion: { (results) in
                                        self.testGold += results.gold
                                        self.fontTestLabel.text = "\(self.testGold)"
        })
    }
}

extension SelectionViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return worldImageView
    }
}
