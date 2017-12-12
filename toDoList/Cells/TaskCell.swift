//
//  TaskCell.swift
//  TaskList
//
//  Created by Tom Odler on 23.01.17.
//  Copyright © 2017 Tom. All rights reserved.
//

import UIKit

class TaskCell: UITableViewCell {

    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var categoryView: UIView!
    
    func configureCell(task : Task, cell : TaskCell){
        nameLbl.text = task.name!
        dateLbl.text = DateFormatter.localizedString(from: task.date as! Date, dateStyle: .short, timeStyle: .short)
        categoryView.backgroundColor = task.category?.color as? UIColor
    }

}
