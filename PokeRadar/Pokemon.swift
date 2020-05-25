//
//  Pokemon.swift
//  Pokem Radar
//
//  Created by Valentin Sanchez on 21/05/2020.
//  Copyright © 2020 Valentin Sanchez. All rights reserved.
//

import Foundation
import UIKit

class Pokemon: NSObject {
    var id: Int
    var name: String
    var image: UIImage
    init(id: Int, name: String){
        self.id = id
        self.name = name
        self.image = UIImage(named: "\(id).png")!
    }
    
}
