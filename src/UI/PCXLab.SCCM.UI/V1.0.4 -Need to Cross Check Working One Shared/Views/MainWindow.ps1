class MainWindowView {
    [object] $Window
    [object] $TxtSourcePath
    [object] $BtnBrowse
    [object] $TxtAppName
    [object] $TxtPkgName
    [object] $TxtCompany
    [object] $TxtProduct
    [object] $TxtVersion
    [object] $PnlDPGroups
    [object] $PnlDPs
    [object] $PnlCMGs
    [object] $BtnRefreshDPs
    [object] $RadApp
    [object] $RadPkg
    [object] $BtnCreate
    [object] $PnlAppName
    [object] $PnlPkgName
    [object] $TxtRefNumber
    [object] $TxtReviewer
    [object] $TxtComment
    [object] $LblComment

    MainWindowView([string]$xamlPath) {
        [xml]$xaml = Get-Content $xamlPath
        $reader = New-Object System.Xml.XmlNodeReader $xaml
        $this.Window = [Windows.Markup.XamlReader]::Load($reader)

        # Map UI Controls
        $this.TxtSourcePath = $this.Window.FindName("txtSourcePath")
        $this.BtnBrowse = $this.Window.FindName("btnBrowse")
        $this.TxtAppName = $this.Window.FindName("txtAppName")
        $this.TxtPkgName = $this.Window.FindName("txtPkgName")
        $this.TxtCompany = $this.Window.FindName("txtCompany")
        $this.TxtProduct = $this.Window.FindName("txtProduct")
        $this.TxtVersion = $this.Window.FindName("txtVersion")
        $this.PnlDPGroups = $this.Window.FindName("pnlDPGroups")
        $this.PnlDPs = $this.Window.FindName("pnlDPs")
        $this.PnlCMGs = $this.Window.FindName("pnlCMGs")
        $this.BtnRefreshDPs = $this.Window.FindName("btnRefreshDPs")
        $this.RadApp = $this.Window.FindName("radApp")
        $this.RadPkg = $this.Window.FindName("radPkg")
        $this.BtnCreate = $this.Window.FindName("btnCreate")
        $this.PnlAppName = $this.Window.FindName("pnlAppName")
        $this.PnlPkgName = $this.Window.FindName("pnlPkgName")
        $this.TxtRefNumber = $this.Window.FindName("txtRefNumber")
        $this.TxtReviewer = $this.Window.FindName("txtReviewer")
        $this.TxtComment = $this.Window.FindName("txtComment")
        $this.LblComment = $this.Window.FindName("lblComment")
    }

    [void] Show() {
        $this.Window.ShowDialog() | Out-Null
    }

    [void] SetWaitCursor([bool]$isWait) {
        $this.Window.Dispatcher.Invoke({
            if ($isWait) {
                $this.Window.Cursor = [System.Windows.Input.Cursors]::Wait
            } else {
                $this.Window.Cursor = [System.Windows.Input.Cursors]::Arrow
            }
        })
    }

    [void] SetCreateButtonState([bool]$enabled) {
        $this.Window.Dispatcher.Invoke({
            $this.BtnCreate.IsEnabled = $enabled
        })
    }

    [void] PopulateDistributionList([object]$panel, [string[]]$items) {
        $this.Window.Dispatcher.Invoke({
            $panel.Children.Clear()
            foreach ($item in $items) {
                $checkBox = New-Object System.Windows.Controls.CheckBox
                $checkBox.Content = $item
                $checkBox.Margin = "2"
                $checkBox.Foreground = [System.Windows.Media.Brushes]::Black
                [void]$panel.Children.Add($checkBox)
            }
        })
    }

    [string[]] GetSelectedItems([object]$panel) {
        $selected = New-Object System.Collections.Generic.List[string]
        $this.Window.Dispatcher.Invoke({
            foreach ($child in $panel.Children) {
                if ($child -is [System.Windows.Controls.CheckBox] -and $child.IsChecked) {
                    $selected.Add($child.Content.ToString())
                }
            }
        })
        return $selected.ToArray()
    }

    [void] UpdateMetadataDisplay([Metadata]$metadata) {
        $this.Window.Dispatcher.Invoke({
            if ($null -eq $metadata) {
                $this.TxtAppName.Text = ""
                $this.TxtPkgName.Text = ""
                $this.TxtCompany.Text = ""
                $this.TxtProduct.Text = ""
                $this.TxtVersion.Text = ""
            } else {
                $this.TxtCompany.Text = $metadata.Company
                $this.TxtProduct.Text = $metadata.Product
                $this.TxtVersion.Text = $metadata.Version
                $this.TxtAppName.Text = "APP $($metadata.Name)"
                $this.TxtPkgName.Text = "PKG $($metadata.Name)"
            }
        })
    }

    [void] UpdateCommentLabel([CommentInfo]$info) {
        $this.Window.Dispatcher.Invoke({
            $remaining = $info.RemainingCharacters
            $used = $info.PrefixLength + $info.NormalizedCommentLength
            $this.LblComment.Content = "Comment ($remaining left | $used/$($info.MaximumCharacters))"

            # Color and Weight adjustments
            if ($remaining -le 10) {
                $this.LblComment.Foreground = [System.Windows.Media.Brushes]::Red
            }
            elseif ($remaining -le 20) {
                $this.LblComment.Foreground = [System.Windows.Media.Brushes]::Firebrick
            }
            elseif ($remaining -le 30) {
                $this.LblComment.Foreground = [System.Windows.Media.Brushes]::DarkOrange
            }
            elseif ($remaining -le 40) {
                $this.LblComment.Foreground = [System.Windows.Media.Brushes]::DarkGoldenrod
            }
            else {
                $this.LblComment.Foreground = [System.Windows.Media.Brushes]::DimGray
            }

            if ($remaining -le 15) {
                $this.LblComment.FontWeight = "Bold"
            }
            elseif ($remaining -le 25) {
                $this.LblComment.FontWeight = "SemiBold"
            }
            else {
                $this.LblComment.FontWeight = "Normal"
            }
        })
    }

    [void] SetPackagePanelVisibility([bool]$isPkg) {
        $this.Window.Dispatcher.Invoke({
            if ($isPkg) {
                $this.BtnCreate.Content = "CREATE PACKAGE"
                $this.BtnCreate.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0078D4")
                $this.PnlAppName.Visibility = "Collapsed"
                $this.PnlPkgName.Visibility = "Visible"
            } else {
                $this.BtnCreate.Content = "CREATE APPLICATION"
                $this.BtnCreate.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#107C10")
                $this.PnlAppName.Visibility = "Visible"
                $this.PnlPkgName.Visibility = "Collapsed"
            }
        })
    }

    [void] SetCommentText([string]$text, [int]$caretIndex) {
        $this.Window.Dispatcher.Invoke({
            $this.TxtComment.Text = $text
            $this.TxtComment.CaretIndex = [Math]::Min($caretIndex, $text.Length)
        })
    }
}
