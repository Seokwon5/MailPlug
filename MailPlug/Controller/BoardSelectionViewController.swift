//
//  BoardSelectionViewController.swift
//  MailPlug
//
//  Created by 이석원 on 2023/10/26.
//

import UIKit
import SnapKit

protocol BoardSelectionDelegate: AnyObject {
    func didSelectBoard(withID boardId: Int, andTitle title: String)
}

class BoardSelectionViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    weak var delegate: BoardSelectionDelegate?
    private var boards : [Board] = []
    
    lazy var closeButton: UIButton = {
        let btn = UIButton()
        btn.setImage(UIImage(systemName: "xmark"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
            
        return btn
    }()

    
    lazy var boardLabel : UILabel = {
        var label = UILabel()
        label.text = "게시판"
        label.font = UIFont.systemFont(ofSize: 14.0, weight: .medium)
        label.textColor = .gray
        
        return label
    }()
    
    lazy var tableView: UITableView = {
            let tv = UITableView()
            tv.dataSource = self
            tv.delegate = self
            tv.register(UITableViewCell.self, forCellReuseIdentifier: "boardCell")
            return tv
        }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        setupViews()
        fetchBoard()
        
    }
    
    private func setupViews() {
        view.addSubview(closeButton)
        view.addSubview(boardLabel)
        view.addSubview(tableView)
        
        closeButton.snp.makeConstraints {
                $0.top.equalTo(view.safeAreaLayoutGuide.snp.top).inset(20)
                $0.leading.equalToSuperview().inset(16.0)
            }
        
        boardLabel.snp.makeConstraints {
                $0.top.equalTo(closeButton.snp.bottom).offset(20.0)
                $0.leading.trailing.equalToSuperview().inset(20)
            }
            
            tableView.snp.makeConstraints {
                $0.top.equalTo(boardLabel.snp.bottom).offset(16.0)
                $0.leading.equalToSuperview()
                $0.trailing.bottom.equalToSuperview().inset(20)
            }
        
    }
    
    @objc func closeButtonTapped() {
            self.dismiss(animated: true, completion: nil)
        }

    
    func fetchBoard() {
        print("fetchBoard called")
            guard let url = URL(string: "https://mp-dev.mail-server.kr/api/v2/boards") else {
                print("Error: Invalid URL")
                return
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODgxMDM5NDAsImV4cCI6MCwidXNlcm5hbWUiOiJtYWlsdGVzdEBtcC1kZXYubXlwbHVnLmtyIiwiYXBpX2tleSI6IiMhQG1wLWRldiFAIyIsInNjb3BlIjpbImVhcyJdLCJqdGkiOiI5MmQwIn0.Vzj93Ak3OQxze_Zic-CRbnwik7ZWQnkK6c83No_M780", forHTTPHeaderField: "Authorization")
            
            URLSession.shared.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print("Network Error:", error.localizedDescription)
                    return
                }
                
                guard let data = data,
                      let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                    print("Error: Invalid response or response code not 200")
                    return
                }
                
                do {
                    guard let jsonResponse = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                              let jsonBoards = jsonResponse["value"] as? [[String: Any]] else {
                            print("Error: Failed to decode JSON")
                            return
                    }
                    
                    self.boards = jsonBoards.compactMap { dic -> Board? in
                            guard let boardId = dic["boardId"] as? Int,
                                  let displayName = dic["displayName"] as? String else {
                                return nil
                            }
                        
                        return Board(boardId: boardId, displayName: displayName)
                    }
                    
                    print("Successfully fetched \(self.boards.count) boards")
                    
                    DispatchQueue.main.async {
                        self.tableView.reloadData()
                    }
                    
                } catch let jsonError {
                    print("JSON Error:", jsonError.localizedDescription)
                }
                
            }.resume()
        }
    
    private func updateLabel() {
            var displayText = "게시판:\n"
            for board in boards {
                displayText += "\(board.displayName) \n"
            }
        print("Updated text: \(displayText)")
            boardLabel.text = displayText
        print("Current boardLabel text: \(boardLabel.text ?? "nil")")
        print("Updating boardLabel with text: \(displayText)")
        }
    
    // UITableViewDataSource
        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return boards.count
        }
        
        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "boardCell", for: indexPath)
            let board = boards[indexPath.row]
            cell.textLabel?.text = board.displayName
            return cell
        }
    
    // UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selectedBoard = boards[indexPath.row]
        delegate?.didSelectBoard(withID: selectedBoard.boardId, andTitle: selectedBoard.displayName)
        dismiss(animated: true, completion: nil)
    }

}


