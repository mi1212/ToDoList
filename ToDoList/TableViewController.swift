//
//  TableViewController.swift
//  ToDoList
//
//  Created by Mikhail Chuparnov on 23.07.2022.
//

import UIKit
import CoreData



class TableViewController: UITableViewController {
    
    var qtyOfCells = 0
    
    static var tasks: [Task] = []

    private lazy var addTaskBarButton = UIBarButtonItem(image: UIImage(systemName: "plus"), style: .done , target: self, action: #selector(addTask))
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let context = getContext()
        
        let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
        
        do  {
            TableViewController.tasks = try context.fetch(fetchRequest)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        
        print(TableViewController.tasks)
        
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.navigationItem.title = "To Do list"
        self.navigationItem.rightBarButtonItem = addTaskBarButton
    }

    
    
    
    @objc func addTask() {
        let newTaskVC = NewTaskViewController()
        newTaskVC.delegate = self
        present(newTaskVC, animated: true)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return TableViewController.tasks.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.font = UIFont.systemFont(ofSize: 20, weight: .light)
        let task = TableViewController.tasks[indexPath.row]
        cell.textLabel?.text = task.title
//        if TableViewController.tasks[indexPath.row].isDone {
//            cell.backgroundColor = .systemGreen
//        } else {
//            cell.backgroundColor = .white
//        }
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
            -> UISwipeActionsConfiguration? {
            let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in

                let context = self.getContext()
                let taskToDelete = TableViewController.tasks[indexPath.row]

                context.delete(taskToDelete)
                
                do  {
                    try context.save()
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                let fetchRequest: NSFetchRequest<Task> = Task.fetchRequest()
                
                do  {
                    TableViewController.tasks = try context.fetch(fetchRequest)
                } catch let error as NSError {
                    print(error.localizedDescription)
                }
                
                tableView.deleteRows(at: [indexPath], with: .automatic)

                completionHandler(true)
            }

                deleteAction.image = UIImage(systemName: "trash")
                deleteAction.backgroundColor = .systemRed

//                let doneAction = UIContextualAction(style: .normal, title: nil) { _, _, completionHandler in
//                    let cell = tableView.cellForRow(at: indexPath)
//                    cell!.backgroundColor = .systemGreen
////                    TableViewController.tasks[indexPath.row].isDone
//                    completionHandler(true)
//                }
//
//                doneAction.image = UIImage(systemName: "checkmark")
//                doneAction.backgroundColor = .systemGreen

//            let configuration = UISwipeActionsConfiguration(actions: [deleteAction, doneAction])
                let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
            return configuration
    }

    
    
//    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        let delete = UITableViewRowAction(style: .default, title: "Delete") { (action:UITableViewRowAction, indexPath:IndexPath) in
//            print("delete at:\(indexPath)")
//        }
//        delete.backgroundColor = .red
//
//        let more = UITableViewRowAction(style: .default, title: "More") { (action:UITableViewRowAction, indexPath:IndexPath) in
//            print("more at:\(indexPath)")
//        }
//        more.backgroundColor = .orange
//
//        return [delete, more]
//    }
}

extension TableViewController: NewTaskViewControllerDelegate {
    func refresh() {
        print("reload")
        tableView.reloadData()
        }
        
    }
    
    

