//
//  WeatherViewController.swift
//  Weather
//
//  Created by LANCEREN on 2018/8/22.
//  Copyright © 2018年 LANCEREN. All rights reserved.
//

import UIKit
import SnapKit
import Hero
import MJRefresh

class WeatherViewController: UIViewController{
    
    var cityInfo: String = ""//需要显示的城市信息
    var cityInfoid: String = ""//需要显示的城市信息ID
    var futureWeatherArray : [String] = [] //存放未来一周天气信息的数组
    var futureWeatherDictionary: Dictionary<String, [String]> = [:]  //存放未来一周天气信息的字典
    let todayDate = Date() //当前日期
    let formatter = DateFormatter() //格式转换变量
    var isNight : Bool? //白天or夜间
    
    let header = MJRefreshNormalHeader() //刷新控件的基类
    
    @IBOutlet weak var bottomView: UIView!
    @IBOutlet weak var weatherInfoScrollView: UIScrollView!
    @IBAction func menuBtn(_ sender: UIButton) {
        //跳转列表
        hero.dismissViewController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.shared.statusBarStyle = .lightContent
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        cityInfo = appDelegate.cityInfo
        cityInfoid = appDelegate.cityInfoID
        
        self.hero.isEnabled = true
        timeDayNight()
        self.view.backgroundColor = isNight! ? UIColor(named: "w_nightblue") : UIColor(named: "w_lightblue")
        bottomView.backgroundColor = self.view.backgroundColor
        self.weatherInfoScrollView.delegate = self
        header.setRefreshingTarget(self, refreshingAction: #selector(refresh))
        self.weatherInfoScrollView.mj_header = header //状态刷新栏
        header.stateLabel.textColor = UIColor.white
        header.stateLabel.isHidden = false
        header.lastUpdatedTimeLabel.textColor = UIColor.white
        header.lastUpdatedTimeLabel.isHidden = false
        
        setUI()
            
        self.getWeatherData()
        self.getFutureWeatherData()
        self.getLifeData()
        self.getPMData()
        
        
//        let notificationName = Notification.Name(rawValue: "cityNotification")
//        NotificationCenter.default.addObserver(self, selector: #selector(dismissNotification(notification:)), name: notificationName, object: nil)
        // Do any additional setup after loading the view, typically from a nib.
    }
    
//    @objc func dismissNotification(notification: Notification){
//        let appDelegate = UIApplication.shared.delegate as! AppDelegate
//        if appDelegate.cityInfoID != "" {
//            cityInfoid = appDelegate.cityInfoID
//        } else {
//            print("当前cityInfo为空,error")
//        }
//        self.getWeatherData()
//        self.getFutureWeatherData()
//        self.getLifeData()
//        self.getPMData()
//    }
    
    @objc func refresh() {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        cityInfo = appDelegate.cityInfo
        cityInfoid = appDelegate.cityInfoID
        
        self.getWeatherData()
        self.getFutureWeatherData()
        self.getLifeData()
        self.getPMData()
        self.weatherInfoScrollView.mj_header.endRefreshing()
        let title = self.view.viewWithTag(101) as! UILabel
        UIView.animate(withDuration: 0.3) {
            title.alpha = 1
        }
    }
}

extension String {
    ///扩展String类 将汉字转化为拼音
    func transformToPinYin()->String {
        let mutableString = NSMutableString(string: self)
        CFStringTransform(mutableString, nil, kCFStringTransformToLatin, false)
        CFStringTransform(mutableString, nil, kCFStringTransformStripDiacritics, false)
        let string = String(mutableString)
        return string.replacingOccurrences(of: " ", with: "")
    }
    ///获取指定字符串在包含该字符串的字符串中的起始位置
    func positionOf(sub:String)->Int {
        var pos = -1
        if let range = range(of:sub) {
            if !range.isEmpty {
//                print("range is \(range.lowerBound) and \(startIndex)")
                pos = characters.distance(from:startIndex, to:range.lowerBound)
            }
        }
        return pos
    }
}

/*
 // MARK: - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
 // Get the new view controller using segue.destinationViewController.
 // Pass the selected object to the new view controller.
 }
 */


