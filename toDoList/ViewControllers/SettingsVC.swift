//
//  CategoriesListVC.swift
//  TaskList
//
//  Created by Tom Odler on 23.01.17.
//  Copyright © 2017 Tom. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class SettingsVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate{
    @IBOutlet weak var tableView: UITableView!
    
    var fetchController : NSFetchedResultsController<Category>!
    var userDefaults = UserDefaults.standard
    var orderChanged = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        initFetcher()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "orderChanged"), object: nil)
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0{
            return 2
        } else {
            if let sectionsInfo = fetchController.sections?[section-1]{
                return sectionsInfo.numberOfObjects
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            switch indexPath.row {
            case 0:
                let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "orderCell", for: indexPath)
                cell.selectionStyle = .none
                let segments = cell.contentView.viewWithTag(1) as! UISegmentedControl
                if userDefaults.bool(forKey: "orderByName"){
                    segments.selectedSegmentIndex = 0
                } else {
                    segments.selectedSegmentIndex = 1
                }
                return cell
            }
            
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "categoryCell", for: indexPath) as! CategoryCell
            configureCell(indexPath: indexPath, cell: cell)
            cell.colorView.layer.masksToBounds = true;
            cell.colorView.layer.cornerRadius = 6;
            return cell
            
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0{
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        } else if indexPath.section == 1{
            let category = (fetchController.fetchedObjects?[indexPath.row])! as Category
            self.performSegue(withIdentifier: "categoryDetail", sender: category)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = tableView.dequeueReusableCell(withIdentifier: "header")
        let label = header?.contentView.viewWithTag(1) as! UILabel
        switch section {
        case 0:
            label.text = "Settings"
            break
        default:
            label.text = "Categories"
            break
        }
        return header
    }
    
    func configureCell(indexPath : IndexPath, cell : CategoryCell){
        let category = (fetchController.fetchedObjects?[indexPath.row])! as Category
        cell.configureCell(category: category)
    }
    
    func initFetcher(){
        let fetchRequest : NSFetchRequest<Category> = Category.fetchRequest()
        let sortDescriptor = NSSortDescriptor.init(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]
        
        let controller = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.sharedManager.appContext, sectionNameKeyPath: nil, cacheName: nil)
        controller.delegate = self
        
        do{
            try controller.performFetch()
            fetchController = controller
        } catch {
            let error = error as NSError
            print("\(error)")
        }
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        var myIndexPath : IndexPath?
        var myNewIndexPath : IndexPath?
        
        if let indexPath = indexPath{
            myIndexPath = IndexPath.init(row: indexPath.row, section: 1)
        }
        
        if let newIndexPath = newIndexPath{
            myNewIndexPath = IndexPath.init(row: newIndexPath.row, section: 1)
        }
        
        switch type {
        case .update:
            if let indexPath = myIndexPath{
                let cell = tableView.cellForRow(at: indexPath) as! CategoryCell
                self.configureCell(indexPath: indexPath, cell: cell)
            }
            break
        case .move:
            if let indexPath = myIndexPath{
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = myNewIndexPath{
                self.tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = myIndexPath{
                self.tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .insert:
            if let indexPath = myNewIndexPath{
                self.tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let myCategory = sender as? Category{
            let controller = segue.destination as! CategoryDetailVC
            controller.category = myCategory
        }
    }
    
    @IBAction func valueChanged(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            userDefaults.set(true, forKey: "orderByName")
        } else {
            userDefaults.set(false, forKey: "orderByName")
        }
    }
}
