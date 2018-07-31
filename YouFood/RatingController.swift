//
//  RatingController.swift
//  YouFood
//
//  Created by XuMaggie on /07/0918.
//  Copyright © 2018年 Novus. All rights reserved.
//
//  Contributers: Maggie Xu
//
//  Unfortunately, this code is unimplemented as we have decided to opt for favorites and
//  counting the number of favorites for a recipe


import UIKit

class RatingController: UIStackView {
	var starRating = 0
	var zero = "grey dot.png"
	var one = "green dot.png"
	override func draw(_ rect: CGRect) {
		let starButtons = self.subviews.filter{$0 is UIButton}
		var starTag = 1
		for button in starButtons {
			if let button = button as? UIButton{
				button.setImage(UIImage(named: zero), for: .normal)
				button.addTarget(self, action: #selector(self.pressed(sender:)), for: .touchUpInside)
				button.tag = starTag
				starTag = starTag + 1
			}
		}
		setStarRating(rating:starRating)
	}
	func setStarRating(rating:Int){
		self.starRating = rating
		let stackSubViews = self.subviews.filter{$0 is UIButton}
		for subView in stackSubViews {
			if let button = subView as? UIButton{
				if button.tag > starRating {
					button.setImage(UIImage(named: zero), for: .normal)
				}else{
					button.setImage(UIImage(named: one), for: .normal)
				}
			}
		}
	}
	@objc func pressed(sender: UIButton) {
		setStarRating(rating: sender.tag)
	}
}
