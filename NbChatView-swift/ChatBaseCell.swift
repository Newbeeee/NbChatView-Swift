//
//  ChatBaseCell.swift
//  NbChatView-swift
//
//  Created by xiuxiong ding on 2017/4/19.
//  Copyright © 2017年 xiuxiongding. All rights reserved.
//

import UIKit
class ChatBaseCell: UITableViewCell {
    var avatarImageView: UIImageView!
    var timeLabel: UILabel!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        self.backgroundColor = UIColor.rgbColorFromHex(rgb: 0xF5F6FA)
        
        timeLabel = UILabel()
        timeLabel.textAlignment = .center
        timeLabel.font = UIFont.systemFont(ofSize: 14)
        
        avatarImageView = UIImageView()
        avatarImageView.layer.cornerRadius = 22.5
        avatarImageView.layer.masksToBounds = true
        
        self.addSubview(avatarImageView)
        self.addSubview(timeLabel)
    }
    
    func setUpWithModel(message: Message) {
        timeLabel.text = message.time
        avatarImageView.image = UIImage(named: message.avatar)
        
        timeLabel.snp.makeConstraints { (make) in
            make.left.equalTo(10)
            make.right.equalTo(-10)
            make.top.equalTo(10)
            make.height.equalTo(10)
        }
        
        avatarImageView.snp.makeConstraints { (make) in
            if message.incoming {
                make.left.equalTo(self.snp.left).offset(10)
            } else {
                make.right.equalTo(self.snp.right).offset(-10)
            }
            make.top.equalTo(timeLabel.snp.bottom).offset(10)
            make.size.equalTo(45)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
