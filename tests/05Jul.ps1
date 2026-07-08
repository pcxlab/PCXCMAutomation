Import-Module .\src\Modules\PCXLab.SCCM

new-pcxcmcomment -reviewer "David" -requestnumber "INC123456" -comment "Google Chrome package"  

$comment = new-pcxcmcomment -reviewer "David" -requestnumber "INC123456" -comment "Google Chrome package"  

$comment


