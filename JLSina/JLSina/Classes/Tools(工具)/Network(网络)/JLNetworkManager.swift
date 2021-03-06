//
//  JLNetworkManager.swift
//  JLSina
//
//  Created by 盘赢 on 2017/11/6.
//  Copyright © 2017年 JinLong. All rights reserved.
//

import UIKit
import AFNetworking

//swift的枚举支持任意数据类型
//switch / enum 在OC中都只是支持整数
/*
  - 如果日常开发中，发现网络请求返回状态码，405，不支持的网络请求方法
  - 首先应该查找网络请求方法是否正确
 */
enum JLHttpMethod {
    case GET
    case POST
}
//网络管理工具
class JLNetworkManager: AFHTTPSessionManager {

    //静态区/常量/闭包 (单例)
    //在第一次访问时执行闭包，并且将结果保存在 shared 常量中
    static let shared: JLNetworkManager = {
        //实例化对象
        let instance = JLNetworkManager()
        
        //设置响应反序列化支持的类型
        instance.responseSerializer.acceptableContentTypes?.insert("text/plain")
        
        //返回对象
        return instance
    }()
    
    //用户懒加载属性
    lazy var userAccount = JLUserAccount()
    
    //用户登录标记(计算型属性)
    var userLogon: Bool {
        return userAccount.access_token != nil
    }
    
    //用户微博id
    
    
    ///专门负责拼接token的网络请求方法
    ///
    /// - Parameters:
    ///   - method: GET/POST
    ///   - URLString: URLString
    ///   - parameters: 参数字典
    ///   - name: 上传文件使用的字段名，默认 nil,就不是上传文件
    ///   - data: 上传文件的二进制数据，默认 nil，不上传文件
    ///   - completion: 完成回调
    func tokenRequest(method: JLHttpMethod = .GET, URLString: String, parameters: [String:AnyObject]?, name: String? = nil , data:Data? = nil , completion: @escaping (_ json: AnyObject?,_ isSuccess: Bool) ->()) {
        
        //处理token字典
        //0>判断token是否为nil，直接返回,程序执行过程中，一般token不会为nil
        guard let token = userAccount.access_token else {
            //发送通知，提示用户登录
            print("没有token，需要登录")
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: nil)
            completion(nil , false)
            return
        }
        //1>判断参数字典是否存在，如果为nil，应该新建一个字典
        var parameters = parameters
        if parameters == nil {
            //实例化字典
            parameters = [String: AnyObject]()
        }
        //2>设置参数字典,代码在此处，字典一定有值
         parameters!["access_token"] = token as AnyObject?
        //调用request发起真正的网络请求方法
//        request(URLString: URLString, parameters: parameters, completion: completion)
        //3，判断name 和 data
        if let name = name ,
           let data = data {
            //上传文件
            upload(URLString: URLString, parameters: parameters, name: name, data: data, completion: completion)
        } else {
            
            request(method: method, URLString: URLString, parameters: parameters, completion: completion)
        }
    }
    
    //MARK: - 封装AFN方法，
    ///封装AFN的上传文件方法
    //上传文件必须是post方法，get只能获取数据，
    /// - Parameters:
    ///   - URLString: URLString
    ///   - parameters: 参数字典
    ///   - name: 接收上传的服务器字段(name: 咨询公司后台) 'pic'
    ///   - data: 要上传的二进制数据
    ///   - completion: 完成回调
    func upload(URLString: String , parameters: [String:AnyObject]? , name: String , data: Data , completion: @escaping (_ json: AnyObject?,_ isSuccess: Bool) ->()) {
        
        post(URLString, parameters: parameters, constructingBodyWith: { (formData) in
            
            //FIXME: - 创建 formData
            /*
             1, data: 要上传的二进制数据
             2, name: 服务器接收的字段名
             3, fileName: 保存在服务器的文件名，大多数服务器可以乱写，
                很多服务器上传图片完成后，会生成缩略图，中图，大图...
             4, mimeType: 告诉服务器上传文件的类型，如果不想告诉，可以使用 application/octet-stream  image/jpg image/png image/gif
             */
            formData.appendPart(withFileData: data, name: name, fileName: "xxx", mimeType: "application/octet-stream")
            
        }, progress: nil, success: { (_, json) in
            
            completion(json as AnyObject, true)
            
        }) { (task, error) in
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                
                print("token过期")
                //发送通知(本方法不知道被谁调用，谁接收到通知，谁处理)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: "bad token")
            }
            print("网络请求错误\(error)")
            completion(nil, false)
        }
    }
    
    //使用一个函数，封装AFN的 get 和 post 请求
    /// - parameter method:     GET /POST
    /// - parameter URLString:  URLString
    /// - parameter parameters: 参数字典
    /// - parameter completion: 回调json、是否成功
    func request(method: JLHttpMethod = .GET, URLString: String, parameters: [String:AnyObject]?, completion: @escaping (_ json: AnyObject?,_ isSuccess: Bool) ->()) {
        
        //成功回调
        let success = {(task: URLSessionDataTask, json: Any?) ->() in
            completion(json as AnyObject, true)
        }
        //失败回调
        let failure = {(task: URLSessionDataTask?, error: Error) ->() in
            
            //针对 403 处理token 过期
            //对于测试用户（应用程序未提交给新浪微博审核）
            //超出上限 token会被锁定一段时间
            //解决办法，新建一个应用程序
            if (task?.response as? HTTPURLResponse)?.statusCode == 403 {
                
                print("token过期")
                //发送通知(本方法不知道被谁调用，谁接收到通知，谁处理)
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: WBUserShouldLoginNotification), object: "bad token")
            }
            print("网络请求错误\(error)")
            completion(nil, false)
        }
        
        if method == .GET {
            get(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }else{
            post(URLString, parameters: parameters, progress: nil, success: success, failure: failure)
        }
    }
}
