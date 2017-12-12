//
//  CategoryVC.swift
//  TaskList
//
//  Created by Tom Odler on 24.01.17.
//  Copyright © 2017 Tom. All rights reserved.
//

import UIKit

class CategoryDetailVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UITextFieldDelegate {
    var defaultColors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.orange, UIColor.brown, UIColor.black, UIColor.yellow, UIColor.purple]
    var selectedColor : UIColor!
    var category : Category?
    
    @IBOutlet weak var nameTf: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        selectedColor = defaultColors.first! as UIColor
        if let cat = category {
            selectedColor = cat.color as! UIColor
            nameTf.text = cat.name
        }
    }

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return defaultColors.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "colorCell", for: indexPath)
        
        cell.backgroundColor = defaultColors[indexPath.row] as UIColor
        let imgView = cell.viewWithTag(1) as! UIImageView
        imgView.image = #imageLiteral(resourceName: "Checkmark").withRenderingMode(.alwaysTemplate)
        imgView.tintColor = UIColor.white
        
        //černé ohraničení kvůli světlým barvám
        if cell.backgroundColor == selectedColor{
            imgView.isHidden = false
            cell.layer.borderWidth = 1.5
            cell.layer.borderColor = UIColor.black.cgColor
        } else {
            imgView.isHidden = true
            cell.layer.borderWidth = 0
            cell.layer.borderColor = UIColor.clear.cgColor
        }
        
        cell.layer.masksToBounds = true;
        cell.layer.cornerRadius = 6;
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedColor = defaultColors[indexPath.row]
        collectionView.reloadData()
    }

    @IBAction func saveTapped(_ sender: Any) {
        if let text = nameTf.text {
            if  let myCategory = self.category{
                myCategory.name = text
                myCategory.color = selectedColor
                CoreDataManager.sharedManager.saveContext()
            } else {
                let myCategory = CoreDataManager.sharedManager.createCategory()
                myCategory.name = text
                myCategory.color = selectedColor
                CoreDataManager.sharedManager.saveContext()
            }
            
            _ = self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "categoryChanged"), object: nil)
        } else {
            let controller = UIAlertController.init(title: "Error", message: "Please type a name", preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            controller.addAction(ok)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}
