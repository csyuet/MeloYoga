//
//  PackageData.swift
//  MeloYoga
//

import Foundation

struct PackageData: Identifiable, Decodable {
    var id: Int
    var cost: Int16
    var totalCredit: Int16
    var expiry: Int16
}
