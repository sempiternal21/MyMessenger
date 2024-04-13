//
//  ViewController.swift
//  1301uitableview
//
//  Created by Danil Antonov on 13.01.2024.
//

import UIKit

class DialogsListViewController: UIViewController {
    
    let tableView = UITableView()
    let searchController = UISearchController(searchResultsController: nil)
    var arr: [DialogItemCellModel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        arr = NetworkStubManager.getDialogs()
        self.view.backgroundColor = .white
        self.navigationItem.title = "Chats"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: nil)
        
        view.addSubview(tableView)
        
        tableView.backgroundColor = .red
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(DialogListItemViewCell.self, forCellReuseIdentifier: "cell")
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
}

extension DialogsListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        arr.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! DialogListItemViewCell
        cell.image.image = UIImage(systemName: arr[indexPath.row].imageName)
        cell.name.text = arr[indexPath.row].name
        cell.text.text = arr[indexPath.row].text
        cell.accessoryType = .disclosureIndicator
        
        return cell
    }
}

extension DialogsListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = DialogViewController()
        vc.dialogTitle = arr[indexPath.row].name
        vc.userId = arr[indexPath.row].userId
        vc.view.backgroundColor = .green
        tableView.deselectRow(at: indexPath, animated: true)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let trash = UIContextualAction(style: .destructive, title: "Trash") { (action, view, completionHandler) in
            self.arr.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: UITableView.RowAnimation.left)
            completionHandler(true)
        }
        trash.backgroundColor = .systemRed

        let configuration = UISwipeActionsConfiguration(actions: [trash])

        return configuration
    }
    
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil, actionProvider: { _ in
            let edit = UIAction(title: "Delete", image: UIImage(systemName: "trash.fill"), attributes: UIMenuElement.Attributes.destructive) { _ in
                print("Delete")
                self.arr.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            let children: [UIMenuElement] = [edit]
            return UIMenu(title: "", children: children)
        })
    }
}
