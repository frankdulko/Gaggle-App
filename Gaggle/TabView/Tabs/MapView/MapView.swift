//
//  MapView.swift
//  Gaggle
//
//  Created by Frank Dulko on 2/26/22.
//

import SwiftUI
import MapKit

struct MapView: View {
    @EnvironmentObject var memoryModel : MemoryModel
    @State private var landmarks: [Landmark] = [Landmark]()
    @State private var tapped: Bool = false
    @ObservedObject var currentLocation : LocationManager
    
    var body: some View {
            ZStack(alignment: .top){
                    VStack(){
                        gaggleTitleView()
                        MapHandler(landmarks: landmarks)
                            .frame(width: 350, height: 350)
                            .cornerRadius(20)
                            
                        Spacer()
                            List{
                                ForEach(self.landmarks, id: \.id) { landmark in
                                    HStack{
                                        Text(landmark.name)
                                        Spacer()
                                        Menu("Join") {
                                            Button {
                                                memoryModel.user.location = landmark.name
                                                memoryModel.user.checkedIn = true
                                            } label: {
                                                Text("Join Gaggle")
                                            }
                                        }
                                        .foregroundColor(.black)
                                        .padding([.leading,.trailing], 20)
                                        .padding([.top,.bottom], 5)
                                        .background(Color.gaggleGreen.cornerRadius(100))
                                        }
                                }
                                
                            }
                            .refreshable {
                                showNearbyLandmarks()
                            }
                            .listStyle(.plain)
                        }
                        .onAppear {
                            showNearbyLandmarks()
                            checkedInManager()
                        }
                        .onDisappear {
                            checkedInManager()
                        }
            }
    }
    
    func checkedInManager(){
        if !landmarks.contains(where: {$0.name == memoryModel.user.location}){
            memoryModel.user.checkedIn = false
        }
    }
    
    func showNearbyLandmarks(){        
        //let region = MKCoordinateRegion(center: locationManager.getCurrentLocation(), latitudinalMeters: 1000, longitudinalMeters: 1000)
        let region = MKCoordinateRegion(center: currentLocation.currentLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)

        let pointOfInterest = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        pointOfInterest.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            MKPointOfInterestCategory.brewery,
            MKPointOfInterestCategory.cafe,
            MKPointOfInterestCategory.nightlife,
            MKPointOfInterestCategory.restaurant,
            MKPointOfInterestCategory.winery])
        let search = MKLocalSearch(request: pointOfInterest)
        
        //let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if let response = response {
                
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placemark: $0.placemark)
                }
                
            }
            
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(currentLocation: LocationManager()).environmentObject(MemoryModel())
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject{
    
    @Published var currentLocation = CLLocationCoordinate2D()
    var locationManager = CLLocationManager()
    
    override init(){
        super.init()
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        currentLocation = locValue
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D{
        return currentLocation
    }
}
