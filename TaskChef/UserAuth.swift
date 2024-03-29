//
//  UserAuth.swift
//  TaskChef
//
//  Created by Thomas Bahmandeji on 10/17/19.
//  Copyright © 2019 Thomas Bahmandeji. All rights reserved.
//

import SwiftUI
import Firebase
import Combine

//class plusButton: ObservableObject {
//    var didChange = PassthroughSubject<Void, Never>()
//    @Published var session: plusButton {didSet {didChange.send() }}
//    var newEntry: Bool
//}

///User paramaters to be used in SessionStore()
class User {
    var uid: String
    var email: String?
    var displayName: String?
    
    init(uid: String, displayName: String?, email: String?) {
        self.uid = uid
        self.email = email
        self.displayName = displayName
    }
}

///Firebase Authentication to be communicated between views and back to Firebase
class SessionStore : ObservableObject {
    var didChange = PassthroughSubject<Void, Never>()
    @Published var session: User? {didSet {self.didChange.send() }}
    var handle: AuthStateDidChangeListenerHandle?
    
    ///Colors
    let ThemeColor = Color(red: 0.3, green: 0.6, blue: 0.99)
    let MainTheme = Color(red: 0.0, green: 0.67, blue: 0.97)
    
    func listen () {
        // monitor authentication changes using firebase
        handle = Auth.auth().addStateDidChangeListener { (auth, user) in
            if let user = user {
                // if we have a user, create a new user model
                print("Got user: \(user)")
                self.session = User(uid: user.uid, displayName: user.displayName, email: user.email)
            } else {
                // if we dont have a user, set our session to nil
                self.session = nil
            }
        }
    }
     
    func signUp (
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
    ) {
        Auth.auth().createUser(withEmail: email, password: password, completion: handler)
    }
    
    func signIn(
        email: String,
        password: String,
        handler: @escaping AuthDataResultCallback
        ) {
        Auth.auth().signIn(withEmail: email, password: password, completion: handler)
    }

    func signOut () -> Bool {
        do {
            try Auth.auth().signOut()
            self.session = nil
            return true
        } catch {
            return false
        }
    }
    
    func unbid () {
        if let handle = handle {
            Auth.auth().removeStateDidChangeListener(handle)
        }
    }
}

/// MODIFIERS

struct SignInModifier: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.all).font(.system(size: 18)).border(Color.purple, width: 2).foregroundColor(Color.purple).shadow(radius: 2).frame(width: 350, height: 50)
    }
}

///Login button Modifier
struct LogInModifier: ViewModifier {
    func body(content: Content) -> some View{
       return content
        .padding().background(Color.blue).cornerRadius(20).foregroundColor(Color.white)
    }
}

/// Mod for SF Symbols
struct SymbolMod: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .imageScale(.large)
    }
}

///profile Navigation items (Settings, etc.) mod
struct ProfileMod: ViewModifier {
    func body(content: Content) -> some View {
        return content
            .padding(.bottom)
            .foregroundColor(Color.gray)
            .font(.system(size: 22))
            .shadow(radius: 1)
            .foregroundColor(Color.blue)
    }
}


//struct CustomTextField: View {
//    var placeholder: Text
//    @State var text: String
//    var editingChanged: (Bool)->() = { _ in }
//    var commit: ()->() = { }
//
//    var body: some View {
//        ZStack(alignment: .leading) {
//            if text.isEmpty { placeholder }
//            TextField("", text: $text, onEditingChanged: editingChanged, onCommit: commit)
//        }
//    }
//}
