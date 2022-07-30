//
//  TableViewController.swift
//  ToDoList
//
//  Created by Mikhail Chuparnov on 23.07.2022.
//

import UIKit
import CoreData


class TableViewController: UITableViewController {
    // MARK: - Properts
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
        
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.navigationItem.title = "To Do list"
        self.navigationItem.rightBarButtonItem = addTaskBarButton
    }
    
    // MARK: - @objc
    @objc func addTask() {
        let newTaskVC = NewTaskViewController()
        newTaskVC.delegate = self
        present(newTaskVC, animated: true)
    }
    
    // MARK: - Funcs
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    private func makeStrikeText( title: String) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: title)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    private func makeNormalText( title: String) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: title)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 0, range: NSMakeRange(0, attributeString.length))
        return attributeString
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
                
        switch task.isDone {
        case true:
            cell.backgroundColor = .init(red: 0, green: 10, blue: 0, alpha: 0.4)
            cell.textLabel?.layer.opacity = 0.5
            cell.textLabel?.attributedText = self.makeStrikeText(title: task.title!)
        case false:
            cell.backgroundColor = .white
            cell.textLabel?.layer.opacity = 1
            cell.textLabel?.attributedText = self.makeNormalText(title: task.title!)
        }
        
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//
//        let cell = tableView.cellForRow(at: indexPath)
//        let context = self.getContext()
//        let task = TableViewController.tasks[indexPath.row]
//
//        let editAction = UIContextualAction(style: .destructive, title: nil) {
//            (_, _, completionHandler) in
//
//
//            let textFieldView: UITextField = {
//                let text = UITextField(frame: CGRect(x: 0, y: 0, width: ((cell?.bounds.width)!), height: (cell?.bounds.height)!))
//                text.backgroundColor = .white
//                let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 2))
//                text.font = UIFont.systemFont(ofSize: 20, weight: .light)
//                text.leftView = leftView
//                text.rightView = leftView
//                text.leftViewMode = .always
//                text.rightViewMode = .always
//                text.placeholder = "edit your task"
//                text.becomeFirstResponder()
//                return text
//            }()
//
//
//            cell?.addSubview(textFieldView)
////            textFieldView.resignFirstResponder()
//
//            textFieldView.becomeFirstResponder()
//        }
//
//        editAction.image = UIImage(systemName: "pencil")
//        editAction.title = "edit"
//        editAction.backgroundColor = UIColor.systemOrange
//
//        let configuration = UISwipeActionsConfiguration(actions: [editAction])
//
//        return configuration
//
//    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath)
    -> UISwipeActionsConfiguration? {
        
        let context = self.getContext()
        let task = TableViewController.tasks[indexPath.row]
        
        let deleteAction = UIContextualAction(style: .destructive, title: nil) { (_, _, completionHandler) in
            
            context.delete(task)
            
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
        
        let doneAction = UIContextualAction(style: .normal, title: nil) { _, _, completionHandler in
            let cell = tableView.cellForRow(at: indexPath)!
            
            let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: task.title!)
            attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
            
            switch task.isDone {
            case true:
                task.isDone = false
                cell.backgroundColor = .white
                cell.textLabel?.attributedText = self.makeNormalText(title: task.title!)
                cell.textLabel?.layer.opacity = 1
                
                
            case false:
                task.isDone = true
                cell.backgroundColor = .init(red: 0, green: 1, blue: 0, alpha: 0.4)
                
                cell.textLabel?.attributedText = self.makeStrikeText(title: task.title!)
                cell.textLabel?.layer.opacity = 0.5
                
            }
            
            
            
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
            
            completionHandler(true)
        }
        
        doneAction.image = UIImage(systemName: "checkmark")
        doneAction.backgroundColor = .systemGreen
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction, doneAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension TableViewController: NewTaskViewControllerDelegate {
    func refresh() {
        tableView.reloadData()
    }
    
}



