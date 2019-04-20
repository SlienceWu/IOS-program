//
//  MyPrinterViewControll.swift
//  Easyprint
//
//  Created by app on 2018/7/12.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class MyPrinterViewControll: UIViewController {
    @IBOutlet weak var mainScrollView: UIScrollView!
    //传值参数
    var listCount: Int?
    
    let width = UIScreen.main.bounds.size.width
    let height = UIScreen.main.bounds.size.height
    
    var listId = [String]()
    var listName = [String]()
    let scrollView = UIScrollView()
    var all = CGFloat()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidAppear(_ animated: Bool) {

    }
    override func viewWillAppear(_ animated: Bool) {
        if PersonInfo.isConnectToServer != 1{
            return
        }
        listId.removeAll()
        listName.removeAll()
        getList()
    }
    //获取打印机列表
    func getList(){
        if PersonInfo().state() == "logout"{
            self.mainScrollView.isHidden = true
            return
        }
        self.view.backgroundColor = UIColor.white
        self.mainScrollView.isHidden = false
        self.mainScrollView.subviews.forEach({$0.removeFromSuperview()})
        let encryStr = PersonInfo().emailAes()
        let token = PersonInfo().token()
        let url = Url.baseUsers + encryStr + "/printersinfo?token=" + token
        PersonInfo.shadowView.initWithIndicatorWithView(view: self.view, withText: "please wait.")
        PersonInfo.shadowView.startTheView()
        AlamofireCustom.alamofireManager.request(url).responseJSON{
            (response) in
            PersonInfo.shadowView.stopAndRemoveFromSuperView()
            let code = response.response?.statusCode
            if code == 200{
                let value = response.result.value as Any
                let list = JSON(value)
                let viewList = UIView()
                viewList.frame = CGRect(x: 0, y: 0, width: Int(self.width), height: 50 * (list.count))
                if list.count > 0{
                    for i in 0...(list.count-1){
                        self.listName.append(list[i]["name"].stringValue)
                        self.listId.append(list[i]["serial_num"].stringValue)
                        
                        let state = list[i]["state"].stringValue
                        let view = UIView()
                        let labelName = UILabel()
                        let border = UIView()
                        let image = UIImageView()
                        view.frame = CGRect(x: 16, y: 50 * i, width: Int(self.width - 32), height: 50)
                        view.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
                        border.frame = CGRect(x: 0, y: 48, width: Int(view.bounds.size.width), height: 2)
                        border.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1)
                        image.frame = CGRect(x: 0, y: 12, width: 24, height: 24)
                        if state != "0" && state != "1"{
                            image.image = UIImage(named: "icon_enable")
                        } else{
                            image.image = UIImage(named: "icon_unable")
                        }
                        labelName.frame = CGRect(x: 30, y: 0, width: Int(self.width - 92), height: 50)
                        labelName.text = list[i]["name"].stringValue
                        
                        let moreView = self.moreView(number: i)
                        view.addSubview(image)
                        view.addSubview(labelName)
                        view.addSubview(moreView)
                        view.addSubview(border)
                        let tapEdit = UITapGestureRecognizer(target: self, action: #selector(self.skipToEdit(sender:)))
                        view.tag = i
                        view.addGestureRecognizer(tapEdit)
                        viewList.addSubview(view)
                    }
                    self.mainScrollView.addSubview(viewList)
                    let btnView = self.btnView(height: (Int(viewList.bounds.size.height + 20)), color: "")
                    self.mainScrollView.addSubview(btnView)
                    
                    self.all = viewList.bounds.size.height + 20 + btnView.bounds.size.height
                    self.mainScrollView.contentSize = CGSize(width: self.width, height: self.all)
                    self.mainScrollView.bounces = true
                    
                } else{
                    self.view.backgroundColor = UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1)
                    self.mainScrollView.isHidden = true
                }
                return
            }else{
                if code != nil{
                    self.mainScrollView.isHidden = true
                    self.view.backgroundColor = UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1)
                    ResponseError().error(target: self, code: code!)
                    return
                }
            }
            if response.result.isFailure{
                self.mainScrollView.isHidden = true
                self.view.backgroundColor = UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1)
                let code = (response.result.error! as NSError).code
                ResponseError().errorNScode(target: self, code: code)
            }
        }
    }
    //绑定
    func btnView(height: Int, color: String) ->UIButton{
        let btn = UIButton()
        if color != "white"{
            btn.backgroundColor = UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1)
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.setTitle("+ Bind New Printer", for: .normal)
        } else{
            btn.backgroundColor = UIColor.init(red: 1, green: 1, blue: 1, alpha: 1)
            btn.setTitleColor(UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1), for: .normal)
            btn.setTitle("Start to bind", for: .normal)
        }
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.isEnabled = true
        btn.setTitleColor(UIColor.blue, for: .highlighted)
        btn.setTitleColor(UIColor.cyan, for: .selected)
        btn.setTitleColor(UIColor.cyan, for: .disabled)
        btn.setTitleShadowColor(UIColor.cyan, for: .normal)
        btn.setTitleShadowColor(UIColor.green, for: .highlighted)
        btn.setTitleShadowColor(UIColor.brown, for: .selected)
        btn.setTitleShadowColor(UIColor.darkGray, for: .disabled)
        btn.frame = CGRect(x: 16, y: height, width: Int(width - 32), height: 50)
        btn.addTarget(self, action: #selector(skipToBind), for: UIControlEvents.touchUpInside)
        return btn
    }
    //未绑定页面
    func noBindView() -> UIView{
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        let img = UIImageView()
        img.frame = CGRect(x: self.width/2 - 100, y: 128, width: 200, height: 200)
        img.image = UIImage(named: "printer_off")
        view.addSubview(img)
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 342, width: self.width, height: 30)
        label.text = "No  3D printers found..."
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 15)
        label.textAlignment = NSTextAlignment.center
        view.addSubview(label)
        let btn = btnView(height: 382, color: "white")
        view.addSubview(btn)
        view.backgroundColor = UIColor.init(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        return view
    }
    //跳转到打印机详情页
    func moreView(number: Int) ->UIImageView{
        let moreView = UIImageView()
        moreView.frame = CGRect(x: Int(self.width - 52), y: 15, width: 10, height: 20)
        moreView.image = UIImage(named: "icon_more")
        return moreView
    }
    //跳转到绑定页
    @objc func skipToBind(){
        self.performSegue(withIdentifier: "bindPrinter", sender: self)
    }
    //跳转到详情页
    @objc func skipToEdit(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        skipToDetail(event: [self.listName[tag!],self.listId[tag!]])
    }
    func skipToDetail(event: [String]){
        self.performSegue(withIdentifier: "printerDetail", sender: event)
    }
    //返回
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    //跳转传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "printerDetail"{
            let controller = segue.destination as! PrinterDetailViewControll
            let array:[String] = sender as! [String]
            controller.printerName = array[0]
            controller.printerId = array[1]
        }
    }
}
