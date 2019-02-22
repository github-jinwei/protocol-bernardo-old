//
//  LayoutTouchbar.swift
//  Protocol Bernardo
//
//  Created by Valentin Dufois on 2019-02-21.
//  Copyright © 2019 Prisme. All rights reserved.
//

import AppKit

class LayoutTouchbar: NSTouchBar {
    /// List of available items for this touchbar
    ///
    /// - layoutConfigurationPopover: <#layoutConfigurationPopover description#>
    /// - toggleSidebarButton: <#toggleSidebarButton description#>
    /// - editConfigurationItems: <#editConfigurationItems description#>
    /// - calibrateConfiguration: <#calibrateConfiguration description#>
    enum ItemsIdentifier: String {
        case layoutConfigurationPopover
        case toggleSidebarButton

        case editConfigurationItems
        case calibrateConfiguration

        var identifier: NSTouchBarItem.Identifier {
            return NSTouchBarItem.Identifier(self.rawValue)
        }
    }
}
