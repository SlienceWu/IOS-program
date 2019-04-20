//
//  ChooseFileControll.swift
//  Easyprint
//
//  Created by app on 2018/11/5.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import SwiftSocket

class ChooseFileControll: UIViewController{
    @IBOutlet weak var ipText: UITextField!
    @IBOutlet weak var portText: UITextField!
    @IBOutlet weak var connect: UIButton!
    @IBOutlet weak var disconnect: UIButton!
    @IBOutlet weak var message: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    @IBOutlet weak var showText: UITextView!
    @IBOutlet weak var chooseFile: UIButton!
    @IBOutlet weak var startUpload: UIButton!
    @IBOutlet weak var showSome: UITextView!
    
    //socket客户端类对象
    var socketClient:TCPClient?
    var socketList: [TCPClient?] = []
    //是否接受数据
    var isReciveData = true
    //定时器
    private var timer:Timer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //导航返回及名称
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.title = "Choose Test"
        
        connect.addTarget(self, action: #selector(connectSocket), for: .touchUpInside)
        disconnect.addTarget(self, action: #selector(disconnectSocket), for: .touchUpInside)
        sendBtn.addTarget(self, action: #selector(sendMsg), for: .touchUpInside)
        chooseFile.addTarget(self, action: #selector(chooseNeed), for: .touchUpInside)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //初始化客户端，并连接服务器
    @objc func processClientSocket(ip: String, port: Int32){
        socketClient = TCPClient(address: ip, port: port)
        if socketList.count > 0{
            for i in 0...(socketList.count - 1){
                print("exist socket ip: " + (socketList[i]?.address)!)
                if ip == socketList[i]?.address{
                    return
                }
            }
        }
        socketList.append(socketClient)
        socketAction(socket: socketClient)
        //return
//        DispatchQueue.global(qos: .background).async {
//            //用于读取并解析服务端发来的消息
//            func readmsg()-> String?{
//                if let buff = self.socketClient!.read(1024*10, timeout: 5){
//                    if let res = String(bytes: buff, encoding: .utf8){
//                        //print("test data==============")
//                        //print(self.socketClient?.port)
//                        self.sendMessage(msgtosend: "start 123")
//                        return res
//                    }
//                } else {
//                    //print("test data nil=======================")
//                    return nil
//                }
//                return nil
//            }
//            //连接服务器
//            switch self.socketClient!.connect(timeout: 5) {
//            case .success:
//                self.isReciveData = true
//                DispatchQueue.main.async {
////                    self.alert(msg: "connect success", after: {
////                    })
//                    self.showText.text = "connect success"
//                }
//
//                //发送用户名给服务器（这里使用随机生成的）
//                self.sendMessage(msgtosend: "start")
//
//                //不断接收服务器发来的消息
//                while self.isReciveData{
//                    if let msg = readmsg(){
//                        DispatchQueue.main.async {
//                            self.processMessage(msg: msg)
//                            //print("00")
//                        }
//                    }else{
//                        self.isReciveData = false
//                        DispatchQueue.main.async {
//                            var ipA: String?
//                            var portA: Int32?
//                            for i in 0...(self.socketList.count - 1){
//                                if self.socketClient?.address == self.socketList[i]?.address{
//                                    self.socketList.remove(at: i)
//                                    ipA = self.socketClient?.address
//                                    portA = self.socketClient?.port
//                                }
//                            }
//                            print("timeout..." + String(self.socketList.count))
//                            self.socketClient?.close()
//                            self.processClientSocket(ip: ipA!, port: portA!)
//                        }
//                        break
//                    }
//                }
//            case .failure(let error):
//                DispatchQueue.main.async {
//                    self.alert(msg: error.localizedDescription,after: {
//                    })
//                }
//            }
//        }
    }
    @objc func connectSocket(){
        let ip = ipText.text
        let port = Int32(portText.text!)
        processClientSocket(ip: ip!, port: port!)
    }
    @objc func disconnectSocket(){
        let ip = ipText.text
        //let port = Int32(portText.text!)
        print("disconnect socket ip: " + (self.socketClient?.address)!)
        self.isReciveData = false
        if self.socketList.count < 1{
            print(self.socketList.count)
            return
        }
        for i in 0...(self.socketList.count - 1){
            if ip == self.socketList[i]?.address{
                self.socketList.remove(at: i)
                print("delete disconnect socket")
            }
        }
        self.socketClient?.close()
    }
    func socketAction(socket: TCPClient?){
        DispatchQueue.global(qos: .background).async {
            //用于读取并解析服务端发来的消息
            func readmsg()-> String?{
                if let buff = socket!.read(1024*10, timeout: 5){
                    if let res = String(bytes: buff, encoding: .utf8){
                        //print("test data==============")
                        //print(self.socketClient?.port)
                        self.sendMessage(msgtosend: "start 123")
                        return res
                    }
                } else {
                    //print("test data nil=======================")
                    return nil
                }
                return nil
            }
            //连接服务器
            switch socket!.connect(timeout: 5) {
            case .success:
                self.isReciveData = true
                DispatchQueue.main.async {
                    //                    self.alert(msg: "connect success", after: {
                    //                    })
                    let ipA = socket?.address
                    self.showText.text = "connect success with ip:" + ipA!
                }
                
                //发送用户名给服务器（这里使用随机生成的）
                self.sendMessage(msgtosend: "start")
                
                //不断接收服务器发来的消息
                while self.isReciveData{
                    if let msg = readmsg(){
                        DispatchQueue.main.async {
                            self.processMessage(msg: msg)
                            //print("00")
                        }
                    }else{
                        self.isReciveData = false
                        DispatchQueue.main.async {
                            var ipA: String?
                            var portA: Int32?
                            print("test count of socket:")
                            print(self.socketList.count)
                            if self.socketList.count > 0{
                                for i in 0...(self.socketList.count - 1){
                                    if i <= self.socketList.count - 1{
                                        if socket?.address == self.socketList[i]?.address{
                                            self.socketList.remove(at: i)
                                            ipA = socket?.address
                                            portA = socket?.port
                                        }
                                    }
                                }
                                if ipA != nil{
                                    print("timeout... count:" + String(self.socketList.count) + " ip:" + ipA!)
                                    socket?.close()
                                    self.processClientSocket(ip: ipA!, port: portA!)
                                }
                            }
                        }
                        break
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async {
                    self.alert(msg: error.localizedDescription,after: {
                    })
                }
            }
        }
    }
    //“发送消息”按钮点击
    @objc func sendMsg() {
        let content = message.text
        self.sendMessage(msgtosend: content!)
        //showText.text = nil
    }

    //发送消息
    func sendMessage(msgtosend: String){
        let a = msgtosend
        _ = self.socketClient!.send(string: a)
    }

    //处理服务器返回的消息
    func processMessage(msg: String){
        print("test ============= msg")
        print(msg)
    }
    //选择文件
    @objc func chooseNeed(){
        //let url = URL(string: UIApplicationOpenSettingsURLString)
//        let url = URL(string: "")
//        if UIApplication.shared.canOpenURL(url!){
//            UIApplication.shared.openURL(url!)
//        }
    }
    //弹出消息框
    func alert(msg:String,after:()->(Void)){
        let alertController = UIAlertController(title: "",
                                                message: msg,
                                                preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)

        //1.5秒后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            alertController.dismiss(animated: false, completion: nil)
        }
    }
    //返回键控制
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
        //dismiss(animated: true, completion: nil)
    }
    //创建定时器
    func creatTimer(){
        print("start timer...")
        self.timer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(self.timerManager), userInfo: nil, repeats: true)
        RunLoop.current.add(self.timer, forMode: .commonModes)
    }
    //创建定时器管理者
    @objc func timerManager(){
        print("timer...")
        switch self.socketClient!.send(string: "test") {
        case .success:
            if let data = self.socketClient!.read(1024*10){
                if let response = String(bytes: data, encoding: .utf8) {
                    print(response)
                }
            }else {
                print("data is nil")
                    self.timer.invalidate()
                    self.isReciveData = false
                    let ipB = self.socketClient?.address
                    let portB = self.socketClient?.port
                    self.socketClient?.close()
                self.processClientSocket(ip: ipB!, port: portB!)
                    return
            }
        case .failure(let error):
            print(error)
        }
    }
}
