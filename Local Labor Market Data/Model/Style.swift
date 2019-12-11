//
//  Style.swift
//  Local Labor Market Data
//
//  Created by Nidhi Chawla on 8/21/18.
//  Copyright © 2018 Department of Labor. All rights reserved.
//

import Foundation
import UIKit


struct Style {
    enum DataType {
        case areaTypeTitle
        case areaNameList
        case seasonallyAdjustedSwitch
        case reportAreaTitle
        case reportSubAreaTitle
        case reportSectionTitle
        case reportPeriodName
        case reportAreaDataTitle
        case seasonalAdjustmentValue
        case reportDataTitle
        case reportData
        case reportSubData
        case reportPercentPointTitle
        case reportChangeTitle
        case reportChangeValue
        case reportOwnershipTitle
        case itemPeriodName
        case itemDataType
        case itemColumnTitle
        case itemSubColumnTitle
        case itemAnscestorsList
        case itemParentTitle
        case itemParentValue
        case itemTitle
        case itemValue
        case itemChangeValue
        case searchAreaSegment
        case graphAxisLabel
        case graphLegendLabel
        case graphValueLabel
        case infoLabel
    }
    
    fileprivate static let styleMap: [DataType: (String?, CGFloat, UIFont.Weight, UIFont.TextStyle?, CGFloat?)] =
        [.areaTypeTitle: (nil, 14, .regular, .subheadline, nil),
        .areaNameList: (nil, 14, .light, .subheadline, nil),
        .reportAreaTitle: (nil, 28, .regular, .title1, nil),
        .reportSectionTitle: (nil, 16, .medium, .headline, nil),
        .seasonallyAdjustedSwitch: (nil, 12, .medium, .caption1, nil),
        .reportSubAreaTitle: (nil, 17, .regular, .body, nil),
        .reportPeriodName: (nil, 12, .bold, .caption1, nil),
        .seasonalAdjustmentValue: (nil, 12, .regular, .caption1, nil),
        .reportAreaDataTitle: (nil, 14, .medium, .subheadline, nil),
        .reportDataTitle: (nil, 16, .regular, nil, nil),
        .reportData: (nil, 30, .medium, nil, 64),
        .reportSubData: (nil, 24, .medium, nil, 50),
        .reportPercentPointTitle: (nil, 16, .medium, nil, nil),
        .reportChangeTitle: (nil, 16, .regular, nil, nil),
        .reportChangeValue: (nil, 14, .medium, nil, nil),
        .reportOwnershipTitle: (nil, 16, .regular, nil, nil),
        .itemPeriodName: (nil, 16, .medium, .title1, nil),
        .itemDataType: (nil, 15, .medium, .subheadline, nil),
        .itemColumnTitle: (nil, 14, .regular, .subheadline, nil),
        .itemSubColumnTitle: (nil, 12, .regular, .subheadline, nil),
        .itemAnscestorsList: (nil, 13, .regular, .body, nil),
        .itemParentTitle: (nil, 15, .medium, .body, nil),
        .itemParentValue: (nil, 14, .regular, .body, nil),
        .itemTitle: (nil, 15, .regular, .body, nil),
        .itemValue: (nil, 14, .regular, .body, nil),
        .itemChangeValue: (nil, 12, .regular, .subheadline, nil),
        .searchAreaSegment: (nil, 15, .medium, .subheadline, nil),
        .graphAxisLabel: (nil, 11, .regular, .body, nil),
        .graphLegendLabel: (nil, 12, .regular, .body, nil),
        .graphValueLabel: (nil, 10, .regular, .body, nil),
        .infoLabel: (nil, 15, .regular, .subheadline, nil)]
    
    static func scaledFont(forDataType type: DataType, for traitCollection: UITraitCollection? = nil) -> UIFont {
        let (fontName, fontSize, fontWeight, textStyle, maximumPointSize) = styleMap[type]!
        
        let customFont: UIFont
        if let fontName = fontName {
            customFont = UIFont(name: fontName, size: fontSize)!
        }
        else {
            customFont = UIFont.systemFont(ofSize: fontSize, weight: fontWeight)
        }
        
        let fontMetrics: UIFontMetrics
        if let textStyle = textStyle {
            fontMetrics = UIFontMetrics(forTextStyle: textStyle)
        }
        else {
            fontMetrics = UIFontMetrics.default
        }
        
        if let traitCollection = traitCollection {
            if let maximumPointSize = maximumPointSize {
                return fontMetrics.scaledFont(for: customFont,
                                              maximumPointSize: maximumPointSize,
                                              compatibleWith: traitCollection)
            }
            return fontMetrics.scaledFont(for: customFont, compatibleWith: traitCollection)
        }
        
        return fontMetrics.scaledFont(for: customFont)
    }
}
