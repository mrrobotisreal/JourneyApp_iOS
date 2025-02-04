//
//  LocationPickerView.swift
//  MyJourney
//
//  Created by Mitch Wintrow on 1/31/25.
//

import SwiftUI
import MapKit

struct LocationPickerView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default (e.g., SF)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var displayName: String = ""
    @State private var isGeocoding: Bool = false
    @State private var showingSearchResults: Bool = false

    var onLocationSelected: (LocationData) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, onSearchButtonClicked: performSearch)
                    .padding()
                
                if showingSearchResults && !searchResults.isEmpty {
                    List(searchResults, id: \.self) { item in
                        Button(action: {
                            selectSearchResult(item)
                        }) {
                            VStack(alignment: .leading) {
                                Text(item.name ?? "Unknown location")
                                    .font(.custom("Nexa Script Light", size: 16))
                                
                                let locality = item.placemark.locality ?? ""
                                let adminArea = item.placemark.administrativeArea ?? ""
                                let country = item.placemark.country ?? ""
                                let address = [locality, adminArea, country]
                                    .filter { !$0.isEmpty }
                                    .joined(separator: ", ")
                                
                                if !address.isEmpty {
                                    Text(address)
                                        .font(.custom("Nexa Script Light", size: 14))
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                    }
                    .transition(.opacity)
                }
                
                MapView(selectedCoordinate: $selectedCoordinate, region: $region).edgesIgnoringSafeArea(.all)
                    .onChange(of: selectedCoordinate) { oldCoordinate, newCoordinate in
                        guard let coordinate = newCoordinate else {
                            displayName = ""
                            return
                        }
                        isGeocoding = true
                        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
                        CLGeocoder().reverseGeocodeLocation(location) { placemarks, error in
                            DispatchQueue.main.async {
                                self.isGeocoding = false
                                if let placemark = placemarks?.first {
                                    if let poi = placemark.areasOfInterest?.first, !poi.isEmpty {
                                        self.displayName = poi
                                        print("Area of interest: \(poi)")
                                    } else if let name = placemark.name, !name.isEmpty {
                                        self.displayName = name
                                        print("name: \(name)")
                                    } else if let locality = placemark.locality {
                                        self.displayName = locality
                                        print("locality: \(locality)")
                                    } else {
                                        self.displayName = "Unknown location"
                                        print("unknown")
                                    }
                                } else {
                                    self.displayName = "Unknown location"
                                }
                            }
                        }
                    }
                if let coord = selectedCoordinate {
                    Text("Selected location: \(coord.latitude), \(coord.longitude)")
                        .padding()
                        .font(.custom("Nexa Script Light", size: 16))
                }
                if isGeocoding {
                    ProgressView("Fetching name...")
                        .padding()
                } else {
                    TextField("Location Name", text: $displayName)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding()
                }
                
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Text("Cancel")
                            .padding()
                            .font(.custom("Nexa Script Light", size: 18))
                            .foregroundColor(Color(red: 0.008, green: 0.282, blue: 0.451))
                    }
                    .padding()
                    
                    Button(action: {
                        if let coordinate = selectedCoordinate {
                            let newLocation = LocationData(
                                latitude: coordinate.latitude,
                                longitude: coordinate.longitude,
                                displayName: displayName
                            )
                            onLocationSelected(newLocation)
                            dismiss()
                        }
                    }) {
                        Text("Confirm location")
                            .padding()
                            .font(.custom("Nexa Script Heavy", size: 18))
                            .foregroundColor(selectedCoordinate == nil ? .gray : Color(red: 0.008, green: 0.282, blue: 0.451))
                    }
                    .padding()
                    .disabled(selectedCoordinate == nil)
                }
            }
            .onAppear {
                locationManager.requestLocation()
            }
            .onChange(of: locationManager.location) { oldLocation, newLocation in
                if let location = newLocation {
                    region = MKCoordinateRegion(
                        center: location.coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                    )
                }
            }
        }
    }
    
    private func performSearch() {
        let searchRequest = MKLocalSearch.Request()
        searchRequest.naturalLanguageQuery = searchText
        searchRequest.region = region
        
        let search = MKLocalSearch(request: searchRequest)
        search.start { response, error in
            guard let response = response else {
                print("Search error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            
            searchResults = response.mapItems
            withAnimation {
                showingSearchResults = true
            }
        }
    }
    
    private func selectSearchResult(_ item: MKMapItem) {
        selectedCoordinate = item.placemark.coordinate
        
        var locationComponents: [String] = []
        
        if let name = item.name {
            locationComponents.append(name)
        }
        
        var addressComponents: [String] = []
        if let locality = item.placemark.locality {
            addressComponents.append(locality)
        }
        if let adminArea = item.placemark.administrativeArea {
            addressComponents.append(adminArea)
        }
        if let country = item.placemark.country {
            addressComponents.append(country)
        }
        
        displayName = locationComponents.first ?? "Unknown location"
        region.center = item.placemark.coordinate
        withAnimation {
            showingSearchResults = false
        }
        searchText = ""
    }
}

struct SearchBar: View {
    @Binding var text: String
    var onSearchButtonClicked: () -> Void
    
    var body: some View {
        HStack {
            TextField("Search location...", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .font(.custom("Nexa Script Light", size: 16))
                .onSubmit {
                    onSearchButtonClicked()
                }
            
            if !text.isEmpty {
                Button(action: {}) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
    }
}

#Preview {
    LocationPickerView(onLocationSelected: { coordinate in
    })
}
