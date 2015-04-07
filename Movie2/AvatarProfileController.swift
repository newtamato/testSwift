//
//  AvatarProfileController.swift
//  Movie2
//
//  Created by 亮亮 侯 on 4/6/15.
//  Copyright (c) 2015 亮亮 侯. All rights reserved.
//

import UIKit

class AvatarProfileController:UIViewController,UITableViewDataSource,UITableViewDelegate{
    @IBOutlet weak var imgItem: UIImageView!
    @IBOutlet weak var textProfile: UITextView!
    
    @IBOutlet weak var listForMovies: UITableView!
    var mWorks:NSArray?;
    var data:NSString?
    override func viewDidLoad() {
        
        super.viewDidLoad()
        self.startToGetPhotoAbourTheId({data,error in
            self.loadAvatarPhoto(data)
        })
        self.startToFindAllInfoAboutTheId({movieData,error in
            self.loadJsonData(movieData)
            
        })
    }
    
    func startToGetPhotoAbourTheId(handler: ((movieData: NSDictionary, NSError!) -> Void)){

        if self.data != nil {
            
            var escapedSearchTerm:NSString = self.data!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            println(escapedSearchTerm)
            var path:NSString = "http://api.douban.com/v2/movie/celebrity/\(escapedSearchTerm)/photos"
            if let url = NSURL(string: path){
                var request: NSURLRequest = NSURLRequest(URL: url)
                NSURLConnection.sendAsynchronousRequest(request,
                    queue: NSOperationQueue.mainQueue(),
                    completionHandler:{response, data, error in
                        handler(movieData:NSJSONSerialization.JSONObjectWithData(data!,options:NSJSONReadingOptions.AllowFragments,error:nil) as NSDictionary, error)
                })
            }
        }
    }
    
    
    func startToFindAllInfoAboutTheId(handler: ((movieData: NSDictionary, NSError!) -> Void)){

        if self.data != nil {
            
            var escapedSearchTerm:NSString = self.data!.stringByAddingPercentEscapesUsingEncoding(NSUTF8StringEncoding)!
            println(escapedSearchTerm)
            var path:NSString = "http://api.douban.com/v2/movie/celebrity/\(escapedSearchTerm)"
            if let url = NSURL(string: path){
                var request: NSURLRequest = NSURLRequest(URL: url)
                NSURLConnection.sendAsynchronousRequest(request,
                    queue: NSOperationQueue.mainQueue(),
                    completionHandler:{response, data, error in
                        handler(movieData:NSJSONSerialization.JSONObjectWithData(data!,options:NSJSONReadingOptions.AllowFragments,error:nil) as NSDictionary, error)
                })
            }
        }
    }
    func loadAvatarPhoto(data:NSDictionary){
        
    }
    func loadJsonData(infoJson:NSDictionary){
//        println(infoJson)
        var largeImg:NSString = (infoJson.objectForKey("avatars") as NSDictionary).objectForKey("large") as NSString
        self.downloadImage(NSURL(string: largeImg)!,{image,error in
            self.imgItem.image = image
            
        })
        
        

        
        self.mWorks = infoJson.objectForKey("works") as NSArray
        
        self.listForMovies.dataSource = self
        self.listForMovies.delegate = self
        self.listForMovies.reloadData()
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.mWorks != nil {
            return self.mWorks!.count
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell:MovieItemTableViewCell = tableView.dequeueReusableCellWithIdentifier("movieNameItem") as MovieItemTableViewCell
//        var cell:AvatarItemTableViewCell = tableView.dequeueReusableCellWithIdentifier("avatarItem") as AvatarItemTableViewCell
        var itemData:NSDictionary = self.mWorks!.objectAtIndex(indexPath.row) as NSDictionary
        var title:NSString = (itemData.objectForKey("subject") as NSDictionary).objectForKey("title") as NSString
        cell.labelMovieName.text = title
        var path:NSString = ((itemData.objectForKey("subject") as NSDictionary).objectForKey("images") as NSDictionary).objectForKey("medium") as NSString
        self.downloadImage(NSURL(string: path)!,{image,error in
            cell.imgMovie.image = image
        })
        return cell
    }
    func downloadImage(url: NSURL, handler: ((image: UIImage, NSError!) -> Void))
    {
        var imageRequest: NSURLRequest = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(imageRequest,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{response, data, error in
                handler(image: UIImage(data: data)!, error)
        })
    }
    
    
}
