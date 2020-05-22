//
//  CityViewController.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 5/21/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

class CityViewController: UIViewController {

    @IBOutlet weak var buildingStackView: UIStackView!
    let city: City
    
    init?(coder: NSCoder, city: City) {
        self.city = city
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        for build in city.buildings {
            print("\(build.name) \(build.reward(city: city))")
        }
    }
    
    @IBAction func done(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
