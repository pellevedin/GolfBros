//
//  ChartDefaults.swift
//  Golfbros11
//
//  Created by Pelle Vedin on 2018-11-21.
//  Copyright © 2018 Pelle Vedin. All rights reserved.
//

import UIKit
import SwiftCharts

struct GBChartsDefaults {
    
    static var chartSettings: ChartSettings {
        if Env.iPad {
            return iPadChartSettings
        } else {
            return iPhoneChartSettings
        }
    }
    
    static var chartSettingsWithPanZoom: ChartSettings {
        if Env.iPad {
            return iPadChartSettingsWithPanZoom
        } else {
            return iPhoneChartSettingsWithPanZoom
        }
    }
    
    fileprivate static var iPadChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 10
        chartSettings.top = 10
        chartSettings.trailing = 10
        chartSettings.bottom = 10
        chartSettings.labelsToAxisSpacingX = 10
        chartSettings.labelsToAxisSpacingY = 10
        chartSettings.axisTitleLabelsToLabelsSpacing = 5
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 15
        chartSettings.spacingBetweenAxesY = 15
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    fileprivate static var iPhoneChartSettings: ChartSettings {
        var chartSettings = ChartSettings()
        chartSettings.leading = 1
        chartSettings.top = 10
        chartSettings.trailing = 1
        chartSettings.bottom = 5
        chartSettings.labelsToAxisSpacingX = 5
        chartSettings.labelsToAxisSpacingY = 5
        chartSettings.axisTitleLabelsToLabelsSpacing = 2
        chartSettings.axisStrokeWidth = 1
        chartSettings.spacingBetweenAxesX = 0
        chartSettings.spacingBetweenAxesY = 0
        chartSettings.labelsSpacing = 0
        return chartSettings
    }
    
    fileprivate static var iPadChartSettingsWithPanZoom: ChartSettings {
        var chartSettings = iPadChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = true
        return chartSettings
    }
    
    fileprivate static var iPhoneChartSettingsWithPanZoom: ChartSettings {
        var chartSettings = iPhoneChartSettings
        chartSettings.zoomPan.panEnabled = true
        chartSettings.zoomPan.zoomEnabled = true
        return chartSettings
    }
    
    static func chartFrame(_ containerBounds: CGRect) -> CGRect {
        return CGRect(x: 0, y: 70, width: containerBounds.size.width, height: containerBounds.size.height - 70)
    }
    
    static var labelSettings: ChartLabelSettings {
        return ChartLabelSettings(font: GBChartsDefaults.labelFont)
    }
    
    static var labelFont: UIFont {
        return GBChartsDefaults.fontWithSize(Env.iPad ? 14 : 17)
    }
    
    static var labelFontSmall: UIFont {
        return GBChartsDefaults.fontWithSize(Env.iPad ? 12 : 10)
    }
    
    static func fontWithSize(_ size: CGFloat) -> UIFont {
        return UIFont(name: "Helvetica Neue", size: size) ?? UIFont.systemFont(ofSize: size)
    }
    
    static var guidelinesWidth: CGFloat {
        return Env.iPad ? 0.5 : 0.1
    }
    
    static var minBarSpacing: CGFloat {
        return Env.iPad ? 10 : 5
    }
}
class Env {
    
    static var iPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
}



