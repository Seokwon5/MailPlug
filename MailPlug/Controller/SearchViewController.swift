//
//  SearchViewController.swift
//  MailPlug
//
//  Created by 이석원 on 2023/10/29.
//

import UIKit

class SearchViewController: UIViewController, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    let searchBar = UISearchBar()
    var tableView: UITableView!
    var searchResults: [SearchResult] = []
    var currentSearchTask: URLSessionTask?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
        
        hideBackButton()
        setupSearchBar()
        setupTableView()
        
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // 사용자가 "검색" 버튼을 눌렀을 때 수행할 작업을 여기에 작성합니다.
        
        if let searchText = searchBar.text, !searchText.isEmpty {
               fetchSearchResults(query: searchText) // API 호출 추가
           }
        
        searchBar.resignFirstResponder() // 키보드 숨기기
    }
    
    func setupSearchBar() {
        view.addSubview(searchBar)
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            searchBar.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            searchBar.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            searchBar.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        searchBar.delegate = self
        searchBar.showsCancelButton = true
        
        if let cancelButton = searchBar.value(forKey: "cancelButton") as? UIButton {
                cancelButton.setTitle("취소", for: .normal)
            }
    }
    
    func setupTableView() {
        tableView = UITableView(frame: .zero, style: .plain)
        tableView.translatesAutoresizingMaskIntoConstraints = false // Auto Layout을 사용하려면 이 값을 false로 설정해야 합니다.
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SearchResultCell")
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    func hideBackButton() {
        // 뒤로가기 버튼 숨기기
        navigationItem.hidesBackButton = true
    }
    
    // UISearchBarDelegate
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        // API 호출
        fetchSearchResults(query: searchText)
    }
    
    // MARK: - UITableViewDataSource, UITableViewDelegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchResults.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchResultCell", for: indexPath)
        let result = searchResults[indexPath.row]
        
        cell.textLabel?.text = result.title
        // 추가적으로 내용이나 작성자를 표시하려면 cell에 적절히 표시
        
        return cell
    }
    
    func fetchSearchResults(query: String) {
        
        currentSearchTask?.cancel()

        let boardId = "YOUR_BOARD_ID"
        let urlString = "https://mp-dev.mail-server.kr/api/v2/boards/\(boardId)/posts?search=\(query)"
        guard let url = URL(string: urlString) else { return }

        var request = URLRequest(url: url)
        request.setValue("Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpYXQiOjE2ODgxMDM5NDAsImV4cCI6MCwidXNlcm5hbWUiOiJtYWlsdGVzdEBtcC1kZXYubXlwbHVnLmtyIiwiYXBpX2tleSI6IiMhQG1wLWRldiFAIyIsInNjb3BlIjpbImVhcyJdLCJqdGkiOiI5MmQwIn0.Vzj93Ak3OQxze_Zic-CRbnwik7ZWQnkK6c83No_M780", forHTTPHeaderField: "Authorization")
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else { return }
            do {
                let apiResponse = try JSONDecoder().decode(APIResponse.self, from: data)
                self?.searchResults = apiResponse.value
                DispatchQueue.main.async {
                    self?.tableView.reloadData()
                }
            } catch {
                print(error)
            }
        }
        task.resume()
    }
    
}
    
