//
//  PurchaseFromView.swift
//  MeloYoga
//

import SwiftUI
import CoreData

struct PurchaseFormView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var user: User
    var package: Package
    let methods = ["None", "Payme", "FPS", "Credit Card"]
    
    @State private var endDate = Date()
    @State private var valid = false
    @State private var paymentMethod = "None"
    @State private var cardNum = ""
    @State private var expDate = ""
    @State private var cvn2 = ""
    @State private var cardHolderName = ""
    @State private var paymentAlert = false
    @State private var paid = false
    @State private var showUploadPhoto = false
    @State var selectedOption = "None"
    
    func processPayment(user: User, package: Package){
        let purchased = PurchasedPackage(context: viewContext)
        purchased.id = UUID()
        purchased.purDate = Date()
        purchased.expDate = endDate
        purchased.remainingCred = package.totalCredit

        package.addToPackages(purchased)
        user.addToPurchased(purchased)
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    var body: some View {
        
        if paid {
            LazyVStack{
                Spacer()
                Image(systemName: "checkmark.circle.fill")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 150, height: 150)
                
                Text("Your payment has completed!")
                    .font(.title)
                Text("Enjoy your yoga time!")
                    .font(.title2)
            }
        } else {
            List{
                Section("Selected Package"){
                    VStack(alignment: .leading){
                        Text("\(package.totalCredit) credits package - \(package.cost)")
                            .bold()
                        Text("(\(package.expiry) months' expiry)")
                        Text("Expire in \(endDate, formatter: itemFormatter(format: "dd/MM/YYYY"))").foregroundStyle(Color.gray)
                    }
                }.headerProminence(.increased)
            
                Section("Payment"){
                    Picker("Payment Method", selection: $paymentMethod) {
                        ForEach(methods, id: \.self){
                            Text($0)
                        }
                    }
                    .pickerStyle(.menu)
                    .fontWeight(.bold)
                    .tint(Color.pinktint)
                    if paymentMethod == "Credit Card"{
                        VStack(alignment: .leading){
                            Text("Card number")
                            TextField("", text: $cardNum)
                            .padding()
                            .background(Color.pinkbg2)
                            .cornerRadius(15)
                            
                            Text("Expiration Date")
                            TextField("", text: $expDate)
                            .padding()
                            .background(Color.pinkbg2)
                            .cornerRadius(15)
                            
                            Text("CVN2")
                            TextField("", text: $cvn2)
                            .padding()
                            .background(Color.pinkbg2)
                            .cornerRadius(15)
                            
                            Text("Card Holder Name")
                            TextField("", text: $cardHolderName)
                            .padding()
                            .background(Color.pinkbg2)
                            .cornerRadius(15)
                        }
                    } else if paymentMethod != "None" {
                        PhotoUploadView()
                    }
                    
                }.headerProminence(.increased)
                
                ZStack{
                    Button{
                        paymentAlert = paymentMethod == "None"
                        valid = !paymentAlert
                    } label: {
                        HStack {
                            Spacer(); Text("COMFIRM").bold(); Spacer()
                        }
                    }.alert("Payment Unsuccessful", isPresented: $paymentAlert) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Payment method is not chosen")
                    }
                }.listRowBackground(Color.pinkword)
                
            }.tint(Color.white)
            .onAppear{
                endDate = Date() + Double(package.expiry)*30*60*60*24
            }
            .onChange(of: valid){
                if valid{
                    processPayment(user: user, package: package)
                    paid = true
                }
            }
        }
    }
}

struct PhotoUploadView: View {
    @State var image:UIImage? = nil
    @State private var showingImagePicker = false
    @State var selectedImageSource = UIImagePickerController.SourceType.photoLibrary
    @State private var placeHolderImage = Image(systemName: "camera.fill")
    
    @State private var selectedOption = "None"
    let options = ["None", "Photo Library", "Camera"]
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Upload receipt:").fontWeight(.semibold)
            LazyVStack(alignment:.center){
                placeHolderImage
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .overlay {
                        Picker("", selection: $selectedOption) {
                            ForEach(options, id: \.self){
                                Text($0)
                            }
                        }.tint(Color(white: 100, opacity: 0))
                    }
            }.frame(height: 300).border(Color.pinkword)
        }.foregroundStyle(Color.pinkword)
            .padding(5)
            .onChange(of: selectedOption) {
                if selectedOption != "None" {
                    selectedImageSource = selectedOption == "Camera" ? .camera : .photoLibrary
                    showingImagePicker = true
                }
            }
            .sheet(isPresented: $showingImagePicker, onDismiss: {
                placeHolderImage = (image == nil) ? Image(systemName: "camera.fill") : Image(uiImage: image!)
            }){
                ImagePicker(image: self.$image, selectedSource: selectedImageSource)
                    .ignoresSafeArea()
            }
    }
}



//#Preview {
//    PurchaseFormView()
//}

struct PurchasePreview: PreviewProvider{
    static var previews: some View{
        ContentView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
            .environmentObject(CourseDataModel())
            .environmentObject(PackageDataModel())
    }
}
