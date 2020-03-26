//
//  AdBuilder.swift
//  AdViewer
//
//  Created by Vincent Guerci on 10/03/2020.
//  Copyright © 2020 Criteo. All rights reserved.
//

typealias BannerView = UIView

protocol InterstitialView {
    func present(viewController: UIViewController)
}

enum AdView {
    case banner(BannerView)
    case interstitial(InterstitialView)
}

typealias AdViewController = UIViewController & InterstitialUpdateDelegate

protocol AdViewBuilder {
    func build(config: AdConfig, criteo: Criteo) -> AdView
}
