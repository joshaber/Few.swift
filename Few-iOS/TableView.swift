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
				realizedElement.remove()

				let parent = RealizedElement(element: Element(), view: self, parent: nil)
				self.realizedElement = element.realize(parent)
            }
        } else {
			let parent = RealizedElement(element: Element(), view: self, parent: nil)
			realizedElement = element.realize(parent)
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
	private let header: Element?
	
	public init(_ elements: [Element], selectedRow: Int? = nil, header: Element? = nil, selectionChanged: (Int -> ())? = nil) {
        self.elements = elements
        self.selectionChanged = selectionChanged
        self.selectedRow = selectedRow
		self.header = header
    }
    
    // MARK: -
    
    public override func applyDiff(old: Element, realizedSelf: RealizedElement?) {
        super.applyDiff(old, realizedSelf: realizedSelf)
        
        if let tableView = realizedSelf?.view as? FewTableView {
            let handler = tableView.handler
            
            layoutElements()
            
            handler?.elements = elements
            
            let newHeaderView = header?.realize(realizedSelf).view
            var needsUpdate = false
            if newHeaderView != tableView.tableHeaderView {
                needsUpdate = true
            } else if let newHeight = newHeaderView?.frame.height where newHeight != tableView.rectForSection(0).minY {
                needsUpdate = true
            }
            if needsUpdate {
                tableView.tableHeaderView = newHeaderView
				/// if you don't do this, the table view may compute the wrong header height
                UIView.performWithoutAnimation {
                    tableView.beginUpdates()
                    tableView.endUpdates()
                }
            }

            handler?.selectionChanged = selectionChanged
        }
    }
    
    public override func elementDidRealize(realizedSelf: RealizedElement) {
        super.elementDidRealize(realizedSelf)
        if let tableView = realizedSelf.view as! FewTableView? {
            tableView.tableHeaderView = header?.realize(realizedSelf).view
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