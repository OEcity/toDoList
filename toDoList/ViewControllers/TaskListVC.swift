//
//  ViewController.swift
//  TaskList
//
//  Created by Tom Odler on 23.01.17.
//  Copyright © 2017 Tom. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications

class TaskListVC: UIViewController, UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var fetchController1 : NSFetchedResultsController<Task>!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initFetcher()
        
        //Byla změněna kategorie, je potřeba obnovit tabulku kvůli barvám
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "categoryChanged"), object: nil, queue: nil) { (notification) in
            self.tableView.reloadData()
        }
        
        //Bylo změněno řazení tasklistu
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "orderChanged"), object: nil, queue: nil) { (notification) in
            self.initFetcher()
        }
    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if let sections = fetchController1.sections{
            return sections.count
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let sections = fetchController1.sections {
            let sectionsInfo = sections[section]
            return sectionsInfo.numberOfObjects
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let task = fetchController1.object(at: indexPath) as Task
            let alert = UIAlertController.init(title: "", message: "Do you want to delete \(task.name!)", preferredStyle: .alert)
            let yesAction = UIAlertAction.init(title: "Yes", style: .default, handler: { (action) in
                CoreDataManager.sharedManager.appContext.delete(task)
            })
            let nopeAction = UIAlertAction.init(title: "No", style: .cancel, handler: nil)
            alert.addAction(yesAction)
            alert.addAction(nopeAction)
            self.present(alert, animated: true, completion: nil)
            break
        default: break
            
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath) as! TaskCell
        configureCell(indexPath: indexPath, cell: cell)
        return cell
    }
    
    func configureCell(indexPath : IndexPath, cell : TaskCell){
        let task = fetchController1.object(at: indexPath) as Task
        cell.configureCell(task: task, cell: cell)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let task = fetchController1.object(at: indexPath) as Task
        self.performSegue(withIdentifier: "taskDetail", sender: task)
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 40
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let sectionInfo = fetchController1.sections?[section] else { fatalError("Unexpected Section") }
        
        let header = tableView.dequeueReusableCell(withIdentifier: "header")
        
        let label = header?.contentView.viewWithTag(1) as! UILabel
        
        
        switch sectionInfo.name {
        case "0":
            label.text = "Pending"
            break
        case "1":
            label.text = "Done"
            break
        default:
            label.text = "Nothing"
            break
        }
        
        //Navracet pouze contentView!! ne celou buňku
        return header?.contentView
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type {
        case .move:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .delete:
            if let indexPath = indexPath{
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
            break
        case .insert:
            if let indexPath = newIndexPath{
                tableView.insertRows(at: [indexPath], with: .fade)
            }
            break
        case .update:
            if let indexPath = indexPath{
                let cell = tableView.cellForRow(at: indexPath) as! TaskCell
                configureCell(indexPath: indexPath, cell: cell)
            }
            break
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .delete:
            tableView.deleteSections([sectionIndex], with: .fade)
            break
        case .insert:
            tableView.insertSections([sectionIndex], with: .fade)
            break
        default:
            break
        }
    }
    
    @IBAction func longPressTriggered(_ sender: UILongPressGestureRecognizer) {
        if(sender.state == .began){
            let touchPoint = sender.location(in: self.tableView)
            if let indexPath = tableView.indexPathForRow(at: touchPoint) {
                let task = fetchController1.object(at: indexPath) as Task
                
                let doneString = task.done ? "Pending" : "Done"
                let alert = UIAlertController.init(title: "\(task.name!)", message: "options:", preferredStyle: .actionSheet)
                let doneAction = UIAlertAction.init(title: doneString, style: .default, handler: { (action) in
                    task.done = !task.done
                    CoreDataManager.sharedManager.saveContext()
                })
                
                let cancelAction = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
                
                let removeAction = UIAlertAction.init(title: "Delete", style: .destructive, handler: { (action) in
                    CoreDataManager.sharedManager.appContext.delete(task)
                })
                alert.addAction(doneAction)
                alert.addAction(removeAction)
                alert.addAction(cancelAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func initFetcher(){
        let fetchRequest : NSFetchRequest<Task> = Task.fetchRequest()
        let orderByName = UserDefaults.standard.bool(forKey: "orderByName")
        let doneDescriptor = NSSortDescriptor.init(key: "done", ascending: true)
        let dateSortDescriptor = NSSortDescriptor.init(key: "date", ascending: true)
        let nameSortDescriptor = NSSortDescriptor.init(key: "name", ascending: true, selector: #selector(NSString.caseInsensitiveCompare(_:)))
        fetchRequest.sortDescriptors = orderByName ? [doneDescriptor,nameSortDescriptor] : [doneDescriptor,dateSortDescriptor]
        let controller = NSFetchedResultsController.init(fetchRequest: fetchRequest, managedObjectContext: CoreDataManager.sharedManager.appContext, sectionNameKeyPath: "done", cacheName: nil)
        
        do{
            try controller.performFetch()
            controller.delegate = self
            fetchController1 = controller
            tableView.reloadData()
        } catch {
            let error = error as NSError
            print("\(error)")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "taskDetail"{
            if let myTask = sender as? Task{
                let controller = segue.destination as! TaskDetailVC
                controller.task = myTask
            }
        }
    }
}

