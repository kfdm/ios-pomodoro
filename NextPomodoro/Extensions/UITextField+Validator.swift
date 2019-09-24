//
//  UITextField+Validator.swift
//  NextPomodoro
//
//  Created by Paul Traylor on 2019/09/21.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import UIKit

struct ValidationError: Error {
    let message: String
}

protocol Validator {
    func validate(_ value: String) throws
}

class ValidatorRequired: Validator {
    func validate(_ value: String) throws {
        if value == "" {
            throw ValidationError(message: "Required field")
        }
    }
}

class ValidatorURL: Validator {
    func validate(_ value: String) throws {
        guard URL(string: value) != nil else {
            throw ValidationError(message: "Invalid URL")
        }
    }

}

enum ValidatorType {
    case required
    case url
}

extension ValidatorType {
    static func validatorFor(type: ValidatorType) -> Validator {
        switch type {
        case .required:
            return ValidatorRequired()
        case .url:
            return ValidatorURL()
        }
    }
}

extension UITextField {
    func validateText(_ validators: [ValidatorType]) throws -> String {
        try validators.forEach { (validator) in
            try ValidatorType.validatorFor(type: validator).validate(text!)
        }
        return text!
    }
}
