//
//  SlideAnimatingTransition.swift
//  AnonApp
//
//  Created by Matthew Capriotti on 6/28/20.
//  Copyright © 2020 Matthew Capriotti. All rights reserved.
//

import UIKit

class SlideAnimatedTransitioning: NSObject {

}

extension SlideAnimatedTransitioning: UIViewControllerAnimatedTransitioning {

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        let containerView = transitionContext.containerView
        let fromView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)!.view
        let toView = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)!.view
        
        let width = containerView.frame.width
        
        var offsetLeft = fromView?.frame
        offsetLeft?.origin.x = width
        
        var offscreenRight = toView?.frame
        offscreenRight?.origin.x = -width / 3.33;
        
        toView?.frame = offscreenRight!;
        
        fromView?.layer.shadowRadius = 5.0
        fromView?.layer.shadowOpacity = 1.0
        toView?.layer.opacity = 0.9
        
        containerView.insertSubview(toView!, belowSubview: fromView!)
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext), delay:0, options:.curveLinear, animations:{
            
            toView?.frame = (fromView?.frame)!
            fromView?.frame = offsetLeft!
            
            toView?.layer.opacity = 1.0
            fromView?.layer.shadowOpacity = 0.1
            
            }, completion: { finished in
                toView?.layer.opacity = 1.0
                toView?.layer.shadowOpacity = 0
                fromView?.layer.opacity = 1.0
                fromView?.layer.shadowOpacity = 0
                
                // when cancelling or completing the animation, ios simulator seems to sometimes flash black backgrounds during the animation. on devices, this doesn't seem to happen though.
                // containerView.backgroundColor = [UIColor whiteColor];
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        
        return 0.3
    }

}
