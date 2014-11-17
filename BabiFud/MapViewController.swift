

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {
  
  @IBOutlet var mapView: MKMapView!
  
  func mapView(mapView: MKMapView!, regionWillChangeAnimated animated: Bool) {
    let region = mapView.region;
    
    
    let cla = round(region.center.latitude * 100.0) / 100.0
    let clo = round(region.center.longitude * 100.0) / 100.0
    let center = CLLocation(latitude:  cla,
                            longitude: clo)
    
    //note this works for US hemisphere
    let upperLeft = CLLocationCoordinate2DMake(
      region.center.latitude - region.span.latitudeDelta,
      region.center.longitude + region.span.longitudeDelta)
    let corner = CLLocation(latitude:  upperLeft.latitude,
                            longitude: upperLeft.longitude)
    let distance = center.distanceFromLocation(corner)
    
    let mapCenter = CLLocation(coordinate: mapView.centerCoordinate, altitude: 0, horizontalAccuracy: 0, verticalAccuracy: 0, timestamp: nil)
    
    Model.sharedInstance().fetchEstablishments(mapCenter, radiusInMeters: distance) {
      results, error in
      if let err = error {
        let message = error.localizedDescription
        let alert = UIAlertView(title: "Error Loading Establishments",
          message: message,
          delegate: nil,
          cancelButtonTitle: "OK")
        alert.show()
      } else {
        mapView.removeAnnotations(mapView.annotations);
        mapView.addAnnotations(results)
      }
    }
  }
  
  let pinIdentifier = "Pin"
  
  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    var pinView = mapView.dequeueReusableAnnotationViewWithIdentifier(pinIdentifier)
    if pinView == nil {
      pinView = MKPinAnnotationView(annotation: annotation,
                                        reuseIdentifier: pinIdentifier)
      pinView.canShowCallout = true
    }
    pinView.annotation = annotation
    (annotation as Establishment).loadCoverPhoto { photo in
      if photo != nil {
        UIGraphicsBeginImageContext(CGSize(width: 30,height: 30))
        photo.drawInRect(CGRectMake(0, 0, 30, 30))
        let smallImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        let imView = UIImageView(image: smallImage)
        pinView.leftCalloutAccessoryView = imView;
      }
    }
    return pinView

  }
}
