//  SmallRouter.swift
//  SwiftUtils
//
//  Created by Lucas Henrique Machado da Silva on 11/02/20.
//  Copyright © 2020 Lucas Henrique Machado da Silva. All rights reserved.
//  See the file "LICENSE" for the full license governing this code.
//

import UIKit

public enum RouteType {
    case present
    case pop(Int? = nil)
    case popToRoot
    case push
    case dismiss
}

public protocol SmallRouter {
    var view: UIViewController? { get }
    var type: RouteType { get }
}

extension SmallRouter {
    func navigate(from: UIViewController, animated: Bool = true, completion: (() -> Void)? = nil) {
        switch (self.type) {
            case .present:
                guard let view = self.view else {
                    fatalError("SmallRouter: View is invalid or isn't implemented")
                }
                from.present(view, animated: animated, completion: completion)
            case .pop(let amount):
                guard let navigationController = from.navigationController else {
                    fatalError("SmallRouter: NavigationController isn't available.")
                }
                
                guard let `amount` = amount else {
                    navigationController.popViewController(animated: animated)
                    return
                }
                
                guard let viewControllers = from.navigationController?.viewControllers, viewControllers.count > amount else {
                    fatalError("SmallRouter: Not enough ViewControllers to pop.")
                }
                
                let viewController = viewControllers[(viewControllers.count - 1) - amount]
                navigationController.popToViewController(viewController, animated: animated)
            case .popToRoot:
                guard let navigationController = from.navigationController else {
                    fatalError("SmallRouter: NavigationController isn't available.")
                }
                navigationController.popToRootViewController(animated: animated)
            case .push:
                guard let navigationController = from.navigationController else {
                    fatalError("SmallRouter: NavigationController isn't available.")
                }
                
                guard let view = self.view else {
                    fatalError("SmallRouter: View is invalid or isn't implemented")
                }
                navigationController.pushViewController(view, animated: animated)
            case .dismiss:
                from.dismiss(animated: animated, completion: completion)
        }
    }
}
