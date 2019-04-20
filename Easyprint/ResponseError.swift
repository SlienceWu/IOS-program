//
//  ResponseError.swift
//  Easyprint
//
//  Created by app on 2018/8/2.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON

//超时管理器
var sessionManager: SessionManager? = nil
class AlamofireCustom{
    //iPhone X不可用
    func alamofireManager() -> SessionManager{
        //var sessionManager: SessionManager? = nil
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 10
        sessionManager = Alamofire.SessionManager(configuration: configuration)
        return sessionManager!
    }
    //兼容iPhone X
    static let alamofireManager: SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 10
        return Alamofire.SessionManager(configuration: sessionConfiguration)
    }()
    static let alamofireLong: SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 120
        return Alamofire.SessionManager(configuration: sessionConfiguration)
    }()
    //1秒超时处理
    static let alamofireFast: SessionManager = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.timeoutIntervalForRequest = 1
        return Alamofire.SessionManager(configuration: sessionConfiguration)
    }()
}

class ResponseError{
    var isChangeToken = false
    //服务器返回错误
    func error(target: UIViewController, code: Int){
        if code == 410{
            target.present(Alert().singleAlert(message: "Machine is offline."), animated: true, completion: nil)
        } else if code == 500{
            target.present(Alert().singleAlert(message: "The server failed to handle the request for some unknown reasons."), animated: true, completion: nil)
        } else if code == 503{
            target.present(Alert().singleAlert(message: "The server is too overloaded to complete the request."), animated: true, completion: nil)
        } else if code == 996{
            target.present(Alert().singleAlert(message: "Wrong parameters in the requested address."), animated: true, completion: nil)
        } else if code == 997{
            target.present(Alert().singleAlert(message: "Token null."), animated: true, completion: nil)
        } else if code == 998{
            if PersonInfo.Var.isChangePassword{
                return
            }
            if PersonInfo().state() == "logout"{
                print("========= 998 again ==========")
                return
            }
            let currentView = UIViewController.currentViewController()
            currentView?.present(Alert().textAlert(message: "Login validation has expired."), animated: true, completion: nil)
            PersonInfo().initPrinterData()
            let userParams = ["email": PersonInfo().email(), "name": "", "address": "", "avatar": "", "token": "", "token_expire": "", "state": ""]
            UserData().setData(key: "user", value: userParams as AnyObject)
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {
                
                currentView?.presentedViewController?.dismiss(animated: false, completion: nil)
                let loginView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "loginView")
                
                if currentView == MyViewController(){
                    target.performSegue(withIdentifier: "login", sender: target)
                }else{
                    //防止有多个Alert弹窗问题
                        currentView?.dismiss(animated: false, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1, execute: {
                        let nowView = UIViewController.currentViewController()
                        let a = nowView as! ViewController
                        a.animateMainView(shouldExpand: false)
                        let c = a.childViewControllers[0].childViewControllers[0] as! UITabBarController
                        c.selectedViewController?.childViewControllers[0].navigationController!.pushViewController(loginView, animated: true)
                    })
                    //#if DEBUG
//                    let a = currentView as! ViewController
//                    a.animateMainView(shouldExpand: false)
//                    let c = currentView?.childViewControllers[0].childViewControllers[0] as! UITabBarController
//                c.selectedViewController?.childViewControllers[0].navigationController!.pushViewController(loginView, animated: true)
                    //#else
                    //currentView?.navigationController!.pushViewController(loginView, animated: true)
                    //#endif
                }
                
                //target.present(loginView, animated: true, completion: nil)
            })
        } else if code == 999{
            if !isChangeToken{
                isChangeToken = true
                changeToken()
            }
        } else{
            print("===== other wrong =====",code)
        }
    }
    //底层返回错误
    func errorNScode(target: UIViewController, code: Int){
        if code == -1009{
            target.present(Alert().singleAlert(message: "Please check whether your network is connected."), animated: true, completion: nil)
        } else if code == -1004{
            target.present(Alert().singleAlert(message: "Server fail."), animated: true, completion: nil)
        } else if code == -1005{
            target.present(Alert().singleAlert(message: "Your networks is unused."), animated: true, completion: nil)
        } else if code == -1001{
            target.present(Alert().singleAlert(message: "Timeout. Please check your network."), animated: true, completion: nil)
        } else if code == -999{
            target.present(Alert().singleAlert(message: "Timeout. Please check your network."), animated: true, completion: nil)
        }
    }
    //修改token值
    func changeToken(){
        let encryStr = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let url = Url.baseAccs + encryStr
        let params = ["action": "update", "target": "user_token", "token": token]
        Alamofire.request(url, method: .patch, parameters: params, encoding: JSONEncoding.default).responseJSON{
            (response) in
            if response.result.isSuccess{
                let code = response.response?.statusCode
                if code == 200{
                    self.isChangeToken = false
                    let value = response.result.value as Any
                    let list = JSON(value)
                    let email = list["email"].stringValue
                    let token = list["new_token"].stringValue
                    let token_expire = list["token_expire"].stringValue
                    let name = PersonInfo().name()
                    let address = PersonInfo().address()
                    let avatar = PersonInfo().avatar()
                    let userParams = ["email": email, "name": name, "address": address, "avatar": avatar, "token": token, "token_expire": token_expire, "state": "login"] as [String : Any]
                    UserData().setData(key: "user", value: userParams as AnyObject)
                }
            } else {
                self.isChangeToken = false
            }
            
        }
    }
}
