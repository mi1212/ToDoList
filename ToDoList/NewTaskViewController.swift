//
//  NewTaskViewController.swift
//  ToDoList
//
//  Created by Mikhail Chuparnov on 23.07.2022.
//

import UIKit
import CoreData

protocol NewTaskViewControllerDelegate: AnyObject {
    func refresh()
}

class NewTaskViewController: UIViewController {
    
    weak var delegate: NewTaskViewControllerDelegate?
    
    private lazy var lableView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "what do you want to plan"
        label.font = UIFont.systemFont(ofSize: 20, weight: .light)
        label.textColor = UIColor(named: "textColor")
        label.numberOfLines = 2
        return label
    }()
    
    private lazy var textFieldView: UITextField = {
        let text = UITextField()
        text.backgroundColor = UIColor(named: "backgroundColor")
        text.layer.borderColor = UIColor(named: "textColor")?.cgColor
        text.layer.borderWidth = 1
        text.layer.cornerRadius = 10
        let leftView = UIView(frame: CGRect(x: 0, y: 0, width: 15, height: 2))
        text.leftView = leftView
        text.rightView = leftView
        text.leftViewMode = .always
        text.rightViewMode = .always
        text.text = nil
        text.textColor = UIColor(named: "textColor")
        text.translatesAutoresizingMaskIntoConstraints = false
        return text
    }()
    
    private lazy var buttonView: UIButton = {
        let button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("add", for: .normal)
        button.backgroundColor = UIColor(named: "textColor")
        button.setTitleColor(UIColor(named: "backgroundColor"), for: .normal)
        button.layer.cornerRadius = 10
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(addTask), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor(named: "backgroundColor")
        setup()
    }
    
    private func setup() {
        view.addSubview(lableView)
        view.addSubview(textFieldView)
        view.addSubview(buttonView)
        view.addGestureRecognizer(tap)
        textFieldView.becomeFirstResponder()
        
        NSLayoutConstraint.activate([
            lableView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            lableView.topAnchor.constraint(equalTo: view.topAnchor, constant: 40),
            lableView.heightAnchor.constraint(equalToConstant: 40),
            
            textFieldView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            textFieldView.topAnchor.constraint(equalTo: lableView.bottomAnchor, constant: 10),
            textFieldView.heightAnchor.constraint(equalToConstant: 40),
            textFieldView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
            textFieldView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            
            buttonView.topAnchor.constraint(equalTo: textFieldView.bottomAnchor, constant: 40),
            buttonView.leadingAnchor.constraint(equalTo: textFieldView.leadingAnchor, constant: 20),
            buttonView.trailingAnchor.constraint(equalTo: textFieldView.trailingAnchor, constant: -20),
            buttonView.heightAnchor.constraint(equalToConstant: 40)
            
        ])
    }

    private lazy var tap: UITapGestureRecognizer = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        return tap
    }()
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func addTask() {
   
        if textFieldView.text != "" {
            let context = getContext()
            guard let entity = NSEntityDescription.entity(forEntityName: "Task", in: context) else { return }
            let taskObject = Task(entity: entity, insertInto: context)
            taskObject.isDone = false
            taskObject.title = textFieldView.text
            TableViewController.tasks.append(taskObject)
            self.view.endEditing(true)
            dismiss(animated: true, completion: nil)
            delegate?.refresh()
            
            do  {
                try context.save()
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        } else {
            shake()
        }
                
    }
    
    func shake(duration timeDuration: Double = 0.07, repeat countRepeat: Float = 3){
        let animation = CABasicAnimation(keyPath: "position")
        animation.duration = timeDuration
        animation.repeatCount = countRepeat
        animation.autoreverses = true
        animation.fromValue = NSValue(cgPoint: CGPoint(x: textFieldView.center.x - 10, y: textFieldView.center.y))
        animation.toValue = NSValue(cgPoint: CGPoint(x: textFieldView.center.x + 10, y: textFieldView.center.y))
        self.textFieldView.layer.add(animation, forKey: "position")
    }
    
    private func getContext() -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }

}


