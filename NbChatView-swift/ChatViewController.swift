//
//  ViewController.swift
//  NbChatView-swift
//
//  Created by xiuxiong ding on 2017/4/19.
//  Copyright © 2017年 xiuxiongding. All rights reserved.
//

import UIKit

let toolBarHeight: CGFloat = 44
let fitBlank: CGFloat = 15

enum AnimateType {
    case animate1 // 键盘弹出的话不会遮挡消息
    case animate2 // 键盘弹出的话会遮挡消息，但最后一条消息距离输入框有一段距离
    case animate3 // 最后一条消息距离输入框在小范围内，这里设为 2 * fitBlank = 30
}

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    var chatTableView: UITableView!
    var toolBarView: ToolBarView!
    
    var msgList = [Message]()
    
    var mUserInfo: Dictionary<AnyHashable, Any>!
    var mKeyBoardAnimateDuration: Double!
    var mKeyBoardHeight: CGFloat!
    
    var fisrtLoad = true
    var animateType = AnimateType.animate1
    var lastDifY: CGFloat = 0
    var animateOption: UIViewAnimationOptions!
    var oldOffsetY: CGFloat = 0
    var isKeyboardShowed = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.rgbColorFromHex(rgb: 0xF5F6FA)
        
        // 消除tableview的留白
        self.automaticallyAdjustsScrollViewInsets = false
        
        // 标题
        let title = UILabel(frame: CGRect(x: (SCREEN_WIDTH - 100)/2, y: 10, width: 100, height: 24))
        title.text = "chat"
        title.textAlignment = .center
        title.font = UIFont.systemFont(ofSize: 20)
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
        chatTableView.contentInset = UIEdgeInsetsMake(0, 0, fitBlank, 0)
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
        
        oldOffsetY = chatTableView.contentOffset.y
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        removeKeyBoard()
        chatTableView.reloadData()
        animateType = .animate1
        lastDifY = 0
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
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > oldOffsetY {
            // 向上滑动
        } else if scrollView.contentOffset.y < oldOffsetY {
            // 向下滑动
            if isKeyboardShowed {
                hideKeyboard()
            }
        }
        
        oldOffsetY = scrollView.contentOffset.y
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
        mUserInfo = userInfo
        let value = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue
        let keyBoardRect = value.cgRectValue
        // 得到键盘高度
        let keyBoardHeight = keyBoardRect.size.height
        mKeyBoardHeight = keyBoardHeight
        
        // 得到键盘弹出所需时间
        let duration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! NSNumber
        mKeyBoardAnimateDuration = duration.doubleValue
        showKeyboard()
    }
    
    func keyBoardWillHide(notification: Notification) {
        hideKeyboard()
    }
    
    func showKeyboard() {
        var animate: (()->Void) = {
            self.toolBarView.transform = CGAffineTransform(translationX: 0, y: -self.mKeyBoardHeight)
        }
        
        
        if msgList.count > 0 {
            let lastIndex = IndexPath(row: msgList.count - 1, section: 0)
            let rectCellView = chatTableView.rectForRow(at: lastIndex)
            let rect = chatTableView.convert(rectCellView, to: chatTableView.superview)
            let cellDistance = rect.origin.y + rect.height
            let distance1 = SCREEN_HEIGHT - toolBarHeight - mKeyBoardHeight
            let distance2 = SCREEN_HEIGHT - toolBarHeight - 2 * fitBlank
            let difY = cellDistance - distance1
            
            if cellDistance <= distance1 {
                animate = {
                    self.toolBarView.transform = CGAffineTransform(translationX: 0, y: -self.mKeyBoardHeight)
                }
                animateType = .animate1
            } else if distance1 < cellDistance && cellDistance <= distance2 {
                animate = {
                    self.toolBarView.transform = CGAffineTransform(translationX: 0, y: -self.mKeyBoardHeight)
                    self.chatTableView.transform = CGAffineTransform(translationX: 0, y: -difY)
                    self.lastDifY = difY
                }
                animateType = .animate2
            } else {
                animate = {
                    self.view.transform = CGAffineTransform(translationX: 0, y: -self.mKeyBoardHeight)
                }
                animateType = .animate3
            }
        }
        let options = UIViewAnimationOptions(rawValue: UInt((mUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
        animateOption = options
        
        UIView.animate(withDuration: mKeyBoardAnimateDuration, delay: 0, options: options, animations: animate) { (isFinished) in
            self.oldOffsetY = self.chatTableView.contentOffset.y
            self.isKeyboardShowed = true
        }
    }
    
    func hideKeyboard() {
        
        if toolBarView.textView.isFirstResponder {
            toolBarView.textView.resignFirstResponder()
            
            let options = UIViewAnimationOptions(rawValue: UInt((mUserInfo[UIKeyboardAnimationCurveUserInfoKey] as! NSNumber).intValue << 16))
            
            var animate: (() -> Void) = {
                
            }
            
            // 返回 view 或 toolBarView 或 chatTableView 到原有状态
            switch animateType {
            case .animate1:
                animate = {
                    self.toolBarView.transform = CGAffineTransform.identity
                    self.chatTableView.transform = CGAffineTransform.identity
                }
            case .animate2:
                animate = {
                    self.toolBarView.transform = CGAffineTransform.identity
                    self.chatTableView.transform = CGAffineTransform.identity
                }
            case .animate3:
                animate = {
                    self.view.transform = CGAffineTransform.identity
                }
            }
            
            UIView.animate(withDuration: mKeyBoardAnimateDuration, delay: 0, options: options, animations: animate, completion: { (finish) in
                self.scrollToBottom()
                self.oldOffsetY = self.chatTableView.contentOffset.y
                self.isKeyboardShowed = false
            })
        }
    }
    
    // 刷新列表
    func reloadTableView() {
        chatTableView.reloadData()
        chatTableView.layoutIfNeeded()
        
        // 得到最后一条消息在view中的位置
        let lastIndex = IndexPath(row: msgList.count - 1, section: 0)
        let rectCellView = chatTableView.rectForRow(at: lastIndex)
        let rect = chatTableView.convert(rectCellView, to: chatTableView.superview)
        let cellDistance = rect.origin.y + rect.height
        let distance1 = SCREEN_HEIGHT - toolBarHeight - mKeyBoardHeight
        
        // 计算键盘可能遮住的消息的长度
        let difY = cellDistance - distance1
        
        
        if animateType == .animate3 {
            // 处于情况三时，由于之前的约束（聊天界面在输入栏上方），并且
            // 是整个界面一起上滑，所以约束依旧成立，只需把聊天界面最后
            // 一条消息滚动到聊天界面底部即可
            scrollToBottom()
        } else if (animateType == .animate1 || animateType == .animate2) && difY > 0{
            // 在情况一和情况二中，如果聊天界面上滑的总距离小于键盘高度，则可以继续上滑
            // 一旦聊天界面上滑的总距离 lastDifY + difY 将要超过键盘高度，则上滑总距离设为键盘高度
            // 此时执行 trans 动画
            // 一旦聊天界面上滑总距离为键盘高度，则变为情况三的情况，把聊天界面最后
            // 一条消息滚动到聊天界面底部即可
            if lastDifY + difY < mKeyBoardHeight {
                lastDifY += difY
                let animate: (()->Void) = {
                    self.chatTableView.transform = CGAffineTransform(translationX: 0, y: -self.lastDifY)
                }
                UIView.animate(withDuration: mKeyBoardAnimateDuration, delay: 0, options: animateOption, animations: animate)

            } else if lastDifY + difY > mKeyBoardHeight {
                if lastDifY != mKeyBoardHeight {
                     let animate: (()->Void) = {
                        self.chatTableView.transform = CGAffineTransform(translationX: 0, y: -self.mKeyBoardHeight)
                    }
                    UIView.animate(withDuration: mKeyBoardAnimateDuration, delay: 0, options: animateOption, animations: animate)
                    lastDifY = mKeyBoardHeight
                }
                scrollToBottom()
            }
        }
        
    }
    
    // 滚动最后一条消息到列表界面底部
    func scrollToBottom() {
        if msgList.count > 0 {
            chatTableView.scrollToRow(at: IndexPath(row: msgList.count - 1, section: 0), at: .bottom, animated: true)
        }
    }
    
    // 清空消息
    func clearMessage() {
        removeKeyBoard()
        msgList.removeAll()
        chatTableView.reloadData()
        animateType = .animate1
        lastDifY = 0
    }
    
    // 点击消息列表键盘消失
    func tapRemoveBottomView(recognizer: UITapGestureRecognizer) {
        removeKeyBoard()
    }
    
    // 键盘消失
    func removeKeyBoard() {
        if toolBarView.textView.isFirstResponder {
            toolBarView.textView.resignFirstResponder()
            toolBarView.transform = CGAffineTransform.identity
        }
    }
}

