//
//  ViewController.swift
//  BusanMaket
//
//  Created by D7703_16 on 2018. 12. 26..
//  Copyright © 2018년 201526109. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, XMLParserDelegate, MKMapViewDelegate  {
    
    @IBOutlet weak var mapView: MKMapView!
    var item:[String:String] = [:]
    var elements:[[String:String]] = []
    var currentElement = ""
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.title = "부산시 전통시장 지도"
        mapView.delegate = self
        dataParsing()
        viewMap()
        
    }
    
    func  viewMap() {
        for maket in elements {
            let geoCoder = CLGeocoder()
            geoCoder.geocodeAddressString(maket["주소"]! , completionHandler: {
                (placemarks: [CLPlacemark]?, error: Error?) -> Void in
                if let error = error {
                    print(error)
                    return
                }
                
                if placemarks != nil {
                    let placemark = placemarks![0]
                    print(placemarks![0])
                    let annotation = MKPointAnnotation()
                    
                    if let location = placemark.location {
                        annotation.title = maket["시장명칭"]
                        annotation.coordinate = location.coordinate
                        annotation.subtitle = maket["전화번호"]
                        self.annotations.append(annotation)
                    }
                }
                self.mapView.showAnnotations(self.annotations, animated: true)
            })
        }
    }
    
    
    func dataParsing() {
        if let path = Bundle.main.url(forResource: "busanMaket", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                
                if parser.parse() {
                    print("parsing succed")
                    
                } else {
                    print("parsing failed")
                }
            }
        } else {
            print("xml파일을 확인 못함")
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "RE"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKMarkerAnnotationView
        
        if annotation is MKUserLocation {
            return nil
        }
        
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            annotationView!.canShowCallout = true
            annotationView?.animatesWhenAdded = true
            annotationView?.clusteringIdentifier = "CL"
            
        } else {
            annotationView?.annotation = annotation
        }
        
        let btn = UIButton(type: .detailDisclosure)
        annotationView?.rightCalloutAccessoryView = btn
        return annotationView
    }
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String]) {
        currentElement = elementName
    }
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        //let data2 = data.components(separatedBy: CharacterSet.alphanumerics.inverted).joined()
        
        //print("data = \(data)")
        
        if !data.isEmpty {
            item[currentElement] = string
        }
    }
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        
        if elementName == "Row" {
            elements.append(item)
        }
        
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            
        }
    }
    
}
