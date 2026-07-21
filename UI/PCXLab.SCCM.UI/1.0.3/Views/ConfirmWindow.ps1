class ConfirmWindowView {
    [object] $Window
    [object] $BtnBack
    [object] $BtnProceed
    [bool] $Confirmed

    ConfirmWindowView([string]$xamlPath, [DeploymentRequest]$request, [string[]]$selectedDPs, [string[]]$selectedCMGs) {
        [xml]$cXaml = Get-Content $xamlPath
        $cReader = New-Object System.Xml.XmlNodeReader $cXaml
        $this.Window = [Windows.Markup.XamlReader]::Load($cReader)

        # Map Controls
        $cTxtSource = $this.Window.FindName("txtConfSource")
        $cTxtType = $this.Window.FindName("txtConfType")
        $cTxtName = $this.Window.FindName("txtConfName")
        $cTxtCompany = $this.Window.FindName("txtConfCompany")
        $cTxtProduct = $this.Window.FindName("txtConfProduct")
        $cTxtVersion = $this.Window.FindName("txtConfVersion")
        $cTxtGroups = $this.Window.FindName("txtConfGroups")
        $cTxtDPs = $this.Window.FindName("txtConfDPs")
        $cTxtCMGs = $this.Window.FindName("txtConfCMGs")
        $cTxtRef = $this.Window.FindName("txtConfRef")
        $cTxtReviewer = $this.Window.FindName("txtConfReviewer")
        $cTxtComment = $this.Window.FindName("txtConfComment")
        $this.BtnBack = $this.Window.FindName("btnConfBack")
        $this.BtnProceed = $this.Window.FindName("btnConfProceed")

        # Populate Data
        $cTxtSource.Text = $request.Path
        $cTxtType.Text = if ($request.IsApplication) { "Application" } else { "Package" }
        $cTxtName.Text = $request.Name
        $cTxtCompany.Text = $request.Company
        $cTxtProduct.Text = $request.Product
        $cTxtVersion.Text = $request.Version
        $cTxtGroups.Text = if ($request.DistributionPointGroups.Count -gt 0) { $request.DistributionPointGroups -join ", " } else { "None" }
        $cTxtDPs.Text = if ($selectedDPs.Count -gt 0) { $selectedDPs -join ", " } else { "None" }
        $cTxtCMGs.Text = if ($selectedCMGs.Count -gt 0) { $selectedCMGs -join ", " } else { "None" }
        $cTxtRef.Text = $request.ReferenceNumber
        $cTxtReviewer.Text = $request.ReviewerName
        $cTxtComment.Text = $request.Comment

        # Style Button
        if ($request.IsApplication) {
            $this.BtnProceed.Content = "CREATE APPLICATION"
            $this.BtnProceed.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#107C10")
        } else {
            $this.BtnProceed.Content = "CREATE PACKAGE"
            $this.BtnProceed.Background = [System.Windows.Media.BrushConverter]::new().ConvertFromString("#0078D4")
        }
    }

    [bool] ShowDialog() {
        $this.Confirmed = $false
        
        $self = $this
        
        $this.BtnBack.Add_Click({
            $self.Confirmed = $false
            $self.Window.Close()
        }.GetNewClosure())

        $this.BtnProceed.Add_Click({
            $self.Confirmed = $true
            $self.Window.Close()
        }.GetNewClosure())

        $this.Window.ShowDialog() | Out-Null
        return $this.Confirmed
    }
}
