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
    @State private var showJoinView: Bool = false
    @State private var selection = ""
    @State private var collection = ""
    @ObservedObject var currentLocation : LocationManager
    @ObservedObject var feedModel : FeedModel
    
    
    @State private var region : MKCoordinateRegion
    
    init(currentLocation: LocationManager, feedModel : FeedModel){
        self.currentLocation = currentLocation
        region = MKCoordinateRegion(center: currentLocation.location.location, span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        self.feedModel = feedModel
    }
    
    var body: some View {
            ZStack(alignment: .top){
                    VStack(){
                        gaggleTitleView()
                        PinAnnotationMapView(places: significantPlaces, region: region)
                            .frame(width: 350, height: 350)
                            .cornerRadius(20)
                        ScrollView{
                            ForEach(significantPlaces) { place in
                                HStack{
                                    Spacer()
                                    Button {
                                        selection = place.name
                                        collection = place.collection
                                        withAnimation {
                                            showJoinView.toggle()
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
//DEBUG LOCATION
//                        Text("locations = \(currentLocation.location.location.latitude) \(currentLocation.location.location.longitude)")
//                        VStack(alignment: .center){
//                            ScrollView{
//                                ForEach(significantPlaces) { place in
//                                    Button {
//                                        selection = place.name
//                                        collection = place.collection
//                                        withAnimation {
//                                            showJoinView.toggle()
//                                        }
//                                    } label: {
//                                        Text(place.name)
//                                            .font(Font.custom("CreatoDisplay-Black", size: 18))
//                                            .padding()
//                                            .background(Color.gray.cornerRadius(10))
//                                    }
//                                    .padding()
//
//                                }
//                            }
//                        }
//                            List{
//                                ForEach(significantPlaces) { place in
//                                    HStack{
//                                        Text(place.name)
//                                            .font(Font.custom("CreatoDisplay-Bold", size: 18))
//                                        Spacer()
//                                        Button {
//                                            selection = place.name
//                                            collection = place.collection
//                                            withAnimation {
//                                                showJoinView.toggle()
//                                            }
//                                        } label: {
//                                            Text("")
//                                        }
//                                    }
//                                }
//                            }
//                            .listStyle(.plain)
                    }
                if showJoinView {
                    VStack{
                        Spacer()
                            VStack{
                            Text("Join \(selection)?")
                                .font(Font.custom("CreatoDisplay-Bold", size: 24))
                                .multilineTextAlignment(.center)
                            Button {
                                memoryModel.user.location = selection
                                memoryModel.user.collection = collection
                                memoryModel.user.checkedIn = true
                                feedModel.getData(location: collection)
                                withAnimation {
                                    showJoinView.toggle()
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
            }
            .onAppear {
                getSignificantPlaces()
                checkedInManager()
            }
            .onDisappear {
            }
            .onChange(of: currentLocation.location) { newValue in
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
    let street : String
    let collection : String
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
    }
}

struct PinAnnotationMapView: View {
    let places : [SignificantPlace]
    @State var region: MKCoordinateRegion

    var body: some View {
        Map(coordinateRegion: $region, interactionModes: .init(), showsUserLocation: true, userTrackingMode: .constant(.follow), annotationItems: places)
        { place in
            MapAnnotation(coordinate: place.location) {
                Image(systemName: "person.3")
                    .resizable()
                    .scaledToFit()
                    .padding(.all, 5)
                    .frame(width: 40, height: 40)
                    .background(LinearGradient(colors: [Color.gaggleGreen, Color.gaggleYellow], startPoint: .bottomLeading, endPoint: .topTrailing).cornerRadius(20).shadow(color: Color(UIColor.systemGray), radius: 5, x: 0, y: 3))
                        }
        }
    }
}
