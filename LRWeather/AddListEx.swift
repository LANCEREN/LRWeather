//
//  AddListEx.swift
//  LRWeather
//
//  Created by lance ren on 2018/8/29.
//  Copyright © 2018年 lanceren. All rights reserved.
//

import Foundation
import UIKit
import Hero
import CoreData
import YNSearch

//MARK:- 城市信息的相关处理
extension AddListViewController{
    
    func DefaultRecommendCityInfo(){
        
    }
    
    func DefaultSearchCityInfo(){
        
        let database1 = YNSearchData(key: "杭州")
        demoDatabase.append(database1)
        self.initData(database: demoDatabase)
        let DefaultCity :String = "杭州"
        self.citynms.append(DefaultCity)
        self.cityInfos[DefaultCity] = "101210101"
        
    }
    
    ///判断搜索后要添加的城市是否存在添加后跳转
    func CheckCityisHad(CitynmsRow row: Int){
        let isHad = fetHadCityInfos(resultCity: citynms[row])
        if isHad == true {
            //alertAction()
            
        } else {
            //不存在则将城市名，时间（作为排序依据） id（json解析需要使用）保存到CoreData中
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            cityInfo = CityInfo(context: appDelegate.persistentContainer.viewContext)
            cityInfo.city = citynms[row]
            cityInfo.id = cityInfos[citynms[row]]
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cityInfo.order = formatter.string(from: todayDate)
            appDelegate.saveContext()
            
        }
        self.pushViewController()
    }
    
    ///搜索城市信息
    func getCityData() {
        //隐藏键盘
        //searchTextField.resignFirstResponder()
        
        let path = "http://api.k780.com/?app=weather.city&appkey=35717&sign=089478792dfe3d89fcbf6f5333eda713&format=json"
        let url = NSURL(string: path)
        let request = URLRequest(url: url! as URL)
        let session = URLSession.shared
        let searchStr = self.ynSearchTextfieldView.ynSearchTextField.text
        let task = session.dataTask(with: request) { (data, response, error) in
            if error == nil {
                do {
                    let json = try JSON(data: data!)
                    let count: Int = json["result"].count
                    let jsonDic = json["result"].dictionary!
                    let sortedKeysAndValues = jsonDic.sorted(by: { (d1, d2) -> Bool in
                        return d1 < d2 ? true : false
                    })
                    self.citynms = []
                    self.demoDatabase = []
                    self.cityInfos = [:]
                    for i in 0..<count {
                        //遍历所有城市 判断与搜索栏的城市的城市名相同 找到后跳出循环
                        let city = sortedKeysAndValues[i].value["citynm"].string!
                        let id = sortedKeysAndValues[i].value["weaid"].string!
                        if city == searchStr! {
                            let newcity: YNSearchData = YNSearchData(key: city)
                            self.demoDatabase.append(newcity)
                            self.citynms.append(city)
                            self.cityInfos[city] = id
                            break
                        }
                    }
                    print("搜索到的城市信息\(self.citynms)")
                    print("搜索到的城市字典信息\(self.cityInfos)")
                    DispatchQueue.main.async {
                        self.updateUI()
                    }
                } catch {
                    print("Error creating the database")
                }
            } else {
                print(error!)
            }
        }
        task.resume()
    }
}

//MARK:- UI界面更新
extension AddListViewController{
    ///当没有搜索结果时显示提示
    func NoneView(){
        let noneView = UIView()
        noneView.tag = 130
        noneView.frame = self.ynSearchView.ynSearchListView.frame
        noneView.backgroundColor = self.ynSearchView.backgroundColor
        noneView.isHidden = true
        self.ynSearchView.addSubview(noneView)
        let noneLabel = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 100))
        noneLabel.text = "没有找到结果"
        noneLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        noneLabel.textColor = UIColor.lightGray
        noneLabel.textAlignment = .center
        noneView.addSubview(noneLabel)
    }
    
    func updateUI() {
        self.initData(database: demoDatabase)
        self.ynSearchView.ynSearchListView.reloadData()
        let noneView = self.view.viewWithTag(130)
        if citynms == [] {
            noneView?.isHidden = false
            self.ynSearchView.ynSearchListView.isHidden = true
        } else {
            noneView?.isHidden = true
            self.ynSearchView.ynSearchListView.isHidden = false
        }
    }

}

//MARK:- CoreData数据处理
extension AddListViewController: NSFetchedResultsControllerDelegate {
    
    //判断是否已经保存过该城市的信息
    func fetHadCityInfos(resultCity: String)->Bool {
        //取回现有数据
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        var hadCityArray: [String] = []
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "CityInfo")
        
        do {
            let citysList = try context.fetch(fetchRequest)
            
            for city in citysList as! [CityInfo] {
                //遍历 将已存在的城市名称存放到hadCityArray数组中
                hadCityArray.append(city.city!)
            }
        } catch {
            print(error)
        }
        do {
            try context.save()
        } catch {
            print(error)
        }
        print("保存之前检查的时候收藏了\(hadCityArray.count)个城市")
        //判断 hadCityArray 数组中是否包含搜索结果的城市名
        
        return hadCityArray.contains(resultCity)
    }
    //如果存在弹出提示框
    func alertAction() {
        let alertController = UIAlertController(title: "提示",message: "列表中已存在该城市", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "好的", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
}
