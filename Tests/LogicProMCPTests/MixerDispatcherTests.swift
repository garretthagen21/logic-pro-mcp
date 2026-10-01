import MCP
import XCTest
@testable import LogicProMCP

final class MixerDispatcherTests: XCTestCase {
    func testWholeNumberVolumeIsNotTreatedAsZero() async {
        let accessibility = FakeChannel(id: .accessibility, responses: ["mixer.set_volume": [.success("{}")]])
        let router = ChannelRouter()
        await router.register(accessibility)

        let result = await MixerDispatcher.handle(
            command: "set_volume", params: ["track": .int(2), "value": .int(1)], router: router, cache: StateCache()
        )

        XCTAssertNotEqual(result.isError, true)
        let calls = await accessibility.callCount("mixer.set_volume")
        XCTAssertEqual(calls, 1)
    }

    func testOutOfRangeVolumeNeverReachesLogic() async {
        let accessibility = FakeChannel(id: .accessibility, responses: ["mixer.set_volume": [.success("{}")]])
        let router = ChannelRouter()
        await router.register(accessibility)

        let result = await MixerDispatcher.handle(
            command: "set_volume", params: ["track": .int(2), "value": .int(2)], router: router, cache: StateCache()
        )

        XCTAssertEqual(result.isError, true)
        let calls = await accessibility.callCount("mixer.set_volume")
        XCTAssertEqual(calls, 0)
    }
}
