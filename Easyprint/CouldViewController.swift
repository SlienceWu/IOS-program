//
//  CouldViewController.swift
//  Easyprint
//
//  Created by app on 2018/6/28.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import DNSPageView
import Alamofire
import SwiftyJSON

class CouldViewController: UIViewController, UIScrollViewDelegate{
    //文件列表
    var SDFileList = [String]()
    var WifiFileList = [String]()
    
    @IBOutlet weak var testView: UIView!
    @IBOutlet weak var titleView: DNSPageTitleView!
    @IBOutlet weak var contentView: DNSPageContentView!
    @IBOutlet weak var heightView: UIView!
    
    let width = UIScreen.main.bounds.size.width
    let mainHeight = UIScreen.main.bounds.size.height
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyAdjustsScrollViewInsets = false
        
        // Do any additional setup after loading the view, typically from a nib.
        // 创建DNSPageStyle，设置样式
        let style = DNSPageStyle()
        style.titleViewBackgroundColor = UIColor.white
        style.isShowCoverView = false
        style.titleMargin = 0
        style.titleViewHeight = 0
        style.isShowBottomLine = true
        
        // 设置标题内容
        let titles = ["Cloud", "SD card", "3DWiFi"]
        
        // 设置默认的起始位置
        let startIndex = 0
        
        // 对titleView进行设置
        titleView.titles = titles
        titleView.style = style
        titleView.currentIndex = startIndex
        
