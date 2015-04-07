//
//  ViewController.swift
//  Movie2
//
//  Created by 亮亮 侯 on 4/5/15.
//  Copyright (c) 2015 亮亮 侯. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITextFieldDelegate,UITableViewDataSource,UITableViewDelegate{

    @IBOutlet weak var avatarTableView: UITableView!
    @IBOutlet weak var inputName: UITextField!
    @IBOutlet weak var image: UIImageView!
    var mSelectedRow:NSInteger?
    var mRight:NSString?
    var mMovieJsonData:NSDictionary?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.mSelectedRow = -1
        // Do any additional setup after loading the view, typically from a nib.
        
        self.inputName.delegate = self
        self.mRight = "123"
        self.inputName.borderStyle = UITextBorderStyle.RoundedRect
    

        self.image.contentMode = UIViewContentMode.ScaleAspectFit
       
        self.searchMovieByName("成龙",{movieData, error in
            self.loadJsonData(movieData)
        } )
       
  
//        loadJsonData()
        
       
    }
    func initTheHorTableView(){
        self.avatarTableView.separatorStyle = UITableViewCellSeparatorStyle.None
        self.avatarTableView.delegate = self
        self.avatarTableView.dataSource = self
        self.avatarTableView.reloadData()
    }
    
    
    //解析JSON的方法
    func loadJsonData(json:NSDictionary){
        println(json)
        var total:NSInteger = json.objectForKey("total") as NSInteger
        if total == 0 {
            println("没有搜素的到呢！")
            return
        }
        //定义获取json数据的接口地址，这里定义的是获取天气的API接口,还有一个好处，就是swift语句可以不用强制在每条语句结束的时候用";"
//        var url = NSURL(string:"http://api.douban.com/v2/movie/subject/24753810")
//        //获取JSON数据
//        var data = NSData(contentsOfURL:url!)
//        var json:AnyObject = NSJSONSerialization.JSONObjectWithData(data!,options:NSJSONReadingOptions.AllowFragments,error:nil)!
        var movieItems:NSArray = json.objectForKey("subjects") as NSArray
        self.mMovieJsonData = movieItems[0] as NSDictionary//json as? NSDictionary
        //解析获取JSON字段值
//        var weatherInfo:AnyObject = json.objectForKey("weatherinfo")! //json结构字段名。
//        var city:AnyObject = weatherInfo.objectForKey("city")!
        var images:NSDictionary =  self.mMovieJsonData!.objectForKey("images") as NSDictionary
        var large:NSString = images.objectForKey("large") as NSString
        println(large)
        
        if let checkedUrl = NSURL(string: large){
            
            self.downloadImage2(checkedUrl, {image, error in
                self.image.image = image
            })
        }
        initTheHorTableView()
        
    }
    func downloadImage2(url: NSURL, handler: ((image: UIImage, NSError!) -> Void))
    {
        var imageRequest: NSURLRequest = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(imageRequest,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{response, data, error in
                handler(image: UIImage(data: data)!, error)
        })
    }
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func textFieldShouldReturn(textField: UITextField) -> Bool{
        self.commitUserAnswer()
        textField.resignFirstResponder()
        return true
    }
//    演员表
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if (self.mMovieJsonData != nil) {
            let casts:NSArray = self.mMovieJsonData?.objectForKey("casts") as NSArray
            return casts.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell{
        var cell:AvatarItemTableViewCell = tableView.dequeueReusableCellWithIdentifier("avatarItem") as AvatarItemTableViewCell
        if (self.mMovieJsonData != nil) {
            let casts:NSArray = self.mMovieJsonData?.objectForKey("casts") as NSArray
            var itemJson:NSDictionary = casts[indexPath.row] as NSDictionary
            var name:NSString = itemJson.objectForKey("name") as NSString
            cell.labelName.text = name
            
            var avatarImg:NSString = (itemJson.objectForKey("avatars") as NSDictionary).objectForKey("small") as NSString
            if let checkedUrl = NSURL(string: avatarImg){
                self.downloadImage2(checkedUrl, {image, error in
                    cell.imgAvatar.image = image
                })
            }
            
        }
        
        return cell
    }
    
    func searchMovieByName(qName:NSString,handler: ((movieData: NSDictionary, NSError!) -> Void)){
//        /v2/movie/search?q=
        var escapedSearchTerm:NSString = qName.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
        println(escapedSearchTerm)
        var path:NSString = "http://api.douban.com/v2/movie/search?q=\(escapedSearchTerm)"
        
        println(path)
        if let url = NSURL(string: path){
            var request: NSURLRequest = NSURLRequest(URL: url)
            NSURLConnection.sendAsynchronousRequest(request,
                queue: NSOperationQueue.mainQueue(),
                completionHandler:{response, data, error in
                    handler(movieData:NSJSONSerialization.JSONObjectWithData(data!,options:NSJSONReadingOptions.AllowFragments,error:nil) as NSDictionary, error)
            })
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        println("被选中了么？")
        self.mSelectedRow = indexPath.row
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
//        self.mMovieJsonData?.objectForKey("casts")
        print("被选中的行是\(self.mSelectedRow)")
        if self.mSelectedRow != -1 {
           
            
        }
        if let cell = sender as? UITableViewCell {
            let i = self.avatarTableView.indexPathForCell(cell)?.row
//            self.mSelectedRow = i as NSInteger
            let casts:NSArray = self.mMovieJsonData?.objectForKey("casts") as NSArray
            var itemJson:NSDictionary = casts[i!] as NSDictionary
            (segue.destinationViewController as AvatarProfileController).data = itemJson.objectForKey("id") as NSString

//            if segue.identifier == "toRestaurant" {
//                let vc = segue.destinationViewController as RestaurantViewController
//                vc.data = currentResponse[i] as NSDictionary
//            }
        }

    }
    
    
    
    @IBAction func onCommitTheAnswer(sender: AnyObject) {
        self.commitUserAnswer()
    }
    
    func commitUserAnswer(){
        if self.inputName.text == self.mRight {
            println("正确")
        }else{
            println("错了")
        }
    }
}

