﻿#Requires -Version 7.0

# Description: This file copies plots from the plotter to the NAS
$Config=Import-PowershellDataFile -Path .\config.psd1 -ErrorAction Stop
$IntermediatePath = $Config.IntermediatePath
$HoldingPaths = $Config.HoldingPaths

$PlotFilesToMove = Get-ChildItem -Path $HoldingPaths -Filter '*.plot' -ErrorAction Ignore
# TODO only permit a single instance of this script to run
echo $PlotFilesToMove
$FileIndex = 0

echo "Found $($PlotFilesToMove.Count) plot files that need to be migrated."
foreach ($PlotFile in $PlotFilesToMove)
{
    $FileIndex = $FileIndex + 1
    if (Test-Path -Path (Join-Path $IntermediatePath $PlotFile.Name) -PathType Leaf)
    {
        $msg = 'Skipping file (' + $FileIndex + ' of ' + $PlotFilesToMove.Count + ') - "' + $PlotFile.Name + '" already exists on "' + $IntermediatePath + '"' 
        echo $msg
        continue
    }

    echo ('Migrating plot (' + $FileIndex + ' of ' + $PlotFilesToMove.Count + ') "' + $PlotFile.Name + '" to "' + $IntermediatePath + '"')
    try
    {
        Start-BitsTransfer -Source $PlotFile -Destination $IntermediatePath -DisplayName 'Migrate plots to NAS' -Description ('Migrating plot (' + $FileIndex + ' of ' + $PlotFilesToMove.Count + ') "' + $PlotFile.Name + '" to "' + $IntermediatePath + '"') -ErrorAction Stop
        Remove-Item $PlotFile
    }

    catch
    {
        echo "Transfer process was interrupted or failed due to network error"
        exit
    }
}
