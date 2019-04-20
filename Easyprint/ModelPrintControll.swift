//
//  ModelPrintControll.swift
//  Easyprint
//
//  Created by app on 2018/9/4.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import Starscream

class ModelPrintControll: UIViewController, UITextFieldDelegate {
    //传值参数
    var modelName: String?
    var modelUrl: String?
    var modelStl: String?
    var modelId: String?
    //默认参数
    var mSupport = true
    var mFlow = "250"
    var mScale = "100"
    //模型长宽高
    var mDepth = "0"
    var mWidth = "0"
    var mHeight = "0"
    var imgCheck = UIImageView()
    var textfieldFlow = UITextField()
    var textfieldScale = UITextField()
    var mSize = UILabel()
    //选中列表参数
    var arrayPProfileDetail: JSON?
    var arrayMProfileDetail: JSON?
    //列表
    var viewList1 = UIView()
    var viewList2 = UIView()
    var viewList3 = UIView()
    var array1: JSON?
    var array2: JSON?
    var array3: JSON?
    @IBOutlet weak var partChoose1: UIView!
    @IBOutlet weak var partLabel1: UILabel!
    @IBOutlet weak var bindPrinter: UIButton!
    @IBOutlet weak var partChoose2: UIView!
    @IBOutlet weak var partLabel2: UILabel!
    @IBOutlet weak var addPprofile: UIButton!
    @IBOutlet weak var partChoose3: UIView!
    @IBOutlet weak var partLabel3: UILabel!
    @IBOutlet weak var addMprofile: UIButton!
    
    @IBOutlet weak var partView4: UIView!
    var isShowAdvance = false
    @IBOutlet weak var addSetBtn: UIButton!
    @IBOutlet weak var draftBtn: UIView!
    @IBOutlet weak var draftIcon: UIImageView!
    @IBOutlet weak var normalBtn: UIView!
    @IBOutlet weak var normalIcon: UIImageView!
    @IBOutlet weak var bestBtn: UIView!
    @IBOutlet weak var bestIcon: UIImageView!
    //默认质量
    var isChooseQuality = "normal"
    //websocket 47.88.84.109:3389
    var socket = WebSocket(url: URL(string: "ws://192.168.1.247:5000/")!, protocols: ["chat"])
    //创建轮播图定时器
    var timer = Timer()
    //切片进度视图
    var progressView1 = UIView()
    var progressView2 = UIView()
    var progressView3 = UIView()
    
