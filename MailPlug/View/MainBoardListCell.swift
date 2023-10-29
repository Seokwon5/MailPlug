//
//  MainBoardListCell.swift
//  MailPlug
//
//  Created by 이석원 on 2023/10/26.
//

import UIKit
import SnapKit

class MainBoardListCell: UITableViewCell {
    var post: Post? {
        didSet{
            titleLabel.text = post?.title
            
            writerLabel.text = post?.writer.displayName
            dateLabel.text = post?.createdDateTime
        }
    }
    
    let titleLabel = UILabel()
    let writerLabel = UILabel()
    let dateLabel = UILabel()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        titleLabel.font = UIFont.systemFont(ofSize: 22.0, weight: .bold)
        
        writerLabel.textColor = .lightGray
        dateLabel.textColor = .lightGray
        
        [titleLabel, writerLabel, dateLabel].forEach {
            contentView.addSubview($0)
        }
        
        setupLayout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    func setupLayout() {
        titleLabel.snp.makeConstraints {
            $0.top.greaterThanOrEqualTo(contentView).offset(10)
            $0.leading.equalTo(contentView).offset(15)
            $0.trailing.lessThanOrEqualTo(contentView).offset(-15)
            $0.centerY.equalTo(contentView).offset(-10)
            
        }
        
        writerLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(5)
            $0.leading.equalTo(titleLabel)
            
        }
        
        dateLabel.snp.makeConstraints {
            $0.top.equalTo(writerLabel)
            $0.leading.equalTo(writerLabel.snp.trailing).offset(20.0)
            
            
        }
    }
    
    
    
}


