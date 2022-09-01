//
//  ViewController.swift
//  To-Do-List-UsingCoreData
//
//  Created by Bonginkosi Tshabalala on 2022/08/23.
//

import UIKit
import CoreData

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, isChecked{
    func toggleIsComplete(for cell: UITableViewCell){
        
        if let indexPath = tableView.indexPath(for: cell) {
            
            toggleIsComplete(for: indexPath.row)
            tableView.reloadData()
        }
    }
    //Switch for archiving
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var archivingSwitch: UISwitch!
    
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    
    //A global variable that will drive the number of cells in our table view
    
    private var models = [ToDoListItem]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
            
        switchIsOn()
        
        view.addSubview(tableView)
        getAllItems() //By calling this function here the data will persist
        tableView.delegate = self
        tableView.dataSource = self
        tableView.frame = view.bounds
        
        
        //Right + (Add) button
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAdd))
        

    }
    
    // Switch button function
    
    func switchIsOn () {
        
        
        if (archivingSwitch.isOn){
            title = "Archived Items"
            getAllItems()
            
        }else {
            
            title = "All Items"
            getAllItems()
        }
        
    }
       
    @objc private func didTapAdd(){
        let alert = UIAlertController(title: "New Item" ,
                                      message: "Enter new item",
                                      preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: nil)
        
        alert.addAction(UIAlertAction(title: "Submit", style: .cancel, handler: { [weak self]_ in
            
            guard let field = alert.textFields?.first, let text = field.text, !text.isEmpty else {
                
                return
            }
            
            self?.createitems(name: text)
            self?.tableView.reloadData()
        }))
        
        present(alert, animated: true)
        
    }
    
    
    
    //MARK: Start Section : Swipe functionality
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
       let deleteAction = UITableViewRowAction(style: .default, title: "Archive"){ _, indexPath in
           
           self.models[indexPath.row].isArchived = !self.models[indexPath.row].isArchived
           print("succeeded")
           self.switchIsOn()
           tableView.reloadData()
        }
        
        let item = models[indexPath.row]
        
    
        
        let sheet = UIAlertController(title: "Changes" ,
                                      message: nil,
                                      preferredStyle: .actionSheet)
        
        
        sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
        sheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: { _ in
            
            let alert = UIAlertController(title: "Edit Item" ,
                                          message: "You Can Edit This Item Here",
                                          preferredStyle: .alert)
            
            alert.addTextField(configurationHandler: nil)
            alert.textFields?.first?.text = item.name
            
            alert.addAction(UIAlertAction(title: "Save", style: .cancel, handler: { [weak self]_ in
                
                guard let field = alert.textFields?.first, let changedName = field.text, !changedName.isEmpty else {
                    
                    return
                }
                
                self?.updateItem(item: item, changedName: changedName)
            }))
            
            self.present(alert, animated: true)
            
            
            
        }))
        
        sheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self ] _ in
            
            let sheet = UIAlertController(title: "Are you sure you want to delete this item from the list?" ,
                                          message: nil,
                                          preferredStyle: .alert)
            
            
            sheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil ))
            sheet.addAction(UIAlertAction(title: "Yes", style: .destructive, handler: { _ in
                
               
                self?.deleteItem(item: item)
                 
            }))
            self!.present(sheet, animated: true)
           
            
            
        } ))
        
        present(sheet, animated: true)
        
        
        return [deleteAction]
    }
    
    //MARK: End Section : Swipe functionality
    
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return models.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd "
        
        let model =  models[indexPath.row]
        let cell =  tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? customTableViewCell
        cell?.setCell(isMarked: model.isChecked)
        //cell?.textLabel?.text = model.name
       cell?.textLabel?.text = "\(model.name!) - \(dateFormatter.string(from: model.createdAt!))"
        
        cell?.isCompleteDelegate = self
        
        //cell.detailTextLabel?.text = "\(model.createdAt!)"
         
        //MARK: Checking items as done on the list
        
       // cell.accessoryType = model.isChecked ? .checkmark : .none
        
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        let item = models[indexPath.row]
        
        
        //Start: Section for checking items in the list as done
        
        //item.isChecked = !item.isChecked
        tableView.reloadData()
        
        //End: Section for checking items in the list as done
        
        
    }
    
    
    
    
    //MARK:  Core Data Section
    
    //The function below gets all the items that are saved
    
    func getAllItems(){
        let request: NSFetchRequest<ToDoListItem> = ToDoListItem.fetchRequest()
        
        
        if archivingSwitch.isOn {
            
            
            request.predicate = NSPredicate(format: "isArchived == 1")
            
            
            do {
            models = try context.fetch(request)
                
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            
            }
            catch {
                
                //Error
                
                print("Could not fetch items")
            }
            
        }else {
            
            request.predicate = NSPredicate(format: "isArchived == 0")
            
            do {
            models = try context.fetch(request)
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
            catch {
                
                //Error
                
                print("Could not fetch items")
            }
        }
    }
    
    //This function below creates an item
    func createitems(name: String){
        
        let newItem = ToDoListItem(context: context)
        newItem.name = name
        newItem.createdAt = Date()
        newItem.isChecked = false
        newItem.isArchived = false
        
        do{
            try context.save()
            getAllItems()
            
        }
        catch {
            
            // Error
            
            print("Could not add item to the list")
        }
        
    }
    
    //The function below deletes an item
    func deleteItem(item: ToDoListItem){
        
        context.delete(item)
        do{
            try context.save()
            getAllItems()
        }
        catch {
            
            // Error
            
            print("This item could not be deleted ")
        }
    }
    
    //This function below updates an item
    func updateItem(item: ToDoListItem, changedName: String){
        
        item.name = changedName
        
        
        do{
            try context.save()
            getAllItems()
        }
        catch {
            
            // Error
            
            print("Item updated  ")
        }
        
        
    }
    
    //This function marks items as done/completed
    
    //This function archives an item
    
    @IBAction func archivedItems(_ sender: Any) {
        
        switchIsOn()
        
        tableView.reloadData()
        
    }
    
    func toggleIsComplete(for index: Int){
        models[index].isChecked.toggle()
        
        do{
            try context.save()
        }
        catch{
        }
    }
}

