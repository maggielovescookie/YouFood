//
//  CustomController.swift
//  YouFood
//
//  Created by XuMaggie on /07/0718.
//  Copyright © 2018年 Novus. All rights reserved.
//

import UIKit

class CustomNavController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
		self.navigationBar.setBackgroundImage(UIImage(), for: .default)
		self.navigationBar.shadowImage = UIImage()
    }

    

}
