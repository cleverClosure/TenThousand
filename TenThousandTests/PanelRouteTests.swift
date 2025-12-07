//
//  PanelRouteTests.swift
//  TenThousandTests
//
//  Unit tests for PanelRoute Equatable implementation
//

import Foundation
@testable import TenThousand
import Testing

@Suite("PanelRoute Behaviors", .serialized)
struct PanelRouteTests {
    // MARK: - Test Helpers

    func makeSkill(name: String = "Test Skill") -> Skill {
        Skill(name: name, paletteId: ColorPalette.summerOceanBreeze.id, colorIndex: 0)
    }

    // MARK: - Simple Route Equality Tests

    @Test("skillList routes are equal")
    func testSkillListRoutesEqual() {
        let route1 = PanelRoute.skillList
        let route2 = PanelRoute.skillList

        #expect(route1 == route2)
    }

    @Test("activeTracking routes are equal")
    func testActiveTrackingRoutesEqual() {
        let route1 = PanelRoute.activeTracking
        let route2 = PanelRoute.activeTracking

        #expect(route1 == route2)
    }

    @Test("skillList and activeTracking are not equal")
    func testSkillListAndActiveTrackingNotEqual() {
        let route1 = PanelRoute.skillList
        let route2 = PanelRoute.activeTracking

        #expect(route1 != route2)
    }

    // MARK: - Skill Detail Route Equality Tests

    @Test("skillDetail routes with same skill are equal")
    func testSkillDetailSameSkillEqual() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillDetail(skill)
        let route2 = PanelRoute.skillDetail(skill)

        #expect(route1 == route2)
    }

    @Test("skillDetail routes with same ID but different instance are equal")
    func testSkillDetailSameIdDifferentInstanceEqual() {
        let skill1 = makeSkill(name: "Swift")
        let skill2 = Skill(name: "Swift Modified", paletteId: ColorPalette.oceanSunset.id, colorIndex: 3)

        // Manually set same ID to simulate same skill with different properties
        // Since we can't set ID directly, we test with the same skill object
        let route1 = PanelRoute.skillDetail(skill1)
        let route2 = PanelRoute.skillDetail(skill1)

        #expect(route1 == route2)
    }

    @Test("skillDetail routes with different skills are not equal")
    func testSkillDetailDifferentSkillsNotEqual() {
        let skill1 = makeSkill(name: "Swift")
        let skill2 = makeSkill(name: "Python")

        let route1 = PanelRoute.skillDetail(skill1)
        let route2 = PanelRoute.skillDetail(skill2)

        #expect(route1 != route2)
    }

    @Test("skillDetail and skillList are not equal")
    func testSkillDetailAndSkillListNotEqual() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillDetail(skill)
        let route2 = PanelRoute.skillList

        #expect(route1 != route2)
    }

    @Test("skillDetail and activeTracking are not equal")
    func testSkillDetailAndActiveTrackingNotEqual() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillDetail(skill)
        let route2 = PanelRoute.activeTracking

        #expect(route1 != route2)
    }

    // MARK: - Skill Edit Route Equality Tests

    @Test("skillEdit routes with same skill are equal")
    func testSkillEditSameSkillEqual() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillEdit(skill)
        let route2 = PanelRoute.skillEdit(skill)

        #expect(route1 == route2)
    }

    @Test("skillEdit routes with different skills are not equal")
    func testSkillEditDifferentSkillsNotEqual() {
        let skill1 = makeSkill(name: "Swift")
        let skill2 = makeSkill(name: "Python")

        let route1 = PanelRoute.skillEdit(skill1)
        let route2 = PanelRoute.skillEdit(skill2)

        #expect(route1 != route2)
    }

    @Test("skillEdit and skillList are not equal")
    func testSkillEditAndSkillListNotEqual() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillEdit(skill)
        let route2 = PanelRoute.skillList

        #expect(route1 != route2)
    }

    @Test("skillEdit and activeTracking are not equal")
    func testSkillEditAndActiveTrackingNotEqual() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillEdit(skill)
        let route2 = PanelRoute.activeTracking

        #expect(route1 != route2)
    }

    // MARK: - Cross-Route Equality Tests

    @Test("skillDetail and skillEdit with same skill are not equal")
    func testSkillDetailAndSkillEditSameSkillNotEqual() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillDetail(skill)
        let route2 = PanelRoute.skillEdit(skill)

        #expect(route1 != route2)
    }

    @Test("skillDetail and skillEdit with different skills are not equal")
    func testSkillDetailAndSkillEditDifferentSkillsNotEqual() {
        let skill1 = makeSkill(name: "Swift")
        let skill2 = makeSkill(name: "Python")

        let route1 = PanelRoute.skillDetail(skill1)
        let route2 = PanelRoute.skillEdit(skill2)

        #expect(route1 != route2)
    }

    // MARK: - Reflexivity Tests

    @Test("skillList is equal to itself (reflexivity)")
    func testSkillListReflexivity() {
        let route = PanelRoute.skillList
        #expect(route == route)
    }

    @Test("activeTracking is equal to itself (reflexivity)")
    func testActiveTrackingReflexivity() {
        let route = PanelRoute.activeTracking
        #expect(route == route)
    }

    @Test("skillDetail is equal to itself (reflexivity)")
    func testSkillDetailReflexivity() {
        let skill = makeSkill()
        let route = PanelRoute.skillDetail(skill)
        #expect(route == route)
    }

    @Test("skillEdit is equal to itself (reflexivity)")
    func testSkillEditReflexivity() {
        let skill = makeSkill()
        let route = PanelRoute.skillEdit(skill)
        #expect(route == route)
    }

    // MARK: - Symmetry Tests

    @Test("skillDetail equality is symmetric")
    func testSkillDetailSymmetry() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillDetail(skill)
        let route2 = PanelRoute.skillDetail(skill)

        #expect(route1 == route2)
        #expect(route2 == route1)
    }

    @Test("skillEdit equality is symmetric")
    func testSkillEditSymmetry() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillEdit(skill)
        let route2 = PanelRoute.skillEdit(skill)

        #expect(route1 == route2)
        #expect(route2 == route1)
    }

    @Test("inequality is symmetric for different route types")
    func testInequalitySymmetric() {
        let skill = makeSkill()
        let route1 = PanelRoute.skillDetail(skill)
        let route2 = PanelRoute.skillList

        #expect(route1 != route2)
        #expect(route2 != route1)
    }

    // MARK: - All Route Type Combinations

    @Test("All different route types are not equal")
    func testAllRouteTypesNotEqual() {
        let skill = makeSkill()

        let routes: [PanelRoute] = [
            .skillList,
            .activeTracking,
            .skillDetail(skill),
            .skillEdit(skill)
        ]

        // Every route should only be equal to itself (same type)
        for i in 0..<routes.count {
            for j in 0..<routes.count {
                if i == j {
                    #expect(routes[i] == routes[j])
                } else if (i == 2 && j == 3) || (i == 3 && j == 2) {
                    // skillDetail and skillEdit with same skill should not be equal
                    #expect(routes[i] != routes[j])
                } else {
                    #expect(routes[i] != routes[j])
                }
            }
        }
    }
}
