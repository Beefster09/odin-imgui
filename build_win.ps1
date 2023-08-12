param([switch]$debug)

$this_dir = Split-Path $script:MyInvocation.MyCommand.Path
Set-Location $this_dir

$sources = Get-ChildItem -Path $this_dir\cimgui\imgui -Filter *.cpp | ForEach-Object FullName
$sources += "cimgui\cimgui.cpp"

if ($debug) {
    cl /c /nologo /DCIMGUI_NO_EXPORT /MTd /Zi /Fd:$this_dir\external\cimgui_debug.pdb $sources
    $lib_dest = "$this_dir\external\cimgui_debug.lib"
} else {
    cl /c /nologo /DCIMGUI_NO_EXPORT /MT /O2 $sources
    $lib_dest = "$this_dir\external\cimgui.lib"
}

$objs = Get-ChildItem -Path $this_dir -Filter *imgui*.obj | ForEach-Object FullName
lib /nologo $objs /out:$lib_dest
Remove-Item $objs

python generator_py\generate.py
