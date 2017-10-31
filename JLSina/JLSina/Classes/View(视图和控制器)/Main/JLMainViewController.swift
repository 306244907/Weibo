//
//  JLMainViewController.swift
//  JLSina
//
//  Created by 盘赢 on 2017/9/29.
//  Copyright © 2017年 JinLong. All rights reserved.
//

import UIKit

//主控制器
class JLMainViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupChildControllers()
    }

}

//extension 类似于OC中的分类，在Swift中可以查分代码块，
//可以把相近功能的函数，放在一个extension中，便于代码维护
//注意：和OC的分类一样，extension 中不能定义属性

//MARK: - 设置界面
extension JLMainViewController {

    
    //使用字典创建一个子控制器
    private func controller(dict: [String: String]) -> UIViewController {
        //1，取得字典内容
        guard let clsName = dict["clsName"] ,
         let title = dict["title"] ,
         let imageName = dict["imageName"] ,
         let cls = NSClassFromString(Bundle.main.namespace + "." + clsName) as? UIViewController.Type
        else {
            
            return UIViewController()
        }
        
        let vc = cls.init()
        vc.title = title
        
        vc.tabBarItem.image = UIImage(named: "tabbar_" + imageName)
        vc.tabBarItem.selectedImage = UIImage(named: "tabbar_" + imageName + "_highlighted")?.withRenderingMode(.alwaysOriginal)
        
        //设置tabbar标题字体
        vc.tabBarItem.setTitleTextAttributes(
            [NSAttributedStringKey.foregroundColor: UIColor.orange], for: .highlighted)
        
       //系统默认12号字
      vc.tabBarItem.setTitleTextAttributes(
        [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 14)], for: .normal)
        
        let nav = JLNavigationController(rootViewController: vc)
        return nav
        
        
    }
//设置所有子控制器
    private func setupChildControllers() {

        let array = [
            ["clsName":"JLHomeViewController","title":"首页" , "imageName":"home"],
            ["clsName":"JLMessageViewController","title":"消息" , "imageName":"message_center"],
            ["clsName":"JLDiscoverViewController","title":"发现" , "imageName":"discover"],
            ["clsName":"JLProfileViewController","title":"我" , "imageName":"profile"]
        ]
        var arrayM = [UIViewController]()
        for dict in array {
            arrayM.append(controller(dict: dict))
        }
        
        viewControllers = arrayM
        
    }
    
//    private func addChildViewController(vc: UIViewController, title: String, imageName: String) {
//        // 设置标题
//        vc.title = title
//        // 设置图像
//        vc.tabBarItem.image = UIImage(named: imageName)
//        // 导航控制器
//        let nav = UINavigationController(rootViewController: vc)
//        addChildViewController(nav)
//    }
}

