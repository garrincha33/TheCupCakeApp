//
//  ContentView.swift
//  TheCupCakeApp
//
//  Created by Richard Price on 15/03/2021.
//

import Combine
import SwiftUI

class Order: ObservableObject, Codable {
    
    enum CodingKeys: String, CodingKey {
        case type, quantity, extraFosting, addSprinkles, specialRequestsEnabled, name,  streetAddress, city, zip
    }
    
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        type = try container.decode(Int.self, forKey: .type)
        quantity = try container.decode(Int.self, forKey: .quantity)
        extraFosting = try container.decode(Bool.self, forKey: .extraFosting)
        addSprinkles = try container.decode(Bool.self, forKey: .addSprinkles)
        specialRequestsEnabled = try container.decode(Bool.self, forKey: .specialRequestsEnabled)
        name = try container.decode(String.self, forKey: .name)
        streetAddress = try container.decode(String.self, forKey: .streetAddress)
        city = try container.decode(String.self, forKey: .city)
        zip = try container.decode(String.self, forKey: .zip)
    }
    init(){}
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(type, forKey: .type)
        try container.encode(quantity, forKey: .quantity)
        try container.encode(extraFosting, forKey: .extraFosting)
        try container.encode(addSprinkles, forKey: .addSprinkles)
        try container.encode(specialRequestsEnabled, forKey: .specialRequestsEnabled)
        try container.encode(name, forKey: .name)
        try container.encode(streetAddress, forKey: .streetAddress)
        try container.encode(city, forKey: .city)
        try container.encode(zip, forKey: .zip)
    }
    
    var didChange = PassthroughSubject<Void, Never>()
    static let types = ["Vanilla", "Choclate", "Strawberry", "Toffee"]
    
    @Published var type = 0 { didSet { update() } }
    @Published var quantity = 3 { didSet { update() } }
    @Published var extraFosting = false { didSet { update() } }
    @Published var addSprinkles = false { didSet { update() } }
    @Published var specialRequestsEnabled = false { didSet { update() } }
    
    @Published var name = "" { didSet { update() } }
    @Published var streetAddress = "" { didSet { update() } }
    @Published var city = "" { didSet { update() } }
    @Published var zip = "" { didSet { update() } }

    var isValid: Bool {
        if name.isEmpty || streetAddress.isEmpty || city.isEmpty || zip.isEmpty {
            return false
        }
        return true
    }
    
    func update() {
        didChange.send()
    }
}

struct ContentView: View {
    @ObservedObject var order = Order()
    @State var confirmationMessage = ""
    @State var showingConfirmation = false
    
    
    var body: some View {
        NavigationView {
            Form {
                Section {
                    Picker(selection: $order.type, label: Text("select your cake type")) {
                        ForEach(0 ..< Order.types.count) {
                            Text(Order.types[$0]).tag($0)
                        }
                    }
                    Stepper(value: $order.quantity, in: 3...20) {
                        Text("Number of cakes: \(order.quantity)")
                    }
                }
                Section {
                    Toggle(isOn: $order.specialRequestsEnabled, label: {
                        Text("Any Special Requests")
                    })
                    if order.specialRequestsEnabled {
                        Toggle(isOn: $order.extraFosting, label: {
                            Text("Add Extra Frosting")
                        })
                        Toggle(isOn: $order.addSprinkles, label: {
                            Text("Add Sprinkles")
                        })
                    }
                }
                
                Section {
                    TextField("Name", text: $order.name)
                    TextField("Street Address", text: $order.streetAddress)
                    TextField("City", text: $order.city)
                    TextField("Zip", text: $order.zip)
                }
                
                Section {
                    Button(action: {
                        self.placeOrder()
                    }) {
                        Text("Place Order")
                    }
                }.disabled(!order.isValid)            }
            .navigationBarTitle("Cupcake World")
                .alert(isPresented: $showingConfirmation) {
                            Alert(title: Text("Important message"), message: Text("we have recevied your order"), dismissButton: .default(Text("OK")))
                        }
        }
    }
    
    func placeOrder() {
        guard let encoded = try? JSONEncoder().encode(order) else {
            print("failed to encode")
            return
        }
        
        let url = URL(string: "https://reqres.in/api/cupcakes")!
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = encoded
        
        URLSession.shared.dataTask(with: request) { data, _, error in
 
            guard let _ = data else {
                print("couldnt return any data")
                return
            }
            
            if let decodedOrder = try?
                JSONDecoder().decode(Order.self, from: data!) {
                self.confirmationMessage = "Your order for \(decodedOrder.quantity)x \(Order.types[decodedOrder.type].lowercased()) is on its way"
                self.showingConfirmation = true
            } else {
                let dataString = String(decoding: data!, as: UTF8.self)
                print("Invalid response: \(dataString)")
            }
        }.resume()
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

