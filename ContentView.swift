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
    var type = 0
    func update() {
        didChange.send()
    }
}

struct ContentView: View {
    
    @ObservedObject var order = Order()
    
    var body: some View {
        NavigationView {
            Form {
                Picker(selection: $order.type, label: Text("select your cake type")) {
                    ForEach(0 ..< Order.types.count) {
                        Text(Order.types[$0]).tag($0)
                    }
                }
            }
            .navigationBarTitle("Cupcake World")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
