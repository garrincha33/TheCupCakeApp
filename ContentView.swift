//
//  ContentView.swift
//  TheCupCakeApp
//
//  Created by Richard Price on 15/03/2021.
//

import Combine
import SwiftUI

class Order: ObservableObject {
    var didChange = PassthroughSubject<Void, Never>()
    static let types = ["Vanilla", "Choclate", "Strawberry", "Toffee"]
    
    @Published var type = 0 { didSet { update() } }
    @Published var quantity = 3 { didSet { update() } }
    @Published var extraFosting = false { didSet { update() } }
    @Published var addSprinkles = false { didSet { update() } }
    @Published var specialRequestsEnabled = false { didSet { update() } }
    
    @State var name = "" { didSet { update() } }
    @State var streetAddress = "" { didSet { update() } }
    @State var city = "" { didSet { update() } }
    @State var zip = "" { didSet { update() } }
    
    func update() {
        didChange.send()
    }
}

struct ContentView: View {
    @ObservedObject var order = Order()
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
                    TextField("Name", text: order.$name)
                    TextField("Street Address", text: order.$streetAddress)
                    TextField("City", text: order.$city)
                    TextField("Zip", text: order.$zip)
                }
                
                Section {
                    Button(action: {
                        self.placeOrder()
                    }) {
                        Text("Place Order")
                    }
                }
            }
            .navigationBarTitle("Cupcake World")
        }
    }
    
    func placeOrder() {
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
