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
    //@State private var sigPlace = SignificantPlace(lat: 0, long: 0, name: "test", street: "test")
    @State private var tapped: Bool = false
    @State private var showJoinView: Bool = false
    @State private var selection = ""
    @State private var collection = ""
    @State private var street = ""
    @State private var annotationActive = false
    @ObservedObject var currentLocation : LocationManager
    
    @State private var significantPlaces : [SignificantPlace] = [SignificantPlace]()

    @ObservedObject var feedModel : FeedModel

    
    @State private var region : MKCoordinateRegion

    
    
    init(currentLocation: LocationManager, feedModel : FeedModel){
        self.currentLocation = currentLocation
        region = MKCoordinateRegion(center: currentLocation.location.coordinatePrecise, span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
        self.feedModel = feedModel
        print("MapView init")
    }
    
    func findIndex(id: UUID) -> Int? {
        return significantPlaces.firstIndex { item in item.id == id }
    }
    
    func findIndex(name: String) -> Int? {
        return significantPlaces.firstIndex { item in item.name == name }
    }
    
    var body: some View {
            ZStack{
                    VStack{
                        //gaggleTitleView()
                        VStack{
                        PinAnnotationMapView(places: $significantPlaces, region: $region, selection: $selection, collection: $collection, showJoinView: $showJoinView, annotationActive: $annotationActive)
                            .frame(width: 350, height: 350)
                            .cornerRadius(20)
                            .padding([.leading,.top,.trailing])
                            Spacer()
                        }
                        .shadow(color: Color(UIColor.systemGray), radius: 5, x: 0, y: 3)
                        if(significantPlaces.isEmpty)
                        {
                            Spacer()
                            HStack{
                                Text("No nearby locations available to join.")
                                    .font(Font.custom("CreatoDisplay-Black", size: 36))
                                    .padding()
                                    .multilineTextAlignment(.center)
                            }
                            Spacer()
                        }
                        else{
                            ScrollView{
                                HStack{
                                    Text("NEARBY LOCATIONS")
                                        .font(Font.custom("CreatoDisplay-Black", size: 16))
                                        .padding([.leading,.top])
                                        .foregroundColor(Color.gaggleOrange)
                                    Spacer()
                                }
                                ForEach(significantPlaces) { place in
                                    HStack{
                                        Spacer()
                                        Button {
                                            //sigPlace = place
                                            selection = place.name
                                            collection = place.collection
                                            street = place.street
                                            withAnimation {
                                                showJoinView.toggle()
                                            }
                                            if let index = findIndex(id: place.id){
                                                significantPlaces[index].annotationActive.toggle()
                                            }
                                        } label: {
                                            HStack{
                                                Text(place.name)
                                                    .font(Font.custom("CreatoDisplay-Black", size: 18))
                                                    .padding()
                                            }
                                            .frame(width: 350, height: .none)
                                            .background(Color(UIColor.systemGray6).cornerRadius(10))
                                            .padding([.top,.bottom], 5)
                                            .opacity(0.95)
                                        }
                                        Spacer()
                                    }
                                }
                            }
                        }
                    }
                if showJoinView {
                    VStack{
                        Spacer()
                            VStack{
                            Text("Join \(selection)?")
                                .font(Font.custom("CreatoDisplay-Bold", size: 24))
                                .multilineTextAlignment(.center)
                            Button {
                                //memoryModel.user.place = sigPlace
                                memoryModel.user.location = selection
                                memoryModel.user.collection = collection
                                memoryModel.user.street = street
                                memoryModel.user.checkedIn = true
                                feedModel.getData(location: collection)
                                withAnimation {
                                    showJoinView.toggle()
                                }
                                if let index = findIndex(name: selection){
                                    significantPlaces[index].annotationActive.toggle()
                                }
                            } label: {
                                Text("Yes")
                                    .frame(width: UIScreen.main.bounds.width-50, height: 50)
                                    .background(LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing).cornerRadius(15))
                                    .font(Font.custom("CreatoDisplay-Regular", size: 24))
                                    .foregroundColor(.black)
                            }
                            Button {
                                withAnimation {
                                    showJoinView.toggle()
                                }
                                if let index = findIndex(name: selection){
                                    significantPlaces[index].annotationActive.toggle()
                                }
                            } label: {
                                Text("No")
                                    .frame(width: UIScreen.main.bounds.width-50, height: 50)
                                    .background(Color(UIColor.systemGray5).cornerRadius(15))
                                    .font(Font.custom("CreatoDisplay-Regular", size: 24))
                                    .foregroundColor(Color(UIColor.systemGray))
                            }
                        }
                            .padding()
                            .background(Color(UIColor.systemGray6).cornerRadius(15).shadow(color: Color(UIColor.systemGray), radius: 5, x: 0, y: 5))
                    }
                    .opacity(0.95)
                    .padding()
                }
                else{
                    
                }
            }
            .onAppear {
                //currentLocation.getLocation()
                getSignificantPlaces()
                checkedInManager()
            }
            .onDisappear {
            }
            .onChange(of: currentLocation.location.coordinate) { newValue in
                region = MKCoordinateRegion(center: currentLocation.location.coordinatePrecise, span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
                getSignificantPlaces()
                checkedInManager()
            }
    }
    
    func checkedInManager(){
        if !significantPlaces.contains(where: {$0.name == memoryModel.user.location}){
            memoryModel.user.checkedIn = false
            //feedModel.stopListening()
        }
    }
    
    func getSignificantPlaces(){
        let region = MKCoordinateRegion(center: currentLocation.location.coordinatePrecise, span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))

        let pointOfInterest = MKLocalPointsOfInterestRequest(coordinateRegion: region)
        pointOfInterest.pointOfInterestFilter = MKPointOfInterestFilter(including: [
            //MKPointOfInterestCategory.brewery,
            MKPointOfInterestCategory.university,
            MKPointOfInterestCategory.cafe,
            MKPointOfInterestCategory.nightlife,
            MKPointOfInterestCategory.restaurant])
            //MKPointOfInterestCategory.winery])
        let search = MKLocalSearch(request: pointOfInterest)
        
        search.start { (response, error) in
            if let response = response {
                
                let mapItems = response.mapItems
                self.significantPlaces = mapItems.map {
                    SignificantPlace(lat: $0.placemark.coordinate.latitude, long: $0.placemark.coordinate.longitude, name: $0.placemark.name ?? "", street: $0.placemark.thoroughfare ?? "")
                }
            }
            
        }
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(currentLocation: LocationManager(), feedModel: FeedModel(user: UserUpdateModel(), userHonkRefsObs: UserHonkRefsObs())).environmentObject(MemoryModel())
    }
}

