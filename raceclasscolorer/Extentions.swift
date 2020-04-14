//
//  Extentions.swift
//  raceclasscolorer
//
//  Created by Zach Bolton on 4/13/20.
//  Copyright © 2020 Zach Bolton. All rights reserved.
//

import UIKit

extension UIView {
    func showFullScreen(view: UIView) {
        self.addSubview(view)
        self.addConstraints([
            self.leftAnchor.constraint(equalTo: view.leftAnchor),
            self.rightAnchor.constraint(equalTo: view.rightAnchor),
            self.topAnchor.constraint(equalTo: view.topAnchor),
            self.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
