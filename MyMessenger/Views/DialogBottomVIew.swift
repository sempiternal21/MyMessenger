//
//  DialogBottomVIew.swift
//  1301uitableview
//
//  Created by Danil Antonov on 13.01.2024.
//

import UIKit

class DialogBottomView: UIView {

    let addButton = UIButton()
    let textField = UITextField()
    let videoMessageButton = UIButton()
    let audioMessageButton = UIButton()
    let stackView = UIStackView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .yellow
        translatesAutoresizingMaskIntoConstraints = false
        
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Сообщение"
        
        videoMessageButton.translatesAutoresizingMaskIntoConstraints = false
        videoMessageButton.setImage(UIImage(systemName: "play.circle.fill"), for: .normal)
        
        audioMessageButton.translatesAutoresizingMaskIntoConstraints = false
        audioMessageButton.setImage(UIImage(systemName: "mic"), for: .normal)
        audioMessageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(videoMessageButton)
        stackView.addArrangedSubview(audioMessageButton)
        stackView.spacing = 30
        
        addSubview(addButton)
        addSubview(textField)
        addSubview(stackView)
        
        configureConstraints()
    }
    
    /*
     TODO: Во вью не должно быть логики по работе с сетью, и сам запрос в сеть можно было сделать лучше, но столкнулся с трудностями вебсокета, поэтому закостылил так
     */
    @objc func sendMessage() {
        let requestUrl = URL(string: "http://127.0.0.1:8000/messages")!
        var request = URLRequest(url: requestUrl)
        request.httpMethod = "POST"
        request.setValue("application/json",forHTTPHeaderField: "Content-Type")
        
        let messageToSend = Message(id: nil, fromUserID: CurrentUser.currentUserId, body: "\(textField.text ?? "")", time: nil, messageIndex: nil)
        let httpBodyToSend = try! JSONEncoder().encode(messageToSend)
        request.httpBody = httpBodyToSend;
        print("⬅️ httpBody message: \(String(data: httpBodyToSend, encoding: .utf8) ?? "unknown")")
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Error took place \(error)")
                    return
                }
                if let data = data, let dataString = String(data: data, encoding: .utf8) {
                    print("➡️ Response on message: \(dataString)")
                }
        }
        task.resume()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configureConstraints() {
        NSLayoutConstraint.activate([
            addButton.topAnchor.constraint(equalTo: topAnchor),
            addButton.leadingAnchor.constraint(equalTo: leadingAnchor),
            addButton.widthAnchor.constraint(equalToConstant: 50),
            addButton.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            textField.topAnchor.constraint(equalTo: topAnchor),
            textField.leadingAnchor.constraint(equalTo: addButton.trailingAnchor),
            textField.trailingAnchor.constraint(equalTo: stackView.leadingAnchor),
            textField.bottomAnchor.constraint(equalTo: bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.widthAnchor.constraint(equalToConstant: 100),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
        ])
    }
}
