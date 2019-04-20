//
//  ModelDetailControll.swift
//  Easyprint
//
//  Created by app on 2018/7/5.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher

class ModelDetailControll: UIViewController, UIScrollViewDelegate {
    //传值参数
    var modelId: String?
    //图片链接列表
    var listPath = [String]()
    //STL文件名列表及名称
    var listStl = [String]()
    var listStlImg = [String]()
    var listStlName = [String]()
    
    let width = UIScreen.main.bounds.width
    let src = ZYF_MyScrollView()
    let page = UIPageControl()
    
    @IBOutlet weak var showImgView: UIView!
    @IBOutlet weak var chooseInfo: UIButton!
    @IBOutlet weak var chooseFiles: UIButton!
    @IBOutlet weak var infoShow: UIScrollView!
    @IBOutlet weak var fileShow: UIScrollView!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let leftBar = UIBarButtonItem(image: UIImage(named: "icon_back")?.scaleImage(scaleSize: 0.5), style: .plain, target: self, action: #selector(tapBack))
        leftBar.tintColor = UIColor.white
        self.navigationItem.leftBarButtonItem = leftBar
        self.navigationItem.title = "Model"
        getModelDetail()
        chooseInfo.addTarget(self, action: #selector(showInfo), for: .touchUpInside)
        chooseFiles.addTarget(self, action: #selector(showFiles), for: .touchUpInside)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //获取模型详情
    func getModelDetail(){
        let url = Url.basePath + "/v1/modelbase/models/" + self.modelId!
        AlamofireCustom.alamofireFast.request(url).responseJSON{
            response in
            let code = response.response?.statusCode
            if code == 200{
                let json = response.result.value
                let modelDetail = JSON(json as Any)
                //let id = modelDetail["model_id"].stringValue
                let path = modelDetail["model_path"].stringValue
                let thumb = modelDetail["model_thumb"]
                let resource = modelDetail["model_resource"]
                let description = modelDetail["model_description"].stringValue
                print(path,thumb,resource)
                if thumb.count == 0{
                    return
                }
                for i in 0...(thumb.count - 1){
                    let url = Url.baseImgPath + thumb[i].stringValue
                    let stlUrl = Url.baseImgPath + path + resource[i].stringValue
                    if stlUrl.contains(".stl"){
                        self.listStl.append(stlUrl)
                        self.listPath.append(url)
                        self.listStlImg.append(url)
                        self.listStlName.append(resource[i].stringValue)
                    } else{
                        self.listPath.append(stlUrl)
                    }
                }
                //模型图片列表
                self.src.delegate = self
                self.src.creatMyScrollView(imageName: self.listPath, height: 192)
                self.showImgView.addSubview(self.src)
                self.page.frame = CGRect(x: self.width/2-50, y: 160, width: 100, height: 30)
                self.page.numberOfPages = self.listPath.count
                self.showImgView.insertSubview(self.page, aboveSubview: self.src)
                //模型信息
                let infoLabel = UILabel()
                let height = self.getLabelHegit(str: description, font: UIFont.systemFont(ofSize: 12), width: self.width)
                infoLabel.text = description
                infoLabel.numberOfLines = 0
                infoLabel.lineBreakMode = NSLineBreakMode.byClipping
                do{
                    let strData = description.data(using: String.Encoding.unicode, allowLossyConversion: true)
                    let strOptions = [NSAttributedString.DocumentReadingOptionKey.documentType: NSAttributedString.DocumentType.html]
                    let attrStr = try NSAttributedString(data: strData!, options: strOptions, documentAttributes: nil)
                    infoLabel.attributedText = attrStr
                } catch let error as NSError{
                    print(error.localizedDescription)
                }
                infoLabel.frame = CGRect(x: 0, y: 0, width: self.width, height: height)
                self.infoShow.contentSize = CGSize(width: self.width, height: height)
                print(description, height, self.width)
                self.infoShow.addSubview(infoLabel)
                //模型文件
                for i in 0...(self.listStlName.count - 1){
                    let view = UIView()
                    view.frame = CGRect(x: 0, y: i*96, width: Int(self.width), height: 96)
                    let img = UIImageView()
                    img.frame = CGRect(x: 8, y: 8, width: 80, height: 80)
                    let url = URL(string: self.listStlImg[i])
                    img.kf.setImage(with: url)
                    print(self.listStlImg[i])
                    view.addSubview(img)
                    
                    let label = UILabel()
                    label.frame = CGRect(x: 96, y: 0, width: Int(self.width - 176), height: 96)
                    label.text = self.listStlName[i]
                    view.addSubview(label)
                    
                    let btn = UIButton()
                    btn.frame = CGRect(x: Int(self.width - 65), y: 30, width: 50, height: 36)
                    btn.setTitle("print", for: UIControlState.normal)
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
                    btn.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
                    btn.tag = i
                    let tap = UITapGestureRecognizer(target: self, action: #selector(self.skipToPrint(sender:)))
                    btn.addGestureRecognizer(tap)
                    view.addSubview(btn)
                    
                    self.fileShow.contentSize = CGSize(width: self.width, height: CGFloat(96*self.listStlName.count))
                    self.fileShow.addSubview(view)
                }
                //print(self.listPath, self.listStl)
            }
        }
    }
    @objc func showInfo(){
        self.chooseInfo.setTitleColor(UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1), for: .normal)
        self.chooseInfo.backgroundColor = UIColor.white
        self.chooseFiles.setTitleColor(UIColor.white, for: .normal)
        self.chooseFiles.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        self.fileShow.isHidden = true
    }
    @objc func showFiles(){
        self.chooseInfo.setTitleColor(UIColor.white, for: .normal)
        self.chooseInfo.backgroundColor = UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1)
        self.chooseFiles.setTitleColor(UIColor(red: 28/255, green: 142/255, blue: 1, alpha: 1), for: .normal)
        self.chooseFiles.backgroundColor = UIColor.white
        self.fileShow.isHidden = false
    }
    @objc func tapBack(){
        self.navigationController?.popViewController(animated: true)
    }
    @objc func skipToPrint(sender: UIGestureRecognizer){
        let view = sender.view
        let tag = view?.tag
        let need = [self.listStlName[tag!], self.listStlImg[tag!], self.listStl[tag!], self.modelId]
        if PersonInfo().state() != "login"{
            self.present(Alert().singleAlert(message: "Please log in."), animated: true, completion: nil)
            return
        }
        self.performSegue(withIdentifier: "modelPrint", sender: need)
    }
    //同步图片标签
    var cnt = 0
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView){
        if scrollView == src{
            let cPage = src.contentOffset.x / width
            page.currentPage = Int(cPage)
            cnt = Int(cPage)
        }
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView){
        if scrollView == src{
            cnt += 1
            page.currentPage = cnt % (self.listPath.count)
            cnt = page.currentPage
        }
    }
    /// 动态计算Label高度
    func getLabelHegit(str: String, font: UIFont, width: CGFloat)-> CGFloat {
        let statusLabelText: NSString = str as NSString
        let size = CGSize(width: width, height: CGFloat(MAXFLOAT))
        let dic = NSDictionary(object: font, forKey: NSAttributedStringKey.font as NSCopying)
        let strSize = statusLabelText.boundingRect(with: size, options: .usesLineFragmentOrigin, attributes: dic as? [NSAttributedStringKey : AnyObject], context: nil).size
        return strSize.height
    }
    //跳转传值
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let controller = segue.destination as! ModelPrintControll
        let list = sender as? Array<Any>
        controller.modelName = list?[0] as? String
        controller.modelUrl = list?[1] as? String
        controller.modelStl = list?[2] as? String
        controller.modelId = list?[3] as? String
    }
}
