//
//  RaundedShadowView.swift
//  Vision ML
//
//  Created by Kafkas Baranseli on 16/05/2019.
//  Copyright © 2019 Baranseli. All rights reserved.
//

import UIKit

class RoundedShadowView: UIView {

    override func awakeFromNib() {
        self.layer.shadowColor = UIColor.darkGray.cgColor
        self.layer.shadowRadius = 15
        self.layer.shadowOpacity = 0.75
        self.layer.cornerRadius = self.frame.height / 2
    }

}
