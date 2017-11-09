//
//  JLWBOAuthViewController.swift
//  JLSina
//
//  Created by 盘赢 on 2017/11/9.
//  Copyright © 2017年 JinLong. All rights reserved.
//

import UIKit

//通过webView加载新浪微博授权页面控制器
class JLWBOAuthViewController: UIViewController {

    private lazy var webView = UIWebView()
    
    override func loadView() {
        view = webView
        view.backgroundColor = UIColor.white
        
        //设置导航栏
        title = "登录新浪微博"
        //导航栏按钮
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "返回" , target: self, action: #selector(close), isBack: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "自动填充", target: self, action: #selector(autoFill))
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //加载授权界面
        let urlString = "https://api.weibo.com/oauth2/authorize?client_id=\(WBAppKey)&redirect_uri=\(WBRedirectURI)"
        
        //1>URL确定要访问的资源
        guard let url = URL(string: urlString) else {
                return
        }
        
        //2>建立请求
        let request = URLRequest(url: url)
        
        //3>加载请求
        webView.loadRequest(request)
        
    }
    
    
    

    //MARK: - 监听方法
    @objc private func close() {
        dismiss(animated: true, completion: nil)
    }
    
    //自动填充 - webView的注入，直接通过js修改 ‘本地浏览器中‘缓存的页面内容
    //点击登录，执行submit ，将本地的数据提交给服务器
    @objc private func autoFill() {
        //准备js
        let js = "document.getElementById('userId').value = '13611942390';" + "document.getElementById('passwd').value = 'woaini921227';"
        
        //让webView直行js
        webView.stringByEvaluatingJavaScript(from: js)
    }

}
