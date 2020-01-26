//
//  LoginView.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2020/01/26.
//  Copyright © 2020 Paul Traylor. All rights reserved.
//

import SwiftUI
import Foundation

struct LoginView: View {
    @State var username: String = ""
    @State var password: String = ""

    var body: some View {
        VStack {
            Text("Login")

            TextField("Username", text: $username)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)

            Button(action: submit) {
                Text("Login")
            }
        }.padding()
    }

    func submit() {
        guard let components = URLComponents(string: "https://\(username)") else { return }
        Info.get(baseURL: components.host!, username: components.user!, password: password) { (result) in
            switch result {
            case .success(let info):
                ApplicationSettings.defaults.set(value: components.user!, forKey: .username)
                ApplicationSettings.defaults.set(value: components.host!, forKey: .server)
                ApplicationSettings.keychain.set(self.password, forKey: .server)

                if let broker = URLComponents(url: info.mqtt!, resolvingAgainstBaseURL: false) {
                    ApplicationSettings.defaults.set(value: broker.host!, forKey: .broker)
                    ApplicationSettings.defaults.set(value: broker.port!, forKey: .brokerPort)
                    ApplicationSettings.defaults.set(value: broker.scheme == "mqtts", forKey: .brokerSSL)
                }

                DispatchQueue.main.async {
                    NotificationCenter.default.post(name: .authenticationGranted, object: nil)
                }
            case .failure(let error):
                print(error)
            }

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
