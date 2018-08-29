//
//  AddList.swift
//  LRWeather
//
//  Created by lance ren on 2018/8/28.
//  Copyright © 2018年 lanceren. All rights reserved.
//

import Foundation
import UIKit
import Hero
import CoreData
import YNSearch

class YNDropDownMenu: YNSearchModel {
    var starCount = 512
    var description = "Awesome Dropdown menu for iOS with Swift 3"
    var version = "2.3.0"
    var url = "https://github.com/younatics/YNDropDownMenu"
}

class YNSearchData: YNSearchModel {
    var title = "YNSearch"
    var starCount = 271
    var description = "Awesome fully customize search view like Pinterest written in Swift 3"
    var version = "0.3.1"
    var url = "https://github.com/younatics/YNSearch"
}

class YNExpandableCell: YNSearchModel {
    var title = "YNExpandableCell"
    var starCount = 191
    var description = "Awesome expandable, collapsible tableview cell for iOS written in Swift 3"
    var version = "1.1.0"
    var url = "https://github.com/younatics/YNExpandableCell"
}

//MARK:- AddListViewController
class AddListViewController: YNSearchViewController, YNSearchDelegate {
    
    @IBOutlet weak var CancelButton: UIButton!
    var cityInfo : CityInfo!
    var cityInfosMO : [CityInfo] = []
    var fc : NSFetchedResultsController<CityInfo>!
    var citynms : [String] = [] //收藏城市数组
    var cityInfos : Dictionary<String, String> = [:] //城市name<->id
    let todayDate = Date()
    let formatter = DateFormatter()
    let demoCategories = ["Menu", "Animation", "Transition", "TableView", "CollectionView", "Indicator", "Alert", "UIView", "UITextfield", "UITableView", "Swift", "iOS", "Android"]
    let demoSearchHistories = ["Menu", "Animation", "Transition", "TableView"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.hero.isEnabled = true
        
        let ynSearch = YNSearch()
        ynSearch.setCategories(value: demoCategories)
        ynSearch.setSearchHistories(value: demoSearchHistories)
        
        self.ynSearchinit()
        self.ynSearchTextfieldView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))//搜索输入栏的颜色
        self.ynSearchTextfieldView.ynSearchTextField.placeholder = "Search the City what you want"
        
        self.view.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))//最上层的颜色
        self.view.bringSubview(toFront: CancelButton)
        self.delegate = self
//        self.navigationController?.setNavigationBarHidden(true, animated: false)
//cell内默认项目
        let database1 = YNDropDownMenu(key: "YNDropDownMenu")
        let database2 = YNSearchData(key: "YNSearchData")
        let database3 = YNExpandableCell(key: "YNExpandableCell")
        let demoDatabase = [database1, database2, database3]
        self.initData(database: demoDatabase)
        self.setYNCategoryButtonType(type: .border)
        //当没有搜索结果时显示提示
       NoneView()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ynSearchListViewDidScroll() {
        self.ynSearchTextfieldView.ynSearchTextField.endEditing(true)
    }
    
    func ynSearchHistoryButtonClicked(text: String) {
        self.pushViewController(text: text)
        print(text)
    }
    
    func ynCategoryButtonClicked(text: String) {
        self.pushViewController(text: text)
        print(text)
    }
    
    func ynSearchListViewClicked(key: String) {
        self.pushViewController(text: key)
        print(key)
    }
    
    func ynSearchListViewClicked(object: Any) {
        print(object)
    }
    
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        getCityData()
        return true
    }
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.CancelButton.isHidden = true
        return true
    }
    override func ynSearchTextfieldcancelButtonClicked() {
        super.ynSearchTextfieldcancelButtonClicked()
        self.CancelButton.isHidden = false 
    }
    
    
    func ynSearchListView(_ ynSearchListView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.ynSearchView.ynSearchListView.dequeueReusableCell(withIdentifier: YNSearchListViewCell.ID) as! YNSearchListViewCell
        if let ynmodel = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? YNSearchModel {
            cell.searchLabel.text = ynmodel.key
            //cell.searchLabel.text = citynms[indexPath.row]
        }
        cell.backgroundColor = UIColor.clear
        self.ynSearchView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))//tableview.superview的颜色
        ynSearchListView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))//tableview的颜色

        return cell
    }
    
    func ynSearchListView(_ ynSearchListView: UITableView, numberOfRowsInSection indexPath: IndexPath) -> Int {
        return citynms.count
    }
    
    func ynSearchListView(_ ynSearchListView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ynmodel = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? YNSearchModel, let key = ynmodel.key {
            self.ynSearchView.ynSearchListView.ynSearchListViewDelegate?.ynSearchListViewClicked(key: key)
            self.ynSearchView.ynSearchListView.ynSearchListViewDelegate?.ynSearchListViewClicked(object: self.ynSearchView.ynSearchListView.database[indexPath.row])
            self.ynSearchView.ynSearchListView.ynSearch.appendSearchHistories(value: key)
            
            let isHad = fetHadCityInfos(resultCity: citynms[indexPath.row])
            if isHad == true {
                alertAction()
            } else {
                //不存在则将城市名，时间（作为排序依据） id（json解析需要使用）保存到CoreData中
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                cityInfo = CityInfo(context: appDelegate.persistentContainer.viewContext)
                cityInfo.city = citynms[indexPath.row]
                cityInfo.id = cityInfos[citynms[indexPath.row]]
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                cityInfo.order = formatter.string(from: todayDate)
                appDelegate.saveContext()
                
            }
        }
    }
    
    
    @IBAction func CancelToMain(_ sender: Any) {
        hero.dismissViewController()
    }
    func pushViewController(text:String) {
        
        hero.modalAnimationType = .fade
        hero.dismissViewController()
    }
    
    func NoneView(){
        let noneView = UIView()
        noneView.tag = 130
        noneView.frame = self.ynSearchView.ynSearchListView.frame
        noneView.backgroundColor = self.ynSearchView.ynSearchListView.backgroundColor
        noneView.isHidden = true
        self.view.addSubview(noneView)
        let noneLabel = UILabel(frame: CGRect(x: 0, y: 0, width: weatherSize.screen_w, height: 100))
        noneLabel.text = "没有找到结果"
        noneLabel.font = UIFont(name: "HelveticaNeue-Light", size: 16)
        noneLabel.textColor = UIColor.lightGray
        noneLabel.textAlignment = .center
        noneView.addSubview(noneLabel)
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
                    self.cityInfos = [:]
                    for i in 0..<count {
                        //遍历所有城市 判断与搜索栏的城市的城市名相同 找到后跳出循环
                        let city = sortedKeysAndValues[i].value["citynm"].string!
                        let id = sortedKeysAndValues[i].value["weaid"].string!
                        if city == searchStr! {
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
    
    func updateUI() {
        self.ynSearchView.ynSearchListView.reloadData()
        let noneView = self.view.viewWithTag(130)
        if citynms == [] {
            noneView?.isHidden = false
        } else {
            noneView?.isHidden = true
        }
    }
}

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


