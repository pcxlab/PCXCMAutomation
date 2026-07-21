class CommentService {
    [CommentInfo] GetCommentInfo([string]$reviewer, [string]$refNumber, [string]$comment) {
        if (Get-Command Get-PCXCMDescriptionInformation -ErrorAction SilentlyContinue) {
            $info = Get-PCXCMDescriptionInformation -Reviewer $reviewer -RequestNumber $refNumber -Comment $comment
            return [CommentInfo]::new($info)
        }
        
        # Basic Fallback if module function isn't present
        $prefix = "Reviewer: $reviewer | Req: $refNumber | "
        $maxChars = 127
        $prefixLen = $prefix.Length
        $allowedCommentLen = $maxChars - $prefixLen
        $normalizedComment = $comment.Trim() -replace '\r?\n', ' '
        $normLen = $normalizedComment.Length
        $descLen = $prefixLen + $normLen
        $remaining = [Math]::Max(0, $maxChars - $descLen)
        
        $info = @{
            PrefixLength = $prefixLen
            NormalizedCommentLength = $normLen
            DescriptionLength = $descLen
            MaximumCharacters = $maxChars
            AllowedCommentLength = $allowedCommentLen
            RemainingCharacters = $remaining
        }
        return [CommentInfo]::new($info)
    }

    [string] NormalizeAndTrimComment([string]$comment, [int]$allowedLength) {
        $normalized = $comment.Trim() -replace '\r?\n', ' '
        if ($normalized.Length -gt $allowedLength) {
            return $normalized.Substring(0, $allowedLength)
        }
        return $comment
    }
}
