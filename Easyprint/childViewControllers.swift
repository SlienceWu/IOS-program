//
//  ContentView.swift
//  Easyprint
//
//  Created by app on 2018/6/28.
//  Copyright © 2018年 com.geeetech. All rights reserved.
//
import UIKit
import DNSPageView

class ContentViewController: UIViewController  {
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        let width = UIScreen.main.bounds.size.width
//        let src = ZYF_MyScrollView()
//        let imageNames = ["printer_off","printer_off","printer_off","printer_off"]
//        let view = UIView(frame: CGRect(x: 0,y: 0,width: width,height: 200))
//        let textView = UILabel()
//        textView.text = "test"
//        src.creatMyScrollView(imageName: imageNames, height: 200)
//        view.addSubview(src)
//        let page = UIPageControl()
//        page.frame = CGRect(x: width/2-50, y: 160, width: 100, height: 30)
//        page.numberOfPages = imageNames.count
//        view.insertSubview(page, aboveSubview: src)
//        self.view.addSubview(view)
//        self.view.addSubview(textView)
        // Do any additional setup after loading the view.
    }
    
}

extension ContentViewController: DNSPageReloadable {
    func titleViewDidSelectedSameTitle() {
        print("重复点击了标题")
    }
    
    func contentViewDidEndScroll() {
        print("contentView滑动结束")
    }
}
