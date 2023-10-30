import UIKit

public enum TableViewRegistrationMethod {
    case classBased(AnyClass?)
    case nibBased(UINib?)
    case style(UITableViewCell.CellStyle)
    case dynamic
}

// Headers and footers lack the support for UITableViewCellStyle. Hence this separate enum.
public enum TableViewHeaderFooterRegistrationMethod {
    case classBased(AnyClass?)
    case nibBased(UINib?)
    case dynamic
}

public protocol TableViewFactoryType {
    associatedtype Item
    
    func registerCell<C>(method: TableViewRegistrationMethod, reuseIdentifier: String, in view: UITableView, configuration: @escaping (_ cell: C, _ item: Item, _ indexPath: IndexPath) -> Void)
    func cell(for item: Item, in view: UITableView, at indexPath: IndexPath) -> UITableViewCell?

    func registerHeaderText(in view: UITableView, textProvider: @escaping (_ section: Int) -> String?)
    func headerText(forSection section: Int, in view: UITableView) -> String?
    func registerFooterText(in view: UITableView, textProvider: @escaping (_ section: Int) -> String?)
    func footerText(forSection section: Int, in view: UITableView) -> String?
    
    func registerHeaderFooterView<V>(method: TableViewHeaderFooterRegistrationMethod, reuseIdentifier: String, in view: UITableView, configuration: @escaping (_ headerFooterView: V, _ section: Int) -> Void)
    func headerFooterView(reuseIdentifier: String, in view: UITableView, forSection section: Int) -> UIView?
}

public class TableViewFactory<Item>: TableViewFactoryType {
    
    // These just make our internal types more readable.
    private typealias ContainerView = UITableView
    private typealias ReuseIdentifier = String
    private typealias ContainerViewIdentifier = Int
    private typealias CellProvider = (Item, ContainerView, IndexPath) -> Any?
    private typealias HeaderFooterTextProvider = (Int) -> String?
    private typealias HeaderFooterViewProvider = (ContainerView, Int) -> Any?
    
    private let reuseIdentifierForItem: (Item, ContainerView) -> String
    private var cellProviders = [ContainerViewIdentifier : [ReuseIdentifier : CellProvider]]()
    private var headerTextProviders = [ContainerViewIdentifier : HeaderFooterTextProvider]()
    private var footerTextProviders = [ContainerViewIdentifier : HeaderFooterTextProvider]()
    private var headerFooterViewProviders = [ContainerViewIdentifier : [ReuseIdentifier : HeaderFooterViewProvider]]()

    public init(reuseIdentifierForItem: @escaping (Item, UITableView) -> String) {
        self.reuseIdentifierForItem = reuseIdentifierForItem
    }
    
    // MARK: - Cells
    
    public func registerCell<C>(method: TableViewRegistrationMethod, reuseIdentifier: String, in view: UITableView, configuration: @escaping (_ cell: C, _ item: Item, _ indexPath: IndexPath) -> Void) {
        
        switch method {
        case .classBased(let c):
            view.register(c, forCellReuseIdentifier: reuseIdentifier)
        case .nibBased(let nib):
            view.register(nib, forCellReuseIdentifier: reuseIdentifier)
        case .style(_):
            if C.self != UITableViewCell.self {
                fatalError("Registering a UITableViewCellStyle is not supported for custom subclasses of UITableViewCell.")
            }
        case .dynamic:
            break
        }
        
        var cellProvidersForView = cellProviders[view.hashValue] ?? [:]
        cellProvidersForView[reuseIdentifier] = { (item, view, indexPath) -> C? in
            let optionalCell: C?
            if case .style(let style) = method {
                if let dequeued = view.dequeueReusableCell(withIdentifier: reuseIdentifier) {
                    optionalCell = dequeued as? C
                } else {
                    optionalCell = UITableViewCell(style: style, reuseIdentifier: reuseIdentifier) as? C
                }
            } else {
                optionalCell = view.dequeueReusableCell(withIdentifier: reuseIdentifier, for: indexPath) as? C
            }
            guard let cell = optionalCell else { return nil }
            configuration(cell, item, indexPath)
            return cell
        }
        cellProviders[view.hashValue] = cellProvidersForView
    }
    
    public func cell(for item: Item, in view: UITableView, at indexPath: IndexPath) -> UITableViewCell? {
        let reuseIdentifier = reuseIdentifierForItem(item, view)
        let cellProvider = cellProviders[view.hashValue]?[reuseIdentifier]
        return cellProvider?(item, view, indexPath) as? UITableViewCell
    }
    
    // MARK: - Header/Footer Text
    
    public func registerHeaderText(in view: UITableView, textProvider: @escaping (_ section: Int) -> String?) {
        headerTextProviders[view.hashValue] = textProvider
    }
    
    public func headerText(forSection section: Int, in view: UITableView) -> String? {
        return headerTextProviders[view.hashValue]?(section)
    }
    
    public func registerFooterText(in view: UITableView, textProvider: @escaping (_ section: Int) -> String?) {
        footerTextProviders[view.hashValue] = textProvider
    }
    
    public func footerText(forSection section: Int, in view: UITableView) -> String? {
        return footerTextProviders[view.hashValue]?(section)
    }    

    // MARK: - Custom Header/Footer Views
    
    // NOTE:
    //
    // These methods for custom header/footer views are not called from TableViewDataSource. The UITableView API
    // requires that these views are returned from the UITableViewDelegate. They are provided to make it more
    // convenient to implement this delegate functionality. The custom delegate can invoke these methods directly
    // on the view factory.
    
    public func registerHeaderFooterView<V>(method: TableViewHeaderFooterRegistrationMethod, reuseIdentifier: String, in view: UITableView, configuration: @escaping (_ headerFooterView: V, _ section: Int) -> Void) {
        switch method {
        case .classBased(let c):
            view.register(c, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        case .nibBased(let nib):
            view.register(nib, forHeaderFooterViewReuseIdentifier: reuseIdentifier)
        case .dynamic:
            break
        }

        var headerFooterViewProvidersForView = headerFooterViewProviders[view.hashValue] ?? [:]
        headerFooterViewProvidersForView[reuseIdentifier] = { (view, section) -> V? in
            guard let headerFooterView = view.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? V else { return nil }
            configuration(headerFooterView, section)
            return headerFooterView
        }
        headerFooterViewProviders[view.hashValue] = headerFooterViewProvidersForView
    }
    
    public func headerFooterView(reuseIdentifier: String, in view: UITableView, forSection section: Int) -> UIView? {
        let headerFooterViewProvider = headerFooterViewProviders[view.hashValue]?[reuseIdentifier]
        return headerFooterViewProvider?(view, section) as? UIView
    }
}
