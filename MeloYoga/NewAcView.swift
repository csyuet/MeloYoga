//
//  NewAcView.swift
//  MeloYoga
//

import SwiftUI

struct NewAcView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var inputName = ""
    @State private var nValid = ""
    
    @State private var inputPhone = ""
    @State private var pValid = ""
    
    @State private var inputEmail = ""
    @State private var eValid = ""
    
    @State private var inputpw = ""
    @State private var pwValid = ""
    
    @State private var inputpw2 = ""
    @State private var cValid = ""
    
    @State private var created = false
    
    var body: some View {
      
        VStack(alignment:.leading, spacing: 10){
            HStack{
                Text("Your Name: ")
                    .fixedSize()
                Text(nValid)
                    .foregroundStyle(.red)
            }
            TextField("Your Name", text: $inputName)
            .padding()
            .frame(width: 300, height: 45)
            .background(Color.pinkbg2)
            .cornerRadius(15)
            
            HStack{
                Text("Your Phone: ")
                    .fixedSize()
                Text(pValid)
                    .foregroundStyle(.red)
            }
            TextField("Your Phone", text: $inputPhone)
            .padding()
            .frame(width: 300, height: 45)
            .background(Color.pinkbg2)
            .cornerRadius(15)
            
            HStack{
                Text("Your Email: ")
                    .fixedSize()
                Text(eValid)
                    .foregroundStyle(.red)
            }
            TextField("abc @example.com", text: $inputEmail)
            .padding()
            .frame(width: 300, height: 45)
            .background(Color.pinkbg2)
            .cornerRadius(15)
            
            HStack{
                Text("Your Password: ")
                    .fixedSize()
                Text(pwValid)
                    .foregroundStyle(.red)
            }
            SecureField("Your Password", text: $inputpw)
            .padding()
            .frame(width: 300, height: 45)
            .background(Color.pinkbg2)
            .cornerRadius(15)
            
            HStack{
                Text("Confirm password: ")
                    .fixedSize()
            }
            SecureField("Confirm password", text: $inputpw2)
            .padding()
            .frame(width: 300, height: 45)
            .background(Color.pinkbg2)
            .cornerRadius(15)
            Text(cValid)
                .foregroundStyle(.red)
        }
        .foregroundStyle(Color.pinkword).bold()
        Button {
            nValid = inputName.isEmpty ? "This field is empty!" : ""
            eValid = inputEmail.isEmpty ? "This field is empty!" : ""
            pValid = inputPhone.isEmpty ? "This field is empty!" : ""
            pwValid = inputpw.isEmpty ? "This field is empty!" : ""
            cValid = inputpw2==inputpw ? "" : "Password not the same!"
            if (nValid.isEmpty && eValid.isEmpty && pValid.isEmpty && pwValid.isEmpty && cValid.isEmpty){
                
                let newUser = User(context: viewContext)
                newUser.id = UUID()
                newUser.name = inputName
                newUser.phone = inputPhone
                newUser.email = inputEmail
                newUser.pw = inputpw
                newUser.login = false
                do {
                    try viewContext.save()
                } catch {
                    let nsError = error as NSError
                    fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                }
                created = true
            }
            
        } label: {
            Text("Register")
                .font(.system(size: 30))
                .fontWeight(.semibold)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.pinkword)
                .frame(width: 188, height: 50)
        }
        .background(Color.pinkbg2)
        
        .cornerRadius(20)
        .padding()
        .disabled(created)
        
        Text(created ? "Successfully Registered!" : "")
        
    }
}

#Preview {
    NewAcView()
}
