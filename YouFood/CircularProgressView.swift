//
//  CircularProgressView.swift
//  YouFood
//
//  Created by XuMaggie on /07/1118.
//  Copyright © 2018年 Novus. All rights reserved.
//
// Contributers: Maggie Xu, Syou (Cloud) Kanou, Ryan Thompson
//
import UIKit

class Nutrition: NSObject {
    
    var title: String?
    var percentage: CGFloat?
    var trackColor: UIColor?
    var shapeColor: UIColor?
    var recommendedDailyAmount: Float?
    
}

class CircularProgressView: UICollectionViewCell {
    
    var nutrition: Nutrition? {
        didSet {
            
            titleLabel.text = nutrition?.title
            if titleLabel.text == ""{
                percentageLabel.text = ""
            } else {
                percentageLabel.text = "\(Int((nutrition?.percentage)! * 100))%"
            }
            
            self.backgroundColor = UIColor.clear
            self.layer.cornerRadius = self.frame.size.width/2
            let circlePath = UIBezierPath(arcCenter: CGPoint(x: frame.size.width/2, y: frame.size.height/2), radius: (frame.size.width - 1.5)/2, startAngle: CGFloat(-0.5 * .pi), endAngle: CGFloat(1.5 * .pi), clockwise: true)
            trackLayer.path = circlePath.cgPath
            trackLayer.fillColor = UIColor.clear.cgColor
            trackLayer.lineWidth = 6.0
            trackLayer.strokeEnd = 1.0
            trackLayer.lineCap = kCALineCapRound
            trackLayer.strokeColor = (nutrition?.trackColor)!.cgColor
            layer.addSublayer(trackLayer)
            
            shapeLayer.path = circlePath.cgPath
            shapeLayer.fillColor = UIColor.clear.cgColor
            shapeLayer.lineWidth = 6.0
            shapeLayer.strokeEnd = 0.0
            shapeLayer.lineCap = kCALineCapRound
            shapeLayer.strokeColor = (nutrition?.shapeColor)!.cgColor
            layer.addSublayer(shapeLayer)
            
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.duration = 1
            animation.fromValue = 0
            animation.toValue = nutrition?.percentage
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
            
            animation.fillMode = kCAFillModeForwards
            animation.isRemovedOnCompletion = false
            
            shapeLayer.strokeEnd = (nutrition?.percentage)!
            shapeLayer.add(animation, forKey: "animateprogress")
        }
        
    }
    
    let shapeLayer = CAShapeLayer()
    let trackLayer = CAShapeLayer()
    
    let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: -12, width: 100, height: 100))
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "gillsans", size: 15)
        return label
    }()

    
    let percentageLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 7, width: 100, height: 100))
        label.lineBreakMode = .byWordWrapping
        label.numberOfLines = 0
        label.textColor = .black
        label.textAlignment = .center
        label.font = UIFont(name: "gillsans", size: 25)
        return label
    }()
    
    /*
    func setupViews(frame: CGRect) {
        addSubview(titleLabel)
        addSubview(percentageLabel)
      
    }
 */
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(self.titleLabel)
        self.addSubview(self.percentageLabel)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}


