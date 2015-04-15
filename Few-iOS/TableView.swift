//
//  TableView.swift
//  Few
//
//  Created by Coen Wessels on 13-03-15.
//  Copyright (c) 2015 Josh Abernathy. All rights reserved.
//

import UIKit

private var ElementKey = "ElementKey"

private let defaultRowHeight: CGFloat = 42

private class FewListCell: UITableViewCell {
    private var realizedElement: RealizedElement?
    
    func updateWithElement(element: Element) {
        if let realizedElement = realizedElement {
            if element.canDiff(realizedElement.element) {
                element.applyDiff(realizedElement.element, realizedSelf: realizedElement)
            } else {
                realizedElement.element.derealize()
                realizedElement.view?.removeFromSuperview()
                
                let newRealizedElement = element.realize()
                newRealizedElement.view?.frame = bounds
                addSubview <^> newRealizedElement.view
            }
        } else {
            let newRealizedElement = element.realize()
            newRealizedElement.view?.frame = bounds
            addSubview <^> newRealizedElement.view
            
            realizedElement = newRealizedElement
        }
    }
}

private class TableViewHandler: NSObject, UITableViewDelegate, UITableViewDataSource {
    let tableView: UITableView
    
    var elements: [Element] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var selectionChanged: (Int -> ())?
    
    init(tableView: UITableView, elements: [Element]) {
        self.tableView = tableView
        self.elements = elements
        super.init()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    // MARK: NSTableViewDelegate
    
    @objc func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let element = elements[indexPath.row]
        
        let key = "ListCell"
        var listCell = tableView.dequeueReusableCellWithIdentifier(key) as? FewListCell
        if listCell == nil {
            listCell = FewListCell(style: .Default, reuseIdentifier: key)
        }
        listCell?.updateWithElement(element)
        return listCell ?? UITableViewCell()
    }
    
    @objc func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let height = elements[indexPath.row].frame.height
        return height > CGFloat(0) ? height : defaultRowHeight
    }
    
    @objc func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    @objc func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements.count
    }
	
	@objc func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectionChanged?(indexPath.row)
    }
}

private class FewTableView: UITableView {
    var handler: TableViewHandler?
}

public class TableView: Element {
    private let elements: [Element]
    private let selectionChanged: (Int -> ())?
    private let selectedRow: Int?
    
    public init(_ elements: [Element], selectedRow: Int? = nil, selectionChanged: (Int -> ())? = nil) {
        self.elements = elements
        self.selectionChanged = selectionChanged
        self.selectedRow = selectedRow
    }
    
    // MARK: -
    
    public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
        super.applyDiff(old, realizedSelf: realizedSelf)
        
        if let scrollView = realizedSelf?.view as? FewTableView {
            let handler = scrollView.handler
            
            layoutElements()
            
            handler?.elements = elements
            
            let tableView = scrollView.handler?.tableView
            
            handler?.selectionChanged = selectionChanged
        }
    }
    
    public override func createView() -> ViewType {
        let tableView = FewTableView(frame: frame)
        layoutElements()
        tableView.handler = TableViewHandler(tableView: tableView, elements: elements)
        tableView.handler?.selectionChanged = selectionChanged
        tableView.alpha = alpha
        tableView.hidden = hidden
        
        return tableView
    }
    
    private final func layoutElements() {
        for element in elements {
            let node = element.assembleLayoutNode()
            let layout = node.layout(maxWidth: frame.size.width)
            element.applyLayout(layout)
        }
    }
}