//
//  RoundedShadowImage.swift
//  Vision ML
//
//  Created by Kafkas Baranseli on 16/05/2019.
//  Copyright © 2019 Baranseli. All rights reserved.
//

import UIKit

class RoundedShadowImage: UIImageView {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = 15
    }

}
