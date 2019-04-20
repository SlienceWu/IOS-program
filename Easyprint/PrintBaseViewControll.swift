//
//  PrintBaseViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/17.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class PrintBaseViewControll: UIViewController {
    @IBOutlet weak var mainView: UIView!
    //菜单栏按键
    @IBOutlet weak var moveView: UIView!
    @IBOutlet weak var tempView: UIView!
    @IBOutlet weak var levelView: UIView!
    @IBOutlet weak var filamentView: UIView!
    @IBOutlet weak var wifiView: UIView!
    @IBOutlet weak var configView: UIView!
    //显示菜单按键
    @IBOutlet weak var showMenuView: UIImageView!
    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var menuViewShadow: UIView!
    //暂停开始
    @IBOutlet weak var startView: UIImageView!
    @IBOutlet weak var stopView: UIImageView!
    
    //温度显示
    @IBOutlet weak var heatbedView: UIView!
    @IBOutlet weak var extruderView: UIView!
    @IBOutlet weak var heatbedTempView: UILabel!
    @IBOutlet weak var extruderTempView: UILabel!
    
    //状态等其他
    @IBOutlet weak var printerStateView: UILabel!
    @IBOutlet weak var modelNameView: UILabel!
    //@IBOutlet weak var printerNameView: UILabel!
    
    let circleView = ProgressView.init(frame: CGRect(x: UIScreen.main.bounds.size.width/2 - 100, y: 100, width: 200, height: 200))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        // Do any additional setup after loading the view, typically from a nib.
        //创建定时器查询打印机状态
        creatTimer()
        //创建圆形进度条
        creatCircleView()
        //上拉导航跳转
        let tapMove = UITapGestureRecognizer(target: self, action: #selector(skipToMove(sender:)))
        moveView.addGestureRecognizer(tapMove)
        let tapTemp = UITapGestureRecognizer(target: self, action: #selector(skipToTemp(sender:)))
        tempView.addGestureRecognizer(tapTemp)
        let tapLevel = UITapGestureRecognizer(target: self, action: #selector(skipToLevel(sender:)))
        levelView.addGestureRecognizer(tapLevel)
        let tapFilament = UITapGestureRecognizer(target: self, action: #selector(skipToFilament(sender:)))
        filamentView.addGestureRecognizer(tapFilament)
        let tapWifi = UITapGestureRecognizer(target: self, action: #selector(skipToWifi(sender:)))
        wifiView.addGestureRecognizer(tapWifi)
        let tapConfig = UITapGestureRecognizer(target: self, action: #selector(skipToConfig(sender:)))
        configView.addGestureRecognizer(tapConfig)
        
        let tapToTemp1 = UITapGestureRecognizer(target: self, action: #selector(skipToTemp(sender:)))
        heatbedView.addGestureRecognizer(tapToTemp1)
        let tapToTemp2 = UITapGestureRecognizer(target: self, action: #selector(skipToTemp(sender:)))
        extruderView.addGestureRecognizer(tapToTemp2)
        //开始暂停
        let tapStart = UITapGestureRecognizer(target: self, action: #selector(startPrint(sender:)))
        startView.addGestureRecognizer(tapStart)
        let tapStop = UITapGestureRecognizer(target: self, action: #selector(stopPrint))
        stopView.addGestureRecognizer(tapStop)
        //显示菜单
        let tapShow = UITapGestureRecognizer(target: self, action: #selector(showMenu))
        showMenuView.addGestureRecognizer(tapShow)
        let tapHidden = UITapGestureRecognizer(target: self, action: #selector(hiddenMenu))
        menuViewShadow.addGestureRecognizer(tapHidden)
        //test
        //PrintBaseViewControll.currentNetReachability()
//        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
//        leftBar.tintColor = UIColor.white
//        self.navigationItem.leftBarButtonItem = leftBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        hiddenMenu()
        PersonInfo.Var.isOpenCH  = false
    }
    override func viewWillAppear(_ animated: Bool) {
        PersonInfo.Var.isOpenCH = true
        //printerNameView.text = PersonInfo.Var.currentMachineName
        self.navigationItem.title = PersonInfo.Var.currentMachineName
        if PersonInfo.Var.currentMachine == ""{
            self.changeProgress(progress: 0)
            self.changeImg(printerImg: "printer_off")
            self.printerStateView.text = ""
            self.heatbedTempView.text = "0°C"
            self.extruderTempView.text = "0°C"
            self.modelNameView.text = ""
            self.startView.image = UIImage(named: "icon_start")
            self.startView.tag = 0
            return
        }
        if PersonInfo.isConnectToServer == 1{
            getList()
        }
    }
    @objc func tapBack(){
        print("test show CH")
        ViewController().showMenu()
    }

    //显示菜单
    @objc func showMenu(){
        menuView.isHidden = false
        menuViewShadow.isHidden = false
    }
    @objc func hiddenMenu(){
        menuView.isHidden = true
        menuViewShadow.isHidden = true
    }
    //开始打印or暂停
    @objc func startPrint(sender: UITapGestureRecognizer){
        if startView.tag == 0{
            let state = PersonInfo.Var.currentMachineState
            if state == "0" || state == "1"{
                return
            }
            if PersonInfo.Var.currentMachineState == "2"{
                if PersonInfo.isClickPrint != 4 && PersonInfo.isClickPrint != 0{
                    PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
                    PersonInfo.shadowView.startTheView()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {PersonInfo.shadowView.stopAndRemoveFromSuperView()
                    })
                    return
                }
                startView.tag = 0
                startView.image = UIImage(named: "icon_start")
                self.tabBarController?.selectedIndex = 1
                return
            }
            if PersonInfo.isClickPrint == 4{
                if PersonInfo.Var.currentMachineState != "2"{
                    PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
                    PersonInfo.shadowView.startTheView()
                    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2, execute: {PersonInfo.shadowView.stopAndRemoveFromSuperView()
                    })
                    return
                }
                self.tabBarController?.selectedIndex = 1
                return
            }
            
            let alert = UIAlertController(title: "", message: "Do you want to start the print job now?", preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in
                PersonInfo.isClickPrint = 3
                self.startView.tag = 1
                self.printerStateView.text = "Printing"
                self.startView.image = UIImage(named: "icon_stop_1")
                self.changePrintState(action: "resume")
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        } else{
            
            let alert = UIAlertController(title: "", message: "Do you want to pause the print job now?", preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in
                PersonInfo.isClickPrint = 2
                self.startView.tag = 0
                self.printerStateView.text = "Pause"
                self.startView.image = UIImage(named: "icon_start")
                self.changePrintState(action: "pause")
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    @objc func stopPrint(){
        let state = PersonInfo.Var.currentMachineState
        if state == "3" || state == "4"{
            let alert = UIAlertController(title: "", message: "Stop printing or not?", preferredStyle: UIAlertControllerStyle.alert)
            let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
            let ok = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {(UIAlertAction) in
                self.changePrintState(action: "stop")
            })
            alert.addAction(cancel)
            alert.addAction(ok)
            self.present(alert, animated: true, completion: nil)
        }
    }
    func changePrintState(action: String){
        
        let token = PersonInfo().token()
        let encryStr = PersonInfo().emailAes()
        let machineNumber = PersonInfo.Var.currentMachine
        let encryStrId = AES_ECB().encypted(need: machineNumber)
        let name = PersonInfo.Var.currentPrintName
        let params = ["action": action, "target": "printer_task", "value": name, "token": token]
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                if action == "stop"{
                    PersonInfo.isClickPrint = 4
                    self.startView.tag = 0
                    self.printerStateView.text = "Online"
                }
            }
        }
    }
    //跳转到移动页面
    @objc func skipToMove(sender: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "move", sender: self)
    }
    //跳转到温度页面
    @objc func skipToTemp(sender: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "temp", sender: self)
    }
    //跳转到调平页面
    @objc func skipToLevel(sender: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "level", sender: self)
    }
    //跳转到挤出头页面
    @objc func skipToFilament(sender: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "filament", sender: self)
    }
    //跳转到Wi-Fi页面
    @objc func skipToWifi(sender: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "wifi", sender: self)
    }
    //跳转到设置页面
    @objc func skipToConfig(sender: UITapGestureRecognizer){
        self.performSegue(withIdentifier: "config", sender: self)
    }
    //创建轮播图定时器
    func creatTimer(){
        let timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerManager), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    //创建定时器管理者
    @objc func timerManager(){
        if PersonInfo().state() == "logout" || PersonInfo().state() == ""{
            return
        }
        if PersonInfo.Var.currentMachine == "" && PersonInfo.isConnectToServer == 1{
            getList()
        }
        getPrinterState()
    }
    func getList(){
        let encryStr = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let url = Url.baseUsers + encryStr + "/printers?token=" + token
        Alamofire.request(url, method: .get).responseJSON{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                let value = response.result.value as Any
                let json = JSON(value)
                let first = json[0]["serial_num"].stringValue
                PersonInfo.Var.currentMachineList = json
                if PersonInfo.Var.currentMachine == ""{
                    PersonInfo.Var.currentMachine = first
                    PersonInfo.Var.currentMachineName = json[0]["name"].stringValue
                    self.navigationItem.title = PersonInfo.Var.currentMachineName
                    self.getImg()
                }                
            } else {
                if code == nil{
                    return
                }
                ResponseError().error(target: self, code: code!)
            }
        }
    }
    func getImg(){
        let encryStrId = AES_ECB().encypted(need: PersonInfo.Var.currentMachine)
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printers/" + encryStrId + "/image?token=" + PersonInfo().token()
        Alamofire.request(url).response{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.data as Any)
                PersonInfo.Var.currentMachineImg = json["image"].stringValue
            }
        }
    }
    func getPrinterState(){
        let machineNumber = PersonInfo.Var.currentMachine
        if machineNumber == ""{
            //printerNameView.text = ""
            self.navigationItem.title = ""
            printerStateView.text = "Unbind"
            return
        }
        if PersonInfo.isConnectToServer != 1{
            self.changeProgress(progress: 0)
            self.changeImg(printerImg: "printer_off")
            self.printerStateView.text = "Offline"
            self.heatbedTempView.text = "0°C"
            self.extruderTempView.text = "0°C"
            return
        }
        let token = PersonInfo().token()
        let encryStr = PersonInfo().emailAes()
        let encryStrId = AES_ECB().encypted(need: machineNumber)
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId + "?token=" + token
        AlamofireCustom.alamofireFast.request(url, method: .get).responseJSON{
            (response) in
            let code = response.response?.statusCode
            if code == 200{
                let value = response.result.value as Any
                let json = JSON(value)
                PersonInfo.Var.currentMachineState = json["state"].stringValue
                if PersonInfo.Var.currentMachineState == "0" || PersonInfo.Var.currentMachineState == "1"{
                    self.changeProgress(progress: 0)
                    self.changeImg(printerImg: "printer_off")
                    self.printerStateView.text = "Offline"
                    self.heatbedTempView.text = "0°C"
                    self.extruderTempView.text = "0°C"
                    self.modelNameView.text = ""
                    self.startView.image = UIImage(named: "icon_start")
                    self.startView.tag = 0
                    PersonInfo().initTemp()
                    return
                } else if json["state"].stringValue == "2"{
                    if PersonInfo.isClickPrint == 1{
                        self.printerStateView.text = "Please wait to print..."
                        self.startView.tag = 1
                        self.startView.image = UIImage(named: "icon_stop_1")
                    }else if PersonInfo.isClickPrint == 2{
                        self.startView.tag = 0
                    }else{
                        PersonInfo.isClickPrint = 0
                        self.printerStateView.text = "Online"
                        self.startView.tag = 0
                        self.startView.image = UIImage(named: "icon_start")
                    }
                } else if json["state"].stringValue == "3"{
                    if PersonInfo.isClickPrint != 4{
                        if PersonInfo.isClickPrint == 2{
                            self.printerStateView.text = "Pause"
                            self.startView.tag = 0
                            self.startView.image = UIImage(named: "icon_start")
                        }else{
                            PersonInfo.isClickPrint = 0
                            self.printerStateView.text = "Printing"
                            self.startView.tag = 1
                            self.startView.image = UIImage(named: "icon_stop_1")
                        }
                    }
                } else if json["state"].stringValue == "4"{
                    if PersonInfo.isClickPrint != 4{
                        if PersonInfo.isClickPrint == 3{
                            self.printerStateView.text = "Printing"
                            self.startView.tag = 1
                            self.startView.image = UIImage(named: "icon_stop_1")
                        } else{
                            PersonInfo.isClickPrint = 0
                            self.printerStateView.text = "Pause"
                            self.startView.tag = 0
                            self.startView.image = UIImage(named: "icon_start")
                        }
                    }
                }
                let avatar = PersonInfo.Var.currentMachineImg
                if avatar == ""{
                    if machineNumber.contains("E180"){
                        self.changeImg(printerImg: "icon_e180")
                    } else if machineNumber.contains("A30"){
                        self.changeImg(printerImg: "icon_a30")
                    } else if machineNumber.contains("D200"){
                        self.changeImg(printerImg: "icon_d200")
                    } else if machineNumber.contains("3DWF"){
                        self.changeImg(printerImg: "icon_3dwifi")
                    }
                }else{
                    self.changeImg(printerImg: avatar)
                }
                
                PersonInfo.Var.extruderSetTemp = json["extruder_setting_temp"].stringValue
                PersonInfo.Var.currentExtruderTemp = json["extruder_current_temp"].stringValue
                PersonInfo.Var.hotBedSetTemp = json["bed_setting_temp"].stringValue
                PersonInfo.Var.currentHotBedTemp = json["bed_current_temp"].stringValue
                PersonInfo.Var.taskState = json["task_state"].stringValue
                PersonInfo.Var.taskFileName = json["task_file"].stringValue
                PersonInfo.Var.taskFileUploaded = Int((json["task_file_uploaded"].stringValue as NSString).intValue)
                PersonInfo.Var.taskFileLength = Int((json["task_file_length"].stringValue as NSString).intValue)
                PersonInfo.Var.currentProgress = Int((json["progress"].stringValue as NSString).doubleValue * 100)
                self.changeProgress(progress: PersonInfo.Var.currentProgress)
                self.heatbedTempView.text = json["bed_current_temp"].stringValue + "°C"
                self.extruderTempView.text = json["extruder_current_temp"].stringValue + "°C"
                self.modelNameView.text = json["printing_file"].stringValue
            } else{
                if code != nil{
                    ResponseError().error(target: self, code: code!)
                }
            }
            if response.result.isFailure{
                let code = (response.result.error! as NSError).code
                if code == -1001 || code == -999{
                    print("=====test timeout=====")
                }
            }
        }
    }
    //创建圆环进度条
    func creatCircleView(){
        self.mainView.addSubview(circleView)
        self.circleView.value = 0
        self.circleView.maximumValue = 100
        self.circleView.backgroundImage = "printer_off"
        self.circleView.backgroundColor = UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        self.circleView.frame = CGRect(x: UIScreen.main.bounds.size.width/2 - 100, y: 38, width: 200, height: 200)
    }
    //修改进度及图片
    func changeProgress(progress: Int){
        self.circleView.value = CGFloat(progress)
    }
    func changeImg(printerImg: String){        
        self.circleView.backgroundImage = printerImg
    }
    
    //获取网络变化
    class func currentNetReachability() {
        let manager = NetworkReachabilityManager(host: "www.apple.com")
        manager?.listener = { status in
            var statusStr: String?
            switch status {
            case .unknown:
                statusStr = "未识别的网络"
                break
            case .notReachable:
                statusStr = "不可用的网络(未连接)"
            case .reachable:
                if (manager?.isReachableOnWWAN)! {
                    statusStr = "2G,3G,4G...的网络"
                } else if (manager?.isReachableOnEthernetOrWiFi)! {
                    statusStr = "wifi的网络";
                }
                break
            }
            print(statusStr as Any)
        }
        manager?.startListening()
    }
}

//获取当前view controller
extension UIViewController{
    class func currentViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController?{
        if let nav = base as? UINavigationController{
            return currentViewController(base: nav.visibleViewController)
        }
        if let tab = base as? UITabBarController{
            return currentViewController(base: tab.selectedViewController)
        }
        
        if let presented = base?.presentedViewController{
            return currentViewController(base: presented)
        }
        return base
    }
}
