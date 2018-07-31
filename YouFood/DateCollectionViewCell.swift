//
//  CollectionViewCell.swift
//  YouFood
//
//  Created by XuMaggie on /07/2518.
//  Copyright © 2018年 Novus. All rights reserved.
//
//  Contributers: Maggie Xu
//
//  Properties and functions for the calender cells

import UIKit
import Foundation


class DateCollectionViewCell: UICollectionViewCell {

	let Circle: UIView = {
		let view = UIView(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
		
		return view
	}()
	let DateLabel: UILabel = {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 25, height: 25))
		label.lineBreakMode = .byWordWrapping
		label.numberOfLines = 0
		label.textAlignment = .center
		label.font = UIFont(name: "gillsans", size: 17)
		
		return label
	}()
	
	func DrawCircle() {
		
		let circleCenter = Circle.center
		
		let circlePath = UIBezierPath(arcCenter: circleCenter, radius: ((Circle.bounds.width)/2 - 5), startAngle: -CGFloat.pi/2, endAngle: (2 * CGFloat.pi), clockwise: true)
		
		let CircleLayer = CAShapeLayer()
		CircleLayer.path = circlePath.cgPath
		CircleLayer.strokeColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 0.5).cgColor
		CircleLayer.lineWidth = 2
		CircleLayer.strokeEnd = 0
		CircleLayer.fillColor = UIColor(red: 252.0/255.0, green: 141.0/255.0, blue: 165.0/255.0, alpha: 0.5).cgColor
		CircleLayer.lineCap = kCALineCapRound
		
		let Animation = CABasicAnimation(keyPath: "strokeEnd")
		Animation.duration = 1.5
		Animation.toValue = 1
		Animation.fillMode = kCAFillModeForwards
		Animation.isRemovedOnCompletion = false
		
		CircleLayer.add(Animation, forKey: nil)
		Circle.layer.addSublayer(CircleLayer)
		Circle.layer.backgroundColor = UIColor.clear.cgColor
		
	}
	
	override init(frame: CGRect) {
		super.init(frame: frame)
		self.addSubview(self.Circle)
		self.addSubview(self.DateLabel)
		
	}
	
	required init?(coder aDecoder: NSCoder) {
		super.init(coder: aDecoder)
	}
}

