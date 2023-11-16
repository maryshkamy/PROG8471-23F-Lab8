//
//  WeatherInfo.swift
//  Lab8MarianaRiosSilveiraCarvalho
//
//  Created by Mariana Rios Silveira Carvalho on 2023-11-13.
//

import Foundation

struct WeatherInfo: Codable {
    let id: Int
    let main, description, icon: String
}
