//
//  TaskDetailVC.swift
//  TaskList
//
//  Created by Tom Odler on 23.01.17.
//  Copyright © 2017 Tom. All rights reserved.
//

import UIKit
import UserNotifications

class TaskDetailVC: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UNUserNotificationCenterDelegate {

    @IBOutlet weak var nameTf: UITextField!
    @IBOutlet weak var dateBtn: UIButton!
    @IBOutlet weak var categoryBtn: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var categoryPicker: UIPickerView!
    @IBOutlet weak var pickerTlbr: UIToolbar!
    @IBOutlet weak var doneBtn: UIBarButtonItem!
    @IBOutlet weak var notifySwitch: UISwitch!
    @IBOutlet weak var taskDoneSwitch: UISwitch!
    @IBOutlet weak var categoryView: UIView!
    
    var dateForNotification : NSDate = NSDate()
    var selectedCategory : Category = CoreDataManager.sharedManager.getAllCategories().firstObject as! Category
    var task : Task?
    var center = UNUserNotificationCenter.current()
    var categoriesArray : [Category]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        datePicker.backgroundColor = UIColor.lightGray
        self.categoriesArray = CoreDataManager.sharedManager.getAllCategories() as? [Category]
        
        // Do any additional setup after loading the view.
        if task != nil{
            nameTf.text = task?.name!
            dateForNotification = (task?.date)! as NSDate
            selectedCategory = (task?.category)!
            taskDoneSwitch.isOn = (task?.done)!
            
            UNUserNotificationCenter.current().getPendingNotificationRequests(completionHandler: { (requests) in
                for request in requests{
                    if request.identifier == self.task?.objectID.uriRepresentation().absoluteString{
                        self.notifySwitch.isOn = true
                    }
                }
            })
        }
        
        datePicker.date = dateForNotification as Date
        let index = categoriesArray?.index(of: selectedCategory)
        categoryPicker.selectRow(index ?? 0, inComponent: 0, animated: false)
        
        setViews()
    }
    
    func setViews(){
        categoryBtn.setTitle(selectedCategory.name, for: .normal)
        categoryView.backgroundColor = selectedCategory.color as? UIColor
        
        dateBtn.setTitle(DateFormatter.localizedString(from: datePicker.date, dateStyle: .short, timeStyle: .short), for: .normal)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categoriesArray?.count ?? 0
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let category = categoriesArray![row]
        return category.name
    }

    @IBAction func categoryTapped(_ sender: UIButton) {
        nameTf.resignFirstResponder()
        categoryPicker.isHidden = false
        datePicker.isHidden = true
        pickerTlbr.isHidden = false
        doneBtn.tag = 1
    }
    
    @IBAction func dateTapped(_ sender: Any) {
        nameTf.resignFirstResponder()
        datePicker.isHidden = false
        categoryPicker.isHidden = true
        pickerTlbr.isHidden = false
        doneBtn.tag = 2
    }

    
    @IBAction func doneTapped(_ sender: Any) {
        let btn = sender as! UIBarButtonItem
        switch  btn.tag{
        case 1:
            categoryPicker.isHidden = true
            selectedCategory = categoriesArray![categoryPicker.selectedRow(inComponent: 0)]
            break
        case 2:
            dateForNotification = (datePicker.date as NSDate?)!
            datePicker.isHidden = true
            break
        default:
            datePicker.isHidden = true
            categoryPicker.isHidden = true
            
        }
        setViews()
        pickerTlbr.isHidden = true
    }
    
    @IBAction func saveTapped(_ sender: Any) {
        if let text = nameTf.text {
            if  let myTask = self.task{
                myTask.name = text
                myTask.category = selectedCategory
                myTask.date = dateForNotification as Date
                myTask.done = taskDoneSwitch.isOn
                CoreDataManager.sharedManager.saveContext()
            } else {
                self.task = CoreDataManager.sharedManager.createTask()
                self.task?.name = text
                self.task?.category = selectedCategory
                self.task?.date = dateForNotification as Date
                self.task?.done = taskDoneSwitch.isOn
                CoreDataManager.sharedManager.saveContext()
            }
            triggerNotification()
            _ = self.navigationController?.popViewController(animated: true)
        } else {
            let controller = UIAlertController.init(title: "Error", message: "Please type a name", preferredStyle: .alert)
            let ok = UIAlertAction.init(title: "OK", style: .default, handler: nil)
            controller.addAction(ok)
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    @IBAction func didBeginEditing(_ sender: Any) {
        pickerTlbr.isHidden = true
        datePicker.isHidden = true
        categoryPicker.isHidden = true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func triggerNotification(){
        if let task = task{
            center.removePendingNotificationRequests(withIdentifiers: [task.objectID.uriRepresentation().absoluteString])
            
            if notifySwitch.isOn{
                center.delegate = self
                
                let calendar = NSCalendar(identifier: NSCalendar.Identifier.gregorian)!
                let components = calendar.components([.month, .day, .hour, .minute], from: dateForNotification as Date)
                
                let content = UNMutableNotificationContent()
                content.title = "Task: \(task.name ?? "default task name")"
                content.body = "Category: \(task.category?.name ?? "default category name")"
                content.sound = UNNotificationSound.default()
                
                let trigger = UNCalendarNotificationTrigger.init(dateMatching: components, repeats: false)
                let request = UNNotificationRequest(identifier: task.objectID.uriRepresentation().absoluteString, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    @IBAction func notifySwitchTapped(_ sender: UISwitch) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge];
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                sender.isOn = false
                let alert = UIAlertController.init(title: "Error", message: "Please, allow notifications in settings", preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: "Ok", style: .cancel, handler: nil)
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
}
