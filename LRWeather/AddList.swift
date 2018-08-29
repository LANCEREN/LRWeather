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

//MARK:- AddListViewController
class AddListViewController: YNSearchViewController, YNSearchDelegate {
    
    @IBOutlet weak var CancelButton: UIButton!
    var cityInfo : CityInfo!//储存coredata的实例
    var cityInfosMO : [CityInfo] = []//?可以作为已经收藏的城市列表的fc返回值
    var fc : NSFetchedResultsController<CityInfo>!//coredata?
    var citynms : [String] = [] //搜索到的要添加的城市（可能会有重名的）
    var cityInfos : Dictionary<String, String> = [:] //搜索到的要添加的城市的字典城市name<->id
    let todayDate = Date()
    let formatter = DateFormatter()
    let demoCategories = ["Menu", "Animation", "Transition", "TableView", "CollectionView", "Indicator", "Alert", "UIView", "UITextfield", "UITableView", "Swift", "iOS", "Android"]
    let demoSearchHistories = ["Menu", "Animation", "Transition", "TableView"]
    var demoDatabase: [YNSearchData] = []
    
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
        //FIXME:不能添加
        let database1 = YNSearchData(key: "杭州")
        demoDatabase.append(database1)
        self.initData(database: demoDatabase)
        self.setYNCategoryButtonType(type: .border)
        //当没有搜索结果时显示提示
        NoneView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK:- YNSearchViewController: UIViewController, UITextFieldDelegate
    //MARK:YNSearchDelegate: YNSearchMainViewDelegate, YNSearchListViewDelegate
    
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
        super.textFieldShouldReturn(textField)
        getCityData()
        view.endEditing(true)
        return true
    }
    open func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        self.CancelButton.isHidden = true
        return true
    }
    override func ynSearchTextfieldcancelButtonClicked() {
        super.ynSearchTextfieldcancelButtonClicked()
        self.CancelButton.isHidden = false
        let noneView = self.view.viewWithTag(130)
        noneView?.isHidden = true
    }
    
    
    func ynSearchListView(_ ynSearchListView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = self.ynSearchView.ynSearchListView.dequeueReusableCell(withIdentifier: YNSearchListViewCell.ID) as! YNSearchListViewCell
        if let ynmodel = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? YNSearchModel {
            cell.searchLabel.text = ynmodel.key
            //cell.searchLabel.text = citynms[indexPath.row]
        }
        cell.backgroundColor = UIColor.clear
        self.ynSearchView.ynSearchMainView.backgroundColor = nil//tableview.superview上的颜色
        self.ynSearchView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))//tableview.superview下的颜色
        ynSearchListView.backgroundColor = UIColor(patternImage: #imageLiteral(resourceName: "background"))//tableview的颜色
        return cell
    }
    
    //123
    func ynSearchListView(_ ynSearchListView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return citynms.count
    }
    
    func ynSearchListView(_ ynSearchListView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let ynmodel = self.ynSearchView.ynSearchListView.searchResultDatabase[indexPath.row] as? YNSearchModel, let key = ynmodel.key
        {
            self.ynSearchView.ynSearchListView.ynSearchListViewDelegate?.ynSearchListViewClicked(key: key)
            self.ynSearchView.ynSearchListView.ynSearchListViewDelegate?.ynSearchListViewClicked(object: self.ynSearchView.ynSearchListView.database[indexPath.row])
            self.ynSearchView.ynSearchListView.ynSearch.appendSearchHistories(value: key)
        }
        CheckCityisHad(CitynmsRow: indexPath.row)
    }
    
    //MARK:- 页面跳转
    @IBAction func CancelToMain(_ sender: Any) {
        hero.modalAnimationType = .uncover(direction: .down)
        hero.dismissViewController()
    }
    func pushViewController(text:String) {
        
        hero.modalAnimationType = .fade
        hero.dismissViewController()
    }
}



