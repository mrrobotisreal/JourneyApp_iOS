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
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default (e.g., SF)
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var selectedCoordinate: CLLocationCoordinate2D?
    @State private var displayName: String = ""
    @State private var isGeocoding: Bool = false

    var onLocationSelected: (LocationData) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
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
        }
    }
    
    // This is a duplicate until I can figure out how to properly fetchDisplayName for display here
    private func fetchDisplayName(for location: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let clLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)

        geocoder.reverseGeocodeLocation(clLocation) { placemarks, error in
            if let placemark = placemarks?.first {
                completion(placemark.name ?? placemark.locality)
            } else {
                completion(nil)
            }
        }
    }
}

#Preview {
    LocationPickerView(onLocationSelected: { coordinate in
//        fetchDisplayName(for: coordinate) { name in
//            let newLocation = LocationData(
//                latitude: coordinate.latitude,
//                longitude: coordinate.longitude,
//                displayName: name
//            )
//            locations.append(newLocation)
//        }
    })
}
