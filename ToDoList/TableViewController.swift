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
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        self.tableView.register(TaskTableViewCell.self, forCellReuseIdentifier: TaskTableViewCell.identifire)
        self.tableView.separatorStyle = .none
        self.tableView.isEditing = false
        self.navigationItem.title = "To Do list"
        self.navigationItem.rightBarButtonItem = addTaskBarButton
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor(named: "textColor")
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
    
    func makeStrikeText( title: String) -> NSMutableAttributedString {
        let attributeString: NSMutableAttributedString =  NSMutableAttributedString(string: title)
        attributeString.addAttribute(NSAttributedString.Key.strikethroughStyle, value: 2, range: NSMakeRange(0, attributeString.length))
        return attributeString
    }
    
    func makeNormalText( title: String) -> NSMutableAttributedString {
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
        let cell = tableView.dequeueReusableCell(withIdentifier: TaskTableViewCell.identifire, for: indexPath) as! TaskTableViewCell
        
        cell.setupCell(indexPath: indexPath, title: TableViewController.tasks[indexPath.row].title!, isDone: TableViewController.tasks[indexPath.row].isDone, indexPathOfCell: indexPath)
        cell.delegate = self
        return cell
    }
    
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

        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
        cell.selectionStyle = .none
    }
    
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        .none
    }
    
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        false
    }

}

extension TableViewController: NewTaskViewControllerDelegate {
    func refresh() {
        tableView.reloadData()
    }
    
}

extension TableViewController: TaskTableViewCellDelegate {
    func tapTask(indexPath: IndexPath) {
        
        let context = self.getContext()
        let task = TableViewController.tasks[indexPath.row]
        
        let cell = tableView.cellForRow(at: indexPath) as! TaskTableViewCell
        cell.indexPathOfCell = indexPath
        switch task.isDone {
        case true:
            task.isDone = false
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                cell.textView.attributedText = self.makeNormalText(title: task.title!)
                cell.textView.layer.opacity = 1
                cell.tickImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                cell.tickImageView.layer.opacity = 0.6
            } completion: { _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                    cell.tickImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    cell.tickImageView.image = UIImage(named: "circle_rounded")
                    cell.tickImageView.layer.opacity = 1
                    self.tableView.reloadData()
                }
            }
            
            
        case false:
            task.isDone = true
            
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                cell.textView.attributedText = self.makeStrikeText(title: task.title!)
                cell.textView.layer.opacity = 0.5
                cell.tickImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
                cell.tickImageView.layer.opacity = 0.6
            } completion: { _ in
                UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseInOut) {
                    cell.tickImageView.transform = CGAffineTransform(scaleX: 1, y: 1)
                    cell.tickImageView.layer.opacity = 1
                    cell.tickImageView.image = UIImage(named: "circle_straight")
                    self.tableView.reloadData()
                }
            }
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
    }
}



