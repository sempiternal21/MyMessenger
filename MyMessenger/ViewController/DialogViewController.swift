//
//  DialogViewController.swift
//  1301uitableview
//
//  Created by Danil Antonov on 13.01.2024.
//

import UIKit


class DialogViewController: UIViewController {
    var currentUserId = 1

    let simulatedLoadTimeSeconds: TimeInterval = 0.5
    let cellIdentifier = "messageCell"
    let pageSize = 20
    var messageIndex = 0
    var messages = [Message]()
    var isLoading = false
    var lastContentOffsetY: CGFloat = 0
    var cachedHeights = [IndexPath: CGFloat]()
    var loadMore = UIRefreshControl()
    var dialogTitle: String!
    var userId: Int!
    let tableView = UITableView()
    let bottomView2 = DialogBottomView()

    override func viewDidLoad() {
        
        super.viewDidLoad()
        title = dialogTitle

        let callButton = UIBarButtonItem(image: UIImage(systemName: "phone"), style: .plain, target: self, action: nil)
        let videoCallButton = UIBarButtonItem(image: UIImage(systemName: "video"), style: .plain, target: self, action: nil)

        navigationItem.rightBarButtonItems = [videoCallButton, callButton]
        
        tableView.register(DialogTableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 88
        tableView.separatorStyle = .none
        tableView.backgroundColor = .red
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.addSubview(loadMore)
        
        view.addSubview(tableView)
        view.addSubview(bottomView2)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomView2.topAnchor),
            
            bottomView2.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            bottomView2.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            bottomView2.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            bottomView2.heightAnchor.constraint(equalToConstant: 40)
        ])
        NotificationCenter.default.addObserver(self, selector: #selector(addMessageToDialog(_:)), name: Notification.Name(rawValue: "newMessage"), object: nil)

        
        WSManager.shared.connectToWebSocket()
        WSManager.shared.subscribeBtcUsd(currentUserId: currentUserId, userId: userId)

        loadMoreMessages()
    }
    
    
    @objc func addMessageToDialog(_ notification: Notification) {
        let realMessageModel = notification.object as! RealMessageModel
        DispatchQueue.main.async {
            if let message = realMessageModel.data?.message {
                self.messages.append(Message(id: message.id, fromUserID: message.fromUserID, body: message.body, time: message.time, real: true, messageIndex: message.messageIndex))
                let lastIndexPath = IndexPath(row: self.messages.count - 1, section: 0)
                self.tableView.performBatchUpdates({
                     self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1,section: 0)], with: .automatic)
                 }, completion: nil)
                self.tableView.layoutIfNeeded()
                self.tableView.scrollToRow(at: lastIndexPath, at: UITableView.ScrollPosition.bottom, animated: true)
            }
        }
    }
    
    @discardableResult func generateMoreMessages() -> [IndexPath] {
        var indexPaths = [IndexPath]()
        for i in 0..<pageSize {
            var randomText = ""
            for _ in 0...arc4random_uniform(50) {
                randomText += "Hello "
            }
            let newMessage = Message(id: i, fromUserID: 0, body: randomText, time: nil, real: false, messageIndex: messageIndex)
            messages.insert(newMessage, at: 0)
            indexPaths.append(IndexPath(row: i, section: 0))
            messageIndex += 1
        }
        return indexPaths
    }

    func loadMoreMessages() {
        guard !isLoading else { return }

        let isFirstPage = messages.isEmpty
        isLoading = true
        DispatchQueue.main.asyncAfter(deadline: .now() + simulatedLoadTimeSeconds) {
            self.isLoading = false
            self.reloadTableView()

            if isFirstPage {
                let bottomIndexPath = IndexPath(row: self.messages.count-1, section: 0)
                self.tableView.scrollToRow(at: bottomIndexPath, at: .bottom, animated: false)
            }
        }
    }

    func reloadTableView() {
        var currentMessage: Message? = nil
        var offsetFromTopOfMessage: CGFloat = 0
        if let topIndexPath = self.tableView.indexPathsForVisibleRows?.first {
            var topMessageRect = self.tableView.rectForRow(at: topIndexPath)
            topMessageRect = topMessageRect.offsetBy(dx: -tableView.contentOffset.x, dy: -tableView.contentOffset.y)
            offsetFromTopOfMessage = topMessageRect.minY
            currentMessage = self.messages[topIndexPath.row]
        }
        self.generateMoreMessages()
        self.tableView.reloadData()
        if let targetMessage = currentMessage,
           let targetIndex = (self.messages.firstIndex{$0.messageIndex == targetMessage.messageIndex}) {
            let targetIndexPath = IndexPath(row: targetIndex, section: 0)
            self.tableView.scrollToRow(at: targetIndexPath, at: .top, animated: false)
            self.tableView.contentOffset.y -= offsetFromTopOfMessage
        }
    }
}

extension DialogViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.lastContentOffsetY > scrollView.contentOffset.y && scrollView.contentOffset.y < 100 {
            loadMoreMessages()
        }
        self.lastContentOffsetY = scrollView.contentOffset.y
    }
}

extension DialogViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.textLabel?.text = messages[indexPath.row].body
        if messages[indexPath.row].fromUserID == CurrentUser.currentUserId {
            cell.textLabel?.textAlignment = .right
        } else {
            cell.textLabel?.textAlignment = .left
        }
        return cell
    }
}

extension DialogViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cachedHeights[indexPath] = cell.frame.size.height
    }

    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cachedHeights.removeValue(forKey: indexPath)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        var height = tableView.estimatedRowHeight
        if let cachedHeight = cachedHeights[indexPath] {
            height = cachedHeight
        }
        return height
    }
}
