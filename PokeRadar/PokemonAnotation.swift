//
//  PokemonAnotation.swift
//  Pokem Radar
//
//  Created by Valentin Sanchez on 22/05/2020.
//  Copyright © 2020 Valentin Sanchez. All rights reserved.
//

import Foundation
import MapKit

class PokemonAnnotation: NSObject, MKAnnotation{
    var coordinate = CLLocationCoordinate2D()
    var pokemon: Pokemon
    var title: String?
    
    init(coordinate: CLLocationCoordinate2D, pokemonId: Int) {
        self.coordinate = coordinate
        self.pokemon = PokemonFactory.shared.getPokemon(with: pokemonId)
        self.title = self.pokemon.name
    }
}