        // 最后要调用setupUI方法
        titleView.setupUI()
        print(titleView.bounds.size.height)
        // 创建每一页对应的controller
        let childViewControllers: [UIViewController] = titles.map { a -> UIViewController in
            let controller = UIViewController()
            
            if a == "Cloud"{
                let couldView = couldScrollView()
                AlamofireCustom.alamofireManager.request(Url.bannerPath, method: .get).responseJSON{
                    (response)in
                    if response.result.isFailure{
                        couldView.creatCouldScrollView(imageNames: ["icon_error", "icon_error", "icon_error"], width: self.width, height: controller.view.bounds.height, target: self)
                        controller.view.addSubview(couldView)
                        return
                    }
                    let code = response.response?.statusCode
                    if code == 200{
                        if let json = response.result.value{
                            let list = json as![Any]
                            var imageNames = [String]() //"printer_off","icon_default_avatar"
                            for i in 0...(list.count-1){
                                let imgList = list[i] as! [String: AnyObject]
                                let imgUrl = imgList["image_path"] as! String
                                imageNames.append(imgUrl)
                            }
                            couldView.creatCouldScrollView(imageNames: imageNames, width: self.width, height: controller.view.bounds.height, target: self)
                            controller.view.addSubview(couldView)
                        }
                    }
                }
            }

            switch a{
                case "Could" :
                    controller.view.backgroundColor = UIColor.white;
                case "SD card" :
                    controller.view.subviews.forEach({$0.removeFromSuperview()})
                    controller.view.addSubview(fileSDList())
                    controller.view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1);
                case "3DWiFi" :
                    controller.view.subviews.forEach({$0.removeFromSuperview()})
                    controller.view.addSubview(fileWifiList())
                    controller.view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1);
                default:
                    controller.view.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1);
            }
            return controller
        }
        
        // 对contentView进行设置
        contentView.childViewControllers = childViewControllers
        contentView.startIndex = startIndex
        contentView.style = style
        
        // 最后要调用setupUI方法
        contentView.setupUI()
        
        // 让titleView和contentView进行联系起来
        titleView.delegate = contentView
        contentView.delegate = titleView
    }
    override func viewWillAppear(_ animated: Bool) {
        if PersonInfo().state() == "logout" || PersonInfo.Var.currentMachine == ""{
            self.contentView.childViewControllers[1].view.subviews.forEach({$0.removeFromSuperview()})
            self.contentView.childViewControllers[2].view.subviews.forEach({$0.removeFromSuperview()})
        } else{
            self.contentView.childViewControllers[1].view.addSubview(self.fileSDList())
            self.contentView.childViewControllers[2].view.addSubview(self.fileWifiList())
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //打印机文件列表
    func fileSDList() -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 8, width: width, height: 50)
        view.backgroundColor = UIColor.white
        let fileImg = UIImageView()
        fileImg.image = UIImage(named: "icon_file")
        fileImg.frame = CGRect(x: 8, y: 10, width: 30, height: 30)
        view.addSubview(fileImg)
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 50, y: 0, width: 160, height: 50)
        let name = PersonInfo.Var.currentMachineName
        nameLabel.text = name
        view.addSubview(nameLabel)
        let refreshView = UIImageView()
        refreshView.frame = CGRect(x: width - 50, y: 10, width: 30, height: 30)
        refreshView.image = UIImage(named: "icon_refresh")
        refreshView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(getSDFileList))
        refreshView.addGestureRecognizer(tap)
        view.addSubview(refreshView)
        return view
    }
    func fileWifiList() -> UIView {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 8, width: width, height: 50)
        view.backgroundColor = UIColor.white
        let fileImg = UIImageView()
        fileImg.image = UIImage(named: "icon_file")
        fileImg.frame = CGRect(x: 8, y: 10, width: 30, height: 30)
        view.addSubview(fileImg)
        let nameLabel = UILabel()
        nameLabel.frame = CGRect(x: 50, y: 0, width: 160, height: 50)
        let name = "3DWiFi"
        nameLabel.text = name
        view.addSubview(nameLabel)
        let refreshView = UIImageView()
        refreshView.frame = CGRect(x: width - 50, y: 10, width: 30, height: 30)
        refreshView.image = UIImage(named: "icon_refresh")
        refreshView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(getWifiFileList))
        refreshView.addGestureRecognizer(tap)
        view.addSubview(refreshView)

        return view
    }
    
    //获取打印机文件
    @objc func getSDFileList(){
        if PersonInfo.Var.currentMachineState == "0" || PersonInfo.Var.currentMachineState == "1"{
            self.present(Alert().singleAlert(message: "Printer is offline."), animated: true, completion: nil)
            return
        }
        self.SDFileList.removeAll()
        self.contentView.childViewControllers[1].view.subviews.forEach({$0.removeFromSuperview()})
        self.contentView.childViewControllers[1].view.addSubview(self.fileSDList())
        
        getRefreshList(position: "sds")
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            let encryStr = PersonInfo().emailAes()
            let encryStrId = AES_ECB().encypted(need: PersonInfo.Var.currentMachine)
            let token = PersonInfo().token()
            let url = Url.baseUsers + encryStr + "/printers/" + encryStrId + "/sds?token=" + token
            
            AlamofireCustom.alamofireManager.request(url).responseJSON{
                (response) in
                PersonInfo.shadowView.stopAndRemoveFromSuperView()
                let code = response.response?.statusCode
                if code == 410{
                    self.present(Alert().singleAlert(message: "SD card exception."), animated: true, completion: nil)
                    return
                } else if code == 200{
                    let value = response.result.value as Any
                    let list = JSON(value)
                    let scrollView = UIScrollView()
                    if list.count == 0{
                        return
                    }
                    for i in 0...(list.count - 1){
                        self.SDFileList.append(list[i]["file_name"].stringValue)
                        let view = UIView()
                        view.frame = CGRect(x: 0, y: 50 * i + 1, width: Int(self.width), height: 50)
                        view.backgroundColor = UIColor.white
                        let labelName = UILabel()
                        labelName.frame = CGRect(x: 0, y: 0, width: self.width - 100, height: 50)
                        labelName.text = "  " + list[i]["file_name"].stringValue
                        
                        let imgPrint = UIImageView()
                        imgPrint.frame = CGRect(x: labelName.bounds.size.width + 10, y: 10, width: 30, height: 30)
                        imgPrint.image = UIImage(named: "icon_print_start")
                        let tapPrint = UITapGestureRecognizer(target: self, action: #selector(self.SDPrint(sender:)))
                        imgPrint.isUserInteractionEnabled = true
                        imgPrint.tag = i
                        imgPrint.addGestureRecognizer(tapPrint)
                        
                        let imgDelete = UIImageView()
                        imgDelete.frame = CGRect(x: labelName.bounds.size.width + 50, y: 0, width: 50, height: 50)
                        imgDelete.image = UIImage(named: "icon_file_delete")
                        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(self.SDDelete(sender:)))
                        imgDelete.isUserInteractionEnabled = true
                        imgDelete.tag = i
                        imgDelete.addGestureRecognizer(tapDelete)
                        
                        view.addSubview(labelName)
                        view.addSubview(imgPrint)
                        view.addSubview(imgDelete)
                        scrollView.addSubview(view)
                    }
                    scrollView.frame = CGRect(x: 0, y: 60, width: self.width, height: self.contentView.bounds.size.height - 60)
                    scrollView.contentSize = CGSize(width: self.width, height: CGFloat(Float(50 * list.count)))
                    self.contentView.childViewControllers[1].view.subviews.forEach({$0.removeFromSuperview()})
                    self.contentView.childViewControllers[1].view.addSubview(self.fileSDList())
                    self.contentView.childViewControllers[1].view.addSubview(scrollView)
                } else {
                    if code == nil{
                        return
                    }
                    ResponseError().error(target: self, code: code!)
                }
            }
        })
    }
    @objc func getWifiFileList(){
        if PersonInfo.Var.currentMachineState == "0" || PersonInfo.Var.currentMachineState == "1"{
            self.present(Alert().singleAlert(message: "Printer is offline."), animated: true, completion: nil)
            return
        }
        self.WifiFileList.removeAll()
        self.contentView.childViewControllers[2].view.subviews.forEach({$0.removeFromSuperview()})
        self.contentView.childViewControllers[2].view.addSubview(self.fileWifiList())
        
        getRefreshList(position: "boxsds")
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3, execute: {
            let encryStr = PersonInfo().emailAes()
            let encryStrId = AES_ECB().encypted(need: PersonInfo.Var.currentMachine)
            let token = PersonInfo().token()
            let url = Url.baseUsers + encryStr + "/printers/" + encryStrId + "/boxsds?token=" + token
            Alamofire.request(url).responseJSON{
                (response) in
                PersonInfo.shadowView.stopAndRemoveFromSuperView()
                let code = response.response?.statusCode
                if code == 410{
                    self.present(Alert().singleAlert(message: "SD card exception."), animated: true, completion: nil)
                    return
                } else if code == 200{
                    let value = response.result.value as Any
                    let list = JSON(value)
                    let scrollView = UIScrollView()
                    if list.count == 0{
                        return
                    }
                    for i in 0...(list.count - 1){
                        self.WifiFileList.append(list[i]["file_name"].stringValue)
                        let view = UIView()
                        view.frame = CGRect(x: 0, y: 50 * i + 1, width: Int(self.width), height: 50)
                        view.backgroundColor = UIColor.white
                        let labelName = UILabel()
                        labelName.frame = CGRect(x: 0, y: 0, width: self.width - 100, height: 50)
                        labelName.text = "  " + list[i]["file_name"].stringValue
                        
                        let imgPrint = UIImageView()
                        imgPrint.frame = CGRect(x: labelName.bounds.size.width + 10, y: 10, width: 30, height: 30)
                        imgPrint.image = UIImage(named: "icon_print_start")
                        let tapPrint = UITapGestureRecognizer(target: self, action: #selector(self.WifiPrint(sender:)))
                        imgPrint.isUserInteractionEnabled = true
                        imgPrint.tag = i
                        imgPrint.addGestureRecognizer(tapPrint)
                        
                        let imgDelete = UIImageView()
                        imgDelete.frame = CGRect(x: labelName.bounds.size.width + 50, y: 0, width: 50, height: 50)
                        imgDelete.image = UIImage(named: "icon_file_delete")
                        let tapDelete = UITapGestureRecognizer(target: self, action: #selector(self.WifiDelete(sender:)))
                        imgDelete.isUserInteractionEnabled = true
                        imgDelete.tag = i
                        imgDelete.addGestureRecognizer(tapDelete)
                        
                        view.addSubview(labelName)
                        view.addSubview(imgPrint)
                        view.addSubview(imgDelete)
                        scrollView.addSubview(view)
                    }
                    scrollView.frame = CGRect(x: 0, y: 60, width: self.width, height: self.contentView.bounds.size.height - 60)
                    scrollView.contentSize = CGSize(width: self.width, height: CGFloat(Float(50 * list.count)))
                    self.contentView.childViewControllers[2].view.subviews.forEach({$0.removeFromSuperview()})
                    self.contentView.childViewControllers[2].view.addSubview(self.fileWifiList())
                    self.contentView.childViewControllers[2].view.addSubview(scrollView)
                } else {
                    if code == nil{
                        return
                    }
                    ResponseError().error(target: self, code: code!)
                }
            }
        })
    }
    //列表刷新
    func getRefreshList(position: String){
        
        let encryStr = PersonInfo().emailAes()
        let encryStrId = AES_ECB().encypted(need: PersonInfo.Var.currentMachine)
        let token = PersonInfo().token()
        let params = ["action": "refresh", "target": "printer_sd", "token": token]
        let url = Url.baseUsers + encryStr + "/printers/" + encryStrId + "/" + position
        print(position, url)
        Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            (response) in
            
        }
    }
    
    //开始打印及删除文件
    @objc func SDPrint(sender: UITapGestureRecognizer){
        let view = sender.view
        let need = view?.tag
        skipToPrint(position: "sd", tag: need!)
    }
    @objc func WifiPrint(sender: UITapGestureRecognizer){
        let view = sender.view
        let need = view?.tag
        skipToPrint(position: "wifi", tag: need!)
    }
    @objc func SDDelete(sender: UITapGestureRecognizer){
        let view = sender.view
        let need = view?.tag
        deleteFile(position: "sd", tag: need!)
    }
    @objc func WifiDelete(sender: UITapGestureRecognizer){
        let view = sender.view
        let need = view?.tag
        deleteFile(position: "wifi", tag: need!)
    }
    
    func skipToPrint(position: String, tag: Int){
        if PersonInfo.Var.currentMachineState != "2"{
            if PersonInfo.Var.currentMachineState == "3" || PersonInfo.Var.currentMachineState == "4"{
                self.present(Alert().singleAlert(message: "Printer is printing."), animated: true, completion: nil)
            }
            return
        }
        let alert = UIAlertController(title: "", message: "Are you sure to print this model now?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            let encryStr = PersonInfo().emailAes()
            let encryStrId = AES_ECB().encypted(need: PersonInfo.Var.currentMachine)
            var params:[String: String]
            if position == "wifi"{
                print(self.WifiFileList[tag])
                params = ["action": "start", "target": "printer_task", "value": self.WifiFileList[tag] + "3D", "token": PersonInfo().token()]
            } else{
                print(self.SDFileList[tag])
                params = ["action": "start", "target": "printer_task", "value": self.SDFileList[tag], "token": PersonInfo().token()]
            }
            let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
                let code = response.response?.statusCode
                if code == 200{
                    PersonInfo.isClickPrint = 1
                    self.tabBarController?.selectedIndex = 0
                } else{
                    if code == nil{
                        return
                    }
                    ResponseError().error(target: self, code: code!)
                }
            }
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    func deleteFile(position: String, tag: Int){
        if PersonInfo.Var.currentMachineState != "2"{
            if PersonInfo.Var.currentMachineState == "3" || PersonInfo.Var.currentMachineState == "4"{
                self.present(Alert().singleAlert(message: "Printer is printing."), animated: true, completion: nil)
            } else{
                
            }
            return
        }
        let alert = UIAlertController(title: "", message: "Are you sure to delete this model now?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            let encryStr = PersonInfo().emailAes()
            let encryStrId = AES_ECB().encypted(need: PersonInfo.Var.currentMachine)
            var params:[String: String]
            if position == "wifi"{
                print(self.WifiFileList[tag])
                params = ["action": "delete", "target": "printer_sd_file", "value": self.WifiFileList[tag], "token": PersonInfo().token()]
            } else{
                print(self.SDFileList[tag])
                params = ["action": "delete", "target": "printer_sd_file", "value": self.SDFileList[tag], "token": PersonInfo().token()]
            }
            let url = Url.baseUsers + encryStr + "/printers/" + encryStrId
            Alamofire.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
                (response) in
                let code = response.response?.statusCode
                if code == 200{
                    if position == "wifi"{
                        self.WifiFileList.remove(at: tag)
                        self.showList(position: "wifi", tag: 2)
                    } else{
                        self.SDFileList.remove(at: tag)
                        self.showList(position: "sd", tag: 1)
                    }
                } else{
                    if code == nil{
                        return
                    }
                    ResponseError().error(target: self, code: code!)
                }
            }

        })
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
        if position == "wifi"{
            print(WifiFileList[tag])
        } else{
            print(SDFileList[tag])
        }
    }
    //列表展示
    func showList(position: String, tag: Int){
        self.contentView.childViewControllers[tag].view.subviews.forEach({$0.removeFromSuperview()})
        
        var list:[String]
        if position == "wifi"{
            list = self.WifiFileList
            self.contentView.childViewControllers[tag].view.addSubview(self.fileWifiList())
        } else {
            list = self.SDFileList
            self.contentView.childViewControllers[tag].view.addSubview(self.fileSDList())

        }
        
        if list.count == 0{
            return
        }
        let scrollView = UIScrollView()
        for i in 0...(list.count - 1){
            let view = UIView()
            view.frame = CGRect(x: 0, y: 50 * i + 1, width: Int(self.width), height: 50)
            view.backgroundColor = UIColor.white
            let labelName = UILabel()
            labelName.frame = CGRect(x: 0, y: 0, width: self.width - 100, height: 50)
            labelName.text = "  " + list[i]
            
            let imgPrint = UIImageView()
            imgPrint.frame = CGRect(x: labelName.bounds.size.width + 10, y: 10, width: 30, height: 30)
            imgPrint.image = UIImage(named: "icon_print_start")
            var tapPrint = UITapGestureRecognizer()
            if position == "wifi"{
                tapPrint = UITapGestureRecognizer(target: self, action: #selector(self.WifiPrint(sender:)))
            } else{
                tapPrint = UITapGestureRecognizer(target: self, action: #selector(self.SDPrint(sender:)))
            }
            imgPrint.isUserInteractionEnabled = true
            imgPrint.tag = i
            imgPrint.addGestureRecognizer(tapPrint)
            
            let imgDelete = UIImageView()
            imgDelete.frame = CGRect(x: labelName.bounds.size.width + 50, y: 0, width: 50, height: 50)
            imgDelete.image = UIImage(named: "icon_file_delete")
            var tapDelete = UITapGestureRecognizer()
            if position == "wifi"{
                tapDelete = UITapGestureRecognizer(target: self, action: #selector(self.WifiDelete(sender:)))
            } else{
                tapDelete = UITapGestureRecognizer(target: self, action: #selector(self.SDDelete(sender:)))
            }
            imgDelete.isUserInteractionEnabled = true
            imgDelete.tag = i
            imgDelete.addGestureRecognizer(tapDelete)
            
            view.addSubview(labelName)
            view.addSubview(imgPrint)
            view.addSubview(imgDelete)
            scrollView.addSubview(view)
        }
        scrollView.frame = CGRect(x: 0, y: 60, width: self.width, height: self.contentView.bounds.size.height - 60)
        scrollView.contentSize = CGSize(width: self.width, height: CGFloat(Float(50 * list.count)))
        self.contentView.childViewControllers[tag].view.subviews.forEach({$0.removeFromSuperview()})
        if position == "wifi"{
            self.contentView.childViewControllers[tag].view.addSubview(self.fileWifiList())
        }else{
            self.contentView.childViewControllers[tag].view.addSubview(self.fileSDList())
        }
        self.contentView.childViewControllers[tag].view.addSubview(scrollView)
    }
    
    //跳转传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "modelList"{
            let controller = segue.destination as! ModelListViewControll
            controller.categoryID = sender as? String
        }
    }
}
