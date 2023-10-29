//
//  MainBoardListViewController.swift
//  MailPlug
//
//  Created by 이석원 on 2023/10/26.
//

import UIKit

class MainBoardListViewController: UITableViewController, BoardSelectionDelegate {
    var posts: [Post] = []
    
    let defaultBoardID = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(MainBoardListCell.self, forCellReuseIdentifier: "MainBoardListCell")
        tableView.rowHeight = 120
        
        let menuImage = UIImage(systemName: "list.dash")?.withTintColor(.black, renderingMode: .alwaysTemplate)
        let menuButton = UIBarButtonItem(image: menuImage, style: .plain, target: self, action: #selector(showMenu))
        navigationItem.leftBarButtonItem = menuButton
        
        let searchImage = UIImage(systemName: "magnifyingglass")?.withTintColor(.black, renderingMode: .alwaysTemplate)
        let searchButton = UIBarButtonItem(image: searchImage, style: .plain, target: self, action: #selector(showSearch))
        navigationItem.rightBarButtonItem = searchButton
        
        fetchPosts(forBoard: defaultBoardID)
        navigationItem.title = "테스트 게시판"
    }
    
    @objc func showSearch() {
        let searchVC = SearchViewController()

        self.navigationController?.pushViewController(searchVC, animated: true)
    }
    
    @objc func showMenu() {
        let menuViewController = BoardSelectionViewController()
        menuViewController.delegate = self
        menuViewController.modalPresentationStyle = .pageSheet
        menuViewController.modalTransitionStyle = .coverVertical
        self.present(menuViewController, animated: true, completion: nil)
    }
    
    func fetchPosts(forBoard boardId: Int) {
        let urlString = "https://mp-dev.mail-server.kr/api/v2/boards/\(boardId)/posts?offset=0&limit=30"
        guard let url = URL(string: urlString) else { return }
        
        var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODgxMDM5NDAsImV4cCI6MCwidXNlcm5hbWUiOiJtYWlsdGVzdEBtcC1kZXYubXlwbHVnLmtyIiwiYXBpX2tleSI6IiMhQG1wLWRldiFAIyIsInNjb3BlIjpbImVhcyJdLCJqdGkiOiI5MmQwIn0.Vzj93Ak3OQxze_Zic-CRbnwik7ZWQnkK6c83No_M780", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let apiResponse = try JSONDecoder().decode(ApiResponse.self, from: data)
                self?.posts = apiResponse.value
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
    func didSelectBoard(withID boardId: Int, andTitle title: String) {
        navigationItem.title = title
        fetchPosts(forBoard: boardId)
    }
}

//UITableView DataSource Delegate
extension MainBoardListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "MainBoardListCell", for: indexPath) as? MainBoardListCell else { return UITableViewCell() }
        
        let post = posts[indexPath.row]
        cell.post = post
        
        return cell
    }
}