    @IBOutlet weak var stlImg: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.title = "ModelDetail"
        //点击任意处键盘收回
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap(sender:))))
        //模型图片展示
        let url = URL(string: modelUrl!)
        stlImg.kf.setImage(with: url)
        //添加第五部分视图
        let view = modelScale()
        self.scrollView.addSubview(view)
        //选择是否展示支撑选项
        let tap = UITapGestureRecognizer(target: self, action: #selector(showSetting))
        addSetBtn.addGestureRecognizer(tap)
        //选择质量
        let tap1 = UITapGestureRecognizer(target: self, action: #selector(chooseQuality(sender:)))
        draftBtn.tag = 41
        draftBtn.addGestureRecognizer(tap1)
        let tap2 = UITapGestureRecognizer(target: self, action: #selector(chooseQuality(sender:)))
        normalBtn.tag = 42
        normalBtn.addGestureRecognizer(tap2)
        let tap3 = UITapGestureRecognizer(target: self, action: #selector(chooseQuality(sender:)))
        bestBtn.tag = 43
        bestBtn.addGestureRecognizer(tap3)
        //跳转添加打印机，配置文件
        bindPrinter.addTarget(self, action: #selector(skipToBindView), for: .touchUpInside)
        addPprofile.addTarget(self, action: #selector(skipToPProfileView), for: .touchUpInside)
        addMprofile.addTarget(self, action: #selector(skipToMProfileView), for: .touchUpInside)
        
        let show1 = UITapGestureRecognizer(target: self, action: #selector(showPrinterList))
        partChoose1.addGestureRecognizer(show1)
        let show2 = UITapGestureRecognizer(target: self, action: #selector(showPprofileList))
        partChoose2.addGestureRecognizer(show2)
        let show3 = UITapGestureRecognizer(target: self, action: #selector(showMprofileList))
        partChoose3.addGestureRecognizer(show3)
        
        //开始切片上传打印
        self.view.addSubview(serverDownload())
        self.view.addSubview(serverCure())
        self.view.addSubview(serverUpload())
    }
    override func viewWillAppear(_ animated: Bool) {
        //获取列表，模型参数
        getModelDetail()
        getPrinterList()
        getPprofileList()
        getMprofileList()
    }
    override func viewDidAppear(_ animated: Bool) {
        scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 750)
    }
//    override func viewWillDisappear(_ animated: Bool) {
//        timer.invalidate()
//        self.progressView1.isHidden = true
//        self.progressView2.isHidden = true
//        self.progressView3.isHidden = true
//    }
    //跳转添加打印机，配置文件
    @objc func skipToBindView(){
        let bindView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "bindPrinter")
        self.navigationController?.pushViewController(bindView, animated: true)
    }
    @objc func skipToPProfileView(){
        let pProfileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addPProfile")
        self.navigationController?.pushViewController(pProfileView, animated: true)
    }
    @objc func skipToMProfileView(){
        let mProfileView = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "addMProfile")
        self.navigationController?.pushViewController(mProfileView, animated: true)
    }
    //获取模型详情
    func getModelDetail(){
        let url = Url.basePath + "/v1/modelbase/models/" + modelId! + "/submodels/" + modelName!
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                print("=============== ", json)
                self.mWidth = json["submodel_width"].stringValue
                self.mDepth = json["submodel_depth"].stringValue
                self.mHeight = json["submodel_height"].stringValue
                self.mSize.text = "Size: " + self.mWidth + " * " + self.mDepth + " * " + self.mHeight + " mm"
            } else {
                if code != nil{
                    ResponseError().error(target: self, code: code!)
                    return
                }
            }
            if response.result.isFailure{
                let nsCode = (response.error! as NSError).code
                ResponseError().errorNScode(target: self, code: nsCode)
            }
        }
    }
    //获取打印机列表
    func getPrinterList(){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printers?token=" + PersonInfo().token()
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                if json.count == 0{
                    self.partLabel1.text = "null"
                    return
                }
                self.array1 = json
                self.scrollView.addSubview(self.choosePrinter(array: json))
            } else {
                print("========== get printer list fail ===========")
            }
        }
    }
    //获取打印机配置文件列表
    func getPprofileList(){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printer_profiles?token=" + PersonInfo().token()
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                if json.count == 0{
                    self.partLabel2.text = "null"
                    return
                }
                self.array2 = json
                self.scrollView.addSubview(self.choosePprofile(array: json))
            }
        }
    }
    //获取材料配置文件列表
    func getMprofileList(){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/material_profiles?token=" + PersonInfo().token()
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                if json.count == 0{
                    self.partLabel3.text = "null"
                    return
                }
                self.array3 = json
                self.scrollView.addSubview(self.chooseMprofile(array: json))
            }
        }
    }
    //第一部分列表
    func choosePrinter(array: JSON) -> UIView{
        viewList1.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        viewList1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        viewList1.isMultipleTouchEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenList))
        viewList1.addGestureRecognizer(tap)
        viewList1.layer.shadowColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        viewList1.layer.borderColor = viewList1.layer.shadowColor // 边框颜色建议和阴影颜色一致
        viewList1.layer.borderWidth = 0.1 // 只要不为0就行
        viewList1.layer.cornerRadius = 20
        viewList1.layer.shadowOpacity = 1
        viewList1.layer.shadowRadius = 10
        viewList1.layer.shadowOffset = .zero
        partLabel1.text = array[0]["name"].stringValue
        
        let view = UIScrollView()
        let viewHeight = array.count * 30 + 2
        var needHeight = 285
        if viewHeight < needHeight{
            needHeight = viewHeight
        }
        view.frame = CGRect(x: 33, y: 263, width: Int(UIScreen.main.bounds.width - 66), height: needHeight)
        view.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        view.contentSize = CGSize(width: Int(UIScreen.main.bounds.width - 66), height: viewHeight)
        let view1 = UIView()
        view1.frame = CGRect(x: 1, y: 1, width: Int(UIScreen.main.bounds.width - 68), height: viewHeight - 2)
        view1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.addSubview(view1)
        
        for i in 0...(array.count - 1){
            let label = UILabel()
            label.frame = CGRect(x: 8, y: i*30, width: Int(view1.bounds.width), height: 30)
            label.text = array[i]["name"].stringValue
            label.tag = i
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(setPrinter(sender:)))
            label.addGestureRecognizer(tap)
            view1.addSubview(label)
            
            let border = UILabel()
            border.frame = CGRect(x: 0, y: i*30, width: Int(view1.bounds.width), height: 1)
            border.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            view1.addSubview(border)
        }
        
        viewList1.addSubview(view)
        viewList1.isHidden = true
        return viewList1
    }
    @objc func setPrinter(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        //print("===== test choose =====")
        partLabel1.text = array1![tag!]["name"].stringValue
        partLabel1.tag = tag!
        viewList1.isHidden = true
    }
    //第二部分
    func choosePprofile(array: JSON) -> UIView{
        viewList2.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        viewList2.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        viewList2.isMultipleTouchEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenList))
        viewList2.addGestureRecognizer(tap)
        viewList2.layer.shadowColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        viewList2.layer.borderColor = viewList2.layer.shadowColor // 边框颜色建议和阴影颜色一致
        viewList2.layer.borderWidth = 0.1 // 只要不为0就行
        viewList2.layer.cornerRadius = 20
        viewList2.layer.shadowOpacity = 1
        viewList2.layer.shadowRadius = 10
        viewList2.layer.shadowOffset = .zero
        partLabel2.text = array[0]["name"].stringValue
        
        let view = UIScrollView()
        let viewHeight = array.count * 30 + 2
        var needHeight = 285
        if viewHeight < needHeight{
            needHeight = viewHeight
        }
        view.frame = CGRect(x: 33, y: 359, width: Int(UIScreen.main.bounds.width - 66), height: needHeight)
        view.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        view.contentSize = CGSize(width: Int(UIScreen.main.bounds.width - 66), height: viewHeight)
        let view1 = UIView()
        view1.frame = CGRect(x: 1, y: 1, width: Int(UIScreen.main.bounds.width - 68), height: viewHeight-2)
        view1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.addSubview(view1)
        
        for i in 0...(array.count - 1){
            let label = UILabel()
            label.frame = CGRect(x: 8, y: i*30, width: Int(view1.bounds.width), height: 30)
            label.text = array[i]["name"].stringValue
            label.tag = i
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(setPprofile(sender:)))
            label.addGestureRecognizer(tap)
            view1.addSubview(label)
            
            let border = UILabel()
            border.frame = CGRect(x: 0, y: i*30, width: Int(view1.bounds.width), height: 1)
            border.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            view1.addSubview(border)
        }
        
        viewList2.addSubview(view)
        viewList2.isHidden = true
        return viewList2
    }
    @objc func setPprofile(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        //print("===== test choose =====")
        partLabel2.text = array2![tag!]["name"].stringValue
        partLabel2.tag = tag!
        viewList2.isHidden = true
    }
    //第三部分
    func chooseMprofile(array: JSON) -> UIView{
        viewList3.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        viewList3.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        viewList3.isMultipleTouchEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenList))
        viewList3.addGestureRecognizer(tap)
        viewList3.layer.shadowColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1).cgColor
        viewList3.layer.borderColor = viewList3.layer.shadowColor // 边框颜色建议和阴影颜色一致
        viewList3.layer.borderWidth = 0.1 // 只要不为0就行
        viewList3.layer.cornerRadius = 20
        viewList3.layer.shadowOpacity = 1
        viewList3.layer.shadowRadius = 10
        viewList3.layer.shadowOffset = .zero
        partLabel3.text = array[0]["name"].stringValue
        
        let view = UIScrollView()
        let viewHeight = array.count * 30 + 2
        var needHeight = 285
        if viewHeight < needHeight{
            needHeight = viewHeight
        }
        view.frame = CGRect(x: 33, y: 455, width: Int(UIScreen.main.bounds.width - 66), height: needHeight)
        view.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        view.contentSize = CGSize(width: Int(UIScreen.main.bounds.width - 66), height: viewHeight)
        let view1 = UIView()
        view1.frame = CGRect(x: 1, y: 1, width: Int(UIScreen.main.bounds.width - 68), height: viewHeight-2)
        view1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        view.addSubview(view1)
        
        for i in 0...(array.count - 1){
            let label = UILabel()
            label.frame = CGRect(x: 8, y: i*30, width: Int(view1.bounds.width), height: 30)
            label.text = array[i]["name"].stringValue
            label.tag = i
            label.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(setMprofile(sender:)))
            label.addGestureRecognizer(tap)
            view1.addSubview(label)
            
            let border = UILabel()
            border.frame = CGRect(x: 0, y: i*30, width: Int(view1.bounds.width), height: 1)
            border.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
            view1.addSubview(border)
        }
        
        viewList3.addSubview(view)
        viewList3.isHidden = true
        return viewList3
    }
    @objc func setMprofile(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        //print("===== test choose =====")
        partLabel3.text = array3![tag!]["name"].stringValue
        partLabel3.tag = tag!
        viewList3.isHidden = true
    }
    @objc func showPrinterList(){
        viewList1.isHidden = false
    }
    @objc func showPprofileList(){
        viewList2.isHidden = false
    }
    @objc func showMprofileList(){
        viewList3.isHidden = false
    }
    @objc func hiddenList(){
        viewList1.isHidden = true
        viewList2.isHidden = true
        viewList3.isHidden = true
    }
    //是否展示支撑选项
    @objc func showSetting(){
        if !isShowAdvance{
            isShowAdvance = true
            let view = advancedView()
            self.scrollView.addSubview(view)
            self.scrollView.viewWithTag(5)?.frame = CGRect(x: 16, y: 659, width: partView4.bounds.width, height: 162)
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 830)
        } else{
            isShowAdvance = false
            //print(self.scrollView.viewWithTag(999))
            self.scrollView.viewWithTag(999)?.removeFromSuperview()
            self.scrollView.viewWithTag(5)?.frame = CGRect(x: 16, y: 584, width: partView4.bounds.width, height: 162)
            self.scrollView.contentSize = CGSize(width: UIScreen.main.bounds.width, height: 750)
        }
    }
    //支撑视图
    func advancedView() -> UIView{
        let view = UIView()
        view.frame = CGRect(x: 16, y: 583, width: partView4.bounds.width, height: 76)
        view.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        view.tag = 999
        let view1 = UIView()
        view1.frame = CGRect(x: 1, y: 0, width: partView4.bounds.width-2, height: 75)
        view1.backgroundColor = UIColor.white
        view.addSubview(view1)
        
        let view2 = UIView()
        view2.frame = CGRect(x: partView4.bounds.width/2-45, y: 0, width: 90, height: 32)
        //let imgCheck = UIImageView()
        imgCheck.frame = CGRect(x: 0, y: 6, width: 20, height: 20)
        if mSupport{
            imgCheck.image = UIImage(named: "icon_check_on")
        } else{
            imgCheck.image = UIImage(named: "icon_check_out")
        }
        view2.addSubview(imgCheck)
        let label = UILabel()
        label.frame = CGRect(x: 20, y: 6, width: 70, height: 20)
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.text = "Support"
        view2.addSubview(label)
        let tap = UITapGestureRecognizer(target: self, action: #selector(chooseSupport))
        view2.addGestureRecognizer(tap)
        view1.addSubview(view2)
        
        let label2 = UILabel()
        label2.frame = CGRect(x: (partView4.bounds.width-180)/2, y: 35, width: 100, height: 30)
        label2.text = "Material Flow:"
        label2.font = UIFont.systemFont(ofSize: 14)
        let label3 = UILabel()
        label3.frame = CGRect(x: partView4.bounds.width/2 + 60, y: 35, width: 20, height: 30)
        label3.text = "%"
        //let textfield = UITextField()
        textfieldFlow.frame = CGRect(x: partView4.bounds.width/2 + 10, y: 35, width: 40, height: 30)
        textfieldFlow.borderStyle = UITextBorderStyle.line
        textfieldFlow.returnKeyType = UIReturnKeyType.done
        textfieldFlow.delegate = self
        textfieldFlow.text = mFlow
        view1.addSubview(label2)
        view1.addSubview(textfieldFlow)
        view.addSubview(label3)
        
        return view
    }
    //第五部分 缩放及打印按钮视图
    func modelScale() -> UIView{
        let view = UIView()
        view.frame = CGRect(x: 16, y: 584, width: UIScreen.main.bounds.width-32, height: 162)
        view.backgroundColor = UIColor(red: 204/255, green: 204/255, blue: 204/255, alpha: 1)
        view.tag = 5
        let view1 = UIView()
        view1.frame = CGRect(x: 1, y: 1, width: UIScreen.main.bounds.width-34, height: 160)
        view1.backgroundColor = UIColor.white
        view.addSubview(view1)
        
        let label = UILabel()
        label.frame = CGRect(x: 16, y: 0, width: UIScreen.main.bounds.width-34, height: 31)
        label.text = "5.Model Scale"
        view1.addSubview(label)
        
        textfieldScale.frame = CGRect(x: (view1.bounds.width - 100)/2, y: 31, width: 100, height: 30)
        textfieldScale.borderStyle = UITextBorderStyle.line
        textfieldScale.returnKeyType = UIReturnKeyType.done
        textfieldScale.delegate = self
        textfieldScale.text = mScale
        view1.addSubview(textfieldScale)
        let label1 = UILabel()
        label1.text = "%"
        label1.frame = CGRect(x: (view1.bounds.width - 100)/2 + 110, y: 31, width: 20, height: 30)
        view1.addSubview(label1)
        
        //let label2 = UILabel()
        mSize.frame = CGRect(x: 0, y: 62, width: view1.bounds.width, height: 30)
        mSize.textAlignment = .center
        mSize.font = UIFont.systemFont(ofSize: 14)
        mSize.text = "Size: " + mWidth + " * " + mDepth + " * " + mHeight + " mm"
        view1.addSubview(mSize)
        
        let btn = UIButton()
        btn.frame = CGRect(x: 32, y: 104, width: view1.bounds.width-64, height: 48)
        btn.layer.cornerRadius = 5
        btn.layer.masksToBounds = true
        btn.setTitle("print", for: .normal)
        btn.isEnabled = true
        btn.setTitleColor(UIColor.white, for: .normal)
        btn.setTitleColor(UIColor.blue, for: .highlighted)
        btn.setTitleColor(UIColor.cyan, for: .selected)
        btn.setTitleColor(UIColor.cyan, for: .disabled)
        btn.setTitleShadowColor(UIColor.cyan, for: .normal)
        btn.setTitleShadowColor(UIColor.green, for: .highlighted)
        btn.setTitleShadowColor(UIColor.brown, for: .selected)
        btn.setTitleShadowColor(UIColor.darkGray, for: .disabled)
        btn.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        btn.addTarget(self, action: #selector(startPrint), for: .touchUpInside)
        view1.addSubview(btn)
        return view
    }
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    //开始切片上传打印
    @objc func startPrint(){
        //print(self.array1?.count)
        if self.array1?.count == 0 || self.array1?.count == nil{
            self.present(Alert().singleAlert(message: "please bind a printer."), animated: true, completion: nil)
            return
        } else if self.array2?.count == 0 || self.array2?.count == nil{
            self.present(Alert().singleAlert(message: "please add a printer profile."), animated: true, completion: nil)
            return
        } else if self.array3?.count == 0 || self.array3?.count == nil{
            self.present(Alert().singleAlert(message: "please add a material profile."), animated: true, completion: nil)
            return
        } else if self.mScale == ""{
            self.present(Alert().singleAlert(message: "please write the scale."), animated: true, completion: nil)
            return
        } else if self.mFlow == ""{
            self.present(Alert().singleAlert(message: "please write the material flow."), animated: true, completion: nil)
            return
        }
        (self.progressView2.subviews[0].viewWithTag(21) as! UIProgressView).progress = 0
        (self.progressView2.subviews[0].viewWithTag(22) as! UILabel).text = "0%"
        (self.progressView3.subviews[0].viewWithTag(31) as! UIProgressView).progress = 0
        (self.progressView3.subviews[0].viewWithTag(32) as! UILabel).text = "0%"
        getPrinterState()
    }
    //选择质量
    @objc func chooseQuality(sender: UITapGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        if tag == 41{
            isChooseQuality = "draft"
            draftIcon.image = UIImage(named: "icon_check_on")
            normalIcon.image = UIImage(named: "icon_check_out")
            bestIcon.image = UIImage(named: "icon_check_out")
        } else if tag == 42{
            isChooseQuality = "normal"
            draftIcon.image = UIImage(named: "icon_check_out")
            normalIcon.image = UIImage(named: "icon_check_on")
            bestIcon.image = UIImage(named: "icon_check_out")
        } else {
            isChooseQuality = "best"
            draftIcon.image = UIImage(named: "icon_check_out")
            normalIcon.image = UIImage(named: "icon_check_out")
            bestIcon.image = UIImage(named: "icon_check_on")
        }
    }
    //选择支撑
    @objc func chooseSupport(){
        if mSupport{
            mSupport = false
            imgCheck.image = UIImage(named: "icon_check_out")
        }else{
            mSupport = true
            imgCheck.image = UIImage(named: "icon_check_on")
        }
    }
    //获取选中打印机状态
    func getPrinterState(){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printers/" + AES_ECB().encypted(need: array1![partLabel1.tag]["serial_num"].stringValue) + "?token=" + PersonInfo().token()
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                let state = json["state"].stringValue
                if state == "2" {
                    self.getPProfileDetail()
                } else if state == "0" {
                    self.present(Alert().singleAlert(message: "The printer is offline."), animated: true, completion: nil)
                    return
                } else if state == "1" {
                    self.present(Alert().singleAlert(message: "The printer is logout."), animated: true, completion: nil)
                    return
                } else if state == "3" || state == "4" {
                    self.present(Alert().singleAlert(message: "The printer is printing."), animated: true, completion: nil)
                    return
                }
            } else {
                if code != nil{
                    ResponseError().error(target: self, code: code!)
                    return
                }
            }
            if response.result.isFailure{
                let nsCode = (response.error! as NSError).code
                ResponseError().errorNScode(target: self, code: nsCode)
            }
        }
    }
    //获取选中打印机配置文件
    func getPProfileDetail(){
        //print(array2![partLabel2.tag])
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printer_profiles/" + AES_ECB().encypted(need: array2![partLabel2.tag]["id"].stringValue) + "?token=" + PersonInfo().token()
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                print(response.result.value)
                let json = JSON(response.result.value as Any)
                self.arrayPProfileDetail = json
                let shape = json["shape"].stringValue
                if shape == "0"{
                    let width = json["width"].stringValue
                    let depth = json["depth"].stringValue
                    let height = json["height"].stringValue
                    let a = Double(self.mWidth)!/Double(width)!*Double(self.mScale)!*0.01
                    let b = Double(self.mDepth)!/Double(depth)!*Double(self.mScale)!*0.01
                    let c = Double(self.mHeight)!/Double(height)!*Double(self.mScale)!*0.01
                    //print(a, b, c)
                    if a > 1 || b > 1 || c > 1{
                        self.present(Alert().singleAlert(message: "The model size is too large for the selected printer. Please resize."), animated: true, completion: nil)
                        return
                    }
                    self.getMProfileDetail()
                }else{
                    let radius = json["radius"].stringValue
                    let height = json["height"].stringValue
                    let a = Double(self.mWidth)!/Double(radius)!*Double(self.mScale)!*0.01*1.4
                    let b = Double(self.mDepth)!/Double(radius)!*Double(self.mScale)!*0.01*1.4
                    let c = Double(self.mHeight)!/Double(height)!*Double(self.mScale)!*0.01
                    //print(a, b, c)
                    if a > 1 || b > 1 || c > 1{
                        self.present(Alert().singleAlert(message: "The model size is too large for the selected printer. Please resize."), animated: true, completion: nil)
                        return
                    }
                    self.getMProfileDetail()
                }
            }
        }
    }
    //获取选中材料配制文件
    func getMProfileDetail(){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/material_profiles/" + AES_ECB().encypted(need: array3![partLabel3.tag]["id"].stringValue) + "?token=" + PersonInfo().token()
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                print(json)
                self.arrayMProfileDetail = json
                self.startCure()
            }
        }
    }
    //开始切片
    func startCure(){
        SingletonSocket.sharedInstance.socket.delegate = self
        SingletonSocket.sharedInstance.socket.connect()
    }
    func getCureParams() -> String{
        var json = JSON()
        var obj = JSON()
        var layerHeight = Double()
        var wallThickness = Double()
        var infillRate = Double()
        var outlineSpeed = Double()
        if isChooseQuality == "draft"{
            layerHeight = 0.2
            wallThickness = 0.4
            infillRate = 10
            outlineSpeed = 60
        } else if isChooseQuality == "best"{
            layerHeight = 0.2
            wallThickness = 0.8
            infillRate = 20
            outlineSpeed = 60
        } else{
            layerHeight = 0.1
            wallThickness = 0.8
            infillRate = 10
            outlineSpeed = 30
        }
        var support = 1
        if mSupport{
            support = 1
        } else{
            support = 0
        }
        var machineRadius = 0.0
        var machineWidth = 0.0
        var machineDepth = 0.0
        if arrayPProfileDetail!["radius"].double != nil{
            machineRadius = arrayPProfileDetail!["radius"].double!
        }else{
            machineWidth = arrayPProfileDetail!["width"].double!
            machineDepth = arrayPProfileDetail!["depth"].double!
        }
//        print("========   " + "\(machineRadius)")
//        print(arrayPProfileDetail)
        obj = ["heatbedExist": "1", "modelUrl": modelStl!, "modelName": modelName!, "modelNewName": "", "modelScale": Double(mScale)!*0.01, "nozzleDiameter": 0.4, "materialDiameter": arrayMProfileDetail!["diameter"].double!, "extruderTemp": arrayMProfileDetail!["extruder_temp"].double!, "bedTemp": arrayMProfileDetail!["bed_temp"].double!, "machineWidth": machineWidth, "machineDepth": machineDepth, "machineHeight": arrayPProfileDetail!["height"].double!, "machineRadius": machineRadius, "machineShape": arrayPProfileDetail!["shape"].double!, "layerHeight": layerHeight, "wallThickness": wallThickness, "infillRate": infillRate, "outlineSpeed": outlineSpeed, "handler": 0, "modelSupport": support, "matarialFlow": Double(mFlow)!]
        
        json = ["reqDev": "iOS", "reqAcc": PersonInfo().email(), "insType": 0, "insParam": obj]
        return json.rawString()!
    }
    deinit {
        SingletonSocket.sharedInstance.socket.disconnect(forceTimeout: 0)
        SingletonSocket.sharedInstance.socket.delegate = nil
    }
    //输入键盘控制消失
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        animateViewMoving(up: false, moveValue: 220)
        if textField == textfieldFlow{
            mFlow = textField.text!
            if mFlow == ""{
                textField.text = "250"
                mFlow = "250"
            }
        } else if textField == textfieldScale{
            mScale = textField.text!
            if mScale == ""{
                textField.text = "100"
                mScale = "100"
            }
            print(Int(mScale)!*Int(Double(self.mWidth)!))
            let width = String(Double(mScale)!*Double(self.mWidth)!*0.01)
            let height = String(Double(mScale)!*Double(self.mHeight)!*0.01)
            let depth = String(Double(mScale)!*Double(self.mDepth)!*0.01)
            print(mWidth, mHeight, mDepth)
            self.mSize.text = "Size: " + width + " * " + depth + " * " + height + " mm"
        }
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        animateViewMoving(up: true, moveValue: 220)
    }
    func animateViewMoving(up: Bool, moveValue: CGFloat){
        let movementDuration: TimeInterval = 0.3
        let movement: CGFloat = (up ? -moveValue : moveValue)
        UIView.beginAnimations("animateView", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(movementDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    @objc func handleTap(sender: UITapGestureRecognizer){
        if sender.state == .ended{
            textfieldFlow.resignFirstResponder()
            textfieldScale.resignFirstResponder()
        }
        sender.cancelsTouchesInView = false
    }
    //限制只能输入数字
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let length = string.lengthOfBytes(using: String.Encoding.utf8)
        for loopIndex in 0..<length{
            let char = ( string as NSString).character(at: loopIndex)
            if char < 48 { return false}
            if char > 57 { return false}
        }
        return true
    }
}
// MARK: - WebSocketDelegate
extension ModelPrintControll : WebSocketDelegate {
    //ws连接
    func websocketDidConnect(socket: WebSocketClient) {
        print("connect")
        SingletonSocket.sharedInstance.socket.write(string: getCureParams())
        progressView2.isHidden = false
    }
    //ws断开
    func websocketDidDisconnect(socket: WebSocketClient, error: Error?) {
        print("disconnect")
        //timer.invalidate()
        let progress = (self.progressView2.subviews[0].viewWithTag(21) as! UIProgressView).progress
        if progress != 1{
            progressView2.isHidden = true
            //self.present(Alert().singleAlert(message: "Slice error."), animated: true, completion: nil)
        }
    }
    //接收信息
    func websocketDidReceiveMessage(socket: WebSocketClient, text: String) {
        //print(text)
        let jsonStr = text
        let jsonData=jsonStr.data(using: String.Encoding.utf8, allowLossyConversion: false)
        let json=try? JSONSerialization.jsonObject(with: jsonData!, options: .mutableContainers)

        let json1 = JSON(json as Any)
        let insParam = json1["insParam"]
        let state = insParam["state"].stringValue
        //print(json1, state)
        if state == "2"{
            print("start slice")
        } else if state == "3"{
            let progress = insParam["prog"]
            progressView2.isHidden = false
            //print(progress)
            (self.progressView2.subviews[0].viewWithTag(21) as! UIProgressView).progress = Float(progress.double!)
            (self.progressView2.subviews[0].viewWithTag(22) as! UILabel).text = String(progress.double! * 100) + "%"
        } else if state == "4"{
            print("slice done")
            progressView2.isHidden = true
            progressView1.isHidden = false
        }
        //print("=======test slice state======",state)
        let modelUrl = insParam["modelUrl"].stringValue
        if modelUrl != ""{
            print("=======================",modelUrl)
            upLoad(modelUrl: modelUrl)
            SingletonSocket.sharedInstance.socket.disconnect()
        }
    }
    
    func websocketDidReceiveData(socket: WebSocketClient, data: Data) {
        print(data)
    }
    //创建定时查询状态
    func creatTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(timerManager), userInfo: nil, repeats: true)
        RunLoop.current.add(timer, forMode: .commonModes)
    }
    //创建定时器管理者
    @objc func timerManager(){
        //获取上传进度
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printers/" + AES_ECB().encypted(need: array1![partLabel1.tag]["serial_num"].stringValue) + "?token=" + PersonInfo().token()
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = JSON(response.result.value as Any)
                let taskState = json["task_state"].double
                print(json)
                let state = json["state"].stringValue
                if state == "0"{
                    self.progressView3.isHidden = true
                    self.timer.invalidate()
                    self.present(Alert().singleAlert(message: "Printer is offline."), animated: true, completion: nil)
                    return
                }
                if taskState == 0{
                    let taskFileLength = json["task_file_length"].double
                    let taskFileUpload = json["task_file_uploaded"].double
                    if taskFileLength! > 0.0 && taskFileLength == taskFileUpload{
                        self.progressView3.isHidden = true
                        self.timer.invalidate()
                        let alert = UIAlertController(title: "", message: "Skip to print.", preferredStyle: .alert)
                        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                        let ok = UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
                            let printView = self.navigationController?.viewControllers[0]
                            self.navigationController?.popToViewController(printView!, animated: true)
                        })
                        alert.addAction(cancel)
                        alert.addAction(ok)
                        self.present(alert, animated: true, completion: nil)
                    }else{
//                        self.progressView3.isHidden = true
//                        self.timer.invalidate()
//                        self.present(Alert().singleAlert(message: "Unkonwn error."), animated: true, completion: nil)
                    }
                    print("upload done.")
                } else if taskState == 4{
                    self.progressView3.isHidden = true
                    self.timer.invalidate()
                    self.present(Alert().singleAlert(message: "SD card exception."), animated: true, completion: nil)
                    return
                } else if taskState == 1{
                    print("server download")
                    return
                } else if taskState == 2{
                    print("upload...", self.progressView3.isHidden)
                } else if taskState == 3{
                    self.progressView3.isHidden = true
                    self.timer.invalidate()
                    self.present(Alert().singleAlert(message: "Upload fail."), animated: true, completion: nil)
                    return
                }
                let taskFile = json["task_file"].stringValue
                let taskFileLength = json["task_file_length"].double
                let taskFileUpload = json["task_file_uploaded"].double
                PersonInfo.Var.currentPrintName = taskFile
                if taskFileLength == 0{
                    return
                }
                if taskFileLength == nil || taskFileUpload == nil{
                    return
                }
                let progress = taskFileUpload!/taskFileLength!
                (self.progressView3.subviews[0].viewWithTag(31) as! UIProgressView).progress = Float(String(format:"%.2f", progress))!
                (self.progressView3.subviews[0].viewWithTag(32) as! UILabel).text = String(format:"%.2f", progress * 100) + "%"
            }
        }
    }
    //切片完成后上传
    func upLoad(modelUrl: String){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printers/" + AES_ECB().encypted(need: array1![partLabel1.tag]["serial_num"].stringValue) + "?token=" + PersonInfo().token()
        let params = ["action": "upload", "value": modelUrl]
        AlamofireCustom.alamofireLong.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            response in
            let code = response.response?.statusCode
            print("======= test upload code======",code as Any)
            if code == 200 || code == 504{
                self.creatTimer()
                self.progressView1.isHidden = true
                self.progressView3.isHidden = false
            } else if code == 500{
                self.progressView1.isHidden = true
                self.present(Alert().singleAlert(message: "Upload error."), animated: true, completion: nil)
            } else if code == 410{
                self.progressView1.isHidden = true
                self.present(Alert().singleAlert(message: "Slice error."), animated: true, completion: nil)
            }
//            else {
//                self.progressView1.isHidden = true
//                self.present(Alert().singleAlert(message: "Unknow error."), animated: true, completion: nil)
//            }
        }
    }
    //取消上传
    @objc func giveUp(){
        let url = Url.baseUsers + PersonInfo().emailAes() + "/printers/" + AES_ECB().encypted(need: array1![partLabel1.tag]["serial_num"].stringValue) + "?token=" + PersonInfo().token()
        let params = ["action": "stop_upload", "value": modelUrl!]
        AlamofireCustom.alamofireFast.request(url, method: .post, parameters: params, encoding: JSONEncoding.default).response{
            response in
            //let code = response.response?.statusCode
            print("==========give up upload===========")
        }
    }
    //切片及上传进度视图
    func serverDownload() -> UIView{
        progressView1.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        progressView1.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        let view1 = UIView()
        view1.frame = CGRect(x: 16, y: self.view.bounds.height/2 - 64, width: self.view.bounds.width - 32, height: 128)
        view1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        progressView1.addSubview(view1)
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: view1.bounds.width, height: 48)
        label.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        label.text = "EasyPrint 3D"
        label.textAlignment = .center
        label.textColor = UIColor.white
        view1.addSubview(label)
        let label1 = UILabel()
        label1.frame = CGRect(x: 0, y: 48, width: view1.bounds.width, height: 80)
        label1.text = "Please wait to download..."
        label1.textAlignment = .center
        label1.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1)
        
        view1.addSubview(label1)
        progressView1.isHidden = true
        return progressView1
    }
    
    func serverCure() -> UIView{
        progressView2.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        progressView2.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        let view1 = UIView()
        view1.frame = CGRect(x: 16, y: self.view.bounds.height/2 - 64, width: self.view.bounds.width - 32, height: 128)
        view1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        progressView2.addSubview(view1)
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: view1.bounds.width, height: 48)
        label.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        label.text = "EasyPrint 3D"
        label.textAlignment = .center
        label.textColor = UIColor.white
        view1.addSubview(label)
        
        let imgBtn = UIImageView()
        imgBtn.frame = CGRect(x: view1.bounds.width - 25, y: 5, width: 20, height: 20)
        imgBtn.image = UIImage(named: "icon_menu_off")
        imgBtn.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenSlice))
        imgBtn.addGestureRecognizer(tap)
        view1.addSubview(imgBtn)
        
        let view2 = UIView()
        view2.frame = CGRect(x: 0, y: 48, width: view1.bounds.width, height: 80)
        view2.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1)
        let label1 = UILabel()
        label1.frame = CGRect(x: 0, y: 0, width: view2.bounds.width, height: 20)
        label1.text = "Slice"
        label1.font = UIFont.systemFont(ofSize: 16)
        label1.textAlignment = .center
        view2.addSubview(label1)
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 16, y: 36, width: view2.bounds.width - 32, height: 20)
        progressView.trackTintColor = UIColor.white
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 10.0)
        progressView.progress = 0
        progressView.tag = 21
        let progressNum = UILabel()
        progressNum.frame = CGRect(x: 16, y: 26, width: view2.bounds.width - 32, height: 20)
        progressNum.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        progressNum.text = String(progressView.progress * 100) + "%"
        progressNum.textAlignment = .center
        progressNum.font = UIFont.systemFont(ofSize: 14)
        progressNum.tag = 22
        view2.addSubview(progressView)
        view2.addSubview(progressNum)
        view1.addSubview(view2)
        
        progressView2.isHidden = true
        return progressView2
    }
    
    func serverUpload() -> UIView{
        progressView3.frame = CGRect(x: 0, y: 0, width: self.view.bounds.width, height: self.view.bounds.height)
        progressView3.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2)
        
        let view1 = UIView()
        view1.frame = CGRect(x: 16, y: self.view.bounds.height/2 - 64, width: self.view.bounds.width - 32, height: 128)
        view1.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 1)
        progressView3.addSubview(view1)
        
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: view1.bounds.width, height: 48)
        label.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        label.text = "EasyPrint 3D"
        label.textAlignment = .center
        label.textColor = UIColor.white
        view1.addSubview(label)
        
        let imgBtn = UIImageView()
        imgBtn.frame = CGRect(x: view1.bounds.width - 25, y: 5, width: 20, height: 20)
        imgBtn.image = UIImage(named: "icon_menu_off")
        imgBtn.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(hiddenUpload))
        imgBtn.addGestureRecognizer(tap)
        view1.addSubview(imgBtn)
        
        let view2 = UIView()
        view2.frame = CGRect(x: 0, y: 48, width: view1.bounds.width, height: 80)
        view2.backgroundColor = UIColor(red: 238/255, green: 239/255, blue: 240/255, alpha: 1)
        let label1 = UILabel()
        label1.frame = CGRect(x: 0, y: 0, width: view2.bounds.width, height: 20)
        label1.text = "Upload"
        label1.font = UIFont.systemFont(ofSize: 16)
        label1.textAlignment = .center
        view2.addSubview(label1)
        let progressView = UIProgressView(progressViewStyle: .default)
        progressView.frame = CGRect(x: 16, y: 36, width: view2.bounds.width - 32, height: 20)
        progressView.trackTintColor = UIColor.white
        progressView.transform = CGAffineTransform(scaleX: 1.0, y: 10.0)
        progressView.progress = 0
        progressView.tag = 31
        let progressNum = UILabel()
        progressNum.frame = CGRect(x: 16, y: 26, width: view2.bounds.width - 32, height: 20)
        progressNum.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        progressNum.text = String(progressView.progress * 100) + "%"
        progressNum.textAlignment = .center
        progressNum.font = UIFont.systemFont(ofSize: 14)
        progressNum.tag = 32
        view2.addSubview(progressView)
        view2.addSubview(progressNum)
        view1.addSubview(view2)

        progressView3.isHidden = true
        return progressView3
    }
    //隐藏视图
    @objc func hiddenSlice(){
        let alert = UIAlertController(title: "", message: "Are you sure to cancel the slice?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            SingletonSocket.sharedInstance.socket.disconnect()
            self.progressView2.isHidden = true
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
    @objc func hiddenUpload(){
        let alert = UIAlertController(title: "", message: "Are you sure to cancel the upload?", preferredStyle: .alert)
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let ok = UIAlertAction(title: "OK", style: .default, handler: {(UIAlertAction) in
            self.giveUp()
            self.timer.invalidate()
            self.progressView3.isHidden = true
        })
        alert.addAction(cancel)
        alert.addAction(ok)
        self.present(alert, animated: true, completion: nil)
    }
}
