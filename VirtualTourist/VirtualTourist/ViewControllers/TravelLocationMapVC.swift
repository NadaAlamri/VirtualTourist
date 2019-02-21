//
//  TravelLocationMapVC.swift
//  VirtualTourist
//
//  Created by Nada AlAmri on 20/05/1440 AH.
//  Copyright © 1440 udacity. All rights reserved.
//

import UIKit
import CoreData
import MapKit

class TravelLocationMapVC: UIViewController, MKMapViewDelegate , UIGestureRecognizerDelegate{
    
   
    var dataController : DataController!
    var coord : CLLocationCoordinate2D?
    var locationName: String?
    
    var coordS: String = ""
    //var imageIDs = [String]()
        var pin: Pin?
    
    
    @IBOutlet weak var mm: UIImageView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
         // fetch and add to map
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "coord != nil")
        if let result = try?  dataController.viewContext.fetch(fetchRequest)
        {
            var annotations = [MKPointAnnotation] ()
            for pin in result
            {
                let long = CLLocationDegrees (pin.long)
                let lat = CLLocationDegrees (pin.lat )
                let annotation = MKPointAnnotation()
                annotation.coordinate = CLLocationCoordinate2D (latitude: lat, longitude: long)
                
                 coordS = "\(lat)" + "\(long)"
                
                annotation.title = coordS
                
                annotations.append (annotation)
         
            }
            self.mapView.addAnnotations (annotations)
            
        }
       
    }
    
    @IBAction func AddPin(_ sender: UILongPressGestureRecognizer) {
       let location = sender.location(in: mapView)
        coord = mapView.convert(location, toCoordinateFrom: mapView)
        // var title = location.t
        
        // Add annotation:
        let annotation = MKPointAnnotation()
        annotation.coordinate = coord!
        
      let long = coord?.longitude
        let lat = coord?.latitude
    
        
        annotation.title = String(lat!)+String(long!) 
        mapView.addAnnotation(annotation)
        let region = MKCoordinateRegion(center: coord!, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01))
        mapView.setRegion(region, animated: true)
        
        AddTravelLocation(long: (coord?.longitude)!, lat: (coord?.latitude)!)
    }
    
    
    func AddTravelLocation(long: CLLocationDegrees, lat: CLLocationDegrees)
    {
        do{
            
            let pin = Pin(context: dataController.viewContext)
             pin.lat  = lat
             pin.long  = long
            coordS = String(lat)+String(long)
            pin.coord = coordS
             
             try dataController.viewContext.save()
            print("done")
        
           
        }
        catch let error
        {
           
            print(error)
        }
        
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
    
   
    
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView)
    {
       coord = view.annotation?.coordinate
        coordS = (view.annotation?.title!)!
      
        //fetch current location data
        let fetchRequest : NSFetchRequest<Pin> = Pin.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "coord == %@",coordS)
        if let result = try?  dataController.viewContext.fetch(fetchRequest)
        {
            if(result.count > 0)
            {
                pin = result[0]
            }
            else
            {
                return
            }
        }
       

       self.performSegue(withIdentifier: "viewPhoto", sender: view)
      
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?)
    {
       
        if segue.identifier == "viewPhoto", let vc = segue.destination as?  PhotoAlbumViewController
        {
            vc.coord = coord
            vc.pin = pin
            vc.dataController = dataController
     
        }
        
        
    }
        
    
}
