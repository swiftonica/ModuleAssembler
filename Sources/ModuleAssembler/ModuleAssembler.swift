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
    associatedtype EventOutputReturnType
    associatedtype InterfaceContractType
    var eventOutput: ((EventOutputReturnType) -> Void)? { get set }
}

public protocol AssemblablePresenter: Initable {
    associatedtype ViewType: AssemblableView
    
    var eventOutputHandler: ((ViewType.EventOutputReturnType) -> Void) { get }
    var interfaceContract: ViewType.InterfaceContractType! { get set }
    
    func start()
}

public extension AssemblablePresenter {
    var eventOutputHandler: ((ViewType.EventOutputReturnType) -> Void) {
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
        var _presenter = self.presenter
        self.currentView = _view
        self.currentPresenter = _presenter
        if let eventOutput = _presenter.eventOutputHandler as? (ViewType.EventOutputReturnType) -> Void {
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

public struct Module<ViewType, PresenterType, PublicInterfaceType> {
    public let view: ViewType
    public let presenter: PresenterType
    public let publicInterface: PublicInterfaceType?
}
