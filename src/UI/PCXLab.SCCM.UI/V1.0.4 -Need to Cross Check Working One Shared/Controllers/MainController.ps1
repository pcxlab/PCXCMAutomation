class MainController {
    [MainWindowView] $View
    [MetadataService] $MetadataService
    [SCCMService] $SCCMService
    [CommentService] $CommentService
    [string] $VersionPath
    [string] $LastLoadedSourcePath

    MainController(
        [MainWindowView]$view, 
        [MetadataService]$metadataService, 
        [SCCMService]$sccmService, 
        [CommentService]$commentService,
        [string]$versionPath
    ) {
        $this.View = $view
        $this.MetadataService = $metadataService
        $this.SCCMService = $sccmService
        $this.CommentService = $commentService
        $this.VersionPath = $versionPath
        $this.LastLoadedSourcePath = ''
    }

    [void] Initialize() {
        $self = $this

        # Register Event Listeners on the View controls
        $this.View.TxtRefNumber.Add_TextChanged({ $self.OnCommentInputChanged() }.GetNewClosure())
        $this.View.TxtReviewer.Add_TextChanged({ $self.OnCommentInputChanged() }.GetNewClosure())
        $this.View.TxtComment.Add_TextChanged({ $self.OnCommentInputChanged() }.GetNewClosure())

        $this.View.RadApp.Add_Checked({ $self.View.SetPackagePanelVisibility($false) }.GetNewClosure())
        $this.View.RadPkg.Add_Checked({ $self.View.SetPackagePanelVisibility($true) }.GetNewClosure())

        $this.View.BtnBrowse.Add_Click({ $self.OnBrowseClick() }.GetNewClosure())
        $this.View.TxtSourcePath.Add_LostFocus({ $self.OnSourcePathLostFocus() }.GetNewClosure())
        $this.View.BtnRefreshDPs.Add_Click({ $self.RefreshDistributionLists($true) }.GetNewClosure())
        
        $this.View.BtnCreate.Add_Click({ $self.OnCreateClick() }.GetNewClosure())

        # Run Initial Refresh
        $this.RefreshDistributionLists($false)
        $this.OnCommentInputChanged()
        
        $isPkg = $this.View.RadPkg.IsChecked
        $this.View.SetPackagePanelVisibility($isPkg)

        [Logger]::Log("System Ready. Please select a package source folder to begin.")
    }

    [void] RefreshDistributionLists([bool]$forceRefresh) {
        [Logger]::Log("Refreshing Distribution Point and Group lists...")
        
        try {
            $groups = $this.SCCMService.GetDistributionPointGroups($forceRefresh)
            $this.View.PopulateDistributionList($this.View.PnlDPGroups, $groups)

            $dps = $this.SCCMService.GetDistributionPoints($forceRefresh)
            $this.View.PopulateDistributionList($this.View.PnlDPs, $dps)

            $cmgs = $this.SCCMService.GetCloudManagementGateways($forceRefresh)
            $this.View.PopulateDistributionList($this.View.PnlCMGs, $cmgs)

            [Logger]::Log("Successfully loaded $($groups.Count) Groups, $($dps.Count) DPs and $($cmgs.Count) CMGs.")
        }
        catch {
            [Logger]::Log("Failed to load distribution lists: $($_.Exception.Message)", "ERROR")
        }
    }

    [void] OnCommentInputChanged() {
        $reviewer = $this.View.TxtReviewer.Text
        $refNumber = $this.View.TxtRefNumber.Text
        $comment = $this.View.TxtComment.Text

        $info = $this.CommentService.GetCommentInfo($reviewer, $refNumber, $comment)
        
        $normalizedComment = $comment.Trim() -replace '\r?\n', ' '
        if ($normalizedComment.Length -gt $info.AllowedCommentLength) {
            $caret = $this.View.TxtComment.CaretIndex
            $trimmed = $this.CommentService.NormalizeAndTrimComment($comment, $info.AllowedCommentLength)
            
            $this.View.SetCommentText($trimmed, $caret)
            
            $info = $this.CommentService.GetCommentInfo($reviewer, $refNumber, $trimmed)
        }

        $this.View.UpdateCommentLabel($info)
    }

    [void] OnSourcePathLostFocus() {
        $currentPath = $this.View.TxtSourcePath.Text.Trim()
        if ($currentPath -ne $this.LastLoadedSourcePath) {
            $this.UpdateMetadata($currentPath)
        }
    }

    [void] OnBrowseClick() {
        try {
            $fileBrowser = New-Object System.Windows.Forms.OpenFileDialog
            $fileBrowser.Title = "Select any file inside the source folder"
            $fileBrowser.Filter = "All Files (*.*)|*.*"
        
            $currentPath = $this.View.TxtSourcePath.Text.Trim()
            if (-not [string]::IsNullOrWhiteSpace($currentPath)) {
                if (Test-Path $currentPath) { 
                    $fileBrowser.InitialDirectory = if (Test-Path $currentPath -PathType Container) { $currentPath } else { Split-Path $currentPath -Parent }
                }
            }

            if ($fileBrowser.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) {
                $folderPath = Split-Path $fileBrowser.FileName -Parent
                $this.View.TxtSourcePath.Text = $folderPath
                $this.UpdateMetadata($folderPath)
            }
        }
        catch {
            [Logger]::Log("Browse failed: $($_.Exception.Message)", "ERROR")
            [System.Windows.MessageBox]::Show("Browse failed: $($_.Exception.Message)", "Error")
        }
    }

    [void] UpdateMetadata([string]$path) {
        if ([string]::IsNullOrWhiteSpace($path)) {
            $this.View.UpdateMetadataDisplay($null)
            $this.LastLoadedSourcePath = ''
            return
        }

        try {
            [Logger]::Log("Validating source folder: $path")
            [Validator]::ValidateSourcePath($path)

            $metadata = $this.MetadataService.ExtractMetadata($path)
            $this.View.UpdateMetadataDisplay($metadata)
            $this.LastLoadedSourcePath = $path
            [Logger]::Log("Successfully identified: $($metadata.Name) (Version: $($metadata.Version))")
        }
        catch {
            $this.View.UpdateMetadataDisplay($null)
            $this.LastLoadedSourcePath = ''
            [Logger]::Log("Path Validation Failed: $($_.Exception.Message)", "ERROR")
        }
    }

    [void] OnCreateClick() {
        $path = $this.View.TxtSourcePath.Text.Trim()
        
        try {
            [Validator]::ValidateSourcePath($path)
        }
        catch {
            [System.Windows.MessageBox]::Show($_.Exception.Message, "Error")
            return
        }

        $selectedGroups = $this.View.GetSelectedItems($this.View.PnlDPGroups)
        $selectedDPs = $this.View.GetSelectedItems($this.View.PnlDPs)
        $selectedCMGs = $this.View.GetSelectedItems($this.View.PnlCMGs)

        $distributionPoints = @(
            $selectedCMGs
            $selectedDPs
        ) | Where-Object { -not [string]::IsNullOrWhiteSpace($_) }

        try {
            [Validator]::ValidateTargets($distributionPoints, $selectedGroups)
        }
        catch {
            [System.Windows.MessageBox]::Show($_.Exception.Message, "Error")
            return
        }

        $isApp = $this.View.RadApp.IsChecked
        $objectName = if ($isApp) { $this.View.TxtAppName.Text } else { $this.View.TxtPkgName.Text }
        
        $metadata = $this.MetadataService.ExtractMetadata($path)

        $request = [DeploymentRequest]::new(
            $path,
            $isApp,
            $objectName,
            $metadata.Company,
            $metadata.Product,
            $metadata.Version,
            $distributionPoints,
            $selectedGroups,
            $this.View.TxtRefNumber.Text,
            $this.View.TxtReviewer.Text,
            $this.View.TxtComment.Text
        )

        # Build Confirm dialog Window View
        $confirmXamlPath = Join-Path $this.VersionPath "Xaml\ConfirmWindow.xaml"
        $confirmView = [ConfirmWindowView]::new($confirmXamlPath, $request, $selectedDPs, $selectedCMGs)
        $confirmed = $confirmView.ShowDialog()

        if (-not $confirmed) {
            return
        }

        # Execute build operation
        [void] $this.View.SetCreateButtonState($false)
        [void] $this.View.SetWaitCursor($true)

        $typeLabel = if ($isApp) { "APPLICATION" } else { "PACKAGE" }
        [Logger]::Log(">>> STARTING $typeLabel CREATION: $objectName", "ACTION")

        try {
            if ($isApp) {
                $this.SCCMService.CreateApplication($request)
            } else {
                $this.SCCMService.CreatePackage($request)
            }

            [Logger]::Log("SUCCESS: $typeLabel created and distributed.", "SUCCESS")
            [System.Windows.MessageBox]::Show("$typeLabel created successfully.", "Success")
        }
        catch {
            [Logger]::Log("FAILED: $($_.Exception.Message)", "ERROR")
            [System.Windows.MessageBox]::Show("Creation failed: $($_.Exception.Message)", "Error")
        }
        finally {
            [void] $this.View.SetCreateButtonState($true)
            [void] $this.View.SetWaitCursor($false)
        }
    }
}
