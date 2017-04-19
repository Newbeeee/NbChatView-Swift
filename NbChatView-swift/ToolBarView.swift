//
//  ToolBarView.swift
//  NbChatView-swift
//
//  Created by xiuxiong ding on 2017/4/19.
//  Copyright © 2017年 xiuxiongding. All rights reserved.
//

import SnapKit

class ToolBarView: UIView {
    var textView: UITextView!
    var refreshButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.rgbColorFromHex(rgb: 0xDCDCDC)
        
        textView = UITextView()
        textView.font = UIFont.systemFont(ofSize: 17)
        textView.layer.cornerRadius = 5.0
        textView.scrollsToTop = false
        textView.textContainerInset = UIEdgeInsetsMake(5, 5, 5, 5)
        textView.backgroundColor = UIColor.white
        textView.returnKeyType = .send
        self.addSubview(textView)
        
        refreshButton = UIButton()
        refreshButton.setImage(UIImage(named: "refresh"), for: .normal)
        self.addSubview(refreshButton)
        
        refreshButton.snp.makeConstraints { (make) in
            make.size.equalTo(32)
            make.top.equalTo(self.snp.top).offset(6)
            make.left.equalTo(self.snp.left).offset(6)
        }
        
        textView.snp.makeConstraints { (make) in
            make.height.equalTo(32)
            make.left.equalTo(refreshButton.snp.right).offset(6)
            make.top.equalTo(self.snp.top).offset(6)
            make.right.equalTo(self.snp.right).offset(-6)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
