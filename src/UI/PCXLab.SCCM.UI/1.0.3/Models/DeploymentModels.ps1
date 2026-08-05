class Metadata {
    [string] $Name
    [string] $Company
    [string] $Product
    [string] $Version

    Metadata([string]$name, [string]$company, [string]$product, [string]$version) {
        $this.Name = $name
        $this.Company = $company
        $this.Product = $product
        $this.Version = $version
    }
}

class DeploymentRequest {
    [string] $Path
    [bool] $IsApplication
    [string] $Name
    [string] $Company
    [string] $Product
    [string] $Version
    [string[]] $DistributionPoints
    [string[]] $DistributionPointGroups
    [string] $ReferenceNumber
    [string] $ReviewerName
    [string] $Comment

    DeploymentRequest(
        [string]$path,
        [bool]$isApplication,
        [string]$name,
        [string]$company,
        [string]$product,
        [string]$version,
        [string[]]$dps,
        [string[]]$dpGroups,
        [string]$refNum,
        [string]$reviewer,
        [string]$comment
    ) {
        $this.Path = $path
        $this.IsApplication = $isApplication
        $this.Name = $name
        $this.Company = $company
        $this.Product = $product
        $this.Version = $version
        $this.DistributionPoints = $dps
        $this.DistributionPointGroups = $dpGroups
        $this.ReferenceNumber = $refNum
        $this.ReviewerName = $reviewer
        $this.Comment = $comment
    }
}

class CommentInfo {
    [int] $PrefixLength
    [int] $NormalizedCommentLength
    [int] $DescriptionLength
    [int] $MaximumCharacters
    [int] $AllowedCommentLength
    [int] $RemainingCharacters

    CommentInfo([object]$info) {
        $this.PrefixLength = $info.PrefixLength
        $this.NormalizedCommentLength = $info.NormalizedCommentLength
        $this.DescriptionLength = $info.DescriptionLength
        $this.MaximumCharacters = $info.MaximumCharacters
        $this.AllowedCommentLength = $info.AllowedCommentLength
        $this.RemainingCharacters = $info.RemainingCharacters
    }
}
