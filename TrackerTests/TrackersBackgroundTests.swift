import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackersBackgroundTests: XCTestCase {
    override func setUp() {
        super.setUp()
        SnapshotTesting.isRecording = false
    }

    func testTrackersViewControllerAppearance_LightAndDark() {
        let trackersVC = TrackersViewController()
        trackersVC.loadViewIfNeeded()

        trackersVC.view.frame = CGRect(x: 0, y: 0, width: 430, height: 932)

        trackersVC.view.backgroundColor = .ypWhite
        assertSnapshot(of: trackersVC.view, as: .image, named: "Light")

        trackersVC.view.backgroundColor = .red
        assertSnapshot(of: trackersVC.view, as: .image, named: "Light_Modified")

        let traitsDark = UITraitCollection(userInterfaceStyle: .dark)
        trackersVC.view.backgroundColor = .ypWhite
        assertSnapshot(of: trackersVC.view, as: .image(traits: traitsDark), named: "Dark")
    }
}
