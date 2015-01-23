//
//  MapViewController.swift
//  Feed Me
//
//  Created by Ron Kliffer on 8/30/14.
//  Copyright (c) 2014 Ron Kliffer. All rights reserved.
//

import UIKit
import CoreLocation

class MapController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    
    //  @IBOutlet weak var mapCenterPinImage: UIImageView!
    //  @IBOutlet weak var pinImageVerticalConstraint: NSLayoutConstraint!
    let locationManager = CLLocationManager()
    var mapRadius: Double {
        get {
            let region = mapView.projection.visibleRegion()
            let verticalDistance = GMSGeometryDistance(region.farLeft, region.nearLeft)
            let horizontalDistance = GMSGeometryDistance(region.farLeft, region.farRight)
            return max(horizontalDistance, verticalDistance)*0.5
        }
    }
    let dataProvider = GoogleDataProvider()
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    override func viewDidLoad()
    {
        super.viewDidLoad()
        mapView.delegate = self
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        mapView.settings.compassButton = true
        if CLLocationManager.authorizationStatus() == .AuthorizedWhenInUse
        {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func fetchNearbyPlaces(coordinate: CLLocationCoordinate2D)
    {
        mapView.clear()
//            dataProvider.fetchPlacesNearCoordinate(coordinate, radius: mapRadius, types: searchedTypes) { places in
        dataProvider.fetchPlacesWithTextSearch(coordinate, radius: mapRadius) { places in
            for place: GooglePlace in places {
                let marker = PlaceMarker(place: place)
                marker.map = self.mapView
            }
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func locationManager(manager: CLLocationManager!, didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedWhenInUse
        {
            locationManager.startUpdatingLocation()
            mapView.myLocationEnabled = true
            mapView.settings.myLocationButton = true
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        
        if let location = locations.first as? CLLocation{
            mapView.camera = GMSCameraPosition(target: location.coordinate, zoom: 15, bearing: 0, viewingAngle: 0)
            locationManager.stopUpdatingLocation()
            fetchNearbyPlaces(location.coordinate)
        }
    }
    
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    func mapView(mapView: GMSMapView!, markerInfoContents marker: GMSMarker!) -> UIView!
    {
        let placeMarker = marker as PlaceMarker
        if let infoView = UIView.viewFromNibName("MarkerInfoView") as? MarkerInfoView
        {
            infoView.nameLabel.text = placeMarker.place.name
            
            if let photo = placeMarker.place.photo
            {
                infoView.placePhoto.image = photo
            }
            else
            {
                infoView.placePhoto.image = UIImage(named: "generic")
            }
            return infoView
        }
        else
        {
            return nil
        }
    }
    
    
    func mapView(mapView: GMSMapView!, didTapInfoWindowOfMarker marker: GMSMarker!)
    {
        println("info tapped")
        var marker = marker as PlaceMarker
        println(marker.place.placeID)
        dataProvider.fetchPlaceDetails(marker.place.placeID, completion: { ([GooglePlace]) -> Void in
        })
//        performSegueWithIdentifier("placeDetail", sender: self)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?)
    {
        if segue.identifier == "placeDetail"
        {
        
        }
    }
    
    /******************************************************************************************
    *
    ******************************************************************************************/
    @IBAction func refreshPlaces(sender: AnyObject)
    {
        fetchNearbyPlaces(mapView.camera.target)
    }
    
}

