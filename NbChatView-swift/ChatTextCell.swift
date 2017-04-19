//
//  ChatTextCell.swift
//  NbChatView-swift
//
//  Created by xiuxiong ding on 2017/4/19.
//  Copyright © 2017年 xiuxiongding. All rights reserved.
//

import UIKit

class ChatTextCell: ChatBaseCell {
    var messageLabel: UILabel!
    var textBackgroundImageView: UIImageView!
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        messageLabel = UILabel()
        messageLabel.isUserInteractionEnabled = false
        messageLabel.numberOfLines = 0
        
        
        textBackgroundImageView = UIImageView()
        textBackgroundImageView.isUserInteractionEnabled = true
        textBackgroundImageView.layer.cornerRadius = 10
        textBackgroundImageView.layer.masksToBounds = true
        
        
        self.addSubview(textBackgroundImageView)
        self.addSubview(messageLabel)
    }
    
    override func setUpWithModel(message: Message) {
        super.setUpWithModel(message: message)
        messageLabel.text = message.text
        
        if message.incoming {
            textBackgroundImageView.backgroundColor = UIColor.rgbColorFromHex(rgb: 0xFFC95B)
        } else {
            textBackgroundImageView.backgroundColor = UIColor.rgbColorFromHex(rgb: 0xB0C4DE)
        }

        messageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(avatarImageView).offset(10)
            make.width.lessThanOrEqualTo(220)
            make.bottom.equalTo(-20)
            if message.incoming {
                make.left.equalTo(avatarImageView.snp.right).offset(20)
            } else {
                make.right.equalTo(avatarImageView.snp.left).offset(-20)
            }
        }
        
        textBackgroundImageView.snp.makeConstraints { (make) in
            make.top.equalTo(messageLabel).offset(-10)
            make.left.equalTo(messageLabel).offset(-10)
            make.right.equalTo(messageLabel).offset(10)
            make.bottom.equalTo(messageLabel).offset(10)
        }

    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
