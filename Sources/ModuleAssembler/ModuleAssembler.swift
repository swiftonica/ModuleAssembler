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
    var eventOutput: ((EventOutputReturnType) -> Void)? { get set }
}

public protocol AssemblablePresenter: Initable {
    associatedtype EventOutputReturnType
    associatedtype ViewInterfaceContractType
    
    var eventOutputHandler: ((EventOutputReturnType) -> Void) { get }
    var interfaceContract: ViewInterfaceContractType! { get set }
    
    func start()
}

public extension AssemblablePresenter {
    var eventOutputHandler: ((EventOutputReturnType) -> Void) {
        return { _ in }
    }
}

public protocol Assemblable {
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
}

public extension Assemblable {
    var module: Module<
        ViewType, PresenterType, PublicInterfaceType
    > {
        var view = self.view
        var presenter = self.presenter
        if let eventOutput = presenter.eventOutputHandler as? (ViewType.EventOutputReturnType) -> Void {
            view.eventOutput = eventOutput
        }
        if let interfaceContract = view as? PresenterType.ViewInterfaceContractType {
            presenter.interfaceContract = interfaceContract
        }
        presenter.start()
        return Module(
            view: view,
            presenter: presenter,
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
    
}

public struct Module<ViewType, PresenterType, PublicInterfaceType> {
    public let view: ViewType
    public let presenter: PresenterType
    public let publicInterface: PublicInterfaceType?
}

