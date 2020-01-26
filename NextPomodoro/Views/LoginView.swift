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
    @State var loginstring: String = ""
    @State var password: String = ""

    @State var authenticationFailure: Bool = false
    @State var authenticationError: String = ""

    var body: some View {
        VStack {
            TextField("Username", text: $loginstring)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)

            SecureField("Password", text: $password)

            if authenticationFailure {
                Text(authenticationError)
            }

            Button(action: submit) {
                Text("Login")
            }
        }.padding()
    }

    func submit() {
        guard let components = URLComponents(string: "https://\(loginstring)") else { return }
        guard let hostname = components.host else { return }
        guard let username = components.user else { return }

        Info.get(baseURL: hostname, username: username, password: password) { (result) in
            switch result {
            case .success(let info):
                ApplicationSettings.defaults.set(value: username, forKey: .username)
                ApplicationSettings.defaults.set(value: hostname, forKey: .server)
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
                self.authenticationFailure = true
                self.authenticationError = error.localizedDescription
            }

        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
