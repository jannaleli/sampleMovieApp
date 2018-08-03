//
//  SearchAndDisplayView.swift
//  movieSort
//
//  Created by Jann Aleli Zaplan on 31/7/18.
//  Copyright © 2018 Jann Aleli Zaplan. All rights reserved.
//
//
//  ViewController.swift
//  Hitist
//
//  Created by Jann Aleli Zaplan on 31/7/18.
//  Copyright © 2018 Jann Aleli Zaplan. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var movieList: [NSManagedObject] = []
    @IBOutlet weak var searchBar: UISearchBar?
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "The List"
        tableView.register(UITableViewCell.self,
                           forCellReuseIdentifier: "Cell")
        

     
        
   
        // Do any additional setup after loading the view, typically from a nib.
    }
    func save(name: Any, key:String) {
        
        guard let appDelegate =
       
            UIApplication.shared.delegate as? AppDelegate else {
                return
        }
        
        // 1
        let managedContext =
            appDelegate.persistentContainer.viewContext
        
        // 2
        let entity =
            NSEntityDescription.entity(forEntityName: "Movies",
                                       in: managedContext)!
        
        let movie = NSManagedObject(entity: entity,
                                     insertInto: managedContext)
        
        // 3
        movie.setValue(name, forKeyPath: key)
        
        
        // 4
        do {
            try managedContext.save()
            movieList.append(movie)
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    @IBAction func search(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "New Name",
                                      message: "Add a new name",
                                      preferredStyle: .alert)
        
        let searchAction = UIAlertAction(title: "Search", style: .default) {
            [unowned self] action in
            
            guard let textField = alert.textFields?.first,
                let nameToSave = textField.text else {
                    return
            }
            
            CallAPI().getMovie(keyword: nameToSave, year: 2017, page: 1, completionBlock: { data, error in
                
                if error == nil {
                    print(data!)
                    
                    guard let jsonArray = data! as? [String:AnyObject] else {
                        print("ERROR ERROR ERROR")
                        return
                    }
                    
                    let arrayObjects = jsonArray["results"] as? [[String:AnyObject]]
                    
                    for each in arrayObjects! {
                        print(each["original_title"] as? String)
                        DispatchQueue.main.async {
                            //1 name
                            self.save(name: (each["title"] as? String)!, key: "name")
                            //2 rating
                            let rating = each["popularity"] as? NSNumber
                           
                            self.save(name: rating, key: "ratings")
                            //3 overview
                            self.save(name: (each["overview"] as? String)!, key: "overview")
                            //4 release date
                            let dateString = each["release_date"] as? String
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                            let date = dateFormatter.date(from:dateString!)!
                            let calendar = Calendar.current
                            let components = calendar.dateComponents([.year, .month, .day, .hour], from: date)
                            let finalDate = calendar.date(from:components)
                            self.save(name: finalDate, key: "releaseDate")
                        }
                        
                    }
                    
                    
                    
                  
                }else{
                    
                }
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
                
            })
          
          
        }
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .default)
        
        alert.addTextField()
        
        alert.addAction(searchAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    
    func displayAlert(message: String){
        let alert = UIAlertController(title: "Warning",
                                      message: message,
                                      preferredStyle: .alert)
        
        

        
        let cancelAction = UIAlertAction(title: "Okay",
                                         style: .default)
        
        alert.addTextField()
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

}


// MARK: - UITableViewDataSource
extension ViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        return movieList.count
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath)
        -> UITableViewCell {
            
            let movie = movieList[indexPath.row]
            let cell =
                tableView.dequeueReusableCell(withIdentifier: "Cell",
                                              for: indexPath)
            cell.textLabel?.text =
                movie.value(forKeyPath: "name") as? String
            return cell
    }
}

