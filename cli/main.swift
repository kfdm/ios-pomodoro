//
//  main.swift
//  pomodoro-cli
//
//  Created by ST20638 on 2019/12/19.
//  Copyright © 2019 Paul Traylor. All rights reserved.
//

import SwiftCLI

let main = CLI(name: "pomodoro", version: "1.0.0", description: "Tool for managing pomodoros")
main.commands = [AlfredGroup()]
main.goAndExit()
