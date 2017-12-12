//
//  CoreDataManager.swift
//  toDoList
//
//  Created by Tom Odler on 12.12.17.
//  Copyright © 2017 Tom Odler. All rights reserved.
//

import UIKit
import CoreData

class CoreDataManager: NSObject {
    var appD = UIApplication.shared.delegate as! AppDelegate
    var appContext : NSManagedObjectContext!
    
    static var sharedManager = CoreDataManager()
    
    override init() {
        super.init()
            self.appContext = self.persistentContainer.viewContext
    }
    
    func createCategory() -> Category{
        let category = Category(entity: NSEntityDescription.entity(forEntityName: "Category", in: appContext)!, insertInto: appContext)
        return category
    }
    
    func createTask() -> Task{
        let task = Task(entity: NSEntityDescription.entity(forEntityName: "Task", in: appContext)!, insertInto: appContext)
        return task
    }
    
    func getAllCategories() -> NSArray{
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        let descriptor = NSSortDescriptor.init(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [descriptor]
        
        do{
            let categories = try appContext.fetch(fetchRequest)
            return categories as NSArray
        } catch {
            let error = error as NSError
            print("\(error)")
        }
        return NSArray()
    }
    
    func checkAndCreateDefaultCategories(){
        let fetchRequest = NSFetchRequest<Category>(entityName: "Category")
        do{
            let count = try appContext.count(for: fetchRequest)
            let categoryNames = ["Default1", "Default2", "Default3", "Default4"]
            let defaultColors = [UIColor.red, UIColor.green, UIColor.blue, UIColor.orange]
            if count == 0 {
                for index in 0..<categoryNames.count{
                    let category = createCategory()
                    category.name = categoryNames[index]
                    category.color = defaultColors[index]
                    self.saveContext()
                }
            }
        } catch {
            let error = error as NSError
            print("\(error)")
        }
        
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "TaskList")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
}
