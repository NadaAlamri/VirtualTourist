//
//  PhotoAlbumViewController.swift
//  VirtualTourist
//
//  Created by Nada AlAmri on 20/05/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import UIKit
import MapKit
import  CoreData

class PhotoAlbumViewController: UIViewController, MKMapViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate  {
    
    var dataController: DataController!
    
    @IBAction func BackBtn(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var NewCollectionBtn: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var photoLbl: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    
    var coord: CLLocationCoordinate2D?
    var name: String?
    var pin: Pin?
    var photoCount: Int = 0
    
    var photos = [UIImage]()
    
    //==============
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        flowLayout.minimumInteritemSpacing = 1
        flowLayout.minimumLineSpacing = 1
        flowLayout.itemSize = CGSize(width: 135, height: 135)
        
        photoCount = (pin?.has?.count)!
        print(photoCount)
        if photoCount > 0 {
            
            let photoObjects = pin?.has?.allObjects
            
            for photoData in photoObjects! {
                
                let photo = photoData as! Photos
                let image = UIImage(data: photo.image as! Data)
                photos.append(image!)
            }
        }
        else
        {
            
            flicker()
        }
        
        
        
        collectionView?.reloadData()
        collectionView?.allowsMultipleSelection = true;
        
        
        
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coord!
        annotation.title = name
        
        self.mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coord!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseId = "pin"
        
        var pin = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        if pin == nil {
            pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pin!.canShowCallout = true
            //   pin!.pinTintColor = .red
            pin!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pin!.annotation = annotation
        }
        
        return pin
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let space:CGFloat = 3.0
        let dimension = (view.frame.size.width - (2 * space)) / 3.0
        let hdimention = (view.frame.size.height - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: hdimention)
        
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photoCount
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionCell", for: indexPath) as! CollectionCell
        
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        cell.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.015)
        
        
        DispatchQueue.main.async {
            if self.photos.count >= indexPath.item + 1 {
                // Display photo
                cell.photoCell.image = self.photos[indexPath.item]
            }
                
            else
            {
                cell.photoCell.image = nil
               
            }
        }
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath:IndexPath) {
        if self.NewCollectionBtn.isEnabled == false {
            let alert = UIAlertController(title: "Loading", message: "Loading Photos...", preferredStyle: .alert )
            
            alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
                return
            }))
            self.present(alert, animated: true, completion: nil)
        }
        else {
            self.photoCount -= 1
            self.photos.remove(at: indexPath.item)
            self.collectionView.deleteItems(at: [indexPath])
            
            // Remove from DB
            let photoObjs = self.pin?.has?.allObjects
            let photoObj = photoObjs?[indexPath.item] as? Photos
            
            do {
                dataController.viewContext.delete(photoObj!)
                try dataController.viewContext.save()
            }
            catch let error
            {
                print(error)
            }
        }
        return
    }
    
    @IBAction func NewCollectionBtn(_ sender: Any) {
        
        self.NewCollectionBtn.isEnabled = false
        photoCount = 0
        photos = [UIImage]()
        let photoSet = pin?.has
        for photo in photoSet! {
            dataController.viewContext.delete(photo as! NSManagedObject)
        }
        
        collectionView.reloadData()
        flicker()
    }
    
    func flicker()
    {
        
        
        FlickerAPI.pageNo(latitude: (coord?.latitude)!, longitude: (coord?.longitude)!) { (pageNo,  error) in
            DispatchQueue.main.async {
                if error != nil {
                    
                    self.showAlert("Error in getting page No", message: error as! String)
                }
                if (pageNo != nil && pageNo! > 0)
                {
                    let number =  Int(arc4random_uniform(UInt32(pageNo!) + 1))
                    
                    FlickerAPI.searchPhoto(latitude: (self.coord?.latitude)!, longitude: (self.coord?.longitude)!, limit: 12, page: number) { (result,  error) in
                        DispatchQueue.main.async {
                            
                            if error != nil {
                                
                                self.showAlert("Error", message: error as! String)
                            }
                            guard let imageIds = result else {
                                self.showAlert("Error", message: "There is no photo for the specified location ")
                                return
                            }
                            
                            self.photoCount = imageIds.count
                            
                            DispatchQueue.main.async {
                                self.collectionView.reloadData()
                            }
                            
                            for id in imageIds
                            {
                                FlickerAPI.getPhotoURL(id: id, completion: { (urls, errorUrl) in
                                    if errorUrl != nil {
                                        
                                        self.showAlert("Error", message: "There was an error performing your request")
                                        
                                    }
                                    guard let imgeUrl = urls else {
                                        self.showAlert("Error", message: "no image URL were found")
                                        return
                                    }
                                    let downloadImage = try! UIImage(data: Data(contentsOf: URL (string:imgeUrl)!))
                                    self.photos.append(downloadImage!)
                                    
                                    
                                    DispatchQueue.main.sync {
                                        
                                        do{
                                            
                                            let image = Photos(context: self.dataController.viewContext)
                                            image.image = UIImagePNGRepresentation(downloadImage!) as Data?
                                            self.pin?.addToHas(image)
                                            try self.dataController.viewContext.save()
                                            print(self.pin?.has?.count ?? 0)
                                            
                                            
                                            
                                            let path = IndexPath(item: self.photos.count - 1, section: 0)
                                            self.collectionView.reloadItems(at: [path])//*****ERROR
                                            
                                            // Enable create button once downloaded photo count matches expected count
                                            if self.photos.count == self.photoCount {
                                                self.NewCollectionBtn.isEnabled = true
                                            }
                                            
                                        }
                                        catch let error
                                        {
                                            print(error)
                                        }
                                    }
                                })
                            }
                            
                        }
                        
                    }
                    
                    
                }
                else
                {
                    self.showAlert("Error", message: "no result were found")
                    self.photoLbl.text = "no images were found"
                }
                
            }
            
        }
        
        
    }
    
    func showAlert(_ title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction (title: "OK", style: .default, handler: { _ in
            return
        }))
        self.present(alert, animated: true, completion: nil)
        return
    }
    
    
}
