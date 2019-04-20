//
//  DataFile.swift
//  Easyprint
//
//  Created by app on 2018/7/3.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import CryptoSwift
import SwiftyJSON

//请求地址
class Url{
    static let baseWifi = "47.254.41.125:5000"
    static let basePath = "http://47.254.41.125:5000"
    static let bannerPath = "http://47.254.41.125:5000/v1/app/banner"
    static let baseImgPath = "http://www.geeetech.com/3d_models/public"
    static let baseUserLogin = basePath + "/v1/accs/"
    static let baseUsers = basePath + "/v1/users/"
    static let baseAccs = basePath + "/v1/accs/"
}
//本地储存
class UserData{
    func setData(key: String, value: AnyObject){
        if value.count <= 0{
            UserDefaults.standard.removeObject(forKey: key)
        }else{
            UserDefaults.standard.set(value, forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    func removeData(key: String){
        if key != ""{
            UserDefaults.standard.removeObject(forKey: key)
            UserDefaults.standard.synchronize()
        }
    }
    
    func getData(key: String) ->AnyObject{
        return UserDefaults.standard.value(forKey: key) as AnyObject
    }
    
    func getDataValue(key: String, value: String) ->String{
        let list = UserData().getData(key: "user")
        let result = list[value] as! String
        return result
    }
}
//AES_ECB加密
class AES_ECB{
    func encypted(need: String) -> String{
        do{
            let aesKey: [UInt8] = [0xb3, 0x3a, 0x34, 0x20, 0x87, 0x85, 0x1f, 0x24, 0xd3, 0x78, 0x68, 0xbe, 0x3e, 0x09, 0xfd, 0x0f]
            // ECB不需要iv
            //let aesIv: [UInt8] = [0x6d, 0x3b, 0x2d, 0xe0, 0x09, 0x79, 0xd0, 0x2f, 0x97, 0xb6, 0x57, 0x86, 0x67, 0xe8, 0xdf, 0x36]
            let aes = try! AES(key: aesKey, blockMode: ECB(), padding: .pkcs7)
            let ciphertext = try aes.encrypt(Array(need.utf8))
            return ciphertext.toHexString()
        } catch {
            return ""
        }
    }
}
//系统弹窗
class Alert{
    func textAlert(message: String) -> UIAlertController{
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        return alert
    }
    func singleAlert(message: String) -> UIAlertController{
        let alert = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let cancel = UIAlertAction(title: "ok", style: .default, handler: nil)
        alert.addAction(cancel)
        return alert
    }
}
//个人信息
class PersonInfo{
    //请求等待框
    static var shadowView = CustView()
    //是否点击打印 0.默认无 1.点击列表页打印 2.点击暂停 3.点击继续打印 4.点击终止打印
    static var isClickPrint = 0
    //是否连接到服务器  0.没有网络 1.默认连接 2.服务器检查5次不可用
    static var isConnectToServer = 1
    
    let list = UserData().getData(key: "user")
    func email() ->String{
        let email = list["email"] as! String
        return email
    }
    func name() ->String{
        let name = list["name"] as! String
        return name
    }
    func address() ->String{
        let address = list["address"] as! String
        return address
    }
    func avatar() ->String{
        let avatar = list["avatar"] as! String
        return avatar
    }
    func token() ->String{
        let token = list["token"] as! String
        return token
    }
    func token_expire() ->String{
        let token_expire = list["token_expire"] as! String
        return token_expire
    }
    func state() ->String{
        var state = list["state"] as! String
        if state == ""{
            state = "logout"
        }
        return state
    }
    func emailAes() ->String{
        let emailAes = AES_ECB().encypted(need: PersonInfo().email())
        return emailAes
    }

    struct Var{
        //打印机列表
        static var currentMachineList = JSON()
        //当前打印机序列号
        static var currentMachine = ""
        //当前打印机状态 0.未连接 1.未登录 2.在线无任务 3.正在打印 4.打印暂停
        static var currentMachineState = "0"
        //当前打印机名称
        static var currentMachineName = ""
        //挤出头设置温度
        static var extruderSetTemp = "0"
        //当前挤出头温度
        static var currentExtruderTemp = "0"
        //热床设置温度
        static var hotBedSetTemp = "0"
        //当前热床温度
        static var currentHotBedTemp = "0"
        //上传任务状态
        static var taskState = ""
        //上传文件名
        static var taskFileName = ""
        //上传文件总长度
        static var taskFileLength = Int()
        //已上传文件大小
        static var taskFileUploaded = Int()
        //打印进度
        static var currentProgress = Int()
        //打印文件名
        static var currentPrintName = ""
        //打印图片
        static var currentMachineImg = ""
        //模型库id及name
        static var modelID = [String]()
        static var modelName = [String]()
        static var modelImgID = [String]()
        static var modelImgName = [String]()
        //是否修改密码
        static var isChangePassword = false
        //是否开启侧滑
        static var isOpenCH = true
    }
    
    //初始化打印机参数
    func initPrinterData() -> Void{
        Var.currentMachineList = JSON()
        Var.currentMachine = ""
        Var.currentMachineState = "0"
        Var.currentMachineName = ""
        Var.extruderSetTemp = "0"
        Var.currentExtruderTemp = "0"
        Var.hotBedSetTemp = "0"
        Var.currentHotBedTemp = "0"
        Var.taskState = ""
        Var.taskFileName = ""
        Var.taskFileLength = Int()
        Var.taskFileUploaded = Int()
        Var.currentProgress = Int()
        Var.currentPrintName = ""
    }
    func initTemp() ->Void{
        Var.currentMachineState = "0"
        Var.extruderSetTemp = "0"
        Var.currentExtruderTemp = "0"
        Var.hotBedSetTemp = "0"
        Var.currentHotBedTemp = "0"
    }
}