class LocationManager: NSObject, CLLocationManagerDelegate, ObservableObject{
    
    var locationManager = CLLocationManager()
    @Published var location = Location()
    
    override init(){
        print("Location Manager Init")
        super.init()
        print("locations = \(location.coordinate.latitude) \(location.coordinate.longitude)")
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            //locationManager.startMonitoringSignificantLocationChanges()
            locationManager.startUpdatingLocation()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
//        guard let locValue: CLLocationCoordinate2D = manager.location?.coordinate else { return }
        var lat = locations.last!.coordinate.latitude
        lat = round(lat * 1000)/1000
        var long = locations.last!.coordinate.longitude
        long = round(long * 1000)/1000
        location.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
        location.coordinatePrecise = locations.last!.coordinate
        //currentLocation = locValue
        //print("locations = \(locValue.latitude) \(locValue.longitude)")
        print("locations = \(location.coordinate.latitude) \(location.coordinate.longitude)")
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    func getLocation(){
        //locationManager.requestLocation()
    }
}

extension CLLocationCoordinate2D : Equatable{
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        return(
        lhs.longitude == rhs.longitude &&
        lhs.latitude == rhs.latitude
        )
    }
}

struct Location : Equatable{
    static func == (lhs: Location, rhs: Location) -> Bool {
        return(
        lhs.coordinate.longitude == rhs.coordinate.longitude &&
        lhs.coordinate.latitude == rhs.coordinate.latitude
        )
    }
    var coordinate = CLLocationCoordinate2D()
    var coordinatePrecise = CLLocationCoordinate2D()
}

struct SignificantPlace: Identifiable {
    let id: UUID
    let location: CLLocationCoordinate2D
    let name : String
    let street : String
    let collection : String
    var annotationActive : Bool
    init(id: UUID = UUID(), lat: Double, long: Double, name: String, street: String) {
        self.id = id
        self.location = CLLocationCoordinate2D(
            latitude: lat,
            longitude: long)
        self.name = name
        self.street = street
        let nameNoSpaces = name.replacingOccurrences(of: " ", with: "")
        let streetNoSpaces = street.replacingOccurrences(of: " ", with: "")
        self.collection = nameNoSpaces + streetNoSpaces
        self.annotationActive = false
    }
}

struct PinAnnotationMapView: View {
    @Binding var places : [SignificantPlace]
    @Binding var region: MKCoordinateRegion
    
    @Binding var selection : String
    @Binding var collection : String
    @Binding var showJoinView : Bool
    @Binding var annotationActive : Bool

    var body: some View {
        Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, annotationItems: places)
        { place in
            MapAnnotation(coordinate: place.location) {
                Circle()
                    .strokeBorder(Color.gaggleGray, lineWidth: 2)
                    .background(Circle().fill(LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing)).shadow(color: Color(UIColor.systemGray), radius: 5, x: 0, y: 3))
                    .frame(width: 20, height: 20)
                    .scaleEffect(place.annotationActive ? 2 : 1)
                    .animation(.easeOut)
                    .onTapGesture {
                        selection = place.name
                        collection = place.collection
                        withAnimation {
                            showJoinView.toggle()
                        }
                        if let index = findIndex(id: place.id){
                            places[index].annotationActive.toggle()
                        }
                    }
            }
        }
    }
    
    func findIndex(id: UUID) -> Int? {
        return places.firstIndex { item in item.id == id }
    }
}
