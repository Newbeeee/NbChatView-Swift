//
//  Message.swift
//  NbChatView-swift
//
//  Created by xiuxiong ding on 2017/4/19.
//  Copyright © 2017年 xiuxiongding. All rights reserved.
//

import Foundation

class Message {
    var incoming = true
    var text = ""
    var avatar = ""
    
    let time: String = {
        let calender = Calendar(identifier: .gregorian)
        let date = Date()
        let formater = DateFormatter()
        formater.dateFormat = "MM-dd HH:mm"
        var timeString: String = formater.string(from: date)
        return timeString
    }()
    
    init(incoming: Bool, text: String, avatar: String) {
        self.incoming = incoming
        self.text = text
        self.avatar = avatar
    }
}
