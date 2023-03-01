/// This Library is full opensource and free to use
///
///     version: 1.0
///
///     License: MIT License
///
/// Created by Jeytery for iOS community with love

public protocol Initable {
    init()
}

public extension Initable {
    init() {
        self.init()
    }
}

public protocol AssemblableView: Initable {
    associatedtype EventOutputType
    associatedtype InterfaceContractType
    var eventOutput: ((EventOutputType) -> Void)? { get set }
}

public protocol AssemblablePresenter: Initable, AnyObject {
    associatedtype ViewType: AssemblableView
    
    var eventOutputHandler: ((ViewType.EventOutputType) -> Void) { get }
    var interfaceContract: ViewType.InterfaceContractType! { get set }
    
    func start()
}

public extension AssemblablePresenter {
    var eventOutputHandler: ((ViewType.EventOutputType) -> Void) {
        return { _ in }
    }
}

public protocol Assemblable: AnyObject {
    associatedtype ViewType: AssemblableView
    associatedtype PresenterType: AssemblablePresenter
    associatedtype PublicInterfaceType
    
    var module: Module<
        ViewType, PresenterType, PublicInterfaceType
    > {
        get
    }
    
    var view: ViewType { get }
    var presenter: PresenterType { get }
    var publicInterface: PublicInterfaceType? { get }
    
    var currentView: ViewType! { get set }
    var currentPresenter: PresenterType! { get set }
}

public extension Assemblable {
    var module: Module<
        ViewType, PresenterType, PublicInterfaceType
    > {
        var _view = self.view
        let _presenter = self.presenter
        self.currentView = _view
        self.currentPresenter = _presenter
        if let eventOutput = _presenter.eventOutputHandler as? (ViewType.EventOutputType) -> Void {
            _view.eventOutput = eventOutput
        }
        if let interfaceContract = _view as? PresenterType.ViewType.InterfaceContractType {
            _presenter.interfaceContract = interfaceContract
        }
        _presenter.start()
        return Module(
            view: _view,
            presenter: _presenter,
            publicInterface: self.publicInterface
        )
    }
}

public extension Assemblable {
    var view: ViewType {
        return ViewType()
    }
    
    var presenter: PresenterType {
        return PresenterType()
    }
    
    var publicInterface: PublicInterfaceType? {
        return view as? PublicInterfaceType
    }
}

public class Assembler<
    ViewType: AssemblableView,
    PresenterType: AssemblablePresenter,
    PublicInterfaceType
>: Assemblable {
    public var currentView: ViewType!
    public var currentPresenter: PresenterType!
}

public struct Module<ViewType, PresenterType: AnyObject, PublicInterfaceType>: Equatable {
    public static func == (
        lhs: Module<ViewType, PresenterType, PublicInterfaceType>,
        rhs: Module<ViewType, PresenterType, PublicInterfaceType>
    ) -> Bool {
        return lhs.presenter === rhs.presenter
    }
    
    public let view: ViewType
    public let presenter: PresenterType
    public let publicInterface: PublicInterfaceType?
    
    public init(view: ViewType, presenter: PresenterType, publicInterface: PublicInterfaceType?) {
        self.view = view
        self.presenter = presenter
        self.publicInterface = publicInterface
    }
}

public struct ModuleKeeper<ModulesEnumType: Hashable> {
    private(set) public var modules: [ModulesEnumType: Any] = [:]
    public init() {}

    public mutating func keepModule(_ module: Any, forKey: ModulesEnumType) {
        modules[forKey] = module
    }
    
    public mutating func removeModule(_ module: Any, forKey: ModulesEnumType) {
        modules[forKey] = nil
    }
}
