//
//  ViewController.swift
//  NbChatView-swift
//
//  Created by xiuxiong ding on 2017/4/19.
//  Copyright © 2017年 xiuxiongding. All rights reserved.
//

import UIKit

let toolBarHeight: CGFloat = 44

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var chatTableView: UITableView!
    var toolBarView: ToolBarView!
    
    var msgList = [Message]()
    
    var keyBoardAnimateDuration: Double!
    
    var fisrtLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgbColorFromHex(rgb: 0xF5F6FA)
        
        // 消除tableview的留白
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 标题
        let title = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 100)/2, y: 10, width: 100, height: 24))
        title.text = "聊天"
        title.textAlignment = .center
        title.textColor = UIColor.white
        self.navigationController?.navigationBar.barTintColor = UIColor.rgbColorFromHex(rgb: 0x4682B4)
        self.navigationItem.titleView = title
        
        // 聊天界面
        chatTableView = UITableView()
        chatTableView.backgroundColor = UIColor.clear
        // 自动布局
        chatTableView.translatesAutoresizingMaskIntoConstraints = false
        chatTableView.estimatedRowHeight = 110
        chatTableView.delegate = self
        chatTableView.dataSource = self
        // 让列表最后一条消息和底部工具栏有一定距离
        chatTableView.contentInset = UIEdgeInsetsMake(0, 0, toolBarHeight/2, 0)
        chatTableView.separatorStyle = .none
        chatTableView.register(ChatBaseCell.self, forCellReuseIdentifier: "chat")
        // 点击列表使键盘消失
        let removeKeyBoardTap = UITapGestureRecognizer(target: self, action: #selector(tapRemoveBottomView(recognizer:)))
        chatTableView.addGestureRecognizer(removeKeyBoardTap)
        view.addSubview(chatTableView)
        
        // 底部工具栏界面
        toolBarView = ToolBarView()
        toolBarView.textView.delegate = self
        toolBarView.refreshButton.addTarget(self, action: #selector(clearMessage), for: .touchUpInside)
        view.addSubview(toolBarView)
        
        // 添加约束
        toolBarView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.height.equalTo(toolBarHeight)
            make.bottom.equalTo(view.snp.bottom)
        }
        
        chatTableView.snp.makeConstraints { (make) in
            make.left.equalTo(view.snp.left)
            make.right.equalTo(view.snp.right)
            make.bottom.equalTo(toolBarView.snp.top)
            make.top.equalTo(view.snp.top).offset(64)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // 添加键盘弹出消失监听
        if fisrtLoad {
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(keyBoardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        fisrtLoad = false
    }
    
    // MARK: tableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return msgList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = ChatTextCell(style: .default, reuseIdentifier: "chat")
        let message = msgList[indexPath.row]
        cell.setUpWithModel(message: message)
        return cell
    }
    
    // MARK: textViewDelegate
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            let msgText = textView.text.trimmingCharacters(in: .whitespaces)
            if msgText.lengthOfBytes(using: .utf8) == 0 {
                return true
            }
            let messageOut = Message(incoming: false, text: msgText, avatar: "newbeeee")
            msgList.append(messageOut)
            let messageIn = Message(incoming: true, text: msgText, avatar: "chris")
            msgList.append(messageIn)
            reloadTableView()
            textView.text = ""
            return false
        }
        return true
    }
    
    // MARK: private
    func keyBoardWillShow(notification: Notification) {
        let userInfo = notification.userInfo! as Dictionary
        let value = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyBoardRect = value.cgRectValue
        // 得到键盘高度
        let keyBoardHeight = keyBoardRect.size.height
        
        // 得到键盘弹出所需时间
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        keyBoardAnimateDuration = duration.doubleValue
        
        // 整体上移frame
        let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        
        UIView.animate(withDuration: keyBoardAnimateDuration, delay: 0, options: options, animations: {
            self.view.transform = CGAffineTransform(translationX: 0, y: -keyBoardHeight)
        }) { (finished) in
            if finished {
                // 让消息的最后一条滚动到底部工具栏上方
                self.scrollToBottom()
            }
        }
    }
    
    func keyBoardWillHide(notification: Notification) {
        
        let userInfo = notification.userInfo! as Dictionary
        
        // 得到键盘弹出所需时间
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        keyBoardAnimateDuration = duration.doubleValue
        
        if toolBarView.textView.isFirstResponder {
            toolBarView.textView.resignFirstResponder()
            // 还原frame
            let options = UIViewAnimationOptions(rawValue: UInt((userInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            UIView.animate(withDuration: keyBoardAnimateDuration, delay: 0, options: options, animations: {
                self.view.transform = CGAffineTransform.identity
            })
        }
    }
    
    // 刷新列表
    func reloadTableView() {
        chatTableView.reloadData()
        scrollToBottom()
    }
    
    // 滚动最后一条消息到列表界面底部
    func scrollToBottom() {
        if msgList.count > 0 {
            chatTableView.scrollToRow(at: IndexPath(row: msgList.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    func clearMessage() {
        msgList.removeAll()
        chatTableView.reloadData()
    }
    
    // 点击消息列表键盘消失
    func tapRemoveBottomView(recognizer: UITapGestureRecognizer) {
        if toolBarView.textView.isFirstResponder {
            toolBarView.textView.resignFirstResponder()
        }
    }

}

