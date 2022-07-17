param(
    [switch] $Force,
    [string] $Version
)

$ChoiceDescriptionType = "System.Management.Automation.Host.ChoiceDescription"

function New-ChoiceDescriptionCollection {
    $typename = "System.Management.Automation.Host.ChoiceDescription"
    $dummy = New-Object $typename("dummy","dummy")
    $assembly= $dummy.getType().AssemblyQualifiedName
    New-Object "System.Collections.ObjectModel.Collection``1[[$assembly]]"
}

function New-ChoiceDescriptions {
    param (
        [parameter(Mandatory)]
        [array] $Labels
    )

    $choices = New-ChoiceDescriptionCollection
    for ($i=0; $i -lt $Labels.Count; $i++) {
        $label = $Labels[$i]
        $choices.add((New-Object $ChoiceDescriptionType("$label(&$($i))", $label)))
    }

    $choices
}

function Get-ModuleName {
    param (
        [Parameter(Mandatory)]
        [string] $ModuleConfig
    )
    
    $firstRow = Get-Content $ModuleConfig | Select-Object -First 1
    $firstRow.Substring(6, $firstRow.Length - 6)
}

# タグに日本語が混じった場合、今ソースのEncodingをUTF8にしておかないと文字化けする
# そのため、最所に元のEncodingを取得しておき、UTF8に変更した後、最後に元に戻す
$enc = [Console]::OutputEncoding
try
{
    [Console]::OutputEncoding = [Text.Encoding]::UTF8

    # # Forceオプションが指定されなかった場合、カレントブランチがdevelopブランチかどうか確認する
    # if ($Force -eq $false) {
    #     if (((git branch --contains).Substring(2)) -ne 'develop') {
    #         Write-Host 'developブランチに切り替えてください。'
    #         exit
    #     }
    # }

    # モジュール種別の選択
    $choices = New-ChoiceDescriptions (Get-ChildItem .\.github\workflows\config\ | Select-Object -ExpandProperty Name)
    $answer = $host.ui.PromptForChoice("[モジュール種別選択]", "リリース対象のモジュール種別を選択してください。", $choices, 0)
    $moduleType = $choices[$answer].HelpMessage
    
    # モジュールの選択
    $choices = New-ChoiceDescriptions (Get-ChildItem .\.github\workflows\config\$moduleType\ | ForEach-Object { Get-ModuleName $_ })
    $answer = $host.ui.PromptForChoice("[モジュール選択]", "リリース対象のモジュールを選択してください。", $choices, 0)
    $module = $choices[$answer].HelpMessage

    # リリースタグのプレフィックス
    $tagPrefix = "release/$moduleType/$module/"

    # タグを最新まで更新する
    git pull

    if($Version -eq '') {
        # バージョンが明示的に指定されていなかった場合、タグから最新バージョンを生成する。
        $tag = git tag --sort=taggerdate | Where-Object { $_.StartsWith($tagPrefix) } | Select-Object -Last 1
        if($null -eq $tag){
            $Version = Read-Host "過去にリリースが未実施です。Versionパラメーターを指定してください。"
        }
        else {
            # タグからバージョンを取得し、パッチをインクリメントする
            $previous = $tag.Substring($tag.LastIndexOf('/') + 1)
            $previousPatch = [int] $previous.Substring($previous.LastIndexOf('.') + 1)
            $Version = $previous.Substring(0, $previous.LastIndexOf('.') + 1) + ($previousPatch + 1)
        }
    }
    else {
        # バージョンが明示的に指定されていた場合、指定のバージョンが存在しないか確認する
        $tag = git tag | Where-Object { $_ -eq "$tagPrefix$Version" }
        if(($null -ne $tag) -and ($tag -ne '')) {
            Write-Host "指定のバージョンはリリース済みです。"
            exit
        }
    }

    $comment = Read-Host "リリースコメントを入力してください。"

    $confirm = New-ChoiceDescriptionCollection
    $confirm.add((New-Object $ChoiceDescriptionType("いいえ(&N)","リリースを中断します。")))
    $confirm.add((New-Object $ChoiceDescriptionType("はい(&Y)","リリースします。")))
    $answer = $host.ui.PromptForChoice("[下記でリリースします。よろしいですか？]", " - モジュール： $module`r`n - バージョン: $Version`r`n - コメント: $comment", $confirm, 0)
    if($answer -eq 1) {
        git tag -a "$tagPrefix$Version" -m $comment
        git push --tags
        Write-Host "リリース要求をPipelineへ送信しました。"
    }
    else {
        Write-Host "リリースを中断しました。"
    }


}
finally
{
    [Console]::OutputEncoding = $enc
}
