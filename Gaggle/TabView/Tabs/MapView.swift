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
    @State private var significantPlaces : [SignificantPlace] = [SignificantPlace]()
    @State private var tapped: Bool = false
    @ObservedObject var currentLocation : LocationManager
    
    @State private var region : MKCoordinateRegion
    
    init(currentLocation: LocationManager){
        self.currentLocation = currentLocation
        region = MKCoordinateRegion(center: currentLocation.location.location, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    }
    
    var body: some View {
            ZStack(alignment: .top){
                    VStack(){
                        gaggleTitleView()
                        PinAnnotationMapView(places: significantPlaces, region: region)
                            .frame(width: 350, height: 350)
                            .cornerRadius(20)
//DEBUG LOCATION
//                        Text("locations = \(currentLocation.location.location.latitude) \(currentLocation.location.location.longitude)")
                        Spacer()
                            List{
                                ForEach(significantPlaces) { landmark in
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
                            .listStyle(.plain)
                        }
                        .onAppear {
                            print("Map onAppear")
                            getSignificantPlaces()
                            checkedInManager()
                        }
                        .onDisappear {
                            checkedInManager()
                        }
                        .onChange(of: currentLocation.location) { newValue in
                            getSignificantPlaces()
                            print("Location Changed")
                        }
                        
            }
    }
    
    func checkedInManager(){
        if !significantPlaces.contains(where: {$0.name == memoryModel.user.location}){
            memoryModel.user.checkedIn = false
        }
    }
    
    func getSignificantPlaces(){
        let region = MKCoordinateRegion(center: currentLocation.location.location, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))

        let pointOfInterest = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        pointOfInterest.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            MKPointOfInterestCategory.brewery,
            MKPointOfInterestCategory.cafe,
            MKPointOfInterestCategory.nightlife,
            MKPointOfInterestCategory.restaurant,
            MKPointOfInterestCategory.winery])
        let search = MKLocalSearch(request: pointOfInterest)
        
        search.start { (response, error) in
            if let response = response {
                
                let mapItems = response.mapItems
                self.significantPlaces = mapItems.map {
                    SignificantPlace(lat: $0.placemark.coordinate.latitude, long: $0.placemark.coordinate.longitude, name: $0.placemark.name ?? "")
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
    
    var locationManager = CLLocationManager()
    @Published var location = Location()
    
    override init(){
        print("Location Manager Init")
        super.init()
        print("locations = \(location.location.latitude) \(location.location.longitude)")
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            //locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startMonitoringSignificantLocationChanges()
            //locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        //location.location = locValue

        location.location = locations.last!.coordinate
        //currentLocation = locValue
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        print("locations = \(location.location.latitude) \(location.location.longitude)")
    }
}

struct Location : Equatable{
    static func == (lhs: Location, rhs: Location) -> Bool {
        return(
        lhs.location.longitude == rhs.location.longitude &&
        lhs.location.latitude == rhs.location.latitude
        )
    }
    var location = CLLocationCoordinate2D()
}

struct SignificantPlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    let name : String
    init(id: UUID = UUID(), lat: Double, long: Double, name: String) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
        self.name = name
    }
}

struct PinAnnotationMapView: View {
    let places : [SignificantPlace]
    @State var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, interactionModes: .init(), showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: places)
        { place in
            MapAnnotation(coordinate: place.location) {
                Image("gaggle-icon-clear")
                    .resizable()
                    .scaledToFit()
                    .padding(.all, 5)
                    .frame(width: 40, height: 40)
                    .background(LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing).cornerRadius(20).shadow(color: Color(UIColor.systemGray), radius: 5, x: 5, y: 5))
                        }
        }
    }
}
