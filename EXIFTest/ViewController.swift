//
//  ViewController.swift
//  EXIFTest
//

import UIKit
import MapKit

class ViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var iImageView: UIImageView!
    @IBOutlet weak var mMapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        print("aaa")
        guard let filePath = Bundle.main.path(forResource: "MitakaEkimae", ofType: "JPG") else {
            print("Bundle path creation failed")
            return
        }

        let nsUrl = NSURL(fileURLWithPath: filePath) // 1.

        print("bbb")
        if let imageSource = CGImageSourceCreateWithURL(nsUrl, nil) { // 2.
            
            do {
                let url = URL(fileURLWithPath: filePath)
                let data = try Data(contentsOf: url)
                iImageView.image = UIImage(data:data as Data);
                
                print("ccc")
                //if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) {
                if let imageProperties = CGImageSourceCopyPropertiesAtIndex(imageSource, 0, nil) as! Dictionary<String, AnyObject>? { // 3.
                    print(imageProperties)
                    print("----------------------------------------------------------------------")

                    print("ddd")
                    //if let dict = imageProperties as? [String: Any] {
                    //    dump(dict)
                    //}

                    //let sortedKeys:Array = Array(imageProperties.keys)
                    ////sortedKeys = sortedKeys.sorted(by: {$0 < $1}) // Binary operator '<' cannot be applied to two 'NSObject' operands
                    //for k in sortedKeys {
                    //    print( "## " + ( k as! String ) + " = " )
                    //    print(imageProperties[k]!)
                    //    print("\n")
                    //}
                    
                    if let gpsValue = imageProperties["{GPS}"] { // 4.
                        let latValue = gpsValue["Latitude"] as? Double ?? 0
                        let lonValue = gpsValue["Longitude"] as? Double ?? 0
//print("---- \(latValue) \(lonValue) ----")
                        // 緯度・経度を設定
                        let location:CLLocationCoordinate2D
                            //= CLLocationCoordinate2DMake(35.68154,139.752498)
                            = CLLocationCoordinate2DMake(latValue, lonValue)
                        
                        mMapView.setCenter(location, animated:true)
                        
                        // 縮尺を設定
                        //var region:MKCoordinateRegion = mMapView.region
                        //region.center = location
                        //region.span.latitudeDelta = 0.02
                        //region.span.longitudeDelta = 0.02
                        //mMapView.setRegion(region, animated:true)
                        
                        // MKPointAnnotationインスタンスを取得し、ピンを生成
                        let pin = MKPointAnnotation()
                        pin.coordinate = location
                        mMapView.addAnnotation(pin)
                        
                        // 検索地点の緯度経度を中心に半径500mの範囲を表示
                        mMapView.region = MKCoordinateRegion(center: location, latitudinalMeters: 500.0, longitudinalMeters: 500.0)
                        
                        let locationForGeo = CLLocation(latitude: latValue, longitude: lonValue)
                        CLGeocoder().reverseGeocodeLocation(locationForGeo) { placemarks, error in
                            guard let placemark = placemarks?.first, error == nil else { return }
                            // あとは煮るなり焼くなり
                            let kuni = placemark.country ?? "Unknown"
                            let ken = placemark.administrativeArea ?? "Unknown"
                            let ku = placemark.locality ?? ""
                            let tyou = placemark.thoroughfare ?? ""
                            let banchi = placemark.subThoroughfare ?? ""
                            
                            let juusyo = kuni + ", " + ken  + ", " + ku + ", " + tyou + ", " + banchi
                            
                            print(juusyo)
                        }
                        
                    } else {
                        print("Place unknown")
                    }
                    
                } else {
                    print("imageProperties is nil")
                }
                
            } catch let err {
                print("Error : Cannot convert to URL object... \(err.localizedDescription)")
            }
            
        } else {
            print("imageSource is nil")
        }
        
    }

}

