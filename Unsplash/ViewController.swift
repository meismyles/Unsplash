//
//  ViewController.swift
//  Unsplash
//
//  Created by Myles Ringle on 06/10/2016.
//  Copyright © 2016 MadeFresh. All rights reserved.
//

import SDWebImage
import UIKit

class ViewController: UIViewController {

    @IBOutlet fileprivate weak var tableView: UITableView!
    @IBOutlet fileprivate weak var loadingSpinner: UIActivityIndicatorView!
    fileprivate var numberOfImages: Int = 0
    fileprivate var imagesArray = [UIImage?]()
    fileprivate var timer = Timer()
    fileprivate var appActive = true
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.start), name: Notification.Name("Active"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.stop), name: Notification.Name("Inactive"), object: nil)
        
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(ViewController.clear))
        self.navigationItem.leftBarButtonItem?.tintColor = UIColor.black
        
        self.tableView.separatorInset = .zero
        self.tableView.tableFooterView = UIView()
        
        self.start()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func start() {
        print("*** STARTING ***")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .pause, target: self, action: #selector(ViewController.stop))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        self.newImage()
        self.appActive = true
        self.timer = Timer.scheduledTimer(timeInterval: 5,
                                          target: self,
                                          selector: #selector(self.newImage),
                                          userInfo: nil,
                                          repeats: true)
    }
    
    func stop() {
        print("*** STOPPING ***")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(ViewController.start))
        self.navigationItem.rightBarButtonItem?.tintColor = UIColor.black
        self.appActive = false
        self.timer.invalidate()
    }
    
    func clear() {
        print("*** CLEARING ***")
        SDImageCache.shared().clearMemory()
        SDImageCache.shared().clearDisk()
        self.numberOfImages = 0
        self.imagesArray.removeAll()
        self.tableView.reloadData()
    }
    
    func newImage() {
        print("*** GETTING NEW IMAGE ***")
        SDWebImageManager.shared().downloadImage(with: URL(string: "https://source.unsplash.com/random/750x750#\(self.numberOfImages)"), options: .cacheMemoryOnly, progress: { (_, _) in }, completed:  { (image, error, cacheType, checkBool, url) in
            
            if error == nil && self.appActive {
                self.loadingSpinner.stopAnimating()
                
                self.imagesArray.append(image)
                self.numberOfImages += 1
                self.tableView.beginUpdates()
                let newIndexPath = IndexPath(row: self.numberOfImages-1, section: 0)
                self.tableView.insertRows(at: [newIndexPath], with: .automatic)
                self.tableView.endUpdates()
                if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height)) {
                    self.tableView.scrollToRow(at: IndexPath(row: self.numberOfImages-1, section: 0), at: .bottom, animated: true)
                }
            }
        })
    }
}

extension ViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfImages
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return tableView.frame.width
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "Cell") as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: "Cell")
        }
        
        cell?.selectionStyle = .none
        cell?.imageView?.image = self.imagesArray[indexPath.row]
        DispatchQueue.main.async {
            cell?.imageView?.frame = CGRect(x: 0, y: 0, width: tableView.frame.width, height: tableView.frame.width)
        }
        
        return cell!
    }
}
