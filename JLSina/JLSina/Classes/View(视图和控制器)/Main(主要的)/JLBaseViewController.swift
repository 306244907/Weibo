//
//  JLBaseViewController.swift
//  JLSina
//
//  Created by 盘赢 on 2017/9/29.
//  Copyright © 2017年 JinLong. All rights reserved.
//

import UIKit

//面试题：OC中支持多继承吗？如果不支持，如何替代
//答案：使用协议替代
//Swift的写法更类似于多继承!
//class JLBaseViewController: UIViewController , UITableViewDataSource , UITableViewDelegate {
//Swift中，利用extension 可以把函数按照功能分类管理，便于阅读和维护
//注意：
//1,extension 中不能有属性
//2,extension 不能重写"父类"本类的方法!重写父类方法，是子类的职责，扩展是对类的扩展！

//所有主控制器的基类控制器
class JLBaseViewController: UIViewController {
    
    
    //访客视图信息字典
    var visitorInfoDictionary: [String: String]?
    
    //表格视图 - 如果用户没有登录，就不创建
    var tableView: UITableView?
    
    //刷新控件
    var refreshControl: JLRefreshControl?
    
    //上拉刷新标记
    var isPullup = false
    
    //自定义导航条
    lazy var navigationBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: UIScreen.cz_screenWidth(), height: 44))
    
    //自定义的导航项 - 以后使用导航栏内容，统一使用navItem
    lazy var navItem = UINavigationItem()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        JLNetworkManager.shared.userLogon ? loadData() : ()
        
        //注册登录成功通知
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(loginSucess),
            name: NSNotification.Name(rawValue: WBUserLoginSuccessedNotification),
            object: nil)
    }
    
    deinit {
        //注销通知
        NotificationCenter.default.removeObserver(self)
    }
    
    //重写title的didSet
    override var title: String? {
        didSet {
            navItem.title = title
        }
    }
    
    //加载数据 - 具体实现，由子类负责
    @objc func loadData() {
        //如果子类不实现任何方法，默认关闭刷新
        refreshControl?.endRefreshing()
    }

}

//访客视图监听方法
extension JLBaseViewController {
    
    //登录成功处理
    @objc private func loginSucess(n: Notification) {
        
        print("登录成功\(n)")
        
        //登录前左边是注册，右边是登录
        navItem.rightBarButtonItem = nil
        navItem.leftBarButtonItem = nil

        
        //更新UI => 将访客视图替换为表格视图
        
        //需要重新设置View
        //在访问 view == nil 的getter时，如果view == nil，会调用loadView ->viewDidLoad
        view = nil
        //注销通知 ->重新执行viewDidLoad会再次注册！(注册几次发送几次通知消息)，避免通知被重复注册
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func login() {
        //发送通知
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: nil)
    }
    
    @objc private func register() {
        print("用户注册")
    }
}

// MARK: - 设置界面
extension JLBaseViewController {
    private func setupUI() {
        view.backgroundColor = UIColor.white
        //取消自动缩进 - 如果隐藏了导航栏，会缩进20个点(目前版本不设置也好)
        automaticallyAdjustsScrollViewInsets = false
        setUpNavigationBar()
        
        JLNetworkManager.shared.userLogon ? setupTableView() : setupVisitorView()
    }
    
    //设置表格视图 - 用户登录之后执行(子类重写此类方法)
    //因为子类不需要关心用户登录之前的逻辑
    @objc dynamic func setupTableView() {
        tableView = UITableView(frame: view.bounds, style: .plain)
        view.insertSubview(tableView!, belowSubview: navigationBar)
        
        //设置数据源和代理 ->让子类直接实现数据源方法
        tableView?.dataSource = self
        tableView?.delegate = self
//        tableView?.showsVerticalScrollIndicator = false
//        tableView?.separatorStyle = .none
        
        //设置内容缩进
        tableView?.contentInset = UIEdgeInsets(top: navigationBar.bounds.height, left: 0, bottom: 0, right: 0)
        
        //修改指示器缩进 - 强行解包是为了拿到一个必有的inset
        tableView?.scrollIndicatorInsets = tableView!.contentInset
        //设置刷新控件
        //1,实例化控件
        refreshControl = JLRefreshControl()
//        let str = NSAttributedString(string: "正在刷新")
        
//        refreshControl?.attributedTitle = str
        refreshControl?.tintColor = UIColor.orange
        //2,添加到表格视图
        tableView?.addSubview(refreshControl!)
        
        //3,添加监听方法
        refreshControl?.addTarget(self, action: #selector(loadData), for: .valueChanged)
    }
    
    //设置访客视图
    private func setupVisitorView() {
        let visitorView = JLVisitorView(frame: view.bounds)
        
        view.insertSubview(visitorView, belowSubview: navigationBar)
        
        //1,设置访客视图信息
        visitorView.visitorInfo = visitorInfoDictionary
        print("访客视图\(visitorView)")
        
        //2,添加访客视图按钮监听方法
        visitorView.loginBtn.addTarget(self, action: #selector(login), for: .touchUpInside)
        visitorView.registerBtn.addTarget(self, action: #selector(register), for: .touchUpInside)
        
        //3,设置导航条按钮
        navItem.leftBarButtonItem = UIBarButtonItem(title: "注册", style: .plain, target: self, action: #selector(register))
        navItem.rightBarButtonItem = UIBarButtonItem(title: "登录", style: .plain, target: self, action: #selector(login))
        
    }
    //设置导航条
    private func setUpNavigationBar() {
        //添加导航条
        view.addSubview(navigationBar)
        //将item设置给bar
        navigationBar.items = [navItem]
        //1>设置navbar整个背景的渲染颜色
        navigationBar.barTintColor = UIColor.cz_color(withHex: 0xF6F6F6)
        //2>设置navbar的字体颜色
        navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.darkGray]
        //3>设置item按钮的文字渲染颜色
        navigationBar.tintColor = UIColor.orange
        
//        navigationBar.backgroundColor = UIColor.white
        //设置状态栏背景颜色
        let a = UIApplication.shared.value(forKey: "statusBarWindow") as! UIView
        let v = a .value(forKeyPath: "statusBar") as! UIView
        v.backgroundColor = navigationBar.barTintColor
    }
}

//MARK: - UITableViewDelegate , UITableViewDataSource
extension JLBaseViewController: UITableViewDelegate , UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    //基类只是准备方法，子类负责具体实现
    //子类的数据源方法不需要 super
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //只是保证没有语法错误
        return UITableViewCell()
    }
    
    //在显示最后一行的时候，做上拉刷新
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        //1,判断indexPath是否是最后一行
        //(indexPath.section(最大) / indexPath.row(最后一行))
        //1>row
        let row = indexPath.row
        //2> section
        let section = tableView.numberOfSections - 1
        
        if row < 0 || section < 0 {
            return
        }
        
        //3,行数
        let count = tableView.numberOfRows(inSection: section)
        
        //如果是最后一行，同时没有开始上拉刷新
        if row == count - 1 && !isPullup {
            print("上拉刷新")
            isPullup = true
            //开始刷新
            loadData()
        }
        
//        print("section--\(section)")
    
        
    }
}
