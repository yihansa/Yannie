//
//  DraggableAreaViewController.swift
//
//
//  Created by exerhythm on 05.05.2022.
//

import os
import SwiftUI

class DraggableAreaViewController: UIViewController {
    
    private var calcView: UIView?
    private var lastSwipeBeginningPoint: CGPoint?
    
    var safeAreaInsets: UIEdgeInsets {
        (view.window?.windowScene?.windows.first!.safeAreaInsets)!
    }
    
    let maxCalcWidth: CGFloat = 400
    var bigScreen: Bool {
        view.bounds.width > maxCalcWidth
    }
    
    func calculatorViewShown() -> Bool {
        return calcView != nil
    }
    
    func showCalculatorView() {
        let ratio = 0.6
        let padding: CGFloat = 10
        let calcwidth = min(maxCalcWidth, view.bounds.width - padding * 2)
        let calcheight = calcwidth * ratio
        
        let calculatorView = CalculatorView(close: hideCalculatorView)
            .frame(width: calcwidth, height: calcheight)
        
        if calcView == nil {
            let calcVC = UIHostingController(rootView: calculatorView)
            addChild(calcVC)
            view.addSubview(calcVC.view)
            calcVC.didMove(toParent: self)
            calcView = calcVC.view
        }
        
        let resY = view.bounds.height - calcheight - padding - safeAreaInsets.bottom
        calcView!.frame = .init(x: padding, y: resY, width: calcwidth, height: calcheight)
        
        
        calcView!.backgroundColor = .clear
        calcView!.translatesAutoresizingMaskIntoConstraints = false
        calcView!.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(handlePan)))
        calcView!.alpha = 0
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.calcView!.alpha = 1
        })
    }
    func hideCalculatorView() {
        UIView.animate(withDuration: 0.2, delay: 0, options: .curveEaseOut, animations: {
            self.calcView?.alpha = 0
        }, completion: { _ in
            self.calcView?.removeFromSuperview()
            self.calcView = nil
        })
    }
    
    @objc func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard let calcView = calcView else { return }
        if gesture.state == .ended {
            let velocity = gesture.velocity(in: view)
            
            var calcX: CGFloat = calcView.center.x
            var calcY: CGFloat = 0
            let minVelocity: CGFloat = 300
            
            if velocity.y < -minVelocity || (!(velocity.y > minVelocity) && gesture.location(in: view).y < view.bounds.height / 2) {
                calcY = calcView.frame.height / 2 + safeAreaInsets.top + 10
            } else {
                calcY = view.bounds.height - calcView.frame.height / 2 - 10 - safeAreaInsets.bottom
            }
            
            if velocity.x < -minVelocity || (!(velocity.x > minVelocity) && gesture.location(in: view).x < view.bounds.width / 2) {
                calcX = calcView.frame.width / 2 + safeAreaInsets.left + 10
            } else {
                calcX = view.bounds.width - calcView.frame.width / 2 - 10 - safeAreaInsets.right
            }
            
            let finalPoint = CGPoint(x: calcX, y: calcY)
            
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: sqrt(pow(velocity.y, 2) + pow(velocity.x, 2)) / 70, options: .curveEaseInOut, animations: {
                self.calcView?.center = finalPoint
            })
        }
        let translation = gesture.translation(in: view)
        guard let gestureView = gesture.view else {
            return
        }
        gestureView.center = CGPoint(
            x: gestureView.center.x + translation.x,
            y: gestureView.center.y + translation.y
        )
        gesture.setTranslation(.zero, in: view)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: nil, completion: {_ in
            UIView.setAnimationsEnabled(true)
        })
        UIView.setAnimationsEnabled(false)
        super.viewWillTransition(to: size, with: coordinator);
        
//        hideCalculatorView()
        if calcView != nil {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                self.showCalculatorView()
            })
        }
    }
}
