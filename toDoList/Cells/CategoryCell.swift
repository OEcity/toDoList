//
//  CategoryCell.swift
//  TaskList
//
//  Created by Tom Odler on 23.01.17.
//  Copyright © 2017 Tom. All rights reserved.
//

import UIKit

class CategoryCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var colorView: UIView!
    
    func configureCell(category:Category){
        nameLbl.text = category.name
        colorView.backgroundColor = category.color as? UIColor
    }

}
