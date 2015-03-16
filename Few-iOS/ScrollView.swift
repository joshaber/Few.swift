//
//  ScrollView.swift
//  Few
//
//  Created by Coen Wessels on 14-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private class FewScrollView: UIScrollView, UIScrollViewDelegate {
    private var didScroll: CGRect -> ()
    
    private init(frame: CGRect, didScroll: CGRect -> ()) {
        self.didScroll = didScroll
        
        super.init(frame: frame)
        
        delegate = self
    }
    
    required init(coder: NSCoder) {
        fatalError("FewScrollView should not be used in a xib.")
    }
    
    private func scrollViewDidScroll(scrollView: UIScrollView) {
        didScroll(CGRect(origin: contentOffset, size: frame.size))
    }
}

private class ScrollViewElement: Element {
    private let didScroll: CGRect -> ()
    
    private init(_ didScroll: CGRect -> ()) {
        self.didScroll = didScroll
    }
    
    // MARK: Element
    
    private override func createView() -> ViewType {
        let scrollView = FewScrollView(frame: frame, didScroll: didScroll)
        scrollView.alpha = alpha
        scrollView.hidden = hidden
        return scrollView
    }
    
    private override func addRealizedChildView(childView: ViewType, selfView: ViewType) {
        let scrollVew = selfView as FewScrollView
        scrollVew.addSubview(childView)
    }
    
    private override func realize() -> RealizedElement {
        let realizedElement = super.realize()
        
        let scrollView = realizedElement.view as FewScrollView
        let documentView = scrollView.subviews.first! as UIView
        
        let top = CGPointMake(0, documentView.bounds.size.height);
        scrollView.contentOffset = top
        
        return realizedElement
    }
    
    private override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
        super.applyDiff(old, realizedSelf: realizedSelf)
        
        let scrollView = realizedSelf?.view as FewScrollView
        scrollView.didScroll = didScroll
    }
}

private class ScrollViewContent: Element {
    private let layoutChildren: [Element]
    
    private init(layoutChildren: [Element]) {
        self.layoutChildren = layoutChildren
    }
    
    private override func assembleLayoutNode() -> Node {
        let childNodes = layoutChildren.map { $0.assembleLayoutNode() }
        return Node(size: frame.size, children: childNodes, direction: direction, margin: margin, padding: padding, wrap: wrap, justification: justification, selfAlignment: selfAlignment, childAlignment: childAlignment, flex: flex)
    }
    
    private override func applyLayout(layout: Layout) {
        frame = layout.frame
        
        for (child, layout) in Zip2(layoutChildren, layout.children) {
            child.applyLayout(layout)
        }
    }
}

public typealias ScrollView = ScrollView_<CGRect>

public class ScrollView_<LOL>: Component<CGRect> {
    public var elements: [Element]
    
    public init(_ elements: [Element]) {
        self.elements = elements.reverse()
        super.init(initialState: CGRectZero, render: ScrollView_.render)
    }
    
    private class func render(c: Component<CGRect>, visibleRect: CGRect) -> Element {
        let component = c as ScrollView_
        
        let visibleElements = component.calculateVisibleElements(visibleRect)
        
        let weakScroll: CGRect -> () = { [weak component] rect in
            if let component = component {
                component.didScroll(rect)
            }
        }
        return ScrollViewElement(weakScroll)
            .direction(.Column)
            .children([
                ScrollViewContent(layoutChildren: component.elements)
                    .children(visibleElements)
                    .direction(.Column)
                ])
    }
    
    final private func didScroll(visibleRect: CGRect) {
        updateState { _ in visibleRect }
    }
    
    final private func calculateVisibleElements(visibleRect: CGRect) -> [Element] {
        return elements.filter { CGRectIntersectsRect(visibleRect, $0.frame) }
    }
    
    internal override var selfDescription: String {
        return "\(self.dynamicType): " + calculateVisibleElements(getState()).description
    }
}