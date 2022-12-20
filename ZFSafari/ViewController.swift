//
//  ViewController.swift
//  ZFSafari
//
//  Created by 郑峰 on 2022/12/19.
//

import UIKit

class ViewController: UIViewController, UIWebViewDelegate, UIGestureRecognizerDelegate {

    var webView:UIWebView?
    var searchBar:UITextField?
    var isUp:Bool?
    var titleLabel:UILabel?
    var upSwipe:UISwipeGestureRecognizer?
    var downSwipe:UISwipeGestureRecognizer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView = UIWebView(frame: CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height - 64))
        webView?.scrollView.bounces = false
        webView?.delegate = self
        isUp = false
        titleLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 40, height: 20))
        titleLabel?.backgroundColor = UIColor.clear
        titleLabel?.font = UIFont.systemFont(ofSize: 14)
        titleLabel?.textAlignment = .center
        
        // 默认加载百度
        let url = URL(string: "http://www.baidu.com")
        let request = URLRequest(url: url!);
        webView?.loadRequest(request)
        self.view.addSubview(webView!)
        
        // 设置导航栏
        createSearchBar()
        // 创建手势
        createGesture()
        // 创建工具栏
        createToolBar()
        
    }
    
    func createSearchBar() {
        searchBar = UITextField(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width - 40, height: 30))
        searchBar?.borderStyle = .roundedRect
        let goBtn = UIButton(type: .system)
        goBtn.addTarget(self, action: #selector(goWeb), for: .touchUpInside)
        goBtn.setTitle("GO", for: .normal)
        searchBar?.rightView = goBtn
        searchBar?.rightViewMode = .always
        searchBar?.placeholder = "请输入网址"
        searchBar?.autocapitalizationType = .none // 关闭首字母大写
        searchBar?.spellCheckingType = .no
        self.navigationItem.titleView = searchBar
    }

    func createGesture() {
        upSwipe = UISwipeGestureRecognizer(target: self, action: #selector(upSwipeFunc))
        upSwipe?.delegate = self
        upSwipe?.direction = .up
        webView?.addGestureRecognizer(upSwipe!)
        
        downSwipe = UISwipeGestureRecognizer(target: self, action: #selector(downSwipeFunc))
        downSwipe?.delegate = self
        downSwipe?.direction = .down
        webView?.addGestureRecognizer(downSwipe!)
    }
    
    func createToolBar() {
        self.navigationController?.setToolbarHidden(false, animated: true)
        let itemHistory = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(goHistory))
        let itemLike = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(goLike))
        let itemBack = UIBarButtonItem(title: "back", style: .plain, target: self, action: #selector(goBack))
        let itemForward = UIBarButtonItem(title: "forward", style: .plain, target: self, action: #selector(goForward))
        let itemEmpty = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
        self.toolbarItems = [itemHistory, itemEmpty, itemLike, itemEmpty, itemBack, itemEmpty, itemForward]
    }
    
    // MARK: - action
    @objc func goWeb(sender:UIButton) {
        let str:String! = searchBar?.text
        if (str!.count == 0) {
            let alert = UIAlertController(title: "温馨提示", message: "输入的网址不能为空", preferredStyle: .alert)
            let action = UIAlertAction(title: "好的", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        let url = URL(string: "http://\(str!)")
        
        if (url == nil) {
            let alert = UIAlertController(title: "温馨提示", message: "输入的网址无效", preferredStyle: .alert)
            let action = UIAlertAction(title: "好的", style: .default)
            alert.addAction(action)
            self.present(alert, animated: true)
            return
        }
        
        let request = URLRequest(url: url!)
        webView?.loadRequest(request)
    }
    
    @objc func upSwipeFunc() {
        // 先判断导航栏和工具栏是否已经处于隐藏状态
        if isUp! {
            return
        }
        
        self.navigationItem.titleView = nil;
        webView?.frame = CGRect(x: 0, y: 40, width: self.view.frame.size.width, height: self.view.frame.size.height - 40)
        UIView.animate(withDuration: 0.3) {
            self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 40)
            self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(7, for: .default)
        } completion: { (finished) in
            self.navigationItem.titleView = self.titleLabel!
        }
        self.navigationController?.setToolbarHidden(true, animated: true)
        isUp = true
        print("上滑")
    }

    @objc func downSwipeFunc() {
        if !isUp! {
            return
        }
        
        if webView?.scrollView.contentOffset.y == 0 || isUp! {
            self.navigationItem.titleView = nil
            webView?.frame = CGRect(x: 0, y: 64, width: self.view.frame.size.width, height: self.view.frame.size.height)
            UIView.animate(withDuration: 0.3) {
                self.navigationController?.navigationBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: 64)
                self.navigationController?.navigationBar.setTitleVerticalPositionAdjustment(0, for: .default)
            } completion: { (finished) in
                self.navigationItem.titleView = self.searchBar!
            }
            self.navigationController?.setToolbarHidden(false, animated: true)
            isUp = false

        }
        print("下滑")
    }
    
    @objc func goHistory() {
        let historyVC = HistoryTableViewController()
        self.navigationController?.pushViewController(historyVC, animated: true)
    }
    
    @objc func goLike() {
        let alert = UIAlertController(title: "温馨提示", message: "请选择您要进行的操作", preferredStyle: .actionSheet)
        let action1 = UIAlertAction(title: "添加收藏", style: .default) { (action) in
            var array:Array<String>? = UserDefaults.standard.value(forKey: "Like") as! Array<String>?
            if (array == nil) {
                array = Array<String>()
            }
            array?.append(self.webView!.request!.url!.absoluteString)
            UserDefaults.standard.set(array!, forKey: "Like")
            UserDefaults.standard.synchronize()
        }
        let action2 = UIAlertAction(title: "查看收藏夹", style: .default) { (action) in
            let likeVC = LikeTableViewController()
            self.navigationController?.pushViewController(likeVC, animated: true)
        }
        let action3 = UIAlertAction(title: "取消", style: .default)
        alert.addAction(action1)
        alert.addAction(action2)
        alert.addAction(action3)
        self.present(alert, animated: true)
    }
    
    @objc func goBack() {
        if webView?.canGoBack != nil {
            webView?.goBack()
        }
    }
    
    @objc func goForward() {
        if webView?.canGoForward != nil {
            webView?.goForward()
        }
    }
    
    // MARK: - UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        // 当 gestureRecognizer 或 otherGestureRecognizer 之一的识别将被另一个阻止时调用
        // 返回 YES 以允许两者同时识别。 默认实现返回 NO（默认情况下不能同时识别两个手势）
        if gestureRecognizer == upSwipe || gestureRecognizer == downSwipe {
            return true
        }
        return false
    }
    
    // MARK: - UIWebViewDelegate
    func webViewDidFinishLoad(_ webView: UIWebView) {
        // TODO: 会回调两次
        if (webView.isLoading) {
            return
        }

        titleLabel?.text = webView.request?.url?.absoluteString
        var array:Array<String>? = UserDefaults.standard.value(forKey: "History") as! Array<String>?
        if (array == nil) {
            array = Array<String>()
        }
        array?.append(titleLabel!.text!)
        UserDefaults.standard.set(array!, forKey: "History")
        UserDefaults.standard.synchronize()
    }
    
    // MARK: - helper
    open func loadURL(urlString:String) {
        webView?.loadRequest(URLRequest(url: URL(string: urlString)!))
    }
}

