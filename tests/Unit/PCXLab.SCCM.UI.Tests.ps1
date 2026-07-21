$AppPath = Resolve-Path "$PSScriptRoot\..\..\UI\PCXLab.SCCM.UI\1.0.2"

# Dot-source the clean architecture classes
. (Join-Path $AppPath "Logging\Logger.ps1")
. (Join-Path $AppPath "Configuration\Settings.ps1")
. (Join-Path $AppPath "Infrastructure\ModuleLoader.ps1")
. (Join-Path $AppPath "Models\DeploymentModels.ps1")
. (Join-Path $AppPath "Validation\Validator.ps1")
. (Join-Path $AppPath "Services\MetadataService.ps1")
. (Join-Path $AppPath "Services\CommentService.ps1")
. (Join-Path $AppPath "Services\SCCMService.ps1")

Describe "PCXLab.SCCM.UI Validation and Services Tests" {

    Context "Validator Tests" {
        It "Should throw error if source path is empty" {
            { [Validator]::ValidateSourcePath("") } | Should Throw
            { [Validator]::ValidateSourcePath($null) } | Should Throw
        }

        It "Should throw error if source path does not exist" {
            $NonExistingPath = "C:\NonExistingCompany\NonExistingProduct\NonExistingPackage"
            { [Validator]::ValidateSourcePath($NonExistingPath) } | Should Throw
        }

        It "Should throw error if path structure is invalid (less than 3 parts)" {
            # C:\Windows exists on Windows and has 2 parts (C: and Windows)
            $ShortPath = "C:\Windows"
            if (Test-Path $ShortPath) {
                { [Validator]::ValidateSourcePath($ShortPath) } | Should Throw
            }
        }

        It "Should throw error if package folder is empty" {
            $TempCompanyDir = Join-Path $PSScriptRoot "TempCompany"
            $TempProductDir = Join-Path $TempCompanyDir "TempProduct"
            $TempPackageDir = Join-Path $TempProductDir "TempPackage"
            [void](New-Item -ItemType Directory -Path $TempPackageDir -Force)

            { [Validator]::ValidateSourcePath($TempPackageDir) } | Should Throw

            Remove-Item $TempCompanyDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Should throw error if package folder has no installer files" {
            $TempCompanyDir = Join-Path $PSScriptRoot "TempCompany"
            $TempProductDir = Join-Path $TempCompanyDir "TempProduct"
            $TempPackageDir = Join-Path $TempProductDir "TempPackage"
            [void](New-Item -ItemType Directory -Path $TempPackageDir -Force)
            [void](New-Item -ItemType File -Path (Join-Path $TempPackageDir "document.txt") -Force)

            { [Validator]::ValidateSourcePath($TempPackageDir) } | Should Throw

            Remove-Item $TempCompanyDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Should succeed if package folder has installer file" {
            $TempCompanyDir = Join-Path $PSScriptRoot "TempCompany"
            $TempProductDir = Join-Path $TempCompanyDir "TempProduct"
            $TempPackageDir = Join-Path $TempProductDir "TempPackage"
            [void](New-Item -ItemType Directory -Path $TempPackageDir -Force)
            [void](New-Item -ItemType File -Path (Join-Path $TempPackageDir "installer.msi") -Force)

            { [Validator]::ValidateSourcePath($TempPackageDir) } | Should Not Throw

            Remove-Item $TempCompanyDir -Recurse -Force -ErrorAction SilentlyContinue
        }

        It "Should throw error if targets are empty" {
            { [Validator]::ValidateTargets(@(), @()) } | Should Throw
        }
    }

    Context "MetadataService Tests" {
        $MetadataService = [MetadataService]::new()

        It "Should extract Metadata correctly from clean paths using fallback parsing" {
            $Path = "C:\Projects\PCXLABCMAutomation\Input\Google\Chrome\Chrome_120.0.6099.109"
            $Meta = $MetadataService.FallbackExtractMetadata($Path)

            $Meta.Company | Should Be "Google"
            $Meta.Product | Should Be "Chrome"
            $Meta.Version | Should Be "120.0.6099.109"
            $Meta.Name    | Should Be "Google Chrome 120.0.6099.109"
        }

        It "Should default version to 1.0 if not found in path folder" {
            $Path = "C:\Projects\PCXLABCMAutomation\Input\Adobe\Reader\ReaderNoVersion"
            $Meta = $MetadataService.FallbackExtractMetadata($Path)

            $Meta.Version | Should Be "1.0"
        }
    }

    Context "CommentService Tests" {
        $CommentService = [CommentService]::new()

        It "Should return correct CommentInfo using fallback calculation" {
            $Info = $CommentService.GetCommentInfo("John Doe", "REF-123", "Initial Package release")

            $Info.PrefixLength | Should Be 36  # "Reviewer: John Doe | Req: REF-123 | " is 36 chars
            $Info.NormalizedCommentLength | Should Be 23
            $Info.MaximumCharacters | Should Be 127
            $Info.RemainingCharacters | Should Be (127 - 36 - 23)
        }

        It "Should normalize newlines and trim comment correctly if too long" {
            $Comment = "First line`r`nSecond line"
            $Trimmed = $CommentService.NormalizeAndTrimComment($Comment, 15)
            $Trimmed | Should Be "First line Seco"
        }
    }

    Context "ModuleLoader Tests" {
        It "Should resolve and import the module successfully" {
            { [ModuleLoader]::InitializeUI($AppPath) } | Should Not Throw
        }
    }
}
