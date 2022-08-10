//
//  TaskTableViewCell.swift
//  ToDoList
//
//  Created by Mikhail Chuparnov on 30.07.2022.
//

import UIKit

protocol TaskTableViewCellDelegate: AnyObject {
    func tapTask(indexPath: IndexPath)
}

class TaskTableViewCell: UITableViewCell {
    
    weak var delegate: TaskTableViewCellDelegate?
    
    var indexPathOfCell: IndexPath?

    lazy var textView: UILabel = {
        let text = UILabel()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.font = UIFont.systemFont(ofSize: 22, weight: .light)
        return text
    }()
    
    private lazy var tickButton: UIButton = {
        var button = UIButton()
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(tapTask), for: .touchUpInside)
        return button
    }()
    
    lazy var tickImageView: UIImageView = {
        let image = UIImageView()
        image.translatesAutoresizingMaskIntoConstraints = false
        image.image = UIImage(named: "circle_rounded")
        return image
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        setupViews()
        // Configure the view for the selected state
    }
    
    private func setupViews() {
        contentView.addSubview(textView)
        contentView.addSubview(tickButton)
        tickButton.addSubview(tickImageView)
        
        NSLayoutConstraint.activate([
            textView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            textView.leadingAnchor.constraint(equalTo: tickButton.trailingAnchor),
            textView.trailingAnchor.constraint(equalTo: self.trailingAnchor),

            
            tickButton.topAnchor.constraint(equalTo: self.topAnchor),
            tickButton.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            tickButton.widthAnchor.constraint(equalTo: tickButton.heightAnchor),
            tickButton.heightAnchor.constraint(equalToConstant: self.bounds.height),
            
            tickImageView.heightAnchor.constraint(equalTo: tickButton.heightAnchor, multiplier: 0.36),
            tickImageView.widthAnchor.constraint(equalTo: tickImageView.heightAnchor),
            tickImageView.centerXAnchor.constraint(equalTo: tickButton.centerXAnchor),
            tickImageView.centerYAnchor.constraint(equalTo: tickButton.centerYAnchor)
        ])
    }
    
    func setupCell(indexPath: IndexPath, title: String, isDone: Bool, indexPathOfCell: IndexPath) {
        
        self.indexPathOfCell = indexPathOfCell
        
        switch isDone {
        case true:
            self.backgroundColor = .init(red: 0, green: 1, blue: 0, alpha: 0.4)
            textView.attributedText = makeStrikeText(title: title)
            textView.layer.opacity = 0.5
            tickImageView.image = UIImage(named: "circle_straight")
        case false:
            self.backgroundColor = .white
            textView.attributedText = makeNormalText(title: title)
            textView.layer.opacity = 1
            tickImageView.image = UIImage(named: "circle_rounded")
        }
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

    @objc func tapTask() {
        delegate?.tapTask(indexPath: indexPathOfCell!)
    }
}


