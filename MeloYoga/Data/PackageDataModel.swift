//
//  PackageDataModel.swift
//  MeloYoga
//


import Foundation

class PackageDataModel: ObservableObject {
    @Published var packages = [PackageData]()
    
    init() {
        let pathString = Bundle.main.path(forResource: "pdata", ofType: "json")
        if let path = pathString{
            let url = URL(filePath: path)
            do {
                let data = try Data(contentsOf: url)
                let decoder = JSONDecoder()
                do {
                    let packageData = try decoder.decode([PackageData].self, from: data)
                    self.packages = packageData
                }
                catch{
                    print(error)
                }
            }
            catch{
                print(error)
            }
        }
    }
}
