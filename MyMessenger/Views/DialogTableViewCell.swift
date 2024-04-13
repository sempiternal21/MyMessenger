//
//  DialogTableViewCell.swift
//  1301uitableview
//
//  Created by Danil Antonov on 13.01.2024.
//

import UIKit

class DialogTableViewCell: UITableViewCell {

    var text: UILabel = {
        var label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        contentView.addSubview(text)
        
        NSLayoutConstraint.activate([
            text.topAnchor.constraint(equalTo: topAnchor),
            text.leadingAnchor.constraint(equalTo: leadingAnchor),
            text.bottomAnchor.constraint(equalTo: bottomAnchor),
            text.trailingAnchor.constraint(equalTo: trailingAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
